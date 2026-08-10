import { FieldValue } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

export async function checkRateLimit(
  db: FirebaseFirestore.Firestore,
  uid: string,
  action: string,
  maxCalls: number,
  windowSeconds: number,
): Promise<void> {
  const windowMs = windowSeconds * 1000;
  const ref = db.collection("_rateLimits").doc(`${uid}:${action}`);

  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    const data = doc.data();
    const windowStart = (data?.windowStart as number | undefined) ?? 0;
    const count = (data?.count as number | undefined) ?? 0;
    const now = Date.now();

    if (now - windowStart < windowMs && count >= maxCalls) {
      const resetIn = Math.ceil((windowStart + windowMs - now) / 1000);
      throw new HttpsError(
        "resource-exhausted",
        `Too many requests. Try again in ${resetIn}s.`,
      );
    }

    if (now - windowStart >= windowMs) {
      tx.set(ref, { windowStart: now, count: 1 });
    } else {
      tx.update(ref, { count: FieldValue.increment(1) });
    }
  });
}
