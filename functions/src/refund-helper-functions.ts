import {
  FieldValue,
  Firestore,
  QueryDocumentSnapshot,
  Timestamp,
} from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { asRecord, finiteNumber } from "./stripe-helper-functions";
import { StripeClient, StripeRefund, StripeRefundCreateParams } from "./types";

function stringOrEmpty(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function paymentAmountInCents(data: Record<string, unknown>): number {
  return (
    finiteNumber(data.amountInCents) ??
    Math.round((finiteNumber(data.amount) ?? 0) * 100)
  );
}

export function refundedAmountInCents(data: Record<string, unknown>): number {
  const status = stringOrEmpty(data.status);
  const stripeRefundStatus = stringOrEmpty(data.stripeRefundStatus);
  if (
    status !== "refunded" &&
    status !== "partiallyRefunded" &&
    stripeRefundStatus !== "succeeded"
  ) {
    return 0;
  }
  return Math.max(0, Math.round(finiteNumber(data.refundAmountInCents) ?? 0));
}

function timestampToMillis(value: unknown): number | null {
  if (value instanceof Timestamp) return value.toMillis();
  if (value instanceof Date) return value.getTime();
  const record = asRecord(value);
  const seconds = finiteNumber(record?.seconds);
  if (seconds !== undefined) return seconds * 1000;
  return null;
}

function getNestedRecord(
  value: Record<string, unknown> | undefined,
  key: string,
): Record<string, unknown> | undefined {
  return asRecord(value?.[key]);
}

function getDepartureMillis(
  ride: Record<string, unknown> | undefined,
): number | null {
  const schedule = getNestedRecord(ride, "schedule");
  return timestampToMillis(schedule?.departureTime ?? ride?.departureTime);
}

export function isRefundOperator(auth: unknown): boolean {
  const authRecord = asRecord(auth);
  const token = asRecord(authRecord?.token);
  return (
    token?.admin === true ||
    token?.support === true ||
    token?.refunds === true ||
    token?.role === "admin" ||
    token?.role === "support"
  );
}

export function isWithinRefundRequestWindow(createdAt: unknown): boolean {
  const millis = timestampToMillis(createdAt);
  if (millis === null) return true;
  const maxAgeMs = 30 * 24 * 60 * 60 * 1000;
  return Date.now() - millis <= maxAgeMs;
}

export async function findPaymentDocsByPaymentIntent(
  db: Firestore,
  paymentIntentId: string,
): Promise<QueryDocumentSnapshot[]> {
  const [byPaymentIntent, byStripePaymentIntent] = await Promise.all([
    db
      .collection("payments")
      .where("paymentIntentId", "==", paymentIntentId)
      .get(),
    db
      .collection("payments")
      .where("stripePaymentIntentId", "==", paymentIntentId)
      .get(),
  ]);

  const unique = new Map<string, QueryDocumentSnapshot>();
  for (const doc of byPaymentIntent.docs) unique.set(doc.id, doc);
  for (const doc of byStripePaymentIntent.docs) unique.set(doc.id, doc);
  return [...unique.values()];
}

export async function findPaymentDocsForRefundRequest(
  db: Firestore,
  data: Record<string, unknown>,
): Promise<QueryDocumentSnapshot[]> {
  const paymentId = stringOrEmpty(data.paymentId);
  if (paymentId.length > 0) {
    const doc = await db.collection("payments").doc(paymentId).get();
    if (doc.exists) return [doc as QueryDocumentSnapshot];
  }

  const paymentIntentId = stringOrEmpty(data.paymentIntentId);
  if (paymentIntentId.length === 0) return [];
  return findPaymentDocsByPaymentIntent(db, paymentIntentId);
}

export function isRideObjectivelyRefundable({
  reason,
  ride,
  booking,
}: {
  reason: string;
  ride: Record<string, unknown> | undefined;
  booking: Record<string, unknown> | undefined;
}): { eligible: boolean; reason: string } {
  const rideStatus = stringOrEmpty(ride?.status);
  const bookingStatus = stringOrEmpty(booking?.status);
  const cancellationReason = stringOrEmpty(ride?.cancellationReason);
  const departureMillis = getDepartureMillis(ride);
  const now = Date.now();

  if (reason === "cancelledByDriver") {
    if (
      rideStatus === "cancelled" &&
      cancellationReason !== "expired" &&
      cancellationReason !== "event_cancelled" &&
      cancellationReason !== "payment_failed" &&
      bookingStatus !== "completed"
    ) {
      return { eligible: true, reason: "driver_cancelled_ride" };
    }
    return {
      eligible: false,
      reason: "The ride is not recorded as cancelled by the driver.",
    };
  }

  if (reason === "driverNoShow") {
    const noShowWindowMs = 30 * 60 * 1000;
    if (
      departureMillis !== null &&
      now >= departureMillis + noShowWindowMs &&
      ["active", "full", "cancelled"].includes(rideStatus) &&
      bookingStatus !== "completed"
    ) {
      return { eligible: true, reason: "driver_no_show" };
    }
    return {
      eligible: false,
      reason:
        "No-show refunds become automatic 30 minutes after departure if the ride was not started or completed.",
    };
  }

  return {
    eligible: false,
    reason:
      "This refund reason needs a dispute review because it cannot be verified automatically.",
  };
}

export async function createStripeRefundForPayment({
  db,
  stripe,
  paymentDocs,
  paymentIntentId,
  amountInCents,
  reason,
  source,
  requestedByUid,
  idempotencyKey,
  refundRequestId,
}: {
  db: Firestore;
  stripe: StripeClient;
  paymentDocs: QueryDocumentSnapshot[];
  paymentIntentId: string;
  amountInCents?: number;
  reason: string;
  source: string;
  requestedByUid: string;
  idempotencyKey: string;
  refundRequestId?: string;
}): Promise<StripeRefund> {
  if (paymentDocs.length === 0) {
    throw new HttpsError("not-found", "Payment not found");
  }

  if (amountInCents !== undefined && amountInCents <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "amountInCents must be greater than zero",
    );
  }

  const paymentRef = paymentDocs[0].ref;
  let claimedPayment: Record<string, unknown> = paymentDocs[0].data();
  let amountToRefundInCents = amountInCents ?? 0;

  try {
    await db.runTransaction(async (txn) => {
      const snap = await txn.get(paymentRef);
      if (!snap.exists) throw new Error("payment_not_found");
      const data = snap.data()!;
      const currentStatus = stringOrEmpty(data.status);

      if (currentStatus === "refunded") throw new Error("already_refunded");
      if (currentStatus === "refunding" && data.stripeRefundId) {
        throw new Error("already_refunded");
      }
      if (
        currentStatus !== "succeeded" &&
        currentStatus !== "partiallyRefunded" &&
        currentStatus !== "refundFailed" &&
        currentStatus !== "refunding"
      ) {
        throw new Error("payment_not_succeeded");
      }

      const remainingAmount = Math.max(
        0,
        paymentAmountInCents(data) - refundedAmountInCents(data),
      );
      amountToRefundInCents = amountInCents ?? remainingAmount;
      if (amountToRefundInCents <= 0) throw new Error("already_refunded");
      if (amountToRefundInCents > remainingAmount) {
        throw new Error("invalid_refund_amount");
      }

      claimedPayment = data;
      txn.update(paymentRef, {
        status: "refunding",
        latestRefundRequestId:
          refundRequestId && refundRequestId.length > 0
            ? refundRequestId
            : (data.latestRefundRequestId ?? null),
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (message === "already_refunded") {
      throw new HttpsError(
        "failed-precondition",
        "Payment has already been refunded",
      );
    }
    if (message === "payment_not_succeeded") {
      throw new HttpsError(
        "failed-precondition",
        "Only succeeded payments can be refunded",
      );
    }
    if (message === "invalid_refund_amount") {
      throw new HttpsError(
        "invalid-argument",
        "Refund amount exceeds the remaining refundable amount",
      );
    }
    throw error;
  }

  const refundReason = stringOrEmpty(reason);
  const stripeRefundReason: StripeRefundCreateParams["reason"] = [
    "duplicate",
    "fraudulent",
    "requested_by_customer",
  ].includes(refundReason)
    ? (refundReason as StripeRefundCreateParams["reason"])
    : "requested_by_customer";

  const refundParams: StripeRefundCreateParams = {
    payment_intent: paymentIntentId,
    reason: stripeRefundReason,
    reverse_transfer: true,
    refund_application_fee: true,
    metadata: {
      paymentIntentId,
      paymentDocId: paymentRef.id,
      bookingId: stringOrEmpty(claimedPayment.bookingId),
      driverId: stringOrEmpty(claimedPayment.driverId),
      riderId:
        stringOrEmpty(claimedPayment.riderId) ||
        stringOrEmpty(claimedPayment.passengerId),
      refundReason,
      requestedByUid,
      ...(refundRequestId ? { refundRequestId } : {}),
      source,
    },
  };

  const originalAmountInCents = paymentAmountInCents(claimedPayment);
  if (amountToRefundInCents < originalAmountInCents) {
    refundParams.amount = amountToRefundInCents;
  }

  let refund: StripeRefund;
  try {
    refund = await stripe.refunds.create(refundParams, { idempotencyKey });
  } catch (stripeError) {
    await paymentRef
      .update({
        status: stringOrEmpty(claimedPayment.status) || "succeeded",
        updatedAt: FieldValue.serverTimestamp(),
      })
      .catch(() => {
        /* best-effort */
      });
    const e = stripeError as { message?: string };
    throw new HttpsError(
      "internal",
      `Stripe refund failed: ${e.message ?? "unknown error"}`,
    );
  }

  for (const doc of paymentDocs) {
    await doc.ref.update({
      status: "refunding",
      stripeRefundId: refund.id,
      stripeRefundStatus: refund.status ?? "pending",
      refundReason: refundReason || stripeRefundReason,
      requestedRefundAmountInCents: amountToRefundInCents,
      refundedAt: null,
      latestRefundRequestId:
        refundRequestId && refundRequestId.length > 0
          ? refundRequestId
          : FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  return refund;
}
