import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { db as firestoreDb } from "./firebase-admin";

/**
 * One-shot migration to the v2 chat schema:
 *
 *   chats/{id}.members{uid: {role, joinedAt, lastReadAt}}  (from participantIds + participants[])
 *   chats/{id}.createdBy                                    (from participants[].isAdmin ?? first id)
 *   hiddenBy / clearedAt / mutedUntil                       (renamed from deletedAtBy/clearedAtBy/mutedBy)
 *   legacy fields removed: unreadCounts, deletedAtBy, clearedAtBy, mutedBy
 *   messages/{id}.deletedAt = null                          (legacy docs lack the field; queries
 *                                                            filter deletedAt == null)
 *   messages/{id}.{readBy,deliveredTo,status} removed        (receipts now derived from cursors)
 *
 * Idempotent per chat: docs that already carry `members` are skipped unless
 * {force:true}. Admin-only.
 */
export const backfillChatMembersV2 = onCall(
  { cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    const token = request.auth.token as Record<string, unknown>;
    if (token.admin !== true) {
      throw new HttpsError("permission-denied", "Admin only");
    }

    const force = (request.data as { force?: boolean })?.force === true;
    const db = firestoreDb;
    const chats = await db.collection("chats").get();

    let migrated = 0;
    let skipped = 0;
    let messagesTouched = 0;

    for (const chatDoc of chats.docs) {
      const data = chatDoc.data();
      if (!force && data.members != null) {
        skipped++;
        continue;
      }

      const participantIds = (data.participantIds as string[] | undefined) ??
        (data.participants as { uid?: string }[] | undefined)?.map(
          (p) => p.uid ?? "",
        ).filter(Boolean) ??
        [];

      const legacyParticipants =
        (data.participants as
          | { uid?: string; username?: string; photoUrl?: string; isAdmin?: boolean }[]
          | undefined) ?? [];

      const members: Record<
        string,
        { userId: string; role: string; joinedAt: unknown; lastReadAt: null }
      > = {};
      for (const uid of participantIds) {
        const legacy = legacyParticipants.find((p) => p.uid === uid);
        members[uid] = {
          userId: uid,
          role: legacy?.isAdmin === true ? "admin" : "member",
          joinedAt: FieldValue.serverTimestamp(),
          lastReadAt: null,
        };
      }

      const firstAdmin =
        legacyParticipants.find((p) => p.isAdmin === true)?.uid ?? null;

      const mutedLegacy = (data.mutedBy as Record<string, boolean> | undefined) ?? {};
      const mutedUntil: Record<string, unknown> = {};
      for (const [uid, muted] of Object.entries(mutedLegacy)) {
        if (muted) mutedUntil[uid] = FieldValue.serverTimestamp();
      }

      await chatDoc.ref.update({
        members,
        createdBy: (data.createdBy as string | undefined) ?? firstAdmin ?? participantIds[0] ?? null,
        ...(Object.keys(mutedUntil).length > 0 ? { mutedUntil } : {}),
        hiddenBy: data.deletedAtBy ?? {},
        clearedAt: data.clearedAtBy ?? {},
        unreadCounts: FieldValue.delete(),
        deletedAtBy: FieldValue.delete(),
        clearedAtBy: FieldValue.delete(),
        mutedBy: FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      migrated++;

      // Stamp legacy messages with an explicit deletedAt=null so
      // `where('deletedAt','==',null)` matches them.
      const msgs = await chatDoc.ref.collection("messages").get();
      for (const chunk of chunked(msgs.docs, 300)) {
        const batch = db.batch();
        for (const msg of chunk) {
          const md = msg.data();
          if (md.deletedAt !== undefined && !md.readBy && !md.deliveredTo) continue;
          batch.update(msg.ref, {
            ...(md.deletedAt === undefined ? { deletedAt: null } : {}),
            readBy: FieldValue.delete(),
            deliveredTo: FieldValue.delete(),
            status: FieldValue.delete(),
          });
          messagesTouched++;
        }
        await batch.commit();
      }
    }

    logger.info("backfillChatMembersV2 done", { migrated, skipped, messagesTouched });
    return { migrated, skipped, messagesTouched };
  },
);

function chunked<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) out.push(items.slice(i, i + size));
  return out;
}
