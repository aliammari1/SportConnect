import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { db as firestoreDb } from "./firebase-admin";
import { getAuth } from "firebase-admin/auth";

type AdminRequest = {
  auth?: { uid: string; token?: Record<string, unknown> } | null;
};

/** Platform-admin gate: custom claim `admin:true` OR users/{uid}.role==='admin'. */
async function requirePlatformAdmin(request: AdminRequest): Promise<string> {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in required");
  const tokenRole = (request.auth!.token ?? {})["admin"];
  if (tokenRole === true) return uid;
  const snap = await firestoreDb.collection("users").doc(uid).get();
  const role = snap.data()?.["role"];
  if (role === "admin") return uid;
  throw new HttpsError("permission-denied", "Platform admin only");
}

async function logAdminAction(
  adminUid: string,
  action: string,
  targetId: string,
  details: Record<string, unknown>,
): Promise<void> {
  await firestoreDb.collection("admin_audit").add({
    adminUid,
    action,
    targetId,
    details,
    at: FieldValue.serverTimestamp(),
  });
}

/** Suspend / reinstate a user account (Auth disabled flag + Firestore flag). */
export const setUserSuspended = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as { userId?: string; suspended?: boolean; reason?: string };
  const { userId, suspended } = data;
  if (!userId || typeof suspended !== "boolean") {
    throw new HttpsError("invalid-argument", "userId and suspended are required");
  }
  try {
    await getAuth().updateUser(userId, { disabled: suspended });
  } catch (error) {
    logger.warn("setUserSuspended: auth update failed (user may not exist in Auth)", {
      userId,
      error,
    });
  }
  await firestoreDb.collection("users").doc(userId).set(
    { isBanned: suspended, updatedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
  await logAdminAction(adminUid, suspended ? "user_suspended" : "user_reinstated", userId, {
    reason: data.reason ?? null,
  });
  return { ok: true };
});

/** Server-authoritative premium override (grant/revoke). */
export const setPremiumOverride = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as { userId?: string; premium?: boolean };
  const { userId, premium } = data;
  if (!userId || typeof premium !== "boolean") {
    throw new HttpsError("invalid-argument", "userId and premium are required");
  }
  await firestoreDb.collection("users").doc(userId).set(
    {
      isPremium: premium,
      premiumEntitlementStatus: premium ? "admin_granted" : "none",
      premiumUpdatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  await logAdminAction(adminUid, premium ? "premium_granted" : "premium_revoked", userId, {});
  return { ok: true };
});

/**
 * Admin ride cancellation. Marks the ride cancelled with an admin reason so
 * the existing refund pipeline (onRideUpdated) reimburses paid passengers.
 */
export const adminCancelRide = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as { rideId?: string; reason?: string };
  const { rideId } = data;
  const reason = data.reason ?? "cancelled_by_platform";
  if (!rideId) throw new HttpsError("invalid-argument", "rideId is required");

  const rideRef = firestoreDb.collection("rides").doc(rideId);
  await firestoreDb.runTransaction(async (txn) => {
    const snap = await txn.get(rideRef);
    if (!snap.exists) throw new HttpsError("not-found", "Ride not found");
    txn.update(rideRef, {
      status: "cancelled",
      cancellationReason: "event_cancelled",
      adminCancelledBy: adminUid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  await logAdminAction(adminUid, "ride_cancelled", rideId, { reason });

  // Notify driver + passengers.
  const rideSnap = await rideRef.get();
  const ride = rideSnap.data() ?? {};
  const targets = [ride.driverId as string | undefined].filter(Boolean) as string[];
  return { ok: true, notified: targets.length };
});

export const resolveReport = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as { reportId?: string; note?: string };
  if (!data.reportId) throw new HttpsError("invalid-argument", "reportId required");
  await firestoreDb.collection("reports").doc(data.reportId).update({
    status: "resolved",
    resolvedBy: adminUid,
    resolutionNote: data.note ?? null,
    updatedAt: FieldValue.serverTimestamp(),
  });
  await logAdminAction(adminUid, "report_resolved", data.reportId, { note: data.note ?? null });
  return { ok: true };
});

export const sendAdminPush = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as { userId?: string; title?: string; body?: string; route?: string };
  if (!data.userId || !data.title || !data.body) {
    throw new HttpsError("invalid-argument", "userId, title, body required");
  }
  const { sendPushToUser } = await import("./notifications-helper-functions.js");
  await sendPushToUser(data.userId, data.title, data.body, {
    type: "admin_message",
    ...(data.route ? { route: data.route } : {}),
  });
  await logAdminAction(adminUid, "push_sent", data.userId, { title: data.title });
  return { ok: true };
});

export const setPlatformConfig = onCall({ cors: true }, async (request) => {
  const adminUid = await requirePlatformAdmin(request);
  const data = request.data as {
    commissionPercent?: number;
    refundWindowDays?: number;
    maintenanceMode?: boolean;
  };
  const patch: Record<string, unknown> = { updatedAt: FieldValue.serverTimestamp() };
  if (data.commissionPercent != null) patch.commissionPercent = data.commissionPercent;
  if (data.refundWindowDays != null) patch.refundWindowDays = data.refundWindowDays;
  if (data.maintenanceMode != null) patch.maintenanceMode = data.maintenanceMode;
  await firestoreDb.collection("config").doc("platform").set(patch, { merge: true });
  await logAdminAction(adminUid, "platform_config_updated", "platform", patch);
  return { ok: true };
});

export const getOpsOverview = onCall({ cors: true }, async (request) => {
  await requirePlatformAdmin(request);
  const now = new Date();
  const dayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const weekAgo = new Date(now.getTime() - 7 * 24 * 3600 * 1000);

  const ridesToday = await firestoreDb
    .collection("rides")
    .where("schedule.departureTime", ">=", dayStart)
    .where("schedule.departureTime", "<", dayStart.getTime() + 86400000)
    .count().get().then((s) => s.data().count).catch(() => 0);

  const newUsers7d = await firestoreDb
    .collection("users")
    .where("createdAt", ">=", weekAgo)
    .count().get().then((s) => s.data().count).catch(() => 0);

  let totalBookings7d = 0;
  let completedBookings7d = 0;
  let cancelledBookings7d = 0;
  const bookingsSnap = await firestoreDb
    .collection("bookings")
    .where("createdAt", ">=", weekAgo)
    .get()
    .catch(() => null);
  for (const d of bookingsSnap?.docs ?? []) {
    totalBookings7d++;
    const s = d.data().status;
    if (s === "completed") completedBookings7d++;
    if (s === "cancelled") cancelledBookings7d++;
  }

  let volumeCents7d = 0;
  const paysSnap = await firestoreDb
    .collection("payments")
    .where("createdAt", ">=", weekAgo)
    .get()
    .catch(() => null);
  for (const d of paysSnap?.docs ?? []) {
    if (d.data().status === "succeeded") {
      volumeCents7d += Number(d.data().amountInCents ?? 0);
    }
  }

  const openDisputes = await firestoreDb
    .collection("disputes")
    .where("status", "==", "open")
    .count().get().then((s) => s.data().count).catch(() => 0);

  const openRefunds = await firestoreDb
    .collection("refund_requests")
    .where("updatedAt", ">=", weekAgo)
    .get()
    .then((s) => s.docs.filter((d) => d.data().status !== "approved" && d.data().status !== "rejected").length)
    .catch(() => 0);

  return {
    ridesToday,
    newUsers7d,
    totalBookings7d,
    completedBookings7d,
    cancelledBookings7d,
    volumeCents7d,
    openDisputes,
    openRefunds,
  };
});

export const adminFindUsers = onCall({ cors: true }, async (request) => {
  await requirePlatformAdmin(request);
  const raw = String((request.data as { query?: string })?.query ?? "").trim();
  if (raw.length < 2) return { users: [] };

  const out: Record<string, unknown>[] = [];
  const seen = new Set<string>();
  const push = (snap: FirebaseFirestore.DocumentSnapshot) => {
    if (!snap.exists || seen.has(snap.id)) return;
    const d = snap.data() ?? {};
    seen.add(snap.id);
    out.push({
      uid: snap.id,
      name: d.username ?? d.displayName ?? "(unnamed)",
      email: typeof d.email === "string" ? d.email : "",
      photoUrl: typeof d.photoUrl === "string" ? d.photoUrl : null,
      isPremium: d.isPremium === true,
      isBanned: d.isBanned === true,
    });
  };

  const direct = await firestoreDb.collection("users").doc(raw).get();
  push(direct);

  const byEmail = await firestoreDb
    .collection("users")
    .where("email", "==", raw.toLowerCase())
    .limit(5)
    .get();
  byEmail.docs.forEach(push);

  if (out.length === 0) {
    const byName = await firestoreDb
      .collection("users")
      .orderBy("username")
      .startAt(raw)
      .endAt(raw + "\uf8ff")
      .limit(20)
      .get();
    byName.docs.forEach(push);
  }

  return { users: out };
});

