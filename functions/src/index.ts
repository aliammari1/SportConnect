// ============================================
// SportConnect Cloud Functions
// Stripe Payments + Push Notification Triggers + Event Triggers
// ============================================

import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest, onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import {
  DocumentData,
  DocumentSnapshot,
  FieldValue,
  Firestore,
  QueryDocumentSnapshot,
  Timestamp,
} from "firebase-admin/firestore";

admin.initializeApp();
// const db = getFirestore();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const resendApiKey = defineSecret("RESEND_API_KEY");
const supportFromEmail = defineSecret("SUPPORT_FROM_EMAIL");
const supportInboxEmail = defineSecret("SUPPORT_INBOX_EMAIL");

const PLATFORM_FEE_PERCENT = 0.15; // 15%
const RESOLVED_STATUSES = new Set(["resolved", "closed", "done", "completed"]);
const OPEN_REFUND_REQUEST_STATUSES = new Set([
  "open",
  "pending",
  "inReview",
  "refunding",
]);
const REFUND_REQUEST_WINDOW_DAYS = 30;
const AUTOMATIC_REFUND_REASONS = new Set([
  "cancelledByDriver",
  "driverNoShow",
]);

type StripeClient = Stripe.Stripe;
type StripeAccount = Awaited<ReturnType<StripeClient["accounts"]["create"]>>;
type StripeAccountLink = Awaited<
  ReturnType<StripeClient["accountLinks"]["create"]>
>;
type StripeEvent = ReturnType<StripeClient["webhooks"]["constructEvent"]>;
type StripePaymentIntent = Awaited<
  ReturnType<StripeClient["paymentIntents"]["retrieve"]>
>;
type StripeCharge = Awaited<ReturnType<StripeClient["charges"]["retrieve"]>>;
type StripePayout = Awaited<ReturnType<StripeClient["payouts"]["retrieve"]>>;
type StripeRefund = Awaited<ReturnType<StripeClient["refunds"]["retrieve"]>>;
type StripeTransferReversal = Awaited<
  ReturnType<StripeClient["transfers"]["createReversal"]>
>;
type StripeRefundCreateParams = NonNullable<
  Parameters<StripeClient["refunds"]["create"]>[0]
>;

// France-only Express onboarding.
// Stripe-hosted onboarding collects and verifies required KYC fields.
const STRIPE_ACCOUNT_COUNTRY = "FR" as const;
const DEFAULT_CURRENCY = "eur";

function mapPayoutStatus(status: string | null | undefined): string {
  switch (status) {
    case "pending":
      return "pending";
    case "in_transit":
      return "inTransit";
    case "paid":
      return "paid";
    case "failed":
      return "failed";
    case "canceled":
      return "cancelled";
    default:
      return "pending";
  }
}

function mapRefundStatusToPaymentStatus(
  refund: StripeRefund,
  originalAmountInCents?: number,
): string {
  const isPartial =
    originalAmountInCents !== undefined &&
    (refund.amount ?? 0) < originalAmountInCents;
  switch (refund.status) {
    case "succeeded":
      return isPartial ? "partiallyRefunded" : "refunded";
    case "pending":
      return "refunding";
    case "requires_action":
      return "refunding";
    case "failed":
      return "refundFailed";
    case "canceled":
      return "refundFailed";
    default:
      return "refunding";
  }
}

async function findPaymentDocsByPaymentIntent(
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

function isRefundOperator(auth: unknown): boolean {
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

function stringOrEmpty(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function paymentAmountInCents(data: DocumentData): number {
  return (
    finiteNumber(data.amountInCents) ??
    Math.round((finiteNumber(data.amount) ?? 0) * 100)
  );
}

function refundedAmountInCents(data: DocumentData): number {
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

function isWithinRefundRequestWindow(createdAt: unknown): boolean {
  const millis = timestampToMillis(createdAt);
  if (millis === null) return true;
  const maxAgeMs = REFUND_REQUEST_WINDOW_DAYS * 24 * 60 * 60 * 1000;
  return Date.now() - millis <= maxAgeMs;
}

async function findPaymentDocsForRefundRequest(
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

function getNestedRecord(
  value: Record<string, unknown> | undefined,
  key: string,
): Record<string, unknown> | undefined {
  return asRecord(value?.[key]);
}

function getDepartureMillis(ride: Record<string, unknown> | undefined): number | null {
  const schedule = getNestedRecord(ride, "schedule");
  return timestampToMillis(schedule?.departureTime ?? ride?.departureTime);
}

function isRideObjectivelyRefundable({
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
      reason: "No-show refunds become automatic 30 minutes after departure if the ride was not started or completed.",
    };
  }

  return {
    eligible: false,
    reason: "This refund reason needs a dispute review because it cannot be verified automatically.",
  };
}

async function createStripeRefundForPayment({
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
  let claimedPayment: DocumentData = paymentDocs[0].data();
  let amountToRefundInCents = amountInCents ?? 0;

  try {
    await db.runTransaction(async (txn) => {
      const snap = await txn.get(paymentRef);
      if (!snap.exists) throw new Error("payment_not_found");
      const data = snap.data()!;
      const currentStatus = stringOrEmpty(data.status);

      if (currentStatus === "refunded") {
        throw new Error("already_refunded");
      }
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
      if (amountToRefundInCents <= 0) {
        throw new Error("already_refunded");
      }
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
      .catch(() => { /* best-effort */ });
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

async function findDriverIdForConnectedAccount(
  db: Firestore,
  connectedAccountId: string | undefined,
): Promise<string | null> {
  if (!connectedAccountId) return null;

  const snap = await db
    .collection("driver_connected_accounts")
    .where("stripeAccountId", "==", connectedAccountId)
    .limit(1)
    .get();

  return snap.docs[0]?.id ?? null;
}

function getPaymentIntentIdFromRefund(refund: StripeRefund): string | null {
  return stripeObjectId(refund.payment_intent);
}


// ============================================
// Helper: Clean up a single stale FCM token
// ============================================

async function removeStaleToken(userId: string): Promise<void> {
  logger.info(`Removing stale FCM token for user ${userId}`);
  await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .update({ fcmToken: FieldValue.delete() });
}

// ============================================
// Helper: Send FCM Push Notification (single user)
// Used for single-recipient notifications only.
// For multi-recipient use sendPushToMultipleUsers().
// ============================================

async function sendPushToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  try {
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();
    const fcmToken = userDoc.data()?.fcmToken as string | undefined;

    if (!fcmToken) {
      logger.info(`No FCM token for user ${userId}, skipping push`);
      return;
    }

    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data,
      android: {
        priority: "high",
        notification: {
          channelId:
            data.type === "message"
              ? "sport_connect_messages"
              : data.type === "ride_request" || data.type === "ride_update"
                ? "sport_connect_rides"
                : "sport_connect_general",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            // FIX: badge removed — hardcoding 1 was wrong.
            // Badge counts must be managed client-side or via a counter,
            // not hardcoded to 1 on the server.
          },
        },
      },
    });

    logger.info(`Push sent to ${userId}: "${title}"`);
  } catch (error: unknown) {
    const e = error as { code?: string };
    // FIX: Added all valid FCM v1 API invalid-token error codes.
    // The HTTP v1 API maps stale/invalid tokens to both
    // "messaging/registration-token-not-registered" (UNREGISTERED)
    // and "messaging/invalid-argument" (INVALID_ARGUMENT).
    if (
      e.code === "messaging/registration-token-not-registered" ||
      e.code === "messaging/invalid-registration-token" ||
      e.code === "messaging/invalid-argument"
    ) {
      await removeStaleToken(userId);
    } else {
      logger.error(`Failed to send push to ${userId}:`, error);
    }
  }
}

// ============================================
// Helper: Send FCM Push to Multiple Users (batch)
// FIX: Replaced N individual sendPushToUser() calls with a single
// sendEachForMulticast() to avoid N Firestore reads + N FCM HTTP calls.
// Uses admin.firestore().getAll() to batch-fetch all tokens in one read,
// then sends one multicast request. Stale tokens are cleaned up per-response.
// ============================================

async function sendPushToMultipleUsers(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<void> {
  if (userIds.length === 0) return;

  // Batch-fetch all user documents in a single Firestore call
  const userRefs = userIds.map((id) =>
    admin.firestore().collection("users").doc(id),
  );
  const userDocs = await admin.firestore().getAll(...userRefs);

  // Map tokens back to userIds so we can clean up stale ones later
  const tokenToUserId: Record<string, string> = {};
  const tokens: string[] = [];

  userDocs.forEach((doc, idx) => {
    const token = doc.data()?.fcmToken as string | undefined;
    if (token) {
      tokens.push(token);
      tokenToUserId[token] = userIds[idx];
    } else {
      logger.info(`No FCM token for user ${userIds[idx]}, skipping`);
    }
  });

  if (tokens.length === 0) return;

  const channelId =
    data.type === "message"
      ? "sport_connect_messages"
      : data.type === "ride_request" || data.type === "ride_update"
        ? "sport_connect_rides"
        : "sport_connect_general";

  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: {
        channelId,
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          // FIX: No hardcoded badge — managed client-side
        },
      },
    },
  });

  // Handle per-token failures — clean up stale tokens
  if (response.failureCount > 0) {
    const cleanupPromises: Promise<void>[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success && resp.error) {
        const code = resp.error.code;
        const staleToken = tokens[idx];
        const userId = tokenToUserId[staleToken];
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token" ||
          code === "messaging/invalid-argument"
        ) {
          cleanupPromises.push(removeStaleToken(userId));
        } else {
          logger.error(`FCM send failed for user ${userId}:`, resp.error);
        }
      }
    });
    await Promise.all(cleanupPromises);
  }

  logger.info(
    `Multicast sent: ${response.successCount} success, ${response.failureCount} failure out of ${tokens.length}`,
  );
}

function listToText(values: string[]): string {
  if (values.length === 0) {
    return "None";
  }
  return values.map((value) => `- ${value}`).join("\n");
}

function getSupportInbox(): string {
  const inbox = supportInboxEmail.value().trim();
  if (inbox.length > 0) {
    return inbox;
  }
  return supportFromEmail.value().trim();
}

async function sendSupportMail({
  to,
  subject,
  text,
}: {
  to: string;
  subject: string;
  text: string;
}): Promise<void> {
  const apiKey = resendApiKey.value().trim();
  const from = supportFromEmail.value().trim();

  if (apiKey.length === 0 || from.length === 0) {
    throw new Error("Resend email secrets are not configured");
  }

  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to,
      subject,
      text,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    logger.error("Resend email send failed", {
      status: response.status,
      to,
      subject,
      errorBody,
    });
    throw new Error(`Resend email send failed with status ${response.status}`);
  }
}

// ============================================
// Helper: Per-user rate limiter (Firestore-backed, atomic).
//
// Uses a sliding fixed-window counter stored under _rateLimits/{uid}:{action}.
// One Firestore read + write per call — minimal cost.
// Throws HttpsError("resource-exhausted") when the limit is exceeded.
// ============================================

async function checkRateLimit(
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

// ============================================
// Helper: Recompute driver_stats from the payments collection.
// (CF-7) Called after every payment success AND after every refund so that
// driver_stats always reflects NET (non-refunded) earnings.
//
// Optimisation: only scans payments from the start of the current year
// (captures all time-windowed stats). All-time totals (totalEarnings,
// totalRides) are maintained as incremental counters via FieldValue.increment
// so callers must pass the delta for the current event.
function mapStripeCapabilityStatus(
  value: string | null | undefined,
): "active" | "inactive" | "pending" {
  if (value === "active" || value === "inactive" || value === "pending") {
    return value;
  }
  return "inactive";
}

function mapStripeDisabledReason(
  value: string | null | undefined,
): string | null {
  switch (value) {
    case "action_required.requested_capabilities":
      return "actionRequiredRequestedCapabilities";
    case "listed":
      return "listed";
    case "other":
      return "other";
    case "platform_paused":
      return "platformPaused";
    case "rejected.fraud":
      return "rejectedFraud";
    case "rejected.incomplete_verification":
      return "rejectedIncompleteVerification";
    case "rejected.listed":
      return "rejectedListed";
    case "rejected.other":
      return "rejectedOther";
    case "rejected.platform_fraud":
      return "rejectedPlatformFraud";
    case "rejected.platform_other":
      return "rejectedPlatformOther";
    case "rejected.platform_terms_of_service":
      return "rejectedPlatformTermsOfService";
    case "rejected.terms_of_service":
      return "rejectedTermsOfService";
    case "requirements.past_due":
      return "requirementsPastDue";
    case "requirements.pending_verification":
      return "requirementsPendingVerification";
    case "under_review":
      return "underReview";
    default:
      return null;
  }
}

function buildAccountHolderName(account: StripeAccount): string | null {
  const first = account.individual?.first_name?.trim() ?? "";
  const last = account.individual?.last_name?.trim() ?? "";
  const full = `${first} ${last}`.trim();

  if (full) return full;

  const businessName = account.business_profile?.name?.trim();
  if (businessName) return businessName;

  return null;
}

async function getConnectedAccountBalances(
  stripe: StripeClient,
  accountId: string,
  preferredCurrency: string,
): Promise<{
  availableBalanceInCents: number;
  pendingBalanceInCents: number;
}> {
  try {
    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: accountId },
    );

    const instantAvailableField =
      ((balance as any).instant_available ?? balance.available) as typeof balance.available;

    const instantAvailableInCents = sumBalanceForCurrency(instantAvailableField, preferredCurrency);
    const pendingInCents = sumBalanceForCurrency(balance.pending, preferredCurrency);

    return {
      availableBalanceInCents: instantAvailableInCents,
      // "Processing" = funds in Stripe's pipeline not yet eligible for instant
      // withdrawal. Uber/Lyft model: show only truly-blocked funds here so the
      // total (available + pending) doesn't double-count instant_available.
      pendingBalanceInCents: Math.max(0, pendingInCents - instantAvailableInCents),
    };
  } catch (error) {
    logger.warn("Failed to retrieve connected account balance", {
      accountId,
      error,
    });

    return {
      availableBalanceInCents: 0,
      pendingBalanceInCents: 0,
    };
  }
}

async function syncConnectedAccountSnapshot(
  db: FirebaseFirestore.Firestore,
  stripe: StripeClient,
  account: StripeAccount,
  userId: string,
  opts?: {
    availableBalanceInCents?: number;
    pendingBalanceInCents?: number;
  },
): Promise<void> {
  const defaultCurrency = (account.default_currency ?? "eur").toUpperCase();
  const preferredCurrency = defaultCurrency.toLowerCase();
  const accountHolderName = buildAccountHolderName(account);

  const transfersActive = account.capabilities?.transfers === "active";
  const isActive =
    Boolean(account.charges_enabled) &&
    Boolean(account.payouts_enabled) &&
    Boolean(account.details_submitted) &&
    transfersActive;

  let onboardingStatus = "pending";
  if (isActive) {
    onboardingStatus = "active";
  } else if ((account.requirements?.past_due?.length ?? 0) > 0) {
    onboardingStatus = "restricted";
  } else if (
    (account.requirements?.currently_due?.length ?? 0) > 0 ||
    (account.requirements?.pending_verification?.length ?? 0) > 0
  ) {
    onboardingStatus = "incomplete";
  } else if (account.details_submitted) {
    onboardingStatus = "under_review";
  }

  const balances =
    opts?.availableBalanceInCents != null && opts?.pendingBalanceInCents != null
      ? {
          availableBalanceInCents: opts.availableBalanceInCents,
          pendingBalanceInCents: opts.pendingBalanceInCents,
        }
      : await getConnectedAccountBalances(
          stripe,
          account.id,
          preferredCurrency,
        );

  const requirements = {
    currentlyDue: account.requirements?.currently_due ?? [],
    eventuallyDue: account.requirements?.eventually_due ?? [],
    pastDue: account.requirements?.past_due ?? [],
    pendingVerification: account.requirements?.pending_verification ?? [],
    currentDeadline: account.requirements?.current_deadline
      ? new Date(account.requirements.current_deadline * 1000)
      : null,
    disabledReason: mapStripeDisabledReason(
      account.requirements?.disabled_reason,
    ),
  };

  const futureRequirements = {
    currentlyDue: account.future_requirements?.currently_due ?? [],
    eventuallyDue: account.future_requirements?.eventually_due ?? [],
    pastDue: account.future_requirements?.past_due ?? [],
    pendingVerification:
      account.future_requirements?.pending_verification ?? [],
    currentDeadline: account.future_requirements?.current_deadline
      ? new Date(account.future_requirements.current_deadline * 1000)
      : null,
    disabledReason: mapStripeDisabledReason(
      account.future_requirements?.disabled_reason,
    ),
  };

  await db
    .collection("users")
    .doc(userId)
    .set(
      {
        stripeAccountId: account.id,
        stripeAccountStatus: onboardingStatus,
        chargesEnabled: account.charges_enabled ?? false,
        payoutsEnabled: account.payouts_enabled ?? false,
        detailsSubmitted: account.details_submitted ?? false,
        isStripeEnabled: account.charges_enabled ?? false,
        isStripeOnboarded: isActive,
        stripeRequirements: requirements.currentlyDue,
        stripeDisabledReason: requirements.disabledReason,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  const connectedAccountRef = db
    .collection("driver_connected_accounts")
    .doc(userId);
  const existingSnapshot = await connectedAccountRef.get();

  await connectedAccountRef.set(
    {
      driverId: userId,
      stripeAccountId: account.id,
      email: account.email ?? "",
      country: account.country ?? "FR",
      defaultCurrency,
      chargesEnabled: account.charges_enabled ?? false,
      payoutsEnabled: account.payouts_enabled ?? false,
      detailsSubmitted: account.details_submitted ?? false,
      onboardingCompleted: isActive,
      ...(isActive && {
        onboardingCompletedAt: FieldValue.serverTimestamp(),
      }),
      accountHolderName,
      capabilities: {
        transfers: mapStripeCapabilityStatus(account.capabilities?.transfers),
        cardPayments: mapStripeCapabilityStatus(
          account.capabilities?.card_payments,
        ),
      },
      requirements,
      futureRequirements,
      availableBalanceInCents: balances.availableBalanceInCents,
      pendingBalanceInCents: balances.pendingBalanceInCents,
      updatedAt: FieldValue.serverTimestamp(),
      ...(existingSnapshot.exists
        ? {}
        : { createdAt: FieldValue.serverTimestamp() }),
      metadata: {
        stripeBusinessType: account.business_type ?? null,
        stripeDefaultCurrency: defaultCurrency,
      },
    },
    { merge: true },
  );
}

// ============================================

async function recomputeDriverStats(
  db: Firestore,
  driverId: string,
  earningsDelta?: number,
  ridesDelta?: number,
): Promise<void> {
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const weekStart = new Date(todayStart);
  const daysSinceMonday = (todayStart.getDay() + 6) % 7;
  weekStart.setDate(todayStart.getDate() - daysSinceMonday);
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const yearStart = new Date(now.getFullYear(), 0, 1);

  // Recompute from canonical succeeded payments whose rides are completed, so
  // paid bookings do not become driver earnings before the trip is finished.
  // Store cents as canonical fields for Flutter, and legacy major-unit fields
  // for older app versions.
  const paymentsSnap = await db
    .collection("payments")
    .where("driverId", "==", driverId)
    .where("status", "==", "succeeded")
    .get();
  const rideIds = [...new Set(
    paymentsSnap.docs
      .map((doc) => doc.data().rideId)
      .filter((rideId): rideId is string =>
        typeof rideId === "string" && rideId.trim().length > 0,
      ),
  )];
  const completedRideIds = await getCompletedRideIds(db, rideIds);

  let totalEarningsInCents = 0;
  let totalPlatformFeesInCents = 0;
  let totalStripeFeesInCents = 0;
  let earningsTodayInCents = 0;
  let earningsThisWeekInCents = 0;
  let earningsThisMonthInCents = 0;
  let earningsThisYearInCents = 0;
  let totalPlatformFees = 0;
  let totalStripeFees = 0;
  let earningsToday = 0;
  let earningsThisWeek = 0;
  let earningsThisMonth = 0;
  let earningsThisYear = 0;
  let ridesToday = 0;
  let ridesThisWeek = 0;
  let ridesThisMonth = 0;
  let ridesThisYear = 0;
  let completedPaymentCount = 0;
  let lastRideAt: Date | null = null;

  for (const doc of paymentsSnap.docs) {
    const data = doc.data();
    const rideId = typeof data.rideId === "string" ? data.rideId : "";
    if (!completedRideIds.has(rideId)) continue;
    completedPaymentCount += 1;

    const earningsCents =
      finiteNumber(data.driverEarningsInCents) ??
      Math.round((finiteNumber(data.driverEarnings) ?? 0) * 100);
    const platformFeeCents =
      finiteNumber(data.platformFeeInCents) ??
      Math.round((finiteNumber(data.platformFee) ?? 0) * 100);
    const stripeFeeCents =
      finiteNumber(data.stripeFeeInCents) ??
      Math.round((finiteNumber(data.stripeFee) ?? 0) * 100);
    const earnings = earningsCents / 100;
    const platformFee = platformFeeCents / 100;
    const stripeFee = stripeFeeCents / 100;
    const completedAt =
      (data.rideCompletedAt as Timestamp | null)?.toDate() ??
      (data.completedAt as Timestamp | null)?.toDate() ??
      (data.createdAt as Timestamp | null)?.toDate();

    totalEarningsInCents += earningsCents;
    totalPlatformFeesInCents += platformFeeCents;
    totalStripeFeesInCents += stripeFeeCents;
    totalPlatformFees += platformFee;
    totalStripeFees += stripeFee;

    if (completedAt) {
      if (!lastRideAt || completedAt > lastRideAt) {
        lastRideAt = completedAt;
      }
      if (completedAt >= yearStart) {
        earningsThisYearInCents += earningsCents;
        earningsThisYear += earnings;
        ridesThisYear += 1;
      }
      if (completedAt >= monthStart) {
        earningsThisMonthInCents += earningsCents;
        earningsThisMonth += earnings;
        ridesThisMonth += 1;
      }
      if (completedAt >= weekStart) {
        earningsThisWeekInCents += earningsCents;
        earningsThisWeek += earnings;
        ridesThisWeek += 1;
      }
      if (completedAt >= todayStart) {
        earningsTodayInCents += earningsCents;
        earningsToday += earnings;
        ridesToday += 1;
      }
    }
  }

  const statsRef = db.collection("driver_stats").doc(driverId);

  const updates: Record<string, unknown> = {
    driverId,
    totalEarningsInCents,
    totalPlatformFeesInCents,
    totalStripeFeesInCents,
    earningsTodayInCents,
    earningsThisWeekInCents,
    earningsThisMonthInCents,
    earningsThisYearInCents,
    totalRides: completedPaymentCount,
    totalPlatformFees,
    totalStripeFees,
    totalEarnings: totalEarningsInCents / 100,
    earningsToday,
    earningsThisWeek,
    earningsThisMonth,
    earningsThisYear,
    ridesToday,
    ridesThisWeek,
    ridesThisMonth,
    ridesThisYear,
    lastUpdatedAt: FieldValue.serverTimestamp(),
  };

  if (lastRideAt) {
    updates.lastRideAt = Timestamp.fromDate(lastRideAt);
  }

  await statsRef.set(updates, { merge: true });

  logger.info("driver_stats recomputed", {
    driverId,
    earningsDelta,
    ridesDelta,
    totalEarningsInCents,
    totalRides: completedPaymentCount,
  });
}

// ============================================
// Trigger: New Support Ticket -> Email Support Inbox
// ============================================

export const onSupportTicketCreated = onDocumentCreated(
  {
    document: "support_tickets/{ticketId}",
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
  },
  async (event) => {
    const ticket = event.data?.data() as Record<string, unknown> | undefined;
    if (!ticket) {
      return;
    }

    const ticketId = event.params.ticketId;
    const userId =
      typeof ticket.userId === "string" ? ticket.userId : "unknown";
    const userName =
      typeof ticket.userName === "string" ? ticket.userName : "Unknown";
    const userEmail =
      typeof ticket.userEmail === "string" ? ticket.userEmail : "Unknown";
    const category =
      typeof ticket.category === "string" ? ticket.category : "General";
    const subject =
      typeof ticket.subject === "string" ? ticket.subject : "(No subject)";
    const message =
      typeof ticket.message === "string" ? ticket.message : "(No message)";
    const attachmentUrls = Array.isArray(ticket.attachmentUrls)
      ? ticket.attachmentUrls.filter(
          (url): url is string => typeof url === "string",
        )
      : [];
    const metadata = asRecord(ticket.metadata);
    const metadataLines = metadata
      ? Object.entries(metadata).map(([key, value]) => `${key}: ${String(value)}`)
      : [];

    const emailSubject = `[Support Ticket][${category}] ${subject}`;
    const emailBody = [
      "A new support ticket was created in SportConnect.",
      "",
      `Ticket ID: ${ticketId}`,
      `User ID: ${userId}`,
      `User Name: ${userName}`,
      `User Email: ${userEmail}`,
      `Category: ${category}`,
      "",
      "Message:",
      message,
      "",
      "Metadata:",
      listToText(metadataLines),
      "",
      "Attachment URLs:",
      listToText(attachmentUrls),
    ].join("\n");

    await sendSupportMail({
      to: getSupportInbox(),
      subject: emailSubject,
      text: emailBody,
    });
  },
);

// ============================================
// Trigger: New Report -> Email Support Inbox
// ============================================

export const onReportCreated = onDocumentCreated(
  {
    document: "reports/{reportId}",
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
  },
  async (event) => {
    const report = event.data?.data() as Record<string, unknown> | undefined;
    if (!report) {
      return;
    }

    const reportId = event.params.reportId;
    const reporterId =
      typeof report.reporterId === "string" ? report.reporterId : "unknown";
    const reporterEmail =
      typeof report.reporterEmail === "string"
        ? report.reporterEmail
        : "Unknown";
    const type = typeof report.type === "string" ? report.type : "Other";
    const severity =
      typeof report.severity === "string" ? report.severity : "medium";
    const description =
      typeof report.description === "string"
        ? report.description
        : "(No description)";
    const rideId = typeof report.rideId === "string" ? report.rideId : "N/A";
    const reportedUserId =
      typeof report.reportedUserId === "string" ? report.reportedUserId : "N/A";
    const attachmentUrls = Array.isArray(report.attachmentUrls)
      ? report.attachmentUrls.filter(
          (url): url is string => typeof url === "string",
        )
      : [];

    const emailSubject = `[Issue Report][${severity}][${type}] ${reportId}`;
    const emailBody = [
      "A new issue report was created in SportConnect.",
      "",
      `Report ID: ${reportId}`,
      `Reporter ID: ${reporterId}`,
      `Reporter Email: ${reporterEmail}`,
      `Type: ${type}`,
      `Severity: ${severity}`,
      `Ride ID: ${rideId}`,
      `Reported User ID: ${reportedUserId}`,
      "",
      "Description:",
      description,
      "",
      "Attachment URLs:",
      listToText(attachmentUrls),
    ].join("\n");

    await sendSupportMail({
      to: getSupportInbox(),
      subject: emailSubject,
      text: emailBody,
    });
  },
);

// ============================================
// Trigger: Support Ticket Resolved -> Email User
// ============================================

export const onSupportTicketResolved = onDocumentUpdated(
  {
    document: "support_tickets/{ticketId}",
    secrets: [resendApiKey, supportFromEmail],
  },
  async (event) => {
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;

    if (!after) {
      return;
    }

    const beforeStatus =
      typeof before?.status === "string" ? before.status.toLowerCase() : "";
    const afterStatus =
      typeof after.status === "string" ? after.status.toLowerCase() : "";

    if (beforeStatus === afterStatus || !RESOLVED_STATUSES.has(afterStatus)) {
      return;
    }

    const userEmail =
      typeof after.userEmail === "string" ? after.userEmail.trim() : "";
    if (userEmail.length === 0) {
      logger.warn("Support ticket resolved without userEmail", {
        ticketId: event.params.ticketId,
      });
      return;
    }

    const ticketId = event.params.ticketId;
    const metadata = asRecord(after.metadata);
    const refundRequestId = stringOrEmpty(metadata?.refundRequestId);
    if (refundRequestId.length > 0) {
      await admin.firestore().collection("refund_requests").doc(refundRequestId).set(
        {
          status: afterStatus,
          supportTicketId: ticketId,
          resolvedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    const subject = `Your SportConnect support ticket (${ticketId}) is resolved`;
    const text = [
      "Hello,",
      "",
      "Your SportConnect support request has been marked as resolved.",
      "If you still need help, please open a new ticket from the app.",
      "",
      `Ticket ID: ${ticketId}`,
      "",
      "SportConnect Support",
    ].join("\n");

    await sendSupportMail({ to: userEmail, subject, text });
  },
);

// ============================================
// Trigger: Issue Report Resolved -> Email User
// ============================================

export const onReportResolved = onDocumentUpdated(
  {
    document: "reports/{reportId}",
    secrets: [resendApiKey, supportFromEmail],
  },
  async (event) => {
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;

    if (!after) {
      return;
    }

    const beforeStatus =
      typeof before?.status === "string" ? before.status.toLowerCase() : "";
    const afterStatus =
      typeof after.status === "string" ? after.status.toLowerCase() : "";

    if (beforeStatus === afterStatus || !RESOLVED_STATUSES.has(afterStatus)) {
      return;
    }

    const reporterEmail =
      typeof after.reporterEmail === "string" ? after.reporterEmail.trim() : "";
    if (reporterEmail.length === 0) {
      logger.warn("Issue report resolved without reporterEmail", {
        reportId: event.params.reportId,
      });
      return;
    }

    const reportId = event.params.reportId;
    const subject = `Your SportConnect report (${reportId}) is resolved`;
    const text = [
      "Hello,",
      "",
      "Your SportConnect issue report has been reviewed and marked as resolved.",
      "If you need more help, you can submit another report from the app.",
      "",
      `Report ID: ${reportId}`,
      "",
      "SportConnect Support",
    ].join("\n");

    await sendSupportMail({ to: reporterEmail, subject, text });
  },
);

// ============================================
// Trigger: New Chat Message
// ============================================

export const onNewMessage = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const senderId = message.senderId as string;
    const senderName = message.senderName as string;
    const chatId = event.params.chatId;

    // FIX: Do NOT include raw message content in the push payload.
    // Sending real content through FCM exposes it on Google's infrastructure.
    // Use a generic body and let the app fetch the actual message on open.
    const notificationBody = "You have a new message";

    const chatDoc = await admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .get();
    const chatData = chatDoc.data();
    if (!chatData) return;

    const participantIds = (chatData.participantIds as string[]) || [];
    const recipients = participantIds.filter((id: string) => id !== senderId);

    if (recipients.length === 0) return;

    // FIX: Use batch multicast instead of N individual calls
    await sendPushToMultipleUsers(recipients, senderName, notificationBody, {
      type: "message",
      referenceId: chatId,
      senderId,
    });
  },
);

// ============================================
// Trigger: New Ride Request
// ============================================

// FIXED: Was listening to dead "rideRequests" collection. Flutter now writes
// booking requests to "bookings". Rewritten to fire on bookings/{bookingId}.
export const onNewRideRequest = onDocumentCreated(
  "bookings/{bookingId}",
  async (event) => {
    const booking = event.data?.data();
    if (!booking) return;

    // CF-12: Deduplication — Firestore triggers can be retried on transient
    // errors, sending the same push twice.  We write notificationSentAt before
    // sending; on retry the field is already present and we bail out early.
    if (booking.notificationSentAt) return;
    try {
      await event.data!.ref.update({
        notificationSentAt: FieldValue.serverTimestamp(),
      });
    } catch {
      // Document may have been deleted between trigger and update — abort.
      return;
    }

    const rideId = typeof booking.rideId === "string" ? booking.rideId : null;
    const passengerId =
      typeof booking.passengerId === "string" ? booking.passengerId : null;
    const seatsBooked = (booking.seatsBooked as number) ?? 1;

    if (!rideId || !passengerId) return;

    const db = admin.firestore();

    // Fetch ride to get driverId
    const rideSnap = await db.collection("rides").doc(rideId).get();
    const rideData = rideSnap.data();
    if (!rideData) return;

    const driverId = typeof rideData.driverId === "string" ? rideData.driverId : null;
    if (!driverId) return;

    // Fetch rider name from users collection
    let riderName = "A rider";
    try {
      const userSnap = await db.collection("users").doc(passengerId).get();
      riderName = (userSnap.data()?.username as string) || riderName;
    } catch {
      // Non-critical — fallback to generic name
    }

    // Pickup location name from the booking's pickupLocation
    const pickupLocation = booking.pickupLocation as Record<string, unknown> | undefined;
    const pickup = (pickupLocation?.name as string) || (pickupLocation?.address as string) || "";

    // CF-10: Include the fare amount so the driver can evaluate the booking
    // value without opening the app.
    let fareStr = "";
    try {
      const pricePerSeatInCents = getRidePricePerSeatInCents(rideData);
      if (pricePerSeatInCents !== undefined && pricePerSeatInCents > 0) {
        const total = (pricePerSeatInCents * seatsBooked) / 100;
        fareStr = ` — €${total.toFixed(2)}`;
      }
    } catch {
      // Non-critical — proceed without fare if pricing fetch fails.
    }

    await sendPushToUser(
      driverId,
      "New Ride Request",
      `${riderName} wants to join your ride${pickup ? " from " + pickup : ""}${fareStr}`,
      {
        type: "ride_request",
        referenceId: rideId,
        requestId: event.params.bookingId,
      },
    );
  },
);

// ============================================
// Trigger: Ride Request Status Changed
// ============================================

// FIXED: Was listening to dead "rideRequests" collection. Rewritten to fire
// on "bookings/{bookingId}" which is what Flutter actually writes to.
export const onRideRequestUpdated = onDocumentUpdated(
  "bookings/{bookingId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    if (before.status === after.status) return;

    // onBookingCancelled already handles the cancellation → refund flow.
    // This trigger only handles driver accept/reject notifications.
    const newStatus = after.status as string;
    if (newStatus === "cancelled") return;

    const passengerId =
      typeof after.passengerId === "string" ? after.passengerId : null;
    const rideId = typeof after.rideId === "string" ? after.rideId : null;
    if (!passengerId || !rideId) return;

    let title = "";
    let body = "";

    switch (newStatus) {
      case "accepted":
        title = "Ride Request Accepted! 🎉";
        body = "Your ride request has been accepted. Get ready!";
        break;
      case "rejected":
        title = "Ride Request Declined";
        body = "Unfortunately, your ride request was not accepted.";
        break;
      default:
        return;
    }

    await sendPushToUser(passengerId, title, body, {
      type: "ride_update",
      referenceId: rideId,
      status: newStatus,
    });
  },
);

// ============================================
// Trigger: Ride Status Changes (started, completed)
// ============================================

export const onRideStatusChanged = onDocumentUpdated(
  "rides/{rideId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    // Notify passengers when ride starts or completes.
    // passengerIds are NOT embedded on the ride document — they live in the
    // separate `bookings` collection.  Query accepted bookings to get them.
    const isStarting = before.status !== "active" && after.status === "active";
    const isCompleting =
      before.status !== "completed" && after.status === "completed";

    if (!isStarting && !isCompleting) return;

    const db = admin.firestore();
    const bookingsSnap = await db
      .collection("bookings")
      .where("rideId", "==", event.params.rideId)
      .where("status", "==", "accepted")
      .get();

    const passengerIds = bookingsSnap.docs
      .map((doc) => doc.data().passengerId as string)
      .filter(Boolean);

    if (passengerIds.length === 0) return;

    if (isStarting) {
      // RideModel has no driverName field — fetch from users collection.
      let driverName = "Your driver";
      const driverId = typeof after.driverId === "string" ? after.driverId : null;
      if (driverId) {
        try {
          const driverSnap = await db.collection("users").doc(driverId).get();
          driverName = (driverSnap.data()?.username as string) || driverName;
        } catch { /* non-critical */ }
      }
      await sendPushToMultipleUsers(
        passengerIds,
        "Your Ride Has Started! 🚗",
        `${driverName} has started the ride. Track your trip in the app.`,
        {
          type: "ride_update",
          referenceId: event.params.rideId,
          status: "active",
        },
      );
    }

    if (isCompleting) {
      // GAP-1: Atomically mark all accepted bookings as completed
      const completionBatch = db.batch();
      bookingsSnap.docs.forEach((doc) => {
        completionBatch.update(doc.ref, {
          status: "completed",
          // GAP-8/9: Flag for review prompt on next app open
          reviewPromptPending: true,
          updatedAt: FieldValue.serverTimestamp(),
        });
      });
      if (!bookingsSnap.empty) await completionBatch.commit();

      const driverId =
        typeof after.driverId === "string" ? after.driverId : null;
      if (driverId) {
        const paymentsSnap = await db
          .collection("payments")
          .where("rideId", "==", event.params.rideId)
          .where("driverId", "==", driverId)
          .where("status", "==", "succeeded")
          .get();
        if (!paymentsSnap.empty) {
          const paymentBatch = db.batch();
          paymentsSnap.docs.forEach((doc) => {
            paymentBatch.update(doc.ref, {
              payoutEligible: true,
              rideCompletedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });
          });
          await paymentBatch.commit();
        }

        await recomputeDriverStats(db, driverId);
      }

      // GAP-8/9: Send ride-complete push with review CTA
      await sendPushToMultipleUsers(
        passengerIds,
        "Ride Completed ✅",
        "Your ride is complete! Rate your driver and earn bonus XP.",
        {
          type: "ride_completed",
          referenceId: event.params.rideId,
          status: "completed",
        },
      );

      // Notify driver their ride is done
      if (driverId) {
        await sendPushToUser(
          driverId,
          "Ride Completed 🏁",
          `Great job! Your ride is complete. Earnings will be processed shortly.`,
          {
            type: "ride_completed",
            referenceId: event.params.rideId,
            status: "completed",
          },
        );
      }
    }
  },
);

// ============================================
// Trigger: New Sport Event Created
// ============================================

export const onNewEvent = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const creatorId = data.creatorId as string;
    const title = (data.title as string) || "New event";
    const eventType = (data.type as string) || "sport";
    const eventId = event.params.eventId;

    await sendPushToUser(
      creatorId,
      "Your event is live! 🎉",
      `"${title}" is now visible to all SportConnect users. Good luck!`,
      {
        type: "event_created",
        referenceId: eventId,
        eventType,
      },
    );
  },
);

// ============================================
// Trigger: Event Updated (participant joined / event cancelled)
// ============================================

export const onEventUpdated = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const eventId = event.params.eventId;
    const eventTitle = (after.title as string) || "An event";
    const creatorId = after.creatorId as string;
    const db = admin.firestore();

    const participantsBefore = (before.participantIds as string[]) || [];
    const participantsAfter = (after.participantIds as string[]) || [];

    const newParticipants = participantsAfter.filter(
      (id: string) => !participantsBefore.includes(id),
    );

    // ── 1. New participant joined ─────────────────────────────────────────
    for (const participantId of newParticipants) {
      if (participantId !== creatorId) {
        let joinerName = "A new player";
        try {
          const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(participantId)
            .get();
          joinerName = (userDoc.data()?.username as string) || joinerName;
        } catch {
          // Graceful fallback — name is cosmetic only
        }

        await sendPushToUser(
          creatorId,
          "New participant! 🏅",
          `${joinerName} joined your event "${eventTitle}".`,
          {
            type: "event_joined",
            referenceId: eventId,
            participantId,
          },
        );
      }

      // Confirm to the joining participant
      await sendPushToUser(
        participantId,
        "You're in! ✅",
        `You have successfully joined "${eventTitle}". See you there!`,
        {
          type: "event_joined",
          referenceId: eventId,
        },
      );
    }

    // ── 2. Event cancelled ────────────────────────────────────────────────
    if (before.isActive === true && after.isActive === false) {
      const allParticipants = participantsAfter.filter(
        (id: string) => id !== creatorId,
      );

      // FIX: Use batch multicast for cancellation notifications
      await sendPushToMultipleUsers(
        allParticipants,
        "Event cancelled 😞",
        `Unfortunately "${eventTitle}" has been cancelled by the organiser.`,
        {
          type: "event_cancelled",
          referenceId: eventId,
        },
      );

      // FIX E-2: Cancel all rides linked to this event so drivers and
      // passengers are aware the event no longer exists.
      try {
        const linkedRidesSnap = await db
          .collection("rides")
          .where("eventId", "==", eventId)
          .where("status", "==", "active")
          .get();

        const rideDriverIds: string[] = [];
        for (const rideDoc of linkedRidesSnap.docs) {
          await rideDoc.ref.update({
            status: "cancelled",
            cancellationReason: "event_cancelled",
            updatedAt: FieldValue.serverTimestamp(),
          });
          const driverId = rideDoc.data().driverId as string | undefined;
          if (driverId) rideDriverIds.push(driverId);
        }

        if (rideDriverIds.length > 0) {
          await sendPushToMultipleUsers(
            rideDriverIds,
            "Ride cancelled — event ended",
            `The event "${eventTitle}" was cancelled. Your linked ride has been cancelled automatically.`,
            { type: "ride_update", referenceId: eventId, status: "cancelled" },
          );
        }
      } catch (rideErr) {
        logger.error("onEventUpdated: failed to cancel linked rides", {
          eventId,
          error: rideErr,
        });
      }
    }

    // ── 3. Event is now full ──────────────────────────────────────────────
    const maxParticipants = (after.maxParticipants as number) || 0;
    if (
      maxParticipants > 0 &&
      participantsAfter.length >= maxParticipants &&
      participantsBefore.length < maxParticipants
    ) {
      await sendPushToUser(
        creatorId,
        "Your event is full! 🎊",
        `"${eventTitle}" has reached its maximum capacity of ${maxParticipants} participants.`,
        {
          type: "event_full",
          referenceId: eventId,
        },
      );
    }
  },
);

// ============================================
// Stripe Helpers
// ============================================

function getStripeClient(secretKey: string): StripeClient {
  return new Stripe(secretKey, {
    apiVersion: "2026-04-22.dahlia",
    typescript: true,
  });
}

function calculateFees(amount: number) {
  const platformFee = Math.round(amount * PLATFORM_FEE_PERCENT);
  const driverAmount = amount - platformFee;
  return { platformFee, driverAmount };
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
  if (typeof value !== "object" || value === null) return undefined;
  return value as Record<string, unknown>;
}

function finiteNumber(value: unknown): number | undefined {
  return typeof value === "number" && Number.isFinite(value)
    ? value
    : undefined;
}

function stripeObjectId(value: unknown): string | null {
  if (typeof value === "string" && value.trim().length > 0) {
    return value.trim();
  }

  const record = asRecord(value);
  const id = record?.id;
  return typeof id === "string" && id.trim().length > 0 ? id.trim() : null;
}

function getRidePricePerSeatInCents(
  rideData: Record<string, unknown>,
): number | undefined {
  const pricing = asRecord(rideData.pricing);
  const pricePerSeatInCents = asRecord(pricing?.pricePerSeatInCents);
  const amountInCents = finiteNumber(pricePerSeatInCents?.amountInCents);
  if (amountInCents !== undefined) return Math.round(amountInCents);

  const legacyPricePerSeat = asRecord(pricing?.pricePerSeat);
  const legacyAmountInCents = finiteNumber(legacyPricePerSeat?.amountInCents);
  if (legacyAmountInCents !== undefined) {
    return Math.round(legacyAmountInCents);
  }

  const legacyAmount = finiteNumber(legacyPricePerSeat?.amount);
  if (legacyAmount !== undefined) return Math.round(legacyAmount * 100);

  return undefined;
}

function sumBalanceForCurrency(
  entries:
    | Array<{ amount?: number | null; currency?: string | null }>
    | undefined,
  preferredCurrency: string,
): number {
  if (!entries || entries.length === 0) return 0;

  const normalizedPreferredCurrency = preferredCurrency.toLowerCase();
  const preferredEntries = entries.filter(
    (entry) =>
      (entry.currency ?? "").toLowerCase() === normalizedPreferredCurrency,
  );
  const selectedCurrency =
    preferredEntries.length > 0
      ? normalizedPreferredCurrency
      : (entries[0]?.currency ?? "").toLowerCase();

  return entries
    .filter(
      (entry) => (entry.currency ?? "").toLowerCase() === selectedCurrency,
    )
    .reduce((sum, entry) => sum + (entry.amount ?? 0), 0);
}

async function getCompletedRideIds(
  db: Firestore,
  rideIds: string[],
): Promise<Set<string>> {
  const completedRideIds = new Set<string>();
  const uniqueRideIds = [...new Set(rideIds.filter((id) => id.length > 0))];

  for (let i = 0; i < uniqueRideIds.length; i += 100) {
    const chunk = uniqueRideIds.slice(i, i + 100);
    const refs = chunk.map((rideId) => db.collection("rides").doc(rideId));
    const snapshots = await db.getAll(...refs);
    snapshots.forEach((snapshot) => {
      if (snapshot.data()?.status === "completed") {
        completedRideIds.add(snapshot.id);
      }
    });
  }

  return completedRideIds;
}

async function getDriverPayoutEligibilitySnapshot(
  db: Firestore,
  stripe: StripeClient,
  opts: {
    driverId: string;
    stripeAccountId: string;
    currency: string;
    stripeAvailableBalanceInCents?: number;
  },
): Promise<{
  completedEarningsInCents: number;
  activePayoutsInCents: number;
  eligibleBalanceInCents: number;
  stripeAvailableBalanceInCents: number;
  withdrawableBalanceInCents: number;
  blockedPendingRideEarningsInCents: number;
}> {
  const paymentsSnap = await db
    .collection("payments")
    .where("driverId", "==", opts.driverId)
    .where("status", "==", "succeeded")
    .get();
  const rideIds = paymentsSnap.docs
    .map((doc) => doc.data().rideId)
    .filter((rideId): rideId is string =>
      typeof rideId === "string" && rideId.trim().length > 0,
    );
  const completedRideIds = await getCompletedRideIds(db, rideIds);

  let completedEarningsInCents = 0;
  let blockedPendingRideEarningsInCents = 0;

  for (const doc of paymentsSnap.docs) {
    const data = doc.data();
    const amountInCents =
      finiteNumber(data.driverEarningsInCents) ??
      Math.round((finiteNumber(data.driverEarnings) ?? 0) * 100);
    const rideId = typeof data.rideId === "string" ? data.rideId : "";

    if (completedRideIds.has(rideId)) {
      completedEarningsInCents += amountInCents;
    } else {
      blockedPendingRideEarningsInCents += amountInCents;
    }
  }

  const payoutsSnap = await db
    .collection("payouts")
    .where("driverId", "==", opts.driverId)
    .where("status", "in", ["pending", "inTransit", "paid"])
    .get();

  const activePayoutsInCents = payoutsSnap.docs.reduce((sum, doc) => {
    const data = doc.data();
    const amountInCents =
      finiteNumber(data.amountInCents) ??
      Math.round((finiteNumber(data.amount) ?? 0) * 100);
    return sum + amountInCents;
  }, 0);

  let stripeAvailableBalanceInCents = opts.stripeAvailableBalanceInCents;
  if (stripeAvailableBalanceInCents === undefined) {
    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: opts.stripeAccountId },
    );
    const instantAvailableField =
      ((balance as any).instant_available ?? balance.available) as typeof balance.available;
    stripeAvailableBalanceInCents = sumBalanceForCurrency(
      instantAvailableField,
      opts.currency,
    );
  }

  const eligibleBalanceInCents = Math.max(
    0,
    completedEarningsInCents - activePayoutsInCents,
  );

  return {
    completedEarningsInCents,
    activePayoutsInCents,
    eligibleBalanceInCents,
    stripeAvailableBalanceInCents,
    withdrawableBalanceInCents: Math.max(
      0,
      Math.min(eligibleBalanceInCents, stripeAvailableBalanceInCents),
    ),
    blockedPendingRideEarningsInCents,
  };
}

// ============================================
// Stripe: Create Connected Account
// ============================================

export const createConnectedAccount = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    logger.info("createConnectedAccount called", {
      userId: request.data?.userId,
      authUid: request.auth?.uid,
    });

    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 3 account creations per user per hour.
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "createConnectedAccount",
      3,
      3600,
    );

    const { userId, email } = request.data;
    logger.info("Parsed - userId:", userId, "email:", email);

    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required");
    }

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripeCountry = STRIPE_ACCOUNT_COUNTRY;

    let stripeApiKey: string;
    try {
      stripeApiKey = stripeSecretKey.value().trim();
      logger.info("Stripe API key loaded successfully");
    } catch (err) {
      logger.error("Error getting Stripe secret:", err);
      throw new HttpsError("internal", "Failed to load Stripe API key");
    }

    const stripe = getStripeClient(stripeApiKey);
    const db = admin.firestore();

    const [userDoc, connectedAccountDoc] = await Promise.all([
      db.collection("users").doc(userId).get(),
      db.collection("driver_connected_accounts").doc(userId).get(),
    ]);
    const userData = userDoc.data();
    const connectedAccountData = connectedAccountDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found in database");
    }

    if (userData.role !== "driver") {
      throw new HttpsError(
        "failed-precondition",
        "User is not registered as a driver",
      );
    }

    let accountId =
      typeof connectedAccountData?.stripeAccountId === "string" &&
      connectedAccountData.stripeAccountId.trim().length > 0
        ? connectedAccountData.stripeAccountId
        : userData.stripeAccountId;
    let accountDefaultCurrency = DEFAULT_CURRENCY;
    logger.info(
      "User data - role:",
      userData.role,
      "stripeAccountId:",
      accountId,
    );

    if (accountId) {
      logger.info("Found existing stripeAccountId:", accountId);
      try {
        const existingAccount = await stripe.accounts.retrieve(accountId);
        await syncConnectedAccountSnapshot(db, stripe, existingAccount, userId);
        accountDefaultCurrency =
          existingAccount.default_currency ?? accountDefaultCurrency;
        logger.info("Existing Stripe account found:", existingAccount.id);
      } catch (error) {
        logger.info(
          "Existing Stripe account not valid, creating new one:",
          error,
        );
        accountId = null;
        await db.collection("users").doc(userId).update({
          stripeAccountId: FieldValue.delete(),
          stripeAccountStatus: FieldValue.delete(),
          chargesEnabled: FieldValue.delete(),
          payoutsEnabled: FieldValue.delete(),
          detailsSubmitted: FieldValue.delete(),
        });
      }
    }

    if (!accountId) {
      logger.info("Creating new Stripe Connect account for:", email);

      let createdAccount: StripeAccount;
      try {
        createdAccount = await stripe.accounts.create({
          type: "express",
          country: stripeCountry,
          email,
          capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true },
          },
          business_type: "individual",
          business_profile: {
            mcc: "4121",
            product_description:
              "Carpooling driver on SportConnect - providing shared ride services to passengers for cost-sharing commutes and sports events",
          },
          metadata: { userId, userType: "driver" },
        });
      } catch (stripeError: unknown) {
        const e = stripeError as {
          message?: string;
          type?: string;
          code?: string;
        };
        logger.error("stripe.accounts.create failed", {
          error: e.message,
          type: e.type,
          code: e.code,
          userId,
        });
        throw new HttpsError(
          "internal",
          `Stripe account creation failed: ${e.message ?? "unknown error"}`,
        );
      }

      accountId = createdAccount.id;
      accountDefaultCurrency =
        createdAccount.default_currency ?? accountDefaultCurrency;
      logger.info("New Stripe account created:", accountId);

      await syncConnectedAccountSnapshot(db, stripe, createdAccount, userId);
    }

    const baseUrl = "https://sportaxitrip.com";

    let accountLink: StripeAccountLink;
    try {
      accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: `${baseUrl}/stripe-refresh.html?userId=${userId}`,
        return_url: `${baseUrl}/stripe-return.html?userId=${userId}`,
        type: "account_onboarding",
      });
    } catch (stripeError: unknown) {
      const e = stripeError as { message?: string };
      logger.error("stripe.accountLinks.create failed", {
        error: e.message,
        accountId,
        userId,
      });
      throw new HttpsError(
        "internal",
        `Failed to generate Stripe onboarding link: ${e.message ?? "unknown error"}`,
      );
    }

    return {
      accountId,
      onboardingUrl: accountLink.url,
      defaultCurrency: accountDefaultCurrency.toUpperCase(),
    };
  },
);

// ============================================
// Stripe: Create Account Link (re-onboarding)
// ============================================

export const createAccountLink = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const uid = request.auth.uid;
    const db = admin.firestore();
    const stripe = getStripeClient(stripeSecretKey.value().trim());

    const connectedAccountDoc = await db
      .collection("driver_connected_accounts")
      .doc(uid)
      .get();

    const accountId = connectedAccountDoc.data()?.stripeAccountId;

    if (typeof accountId !== "string" || accountId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "No Stripe connected account found for this user.",
      );
    }

    const baseUrl = "https://sportaxitrip.com";

    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/stripe-refresh.html?userId=${uid}`,
      return_url: `${baseUrl}/stripe-return.html?userId=${uid}`,
      type: "account_onboarding",
    });

    return { url: accountLink.url };
  },
);

// ============================================
// Stripe: Get Account Status
// ============================================

export const getAccountStatus = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { accountId } = request.data;

    if (!accountId) {
      throw new HttpsError("invalid-argument", "accountId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    try {
      const uid = request.auth.uid;
      const [callerDoc, connectedAccountDoc] = await Promise.all([
        db.collection("users").doc(uid).get(),
        db.collection("driver_connected_accounts").doc(uid).get(),
      ]);
      const callerAccountId = callerDoc.data()?.stripeAccountId;
      const connectedAccountId = connectedAccountDoc.data()?.stripeAccountId;
      const authorizedAccountIds = new Set(
        [callerAccountId, connectedAccountId].filter(
          (id): id is string => typeof id === "string" && id.length > 0,
        ),
      );

      if (
        authorizedAccountIds.size > 0 &&
        !authorizedAccountIds.has(accountId)
      ) {
        throw new HttpsError(
          "permission-denied",
          "You are not authorized to access this Stripe account",
        );
      }

      const account = await stripe.accounts.retrieve(accountId);
      if (authorizedAccountIds.size === 0 && account.metadata?.userId !== uid) {
        throw new HttpsError(
          "permission-denied",
          "You are not authorized to access this Stripe account",
        );
      }

      const defaultCurrency = (account.default_currency ?? "eur").toLowerCase();

      // Fetch balance for this connected account. Stripe balance amounts are
      // already in minor units, so keep cents canonical and expose legacy major
      // unit fields only for old app versions.
      let availableBalanceInCents = 0;
      let pendingBalanceInCents = 0;

      try {
        const balance = await stripe.balance.retrieve(
          {},
          {
            stripeAccount: accountId,
          },
        );
        logger.info("Stripe balance retrieved", {
          accountId,
          availableCount: balance.available?.length,
          pendingCount: balance.pending?.length,
          rawAvailable: JSON.stringify(balance.available),
          rawPending: JSON.stringify(balance.pending),
        });

        // Instant payouts draw from instant_available, not available.
        // available only fills after the standard settlement window (T+2) —
        // which never auto-advances in test mode without a test clock.
        const instantAvailableField =
          ((balance as any).instant_available ?? balance.available) as typeof balance.available;

        availableBalanceInCents = sumBalanceForCurrency(
          instantAvailableField,
          defaultCurrency,
        );
        // "Processing" = pending minus what's already instantly withdrawable.
        // This matches how Uber/Lyft display balances: available + processing
        // never double-counts instant_available.
        pendingBalanceInCents = Math.max(
          0,
          sumBalanceForCurrency(balance.pending, defaultCurrency) - availableBalanceInCents,
        );
        logger.info("Calculated balances", {
          availableBalanceInCents,
          pendingBalanceInCents,
          defaultCurrency,
        });
      } catch (balanceError) {
        logger.warn("Could not fetch balance for account", {
          accountId,
          error: balanceError,
        });
      }

      await syncConnectedAccountSnapshot(db, stripe, account, uid, {
        availableBalanceInCents,
        pendingBalanceInCents,
      });

      return {
        chargesEnabled: account.charges_enabled ?? false,
        payoutsEnabled: account.payouts_enabled ?? false,
        detailsSubmitted: account.details_submitted ?? false,
        requirements: account.requirements?.currently_due ?? [],
        disabledReason: account.requirements?.disabled_reason ?? null,
        capabilities: {
          transfers: mapStripeCapabilityStatus(account.capabilities?.transfers),
          cardPayments: mapStripeCapabilityStatus(
            account.capabilities?.card_payments,
          ),
        },
        availableBalance: availableBalanceInCents / 100,
        pendingBalance: pendingBalanceInCents / 100,
        availableBalanceInCents,
        pendingBalanceInCents,
        currency: defaultCurrency.toUpperCase(),
      };
    } catch (error: unknown) {
      if (error instanceof HttpsError) {
        throw error;
      }
      // FIX: Use typed error handling instead of `any`
      const e = error as { message?: string };
      logger.error("getAccountStatus failed", { accountId, error: e.message });
      throw new HttpsError(
        "not-found",
        `Stripe account not found: ${e.message ?? "unknown error"}`,
      );
    }
  },
);

// ============================================
// Stripe: Driver Payout Eligibility
// ============================================

export const getDriverPayoutEligibility = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "getDriverPayoutEligibility",
      20,
      60,
    );

    const db = admin.firestore();
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const requestedStripeAccountId =
      typeof request.data?.stripeAccountId === "string"
        ? request.data.stripeAccountId.trim()
        : "";
    const normalizedCurrency =
      typeof request.data?.currency === "string" &&
      request.data.currency.trim().length > 0
        ? request.data.currency.trim().toLowerCase()
        : DEFAULT_CURRENCY;

    const [callerDoc, connectedAccountDoc] = await Promise.all([
      db.collection("users").doc(request.auth.uid).get(),
      db.collection("driver_connected_accounts").doc(request.auth.uid).get(),
    ]);
    const callerData = callerDoc.data();
    const connectedAccountData = connectedAccountDoc.data();
    const callerStripeAccountId =
      typeof callerData?.stripeAccountId === "string"
        ? callerData.stripeAccountId
        : "";
    const connectedStripeAccountId =
      typeof connectedAccountData?.stripeAccountId === "string"
        ? connectedAccountData.stripeAccountId
        : "";
    const stripeAccountId =
      requestedStripeAccountId || connectedStripeAccountId || callerStripeAccountId;

    if (!callerData || !stripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver must complete Stripe onboarding before payouts are available",
      );
    }

    if (
      stripeAccountId !== callerStripeAccountId &&
      stripeAccountId !== connectedStripeAccountId
    ) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to inspect payouts for this account",
      );
    }

    const eligibility = await getDriverPayoutEligibilitySnapshot(db, stripe, {
      driverId: request.auth.uid,
      stripeAccountId,
      currency: normalizedCurrency,
    });

    try {
      await recomputeDriverStats(db, request.auth.uid);
    } catch (error) {
      logger.warn("getDriverPayoutEligibility: stats recompute failed", {
        driverId: request.auth.uid,
        error,
      });
    }

    return eligibility;
  },
);

// ============================================
// Stripe: Create Instant Payout
// ============================================

export const createInstantPayout = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 5 instant payouts per user per hour
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "createInstantPayout",
      5,
      3600,
    );

    const {
      stripeAccountId,
      amountInCents: requestedAmountInCents,
      amount: legacyAmount,
      currency = "eur",
    } = request.data;
    const normalizedCurrency =
      typeof currency === "string" && currency.trim().length > 0
        ? currency.trim().toLowerCase()
        : "eur";
    const payoutAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)!)
          : undefined;

    if (!stripeAccountId || !payoutAmountInCents || payoutAmountInCents <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "stripeAccountId and a positive amountInCents are required",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    const [callerDoc, connectedAccountDoc] = await Promise.all([
      db.collection("users").doc(request.auth.uid).get(),
      db.collection("driver_connected_accounts").doc(request.auth.uid).get(),
    ]);
    const callerData = callerDoc.data();
    const connectedAccountData = connectedAccountDoc.data();
    const callerStripeAccountId = callerData?.stripeAccountId;
    const connectedStripeAccountId = connectedAccountData?.stripeAccountId;
    if (
      !callerData ||
      (callerStripeAccountId !== stripeAccountId &&
        connectedStripeAccountId !== stripeAccountId)
    ) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorized to create payouts for this account",
      );
    }

    const account = await stripe.accounts
      .retrieve(stripeAccountId, {
        expand: ["external_accounts"],
      })
      .catch((error: unknown) => {
        const e = error as { message?: string };
        logger.error("createInstantPayout: account verification failed", {
          stripeAccountId,
          uid: request.auth?.uid,
          error: e.message,
        });
        throw new HttpsError(
          "not-found",
          `Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      });

    if (!account.payouts_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Payouts are not enabled for this account",
      );
    }

    const externalAccounts = account.external_accounts?.data ?? [];
    if (externalAccounts.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "No payout destination is attached to this Stripe account",
      );
    }

    // Verify at least one external account supports instant payouts.
    // Bank accounts (IBAN) only have available_payout_methods: ["standard"].
    // Eligible debit cards have: ["standard", "instant"].
    // For FR/EUR test mode use card 4000052500000008 (not the US 4000056655665556).
    const instantEligibleAccount = externalAccounts.find(
      (ea) => (ea as unknown as { available_payout_methods?: string[] })
        .available_payout_methods?.includes("instant") === true,
    );
    if (!instantEligibleAccount) {
      throw new HttpsError(
        "failed-precondition",
        "No external account eligible for instant payouts. Add a debit card to enable instant payouts.",
      );
    }

    const balance = await stripe.balance.retrieve(
      {},
      { stripeAccount: stripeAccountId },
    );

    // Instant payouts draw from instant_available, not available.
    const instantAvailableField =
      ((balance as any).instant_available ?? balance.available) as typeof balance.available;

    const availableBalanceInCents = sumBalanceForCurrency(
      instantAvailableField,
      normalizedCurrency,
    );

    if (availableBalanceInCents < payoutAmountInCents) {
      throw new HttpsError(
        "failed-precondition",
        `Insufficient available balance. Available: ${(
          availableBalanceInCents / 100
        ).toFixed(2)} ${normalizedCurrency.toUpperCase()}`,
      );
    }

    const eligibility = await getDriverPayoutEligibilitySnapshot(db, stripe, {
      driverId: request.auth.uid,
      stripeAccountId,
      currency: normalizedCurrency,
      stripeAvailableBalanceInCents: availableBalanceInCents,
    });

    if (eligibility.withdrawableBalanceInCents < payoutAmountInCents) {
      throw new HttpsError(
        "failed-precondition",
        `Only €${(eligibility.withdrawableBalanceInCents / 100).toFixed(2)} is eligible for withdrawal. Ride payments become withdrawable after the ride is completed.`,
      );
    }

    // Include epoch seconds so the same amount can be paid out more than once per day.
    const payoutIdempotencyKey = `payout_${request.auth.uid}_${stripeAccountId}_${payoutAmountInCents}_${normalizedCurrency}_${Math.floor(Date.now() / 1000)}`;

    const payout = await stripe.payouts.create(
      {
        amount: payoutAmountInCents,
        currency: normalizedCurrency,
        method: "instant",
        metadata: {
          driverId: request.auth.uid,
          connectedAccountId: stripeAccountId,
          source: "sportconnect_instant_payout",
        },
      },
      {
        stripeAccount: stripeAccountId,
        idempotencyKey: payoutIdempotencyKey,
      },
    );

    // BUG-CF-04: Guard against duplicate payout docs (idempotency key reuse
    // or webhook race can create two Firestore docs for the same Stripe payout).
    const existingPayoutSnap = await db
      .collection("payouts")
      .where("stripePayoutId", "==", payout.id)
      .limit(1)
      .get();
    if (!existingPayoutSnap.empty) {
      logger.warn("Duplicate payout guard: doc already exists", {
        stripePayoutId: payout.id,
        existingDocId: existingPayoutSnap.docs[0].id,
      });
      return {
        payoutId: existingPayoutSnap.docs[0].id,
        stripePayoutId: payout.id,
        status: payout.status,
        amountInCents: payoutAmountInCents,
        stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
        arrivalDate: payout.arrival_date,
      };
    }

    // Stripe always returns "pending" at payout creation time.
    // The lifecycle is: pending → in_transit → paid (via payout.paid webhook).
    // Map to Dart PayoutStatus enum values: pending, inTransit, paid, failed, cancelled.
    const payoutRef = await db.collection("payouts").add({
      driverId: request.auth.uid,
      driverName:
        (callerData.username as string | undefined) ??
        (callerData.displayName as string | undefined) ??
        (callerData.name as string | undefined) ??
        `${callerData.firstName ?? ""} ${callerData.lastName ?? ""}`.trim(),
      stripePayoutId: payout.id,
      connectedAccountId: stripeAccountId,
      amount: payoutAmountInCents / 100,
      amountInCents: payoutAmountInCents,
      currency: normalizedCurrency,
      status: "pending",
      method: payout.method === "instant" ? "instant" : "standard",
      type: payout.type === "card" ? "card" : "bankAccount",
      destination: stripeObjectId(payout.destination),
      stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
      transactionIds: [],
      isInstantPayout: true,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      expectedArrivalDate: payout.arrival_date
        ? new Date(payout.arrival_date * 1000)
        : null,
    });

    await db
      .collection("driver_connected_accounts")
      .doc(request.auth.uid)
      .set(
        {
          availableBalance: FieldValue.increment(-(payoutAmountInCents / 100)),
          availableBalanceInCents: FieldValue.increment(-payoutAmountInCents),
          lastPayoutAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

    return {
      payoutId: payoutRef.id,
      stripePayoutId: payout.id,
      status: payout.status,
      amountInCents: payoutAmountInCents,
      stripeBalanceTransactionId: stripeObjectId(payout.balance_transaction),
      arrivalDate: payout.arrival_date,
    };
  },
);

// ============================================
// Stripe: Cancel Instant Payout
// ============================================

export const cancelInstantPayout = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { stripePayoutId, payoutDocId } = request.data as {
      stripePayoutId: string;
      payoutDocId: string;
    };

    if (!stripePayoutId || !payoutDocId) {
      throw new HttpsError(
        "invalid-argument",
        "stripePayoutId and payoutDocId are required",
      );
    }

    const db = admin.firestore();
    const stripeSecretKeyVal = stripeSecretKey.value().trim();
    const stripe = getStripeClient(stripeSecretKeyVal);

    // Verify caller owns this payout doc.
    const payoutDoc = await db.collection("payouts").doc(payoutDocId).get();
    if (!payoutDoc.exists) {
      throw new HttpsError("not-found", "Payout not found");
    }
    const payoutData = payoutDoc.data()!;
    if (payoutData.driverId !== request.auth.uid) {
      throw new HttpsError(
        "permission-denied",
        "You do not own this payout",
      );
    }
    if (payoutData.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        `Payout cannot be cancelled in status: ${payoutData.status}`,
      );
    }
    if (payoutData.stripePayoutId !== stripePayoutId) {
      throw new HttpsError(
        "invalid-argument",
        "stripePayoutId does not match payout doc",
      );
    }

    const stripeAccountId = payoutData.connectedAccountId as string;

    const cancelledPayout = await stripe.payouts
      .cancel(stripePayoutId, {}, { stripeAccount: stripeAccountId })
      .catch((error: unknown) => {
        const e = error as { message?: string };
        throw new HttpsError(
          "failed-precondition",
          `Failed to cancel payout: ${e.message ?? "unknown error"}`,
        );
      });

    const cancelBatch = db.batch();
    cancelBatch.update(db.collection("payouts").doc(payoutDocId), {
      status: "cancelled",
      failureReason: "Cancelled by driver",
      updatedAt: FieldValue.serverTimestamp(),
    });
    cancelBatch.set(
      db.collection("driver_connected_accounts").doc(request.auth.uid),
      {
        availableBalance: FieldValue.increment(
          (cancelledPayout.amount ?? payoutData.amountInCents) / 100,
        ),
        availableBalanceInCents: FieldValue.increment(
          cancelledPayout.amount ?? payoutData.amountInCents,
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await cancelBatch.commit();

    return { success: true, status: cancelledPayout.status };
  },
);

// ============================================
// Stripe: Request Automatic Refund
// ============================================

export const requestRefund = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const requestData = asRecord(request.data) ?? {};
    const db = admin.firestore();
    const paymentDocs = await findPaymentDocsForRefundRequest(db, requestData);

    if (paymentDocs.length === 0) {
      throw new HttpsError("not-found", "Payment not found");
    }

    const paymentRef = paymentDocs[0].ref;
    const payment = paymentDocs[0].data();
    const requesterId = request.auth.uid;
    const riderId = stringOrEmpty(payment.riderId) || stringOrEmpty(payment.passengerId);

    if (riderId !== requesterId) {
      throw new HttpsError(
        "permission-denied",
        "Only the rider who paid can request a refund",
      );
    }

    const paymentStatus = stringOrEmpty(payment.status);
    if (paymentStatus === "refunded") {
      throw new HttpsError(
        "failed-precondition",
        "This payment has already been refunded",
      );
    }
    if (paymentStatus === "refunding") {
      throw new HttpsError(
        "failed-precondition",
        "A refund is already being processed for this payment",
      );
    }
    if (!["succeeded", "partiallyRefunded", "refundFailed"].includes(paymentStatus)) {
      throw new HttpsError(
        "failed-precondition",
        "Only completed ride payments can be reviewed for a refund",
      );
    }
    if (!isWithinRefundRequestWindow(payment.createdAt)) {
      throw new HttpsError(
        "failed-precondition",
        `Refund requests must be submitted within ${REFUND_REQUEST_WINDOW_DAYS} days of payment`,
      );
    }

    const paymentIntentId =
      stringOrEmpty(payment.paymentIntentId) ||
      stringOrEmpty(payment.stripePaymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "This payment is missing its Stripe payment reference",
      );
    }

    const reason = stringOrEmpty(requestData.reason) || "other";
    const details = stringOrEmpty(requestData.details).slice(0, 2000);
    const amountInCents = paymentAmountInCents(payment);
    const alreadyRefundedInCents = refundedAmountInCents(payment);
    const remainingAmountInCents = Math.max(0, amountInCents - alreadyRefundedInCents);

    const requestId = `${paymentRef.id}_${requesterId}`;
    const refundRequestRef = db.collection("refund_requests").doc(requestId);
    const existingRequest = await refundRequestRef.get();
    if (existingRequest.exists) {
      const status = stringOrEmpty(existingRequest.data()?.status);
      if (OPEN_REFUND_REQUEST_STATUSES.has(status)) {
        return {
          requestId,
          status,
          alreadyExists: true,
        };
      }
      if (!["notAutomaticallyEligible", "failed"].includes(status)) {
        throw new HttpsError(
          "failed-precondition",
          "This payment already has a reviewed refund request",
        );
      }
    }

    const userSnap = await db.collection("users").doc(requesterId).get();
    const user = userSnap.data() ?? {};
    const requesterEmail =
      stringOrEmpty(user.email) ||
      stringOrEmpty(user.userEmail) ||
      "unknown";
    const rideId = stringOrEmpty(payment.rideId);
    const bookingId = stringOrEmpty(payment.bookingId);
    const driverId = stringOrEmpty(payment.driverId);
    const [rideSnap, bookingSnap] = await Promise.all([
      rideId.length > 0 ? db.collection("rides").doc(rideId).get() : null,
      bookingId.length > 0 ? db.collection("bookings").doc(bookingId).get() : null,
    ]);
    const ride = rideSnap?.data();
    const booking = bookingSnap?.data();
    const policy = isRideObjectivelyRefundable({ reason, ride, booking });

    const metadata = {
      refundRequestId: requestId,
      paymentDocId: paymentRef.id,
      paymentIntentId,
      bookingId,
      rideId,
      driverId,
      requesterId,
      amountInCents,
      remainingAmountInCents,
      reason,
    };

    if (!AUTOMATIC_REFUND_REASONS.has(reason) || !policy.eligible) {
      await refundRequestRef.set({
        ...metadata,
        status: "notAutomaticallyEligible",
        requesterEmail,
        details,
        policyReason: policy.reason,
        paymentStatus,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      throw new HttpsError("failed-precondition", policy.reason);
    }

    await refundRequestRef.set({
      ...metadata,
      status: "refunding",
      requesterEmail,
      details,
      policyReason: policy.reason,
      paymentStatus,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    let refund: StripeRefund;
    try {
      refund = await createStripeRefundForPayment({
        db,
        stripe,
        paymentDocs,
        paymentIntentId,
        reason: policy.reason,
        source: "sportconnect_systematic_refund",
        requestedByUid: requesterId,
        refundRequestId: requestId,
        idempotencyKey: `refund_request_${requestId}`,
      });
    } catch (error) {
      await refundRequestRef.set(
        {
          status: "failed",
          failureReason: error instanceof Error ? error.message : String(error),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      throw error;
    }

    await db.runTransaction(async (txn) => {
      txn.set(refundRequestRef, {
        ...metadata,
        status: "refunding",
        requesterEmail,
        policyReason: policy.reason,
        paymentStatus,
        details,
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        requestedRefundAmountInCents: refund.amount ?? remainingAmountInCents,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
      txn.update(paymentRef, {
        latestRefundRequestId: requestId,
        latestRefundRequestedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    });

    return {
      requestId,
      refundId: refund.id,
      status: refund.status ?? "pending",
      amount: (refund.amount ?? 0) / 100,
      amountInCents: refund.amount ?? 0,
      alreadyExists: false,
    };
  },
);

// ============================================
// Stripe: Refund Payment
// ============================================

export const refundPayment = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError(
        "permission-denied",
        "Refunds must be issued by support or an administrator",
      );
    }

    const {
      paymentIntentId,
      amountInCents: requestedAmountInCents,
      amount: legacyAmount,
      reason = "requested_by_customer",
      refundRequestId,
      idempotencyKey,
    } = request.data;

    if (!paymentIntentId) {
      throw new HttpsError("invalid-argument", "paymentIntentId is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    const paymentDocs = await findPaymentDocsByPaymentIntent(db, paymentIntentId);

    if (paymentDocs.length === 0) {
      throw new HttpsError("not-found", "Payment not found");
    }

    const refundAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)! * 100)
          : undefined;

    if (refundAmountInCents !== undefined && refundAmountInCents <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "amountInCents must be greater than zero",
      );
    }

    const paymentRef = paymentDocs[0].ref;
    let claimedPayment: DocumentData = paymentDocs[0].data();
    let amountToRefundInCents = refundAmountInCents ?? 0;
    try {
      await db.runTransaction(async (txn) => {
        const snap = await txn.get(paymentRef);
        if (!snap.exists) throw new Error("payment_not_found");
        const data = snap.data()!;
        const currentStatus = stringOrEmpty(data.status);
        if (currentStatus === "refunded") {
          throw new Error("already_refunded");
        }
        // "refunding" + stripeRefundId = Stripe accepted it, block duplicate
        // "refunding" without stripeRefundId = previous attempt failed, allow retry
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

        const originalAmount = paymentAmountInCents(data);
        const remainingAmount = Math.max(
          0,
          originalAmount - refundedAmountInCents(data),
        );
        amountToRefundInCents = refundAmountInCents ?? remainingAmount;
        if (amountToRefundInCents <= 0) {
          throw new Error("already_refunded");
        }
        if (amountToRefundInCents > remainingAmount) {
          throw new Error("invalid_refund_amount");
        }

        claimedPayment = data;
        txn.update(paymentRef, {
          status: "refunding",
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
        bookingId:
          typeof claimedPayment.bookingId === "string"
            ? claimedPayment.bookingId
            : "",
        driverId:
          typeof claimedPayment.driverId === "string"
            ? claimedPayment.driverId
            : "",
        riderId:
          typeof claimedPayment.riderId === "string"
            ? claimedPayment.riderId
            : "",
        refundReason,
        source: "sportconnect_manual_refund",
      },
    };

    const originalAmountInCents = paymentAmountInCents(claimedPayment);
    if (amountToRefundInCents < originalAmountInCents) {
      refundParams.amount = amountToRefundInCents;
    }

    const stableIdempotencyKey =
      stringOrEmpty(idempotencyKey) ||
      (stringOrEmpty(refundRequestId).length > 0
        ? `refund_request_${stringOrEmpty(refundRequestId)}`
        : `manual_refund_${paymentIntentId}_${amountToRefundInCents}_${request.auth.uid}_${Date.now()}`);

    let refund: StripeRefund;
    try {
      refund = await stripe.refunds.create(refundParams, {
        idempotencyKey: stableIdempotencyKey,
      });
    } catch (stripeError) {
      // Stripe rejected the refund — roll back to "succeeded" so it can be retried
      await paymentRef.update({
        status: stringOrEmpty(claimedPayment.status) || "succeeded",
        updatedAt: FieldValue.serverTimestamp(),
      }).catch(() => { /* best-effort */ });
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
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    const requestId = stringOrEmpty(refundRequestId);
    if (requestId.length > 0) {
      await db.collection("refund_requests").doc(requestId).set(
        {
          status: "refunding",
          stripeRefundId: refund.id,
          stripeRefundStatus: refund.status ?? "pending",
          reviewedByUid: request.auth.uid,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    return {
      refundId: refund.id,
      status: refund.status,
      amount: (refund.amount ?? 0) / 100,
      amountInCents: refund.amount ?? 0,
    };
  },
);

// ============================================
// Admin: Resolve Refund / Dispute / Support Issues
// ============================================

export const approveRefundRequest = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError("permission-denied", "Admin access required");
    }

    const requestData = asRecord(request.data) ?? {};
    const refundRequestId = stringOrEmpty(requestData.refundRequestId);
    const amountInCents =
      finiteNumber(requestData.amountInCents) !== undefined
        ? Math.round(finiteNumber(requestData.amountInCents)!)
        : undefined;

    if (refundRequestId.length === 0) {
      throw new HttpsError("invalid-argument", "refundRequestId is required");
    }

    const db = admin.firestore();
    const refundRequestRef = db.collection("refund_requests").doc(refundRequestId);
    const refundRequestSnap = await refundRequestRef.get();
    if (!refundRequestSnap.exists) {
      throw new HttpsError("not-found", "Refund request not found");
    }

    const refundRequest = refundRequestSnap.data()!;
    const paymentIntentId = stringOrEmpty(refundRequest.paymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Refund request is missing paymentIntentId",
      );
    }

    const paymentDocs = await findPaymentDocsByPaymentIntent(db, paymentIntentId);
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const refund = await createStripeRefundForPayment({
      db,
      stripe,
      paymentDocs,
      paymentIntentId,
      amountInCents,
      reason: stringOrEmpty(requestData.reason) || stringOrEmpty(refundRequest.reason) || "requested_by_customer",
      source: "sportconnect_admin_refund",
      requestedByUid: request.auth.uid,
      refundRequestId,
      idempotencyKey: `admin_refund_${refundRequestId}_${amountInCents ?? "remaining"}`,
    });

    await refundRequestRef.set(
      {
        status: "refunding",
        reviewedByUid: request.auth.uid,
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        requestedRefundAmountInCents: refund.amount ?? amountInCents ?? null,
        resolutionNote: stringOrEmpty(requestData.note),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      refundId: refund.id,
      status: refund.status,
      amountInCents: refund.amount ?? 0,
    };
  },
);

export const rejectRefundRequest = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const refundRequestId = stringOrEmpty(requestData.refundRequestId);
  if (refundRequestId.length === 0) {
    throw new HttpsError("invalid-argument", "refundRequestId is required");
  }

  await admin.firestore().collection("refund_requests").doc(refundRequestId).set(
    {
      status: "rejected",
      reviewedByUid: request.auth.uid,
      resolutionNote: stringOrEmpty(requestData.note),
      resolvedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true };
});

export const resolveSupportTicket = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const ticketId = stringOrEmpty(requestData.ticketId);
  if (ticketId.length === 0) {
    throw new HttpsError("invalid-argument", "ticketId is required");
  }

  await admin.firestore().collection("support_tickets").doc(ticketId).set(
    {
      status: "resolved",
      resolvedByUid: request.auth.uid,
      resolutionNote: stringOrEmpty(requestData.note),
      resolvedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true };
});

export const rejectDispute = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  if (!isRefundOperator(request.auth)) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  const requestData = asRecord(request.data) ?? {};
  const disputeId = stringOrEmpty(requestData.disputeId);
  if (disputeId.length === 0) {
    throw new HttpsError("invalid-argument", "disputeId is required");
  }

  await admin.firestore().collection("disputes").doc(disputeId).set(
    {
      status: "closed",
      resolution: stringOrEmpty(requestData.note) || "Closed without refund",
      resolvedByUid: request.auth.uid,
      resolvedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true };
});

export const approveDisputeRefund = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }
    if (!isRefundOperator(request.auth)) {
      throw new HttpsError("permission-denied", "Admin access required");
    }

    const requestData = asRecord(request.data) ?? {};
    const disputeId = stringOrEmpty(requestData.disputeId);
    const amountInCents =
      finiteNumber(requestData.amountInCents) !== undefined
        ? Math.round(finiteNumber(requestData.amountInCents)!)
        : undefined;
    if (disputeId.length === 0) {
      throw new HttpsError("invalid-argument", "disputeId is required");
    }

    const db = admin.firestore();
    const disputeRef = db.collection("disputes").doc(disputeId);
    const disputeSnap = await disputeRef.get();
    if (!disputeSnap.exists) {
      throw new HttpsError("not-found", "Dispute not found");
    }

    const dispute = disputeSnap.data()!;
    const rideId = stringOrEmpty(dispute.rideId);
    const riderId =
      stringOrEmpty(dispute.complainantId) || stringOrEmpty(dispute.userId);
    if (rideId.length === 0 || riderId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Dispute is missing ride or complainant data",
      );
    }

    let paymentsSnap = await db
      .collection("payments")
      .where("rideId", "==", rideId)
      .where("riderId", "==", riderId)
      .limit(1)
      .get();
    if (paymentsSnap.empty) {
      paymentsSnap = await db
        .collection("payments")
        .where("rideId", "==", rideId)
        .where("passengerId", "==", riderId)
        .limit(1)
        .get();
    }
    if (paymentsSnap.empty) {
      throw new HttpsError("not-found", "No payment found for this dispute");
    }

    const paymentDoc = paymentsSnap.docs[0];
    const payment = paymentDoc.data();
    const paymentIntentId =
      stringOrEmpty(payment.paymentIntentId) ||
      stringOrEmpty(payment.stripePaymentIntentId);
    if (paymentIntentId.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Payment is missing paymentIntentId",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const refund = await createStripeRefundForPayment({
      db,
      stripe,
      paymentDocs: [paymentDoc],
      paymentIntentId,
      amountInCents,
      reason: "dispute_resolution",
      source: "sportconnect_dispute_refund",
      requestedByUid: request.auth.uid,
      idempotencyKey: `dispute_refund_${disputeId}_${amountInCents ?? "remaining"}`,
    });

    await disputeRef.set(
      {
        status: "resolved",
        resolution: stringOrEmpty(requestData.note) || "Refund approved",
        resolvedByUid: request.auth.uid,
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return {
      refundId: refund.id,
      status: refund.status,
      amountInCents: refund.amount ?? 0,
    };
  },
);

// ============================================
// Stripe: Get or Create Customer
// ============================================

export const getOrCreateCustomer = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 10 calls per user per 60 s
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "getOrCreateCustomer",
      10,
      60,
    );

    const { email, name, phone, existingCustomerId } = request.data;

    if (!email) {
      throw new HttpsError("invalid-argument", "Email is required");
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();
    const userId = request.auth.uid;

    if (existingCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(existingCustomerId);
        if (!existing.deleted) {
          return { customerId: existingCustomerId };
        }
      } catch {
        logger.info("Existing customer not found, creating new one");
      }
    }

    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();
    if (userData?.stripeCustomerId) {
      try {
        const existing = await stripe.customers.retrieve(
          userData.stripeCustomerId,
        );
        if (!existing.deleted) {
          return { customerId: userData.stripeCustomerId };
        }
      } catch {
        logger.info("Stored customer ID invalid, creating new one");
      }
    }

    const customer = await stripe.customers.create({
      email,
      ...(name && { name }),
      ...(phone && { phone }),
      metadata: { userId },
    });

    await db.collection("users").doc(userId).update({
      stripeCustomerId: customer.id,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { customerId: customer.id };
  },
);

// ============================================
// Stripe: Create Payment Intent
// ============================================

export const createPaymentIntent = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 10 payment intents per user per 60 s
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "createPaymentIntent",
      10,
      60,
    );

    const {
      amount: legacyAmount,
      amountInCents: requestedAmountInCents,
      rideId,
      driverId,
      riderId,
      riderName,
      driverName,
      driverStripeAccountId,
      description,
      customerId,
      stripeApiVersion,
    } = request.data;

    if (
      finiteNumber(requestedAmountInCents) === undefined &&
      finiteNumber(legacyAmount) === undefined
    ) {
      throw new HttpsError("invalid-argument", "amountInCents is required");
    }

    if (!rideId || !driverId || !riderId) {
      throw new HttpsError("invalid-argument", "Missing required fields");
    }

    if (!driverStripeAccountId) {
      throw new HttpsError(
        "failed-precondition",
        "Driver has not set up Stripe Connect account. Payment cannot be processed.",
      );
    }

    // FIX CF-1: Verify the authenticated caller is actually a passenger on
    // this booking.  Without this check any authenticated user who knows a
    // rideId can initiate a payment charge.
    if (request.auth.uid !== riderId) {
      throw new HttpsError(
        "permission-denied",
        "You are not authorised to pay for this booking",
      );
    }

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // FIX P-4: Ignore the client-supplied `amount` and recompute the price
    // server-side from the canonical ride document.  A modified client could
    // otherwise request a €0.01 charge instead of the real fare.
    const rideDoc = await db.collection("rides").doc(rideId).get();
    if (!rideDoc.exists) {
      throw new HttpsError("not-found", "Ride not found");
    }
    const rideData = rideDoc.data()!;
    if (rideData.status !== "active" && rideData.status !== "inProgress") {
      throw new HttpsError(
        "failed-precondition",
        "Ride is no longer available for payment",
      );
    }
    // Payment happens only after driver acceptance; requesting a seat and
    // paying for an accepted seat are separate domain states.
    const bookingsSnap = await db
      .collection("bookings")
      .where("rideId", "==", rideId)
      .where("passengerId", "==", riderId)
      .where("status", "==", "accepted")
      .limit(1)
      .get();
    if (bookingsSnap.empty) {
      throw new HttpsError(
        "failed-precondition",
        "No accepted booking found for this ride",
      );
    }
    const bookingId = bookingsSnap.docs[0].id;
    const bookingData = bookingsSnap.docs[0].data();
    if (bookingData.paidAt || bookingData.paymentIntentId) {
      throw new HttpsError(
        "failed-precondition",
        "This booking has already been paid",
      );
    }
    const seatsBooked = (bookingData.seatsBooked as number) ?? 1;
    const pricePerSeatInCents = getRidePricePerSeatInCents(rideData);
    const requestAmountInCents =
      finiteNumber(requestedAmountInCents) !== undefined
        ? Math.round(finiteNumber(requestedAmountInCents)!)
        : finiteNumber(legacyAmount) !== undefined
          ? Math.round(finiteNumber(legacyAmount)!)
          : Number.NaN;
    const amountInCents =
      pricePerSeatInCents !== undefined
        ? pricePerSeatInCents * seatsBooked
        : requestAmountInCents;

    if (!Number.isFinite(amountInCents) || amountInCents <= 0) {
      throw new HttpsError(
        "failed-precondition",
        "Ride price could not be calculated",
      );
    }

    const paymentCurrency = "eur";

    // FIX: Moved charges_enabled check OUTSIDE the try/catch to preserve
    // the meaningful error message. The original swallowed it into a generic catch.
    const account = await stripe.accounts
      .retrieve(driverStripeAccountId)
      .catch((error: unknown) => {
        const e = error as { message?: string };
        logger.error("Error retrieving Stripe account:", {
          driverStripeAccountId,
          driverId,
          error: e.message,
        });
        throw new HttpsError(
          "failed-precondition",
          `Driver's Stripe account verification failed: ${e.message ?? "unknown error"}`,
        );
      });

    // BUG-CF-02: Verify caller-supplied driverStripeAccountId belongs to driverId.
    // Without this check, a rider could substitute another driver's account ID
    // and route charges through it.
    const accountOwnerSnap = await db
      .collection("driver_connected_accounts")
      .where("driverId", "==", driverId)
      .where("stripeAccountId", "==", driverStripeAccountId)
      .limit(1)
      .get();
    if (accountOwnerSnap.empty) {
      logger.error("Ownership check failed: stripeAccountId not owned by driver", {
        driverId,
        driverStripeAccountId,
      });
      throw new HttpsError(
        "permission-denied",
        "The provided Stripe account does not belong to this driver.",
      );
    }

    if (!account.charges_enabled) {
      throw new HttpsError(
        "failed-precondition",
        "Driver's Stripe account is not fully activated. Charges are not enabled.",
      );
    }

    if (!account.payouts_enabled) {
      logger.warn(
        `Driver ${driverId} has charges enabled but payouts disabled`,
      );
    }

    // Use the server-computed amount (P-4) so the client cannot manipulate the charge.
    const { platformFee, driverAmount } = calculateFees(amountInCents);

    const idempotencyKey = `pi_${bookingId}_${amountInCents}`;

    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: amountInCents,
        currency: paymentCurrency,
        automatic_payment_methods: { enabled: true },
        description: description || `SportConnect ride payment - ${rideId}`,
        metadata: {
          rideId,
          driverId,
          riderId,
          bookingId,
          moneyFlow: "platform_held",
          driverStripeAccountId,
          platformFeeInCents: String(platformFee),
          driverAmountInCents: String(driverAmount),
        },
      },
      { idempotencyKey },
    );

    const paymentRef = db.collection("payments").doc(paymentIntent.id);
    const existingPaymentDoc = await paymentRef.get();
    if (!existingPaymentDoc.exists) {
      await paymentRef.set({
        paymentIntentId: paymentIntent.id,
        stripePaymentIntentId: paymentIntent.id,
        bookingId,
        rideId,
        driverId,
        riderId,
        riderName: riderName || "",
        driverName: driverName || "",
        driverStripeAccountId,
        amount: amountInCents / 100,
        amountInCents,
        currency: paymentCurrency,
        platformFee: platformFee / 100,
        platformFeeInCents: platformFee,
        driverEarnings: driverAmount / 100,
        driverEarningsInCents: driverAmount,
        moneyFlow: "platform_held",
        payoutStatus: "pending_completion",
        transferStatus: "not_transferred",
        earnedAt: null,
        transferredAt: null,
        stripeFee: 0,
        stripeFeeInCents: 0,
        seatsBooked,
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // FIX: The ephemeral key apiVersion MUST be the version required by the
    // Flutter stripe SDK (client-side), NOT the server API version.
    // The client passes its required version as `stripeApiVersion`.
    // Stripe enforces that ephemeral keys must be created with the client's version.
    let ephemeralKey: string | undefined;
    if (customerId) {
      const ephemeralKeyVersion = stripeApiVersion || "2026-04-22.dahlia";
      const ephemeralKeyObj = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: ephemeralKeyVersion },
      );
      ephemeralKey = ephemeralKeyObj.secret;
    }

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      ...(ephemeralKey && { ephemeralKey }),
    };
  },
);

// ============================================
// Stripe: Webhook Handler
// ============================================

export const stripeWebhook = onRequest(
  // FIX: Webhooks do NOT need cors:true — they are called by Stripe, not by browsers.
  // Enabling CORS on a webhook can expose it unnecessarily.
  { secrets: [stripeSecretKey, stripeWebhookSecret] },
  async (req, res) => {
    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const sig = req.headers["stripe-signature"];

    if (!sig) {
      res.status(400).json({ error: "Missing Stripe signature" });
      return;
    }

    let event: StripeEvent;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        stripeWebhookSecret.value(),
      );
      logger.info("stripeWebhook received event", {
        type: event.type,
        id: event.id,
        account: event.account ?? "platform",
        livemode: event.livemode,
      });
    } catch (err) {
      logger.error("Webhook signature verification failed:", err);
      res.status(400).json({ error: "Invalid signature" });
      return;
    }

    const db = admin.firestore();
    const webhookEventRef = db.collection("_stripeWebhookEvents").doc(event.id);

    const alreadyProcessed = await db.runTransaction(async (tx) => {
      const existing = await tx.get(webhookEventRef);

      if (existing.exists && existing.data()?.status === "processed") {
        return true;
      }

      tx.set(
        webhookEventRef,
        {
          eventId: event.id,
          eventType: event.type,
          livemode: event.livemode,
          account: event.account ?? null,
          status: "processing",
          processingStartedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return false;
    });

    if (alreadyProcessed) {
      res.status(200).json({ received: true, duplicate: true });
      return;
    }
    try {
      switch (event.type) {
        case "transfer.reversed": {
          const reversal = event.data.object as unknown as StripeTransferReversal;
          const transferId = stripeObjectId(reversal.transfer);

          if (!transferId) {
            logger.warn("transfer.reversed missing transfer id", {
              reversalId: reversal.id,
            });
            break;
          }

          const paymentsSnap = await db
            .collection("payments")
            .where("stripeTransferId", "==", transferId)
            .get();

          for (const doc of paymentsSnap.docs) {
            await doc.ref.update({
              stripeTransferReversalId: reversal.id,
              stripeTransferReversedAmountInCents: reversal.amount,
              stripeTransferReversedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });
          }

          break;
        }
        case "payout.canceled": {
          const po = event.data.object as StripePayout;
          const connectedAccountId = event.account ?? null;

          const payoutsSnap = await db
            .collection("payouts")
            .where("stripePayoutId", "==", po.id)
            .get();

          for (const doc of payoutsSnap.docs) {
            const data = doc.data();

            if (
              connectedAccountId &&
              data.connectedAccountId &&
              data.connectedAccountId !== connectedAccountId
            ) {
              logger.warn(
                "Ignoring payout.canceled for mismatched connected account",
                {
                  payoutDocId: doc.id,
                  stripePayoutId: po.id,
                  docConnectedAccountId: data.connectedAccountId,
                  eventConnectedAccountId: connectedAccountId,
                },
              );
              continue;
            }

            const wasAlreadyFailedOrCancelled =
              data.status === "failed" || data.status === "cancelled";

            const driverId =
              typeof data.driverId === "string"
                ? data.driverId
                : await findDriverIdForConnectedAccount(
                    db,
                    connectedAccountId ?? undefined,
                  );

            // BUG-CF-06: Atomic batch — payout status + balance restore together.
            const cancelBatch = db.batch();
            cancelBatch.update(doc.ref, {
              status: "cancelled",
              amountInCents: po.amount,
              amount: po.amount / 100,
              currency: po.currency,
              method: po.method === "instant" ? "instant" : "standard",
              type: po.type === "card" ? "card" : "bankAccount",
              destination: stripeObjectId(po.destination),
              stripeBalanceTransactionId: stripeObjectId(
                po.balance_transaction,
              ),
              failureReason: po.failure_message ?? "Payout was cancelled",
              failureCode: po.failure_code ?? null,
              updatedAt: FieldValue.serverTimestamp(),
            });

            if (driverId && !wasAlreadyFailedOrCancelled) {
              cancelBatch.set(
                db.collection("driver_connected_accounts").doc(driverId),
                {
                  availableBalance: FieldValue.increment(po.amount / 100),
                  availableBalanceInCents: FieldValue.increment(po.amount),
                  updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true },
              );
            }
            await cancelBatch.commit();

            if (driverId && !wasAlreadyFailedOrCancelled) {
              await sendPushToUser(
                driverId,
                "Payout Cancelled",
                "Your payout was cancelled and the amount has been returned to your available balance.",
                { type: "stripe", referenceId: driverId },
              );
            }
          }

          break;
        }
        case "payout.failed": {
          const po = event.data.object as StripePayout;
          const connectedAccountId = event.account ?? null;

          const payoutsSnap = await db
            .collection("payouts")
            .where("stripePayoutId", "==", po.id)
            .get();

          for (const doc of payoutsSnap.docs) {
            const data = doc.data();

            if (
              connectedAccountId &&
              data.connectedAccountId &&
              data.connectedAccountId !== connectedAccountId
            ) {
              logger.warn(
                "Ignoring payout.failed for mismatched connected account",
                {
                  payoutDocId: doc.id,
                  stripePayoutId: po.id,
                  docConnectedAccountId: data.connectedAccountId,
                  eventConnectedAccountId: connectedAccountId,
                },
              );
              continue;
            }

            const wasAlreadyFailedOrCancelled =
              data.status === "failed" || data.status === "cancelled";

            const driverId =
              typeof data.driverId === "string"
                ? data.driverId
                : await findDriverIdForConnectedAccount(
                    db,
                    connectedAccountId ?? undefined,
                  );

            // BUG-CF-06: Atomic batch — payout status + balance restore together.
            const failedBatch = db.batch();
            failedBatch.update(doc.ref, {
              status: "failed",
              amountInCents: po.amount,
              amount: po.amount / 100,
              currency: po.currency,
              method: po.method === "instant" ? "instant" : "standard",
              type: po.type === "card" ? "card" : "bankAccount",
              destination: stripeObjectId(po.destination),
              stripeBalanceTransactionId: stripeObjectId(
                po.balance_transaction,
              ),
              failureReason: po.failure_message ?? "Payout failed",
              failureCode: po.failure_code ?? null,
              updatedAt: FieldValue.serverTimestamp(),
            });

            if (driverId && !wasAlreadyFailedOrCancelled) {
              failedBatch.set(
                db.collection("driver_connected_accounts").doc(driverId),
                {
                  availableBalance: FieldValue.increment(po.amount / 100),
                  availableBalanceInCents: FieldValue.increment(po.amount),
                  updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true },
              );
            }
            await failedBatch.commit();

            if (driverId && !wasAlreadyFailedOrCancelled) {
              await sendPushToUser(
                driverId,
                "Payout Failed",
                "Your payout could not be processed. Please check your bank details in the app.",
                { type: "stripe", referenceId: driverId },
              );
            }
          }

          break;
        }
        case "payout.updated": {
          const po = event.data.object as StripePayout;
          const connectedAccountId = event.account ?? null;

          const payoutsSnap = await db
            .collection("payouts")
            .where("stripePayoutId", "==", po.id)
            .get();

          const mappedStatus = mapPayoutStatus(po.status);

          for (const doc of payoutsSnap.docs) {
            const data = doc.data();

            if (
              connectedAccountId &&
              data.connectedAccountId &&
              data.connectedAccountId !== connectedAccountId
            ) {
              logger.warn(
                "Ignoring payout.updated for mismatched connected account",
                {
                  payoutDocId: doc.id,
                  stripePayoutId: po.id,
                  docConnectedAccountId: data.connectedAccountId,
                  eventConnectedAccountId: connectedAccountId,
                },
              );
              continue;
            }

            await doc.ref.update({
              status: mappedStatus,
              amountInCents: po.amount,
              amount: po.amount / 100,
              currency: po.currency,
              method: po.method === "instant" ? "instant" : "standard",
              type: po.type === "card" ? "card" : "bankAccount",
              destination: stripeObjectId(po.destination),
              stripeBalanceTransactionId: stripeObjectId(
                po.balance_transaction,
              ),
              updatedAt: FieldValue.serverTimestamp(),
              ...(po.status === "paid" && {
                arrivedAt: FieldValue.serverTimestamp(),
              }),
              ...(po.status === "failed" && {
                failureReason: po.failure_message ?? "Payout failed",
                failureCode: po.failure_code ?? null,
              }),
            });
          }

          break;
        }
        case "payout.paid": {
          const po = event.data.object as StripePayout;
          const connectedAccountId = event.account ?? null;

          const payoutsSnap = await db
            .collection("payouts")
            .where("stripePayoutId", "==", po.id)
            .get();

          for (const doc of payoutsSnap.docs) {
            const data = doc.data();

            if (
              connectedAccountId &&
              data.connectedAccountId &&
              data.connectedAccountId !== connectedAccountId
            ) {
              logger.warn(
                "Ignoring payout.paid for mismatched connected account",
                {
                  payoutDocId: doc.id,
                  stripePayoutId: po.id,
                  docConnectedAccountId: data.connectedAccountId,
                  eventConnectedAccountId: connectedAccountId,
                },
              );
              continue;
            }

            await doc.ref.update({
              status: "paid",
              amountInCents: po.amount,
              amount: po.amount / 100,
              currency: po.currency,
              method: po.method === "instant" ? "instant" : "standard",
              type: po.type === "card" ? "card" : "bankAccount",
              destination: stripeObjectId(po.destination),
              stripeBalanceTransactionId: stripeObjectId(
                po.balance_transaction,
              ),
              arrivedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });

            // BUG-CF-05: Notify driver on successful payout arrival.
            const paidDriverId =
              typeof data.driverId === "string"
                ? data.driverId
                : await findDriverIdForConnectedAccount(
                    db,
                    connectedAccountId ?? undefined,
                  );
            if (paidDriverId) {
              await sendPushToUser(
                paidDriverId,
                "Payout Successful",
                `Your payout of €${(po.amount / 100).toFixed(2)} has arrived in your bank account.`,
                { type: "stripe", referenceId: paidDriverId },
              );
            }
          }

          break;
        }
        case "payout.created": {
          const po = event.data.object as StripePayout;
          const connectedAccountId = event.account ?? null;

          const existing = await db
            .collection("payouts")
            .where("stripePayoutId", "==", po.id)
            .limit(1)
            .get();

          if (!existing.empty) {
            break;
          }

          const driverId =
            typeof po.metadata?.driverId === "string" &&
            po.metadata.driverId.length > 0
              ? po.metadata.driverId
              : await findDriverIdForConnectedAccount(
                  db,
                  connectedAccountId ?? undefined,
                );

          if (!driverId) {
            logger.warn("payout.created could not resolve driverId", {
              payoutId: po.id,
              connectedAccountId,
            });
            break;
          }

          await db.collection("payouts").add({
            driverId,
            driverName: "",
            stripePayoutId: po.id,
            connectedAccountId,
            amount: po.amount / 100,
            amountInCents: po.amount,
            currency: po.currency,
            status: mapPayoutStatus(po.status),
            method: po.method === "instant" ? "instant" : "standard",
            type: po.type === "card" ? "card" : "bankAccount",
            destination: stripeObjectId(po.destination),
            stripeBalanceTransactionId: stripeObjectId(po.balance_transaction),
            transactionIds: [],
            isInstantPayout: po.method === "instant",
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
            expectedArrivalDate: po.arrival_date
              ? new Date(po.arrival_date * 1000)
              : null,
            metadata: {
              createdFromWebhook: true,
              stripeWebhookEventId: event.id,
            },
          });

          break;
        }
        case "charge.refunded": {
          const charge = event.data.object as StripeCharge;
          const paymentIntentId = stripeObjectId(charge.payment_intent);

          if (!paymentIntentId) {
            logger.warn("charge.refunded missing payment_intent", {
              chargeId: charge.id,
            });
            break;
          }

          const paymentDocs = await findPaymentDocsByPaymentIntent(
            db,
            paymentIntentId,
          );

          const isFullRefund =
            (charge.amount_refunded ?? 0) >=
            (charge.amount ?? Number.MAX_SAFE_INTEGER);

          for (const doc of paymentDocs) {
            const data = doc.data();

            await doc.ref.update({
              status: isFullRefund ? "refunded" : "partiallyRefunded",
              stripeChargeId: charge.id,
              refundAmountInCents: charge.amount_refunded ?? 0,
              stripeRefundStatus: "succeeded",
              refundedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });

            const bookingId =
              typeof data.bookingId === "string" && data.bookingId.length > 0
                ? data.bookingId
                : null;

            if (bookingId) {
              await db.collection("bookings").doc(bookingId).set(
                {
                  paymentStatus: isFullRefund ? "refunded" : "partiallyRefunded",
                  updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true },
              );
            }

            const driverId =
              typeof data.driverId === "string" ? data.driverId : null;
            if (driverId) {
              await recomputeDriverStats(db, driverId);
            }
          }

          break;
        }
        case "refund.updated":
        case "refund.failed": {
          const refund = event.data.object as StripeRefund;
          const paymentIntentId = getPaymentIntentIdFromRefund(refund);

          if (!paymentIntentId) {
            logger.warn("refund.updated missing payment_intent", {
              refundId: refund.id,
            });
            break;
          }

          const paymentDocs = await findPaymentDocsByPaymentIntent(
            db,
            paymentIntentId,
          );

          for (const doc of paymentDocs) {
            const data = doc.data();
            const originalAmountInCents =
              finiteNumber(data.amountInCents) ??
              Math.round((finiteNumber(data.amount) ?? 0) * 100);

            const nextStatus = mapRefundStatusToPaymentStatus(refund, originalAmountInCents);

            await doc.ref.update({
              status: nextStatus,
              stripeRefundId: refund.id,
              stripeRefundStatus: refund.status ?? "unknown",
              ...(refund.status === "succeeded"
                ? { refundAmountInCents: refund.amount }
                : { requestedRefundAmountInCents: refund.amount }),
              refundedAt:
                refund.status === "succeeded"
                  ? FieldValue.serverTimestamp()
                  : (data.refundedAt ?? null),
              failureReason:
                refund.status === "failed"
                  ? "Stripe refund failed"
                  : FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            });

            const bookingId =
              typeof data.bookingId === "string" && data.bookingId.length > 0
                ? data.bookingId
                : null;

            if (bookingId) {
              await db
                .collection("bookings")
                .doc(bookingId)
                .set(
                  {
                    paymentStatus: nextStatus,
                    updatedAt: FieldValue.serverTimestamp(),
                  },
                  { merge: true },
                );
            }

            const driverId =
              typeof data.driverId === "string" ? data.driverId : null;
            if (driverId && refund.status === "succeeded") {
              await recomputeDriverStats(db, driverId);
            }

            const riderId =
              typeof data.riderId === "string"
                ? data.riderId
                : typeof data.passengerId === "string"
                  ? data.passengerId
                  : null;

            if (riderId && refund.status === "failed") {
              await sendPushToUser(
                riderId,
                "Refund Failed",
                "Your refund could not be completed. Please contact support.",
                { type: "payment", referenceId: paymentIntentId },
              );
            }

            const refundRequestId = stringOrEmpty(data.latestRefundRequestId);
            if (refundRequestId.length > 0) {
              await db.collection("refund_requests").doc(refundRequestId).set(
                {
                  status: nextStatus,
                  stripeRefundId: refund.id,
                  stripeRefundStatus: refund.status ?? "unknown",
                  ...(refund.status === "succeeded"
                    ? { refundAmountInCents: refund.amount }
                    : { requestedRefundAmountInCents: refund.amount }),
                  updatedAt: FieldValue.serverTimestamp(),
                  ...(refund.status === "succeeded" && {
                    resolvedAt: FieldValue.serverTimestamp(),
                  }),
                },
                { merge: true },
              );
            }
          }

          break;
        }
        case "refund.created": {
          const refund = event.data.object as StripeRefund;
          const paymentIntentId = getPaymentIntentIdFromRefund(refund);

          if (!paymentIntentId) {
            logger.warn("refund.created missing payment_intent", {
              refundId: refund.id,
            });
            break;
          }

          const paymentDocs = await findPaymentDocsByPaymentIntent(
            db,
            paymentIntentId,
          );

          for (const doc of paymentDocs) {
            await doc.ref.update({
              status: "refunding",
              stripeRefundId: refund.id,
              stripeRefundStatus: refund.status ?? "pending",
              refundAmountInCents: refund.amount,
              updatedAt: FieldValue.serverTimestamp(),
            });
          }

          break;
        }
        case "payment_intent.canceled": {
          const pi = event.data.object as StripePaymentIntent;
          const paymentDocs = await findPaymentDocsByPaymentIntent(db, pi.id);

          for (const doc of paymentDocs) {
            const data = doc.data();

            await doc.ref.update({
              status: "cancelled",
              failureReason:
                pi.cancellation_reason ??
                "PaymentIntent was cancelled by Stripe",
              updatedAt: FieldValue.serverTimestamp(),
            });

            const bookingId =
              typeof data.bookingId === "string" && data.bookingId.length > 0
                ? data.bookingId
                : pi.metadata?.bookingId;

            if (bookingId) {
              await db.collection("bookings").doc(bookingId).set(
                {
                  paymentStatus: "cancelled",
                  updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true },
              );
            }
          }

          break;
        }
        case "payment_intent.processing": {
          const pi = event.data.object as StripePaymentIntent;
          const paymentDocs = await findPaymentDocsByPaymentIntent(db, pi.id);

          for (const doc of paymentDocs) {
            await doc.ref.update({
              status: "processing",
              updatedAt: FieldValue.serverTimestamp(),
            });
          }

          break;
        }
        case "payment_intent.succeeded": {
          const pi = event.data.object as StripePaymentIntent;
          const rideId = pi.metadata?.rideId;
          const riderId = pi.metadata?.riderId;
          const driverId = pi.metadata?.driverId;
          const bookingId = pi.metadata?.bookingId;

          let payments = await db
            .collection("payments")
            .where("paymentIntentId", "==", pi.id)
            .get();
          if (payments.empty) {
            payments = await db
              .collection("payments")
              .where("stripePaymentIntentId", "==", pi.id)
              .get();
          }

          if (payments.empty && rideId && riderId && driverId) {
            const amountInCents =
              finiteNumber(pi.amount_received) ?? finiteNumber(pi.amount) ?? 0;
            const { platformFee, driverAmount } = calculateFees(amountInCents);
            await db
              .collection("payments")
              .doc(pi.id)
              .set(
                {
                  paymentIntentId: pi.id,
                  stripePaymentIntentId: pi.id,
                  bookingId: bookingId ?? "",
                  rideId,
                  driverId,
                  riderId,
                  riderName: "",
                  driverName: "",
                  amount: amountInCents / 100,
                  amountInCents,
                  currency: pi.currency ?? "eur",
                  platformFee: platformFee / 100,
                  platformFeeInCents: platformFee,
                  driverEarnings: driverAmount / 100,
                  driverEarningsInCents: driverAmount,
                  stripeFee: 0,
                  stripeFeeInCents: 0,
                  status: "pending",
                  createdAt: FieldValue.serverTimestamp(),
                  updatedAt: FieldValue.serverTimestamp(),
                  metadataRecoveredFromWebhook: true,
                },
                { merge: true },
              );
            payments = await db
              .collection("payments")
              .where("paymentIntentId", "==", pi.id)
              .get();
          }

          const paymentMethodId =
            typeof pi.payment_method === "string"
              ? pi.payment_method
              : pi.payment_method?.id;

          let last4: string | null = null;
          let brand: string | null = null;
          if (paymentMethodId) {
            try {
              const pm = await stripe.paymentMethods.retrieve(paymentMethodId);
              last4 = pm.card?.last4 ?? null;
              brand = pm.card?.brand ?? null;
            } catch {
              logger.warn("Could not retrieve payment method details");
            }
          }

          const latestChargeId = stripeObjectId(pi.latest_charge);
          let stripeChargeId = latestChargeId;
          let stripeTransferId: string | null = null;
          let stripeBalanceTransactionId: string | null = null;
          const payoutEligibilityUpdate: Record<string, unknown> = {};

          if (rideId) {
            const paidRideDoc = await db.collection("rides").doc(rideId).get();
            if (paidRideDoc.data()?.status === "completed") {
              payoutEligibilityUpdate.payoutEligible = true;
              payoutEligibilityUpdate.rideCompletedAt =
                FieldValue.serverTimestamp();
            }
          }

          if (latestChargeId) {
            try {
              const charge: StripeCharge = await stripe.charges.retrieve(
                latestChargeId,
                { expand: ["transfer", "balance_transaction"] },
              );
              stripeChargeId = stripeObjectId(charge);
              stripeTransferId = stripeObjectId(charge.transfer);
              stripeBalanceTransactionId = stripeObjectId(
                charge.balance_transaction,
              );
            } catch (chargeError) {
              logger.warn("Could not retrieve charge reconciliation details", {
                paymentIntentId: pi.id,
                latestChargeId,
                error: chargeError,
              });
            }
          }

          for (const doc of payments.docs) {
            await doc.ref.update({
              status: "succeeded",
              completedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
              ...(last4 && { paymentMethodLast4: last4 }),
              ...(brand && { paymentMethodBrand: brand }),
              ...(stripeChargeId && { stripeChargeId }),
              ...(stripeTransferId && { stripeTransferId }),
              ...(stripeBalanceTransactionId && {
                stripeBalanceTransactionId,
              }),
              ...payoutEligibilityUpdate,
            });
          }

          if (rideId && riderId) {
            let bookingDoc:
              | QueryDocumentSnapshot<DocumentData>
              | DocumentSnapshot<DocumentData>
              | undefined;

            if (bookingId) {
              const exactBooking = await db
                .collection("bookings")
                .doc(bookingId)
                .get();
              const exactBookingStatus = exactBooking.data()?.status as
                | string
                | undefined;
              if (
                exactBooking.exists &&
                exactBookingStatus !== "cancelled" &&
                exactBookingStatus !== "rejected" &&
                !exactBooking.data()?.paidAt
              ) {
                bookingDoc = exactBooking;
              }
            }

            if (!bookingDoc) {
              const bookingsSnap = await db
                .collection("bookings")
                .where("rideId", "==", rideId)
                .where("passengerId", "==", riderId)
                .where("status", "==", "accepted")
                .get();

              const matchingBookings = bookingsSnap.docs
                .filter((doc) => !doc.data()["paidAt"])
                .sort((a, b) => {
                  const aTimestamp = (a.data()["createdAt"] ??
                    a.data()["respondedAt"]) as Timestamp | undefined;
                  const bTimestamp = (b.data()["createdAt"] ??
                    b.data()["respondedAt"]) as Timestamp | undefined;

                  const aMillis = aTimestamp?.toMillis() ?? 0;
                  const bMillis = bTimestamp?.toMillis() ?? 0;
                  return bMillis - aMillis;
                });

              bookingDoc = matchingBookings[0];
            }

            if (bookingDoc) {
              await bookingDoc.ref.update({
                paymentIntentId: pi.id,
                paymentStatus: "paid",
                paidAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp(),
              });
            }
          }

          // Notify driver that a passenger has paid.
          if (driverId) {
            try {
              const paymentDoc = payments.docs[0]?.data();
              const riderDisplayName =
                (paymentDoc?.riderName as string | undefined) ?? "A passenger";

              // Derive earnings from the PaymentIntent when the payment doc is
              // absent (recovery skipped due to missing metadata, or Firestore
              // write lag). This prevents silently crediting the driver €0.
              let driverEarnings = paymentDoc?.driverEarnings as
                | number
                | undefined;
              let driverEarningsInCents = paymentDoc?.driverEarningsInCents as
                | number
                | undefined;
              if (driverEarnings === undefined) {
                const amountInCents =
                  finiteNumber(pi.amount_received) ??
                  finiteNumber(pi.amount) ??
                  0;
                const { driverAmount } = calculateFees(amountInCents);
                driverEarnings = driverAmount / 100;
                driverEarningsInCents = driverAmount;
              }
              driverEarningsInCents ??= Math.round(driverEarnings * 100);

              await sendPushToUser(
                driverId,
                "Payment Received 💰",
                `${riderDisplayName} paid €${driverEarnings.toFixed(2)} for the ride.`,
                { type: "ride_update", referenceId: rideId ?? driverId },
              );

              // Increment driver_connected_accounts.pendingBalance optimistically.
              // Stripe keeps funds as "pending" until the normal payout schedule.
              // This gives the driver a live view without calling the Stripe API.
              const connectedRef = db
                .collection("driver_connected_accounts")
                .doc(driverId);
              const connectedSnap = await connectedRef.get();
              if (connectedSnap.exists) {
                await connectedRef.update({
                  pendingBalance: FieldValue.increment(driverEarnings),
                  pendingBalanceInCents: FieldValue.increment(
                    driverEarningsInCents,
                  ),
                  updatedAt: FieldValue.serverTimestamp(),
                });
              }
            } catch (notifyError) {
              logger.warn("Failed to notify driver or update pending balance", {
                driverId,
                error: notifyError,
              });
              // Best-effort — don't fail the whole webhook
            }
          }

          // CF-7: Recompute time-windowed stats; pass delta so all-time counters
          // are updated incrementally rather than via a full collection scan.
          if (driverId) {
            try {
              const driverEarningsDelta =
                (payments.docs[0]?.data()?.driverEarnings as number) ?? 0;
              await recomputeDriverStats(db, driverId, driverEarningsDelta, 1);
            } catch (statsError) {
              logger.error("Failed to update driver_stats", {
                driverId,
                error: statsError,
              });
              // Don't rethrow — stats update is best-effort, payment already succeeded
            }
          }
          break;
        }

        case "charge.succeeded":
        case "charge.updated": {
          const charge = event.data.object as StripeCharge;
          if (charge.status !== "succeeded" || !charge.paid) {
            break;
          }

          const rideId = charge.metadata?.rideId;
          const riderId = charge.metadata?.riderId;
          const driverId = charge.metadata?.driverId;
          const bookingId = charge.metadata?.bookingId;
          const paymentIntentId = stripeObjectId(charge.payment_intent);

          // Connected-account destination payment events do not carry the ride
          // metadata and should not create duplicate app payment records.
          if (!rideId || !riderId || !driverId) {
            break;
          }

          let payments = paymentIntentId
            ? await db
                .collection("payments")
                .where("paymentIntentId", "==", paymentIntentId)
                .get()
            : await db
                .collection("payments")
                .where("stripeChargeId", "==", charge.id)
                .get();

          if (payments.empty && paymentIntentId) {
            payments = await db
              .collection("payments")
              .where("stripePaymentIntentId", "==", paymentIntentId)
              .get();
          }

          if (payments.empty) {
            const amountInCents =
              finiteNumber(charge.amount_captured) ??
              finiteNumber(charge.amount) ??
              0;
            const { platformFee, driverAmount } = calculateFees(amountInCents);
            const paymentDocId = paymentIntentId ?? charge.id;

            await db
              .collection("payments")
              .doc(paymentDocId)
              .set(
                {
                  paymentIntentId: paymentIntentId ?? "",
                  stripePaymentIntentId: paymentIntentId ?? "",
                  bookingId: bookingId ?? "",
                  rideId,
                  driverId,
                  riderId,
                  riderName: "",
                  driverName: "",
                  amount: amountInCents / 100,
                  amountInCents,
                  currency: charge.currency ?? "eur",
                  platformFee: platformFee / 100,
                  platformFeeInCents: platformFee,
                  driverEarnings: driverAmount / 100,
                  driverEarningsInCents: driverAmount,
                  stripeFee: 0,
                  stripeFeeInCents: 0,
                  status: "pending",
                  createdAt: FieldValue.serverTimestamp(),
                  updatedAt: FieldValue.serverTimestamp(),
                  metadataRecoveredFromWebhook: true,
                },
                { merge: true },
              );

            payments = await db
              .collection("payments")
              .where("__name__", "==", paymentDocId)
              .get();
          }

          for (const doc of payments.docs) {
            await doc.ref.update({
              status: "succeeded",
              completedAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
              stripeChargeId: charge.id,
              ...(paymentIntentId && { paymentIntentId }),
              ...(paymentIntentId && {
                stripePaymentIntentId: paymentIntentId,
              }),
              ...(stripeObjectId(charge.transfer) && {
                stripeTransferId: stripeObjectId(charge.transfer),
              }),
              ...(stripeObjectId(charge.balance_transaction) && {
                stripeBalanceTransactionId: stripeObjectId(
                  charge.balance_transaction,
                ),
              }),
            });
          }

          if (bookingId) {
            await db
              .collection("bookings")
              .doc(bookingId)
              .set(
                {
                  ...(paymentIntentId && { paymentIntentId }),
                  paymentStatus: "paid",
                  paidAt: FieldValue.serverTimestamp(),
                  updatedAt: FieldValue.serverTimestamp(),
                },
                { merge: true },
              );
          }

          await recomputeDriverStats(db, driverId);
          break;
        }

        case "payment_intent.payment_failed": {
          const pi = event.data.object as StripePaymentIntent;
          const [failedPayments, failedBookingsSnap] = await Promise.all([
            db
              .collection("payments")
              .where("paymentIntentId", "==", pi.id)
              .get(),
            db
              .collection("bookings")
              .where("paymentIntentId", "==", pi.id)
              .get(),
          ]);
          const failedBookingDocs: Array<
            QueryDocumentSnapshot<DocumentData> | DocumentSnapshot<DocumentData>
          > = [...failedBookingsSnap.docs];
          const failedBookingId = pi.metadata?.bookingId;
          if (failedBookingDocs.length === 0 && failedBookingId) {
            const failedBookingDoc = await db
              .collection("bookings")
              .doc(failedBookingId)
              .get();
            if (failedBookingDoc.exists)
              failedBookingDocs.push(failedBookingDoc);
          }

          // Mark payment docs as failed
          for (const doc of failedPayments.docs) {
            await doc.ref.update({
              status: "failed",
              failedAt: FieldValue.serverTimestamp(),
              failureMessage:
                pi.last_payment_error?.message || "Payment failed",
            });
          }

          // GAP-3: Cancel related bookings + notify passengers
          if (failedBookingDocs.length > 0) {
            const bookingBatch = db.batch();
            failedBookingDocs.forEach((doc) => {
              bookingBatch.update(doc.ref, {
                status: "rejected",
                cancellationReason: "payment_failed",
                paymentStatus: "failed",
                updatedAt: FieldValue.serverTimestamp(),
              });
            });
            await bookingBatch.commit();

            for (const doc of failedBookingDocs) {
              const passengerId = doc.data()?.passengerId as string | undefined;
              if (passengerId) {
                await sendPushToUser(
                  passengerId,
                  "Payment Failed ❌",
                  "Your payment could not be processed. Your booking has been cancelled — please try again.",
                  { type: "payment_failed", referenceId: doc.id },
                );
              }
            }
            logger.info("GAP-3: cancelled bookings after payment failure", {
              paymentIntentId: pi.id,
              count: failedBookingDocs.length,
            });
          }
          break;
        }

        case "account.updated": {
          const account = event.data.object as StripeAccount;
          const userId = account.metadata?.userId;
          logger.info("Stripe account status", {
            accountId: account.id,
            chargesEnabled: account.charges_enabled,
            payoutsEnabled: account.payouts_enabled,
            detailsSubmitted: account.details_submitted,
            currentlyDue: account.requirements?.currently_due ?? [],
            pastDue: account.requirements?.past_due ?? [],
            pendingVerification:
              account.requirements?.pending_verification ?? [],
            disabledReason: account.requirements?.disabled_reason ?? null,
            transfersCapability: account.capabilities?.transfers ?? null,
            cardPaymentsCapability: account.capabilities?.card_payments ?? null,
          });
          if (!userId) {
            logger.warn("account.updated received without metadata.userId", {
              accountId: account.id,
            });
            break;
          }

          await syncConnectedAccountSnapshot(db, stripe, account, userId);

          const isActive =
            Boolean(account.charges_enabled) &&
            Boolean(account.payouts_enabled) &&
            Boolean(account.details_submitted) &&
            account.capabilities?.transfers === "active";

          const hasCurrentlyDue =
            (account.requirements?.currently_due?.length ?? 0) > 0;
          const hasPastDue = (account.requirements?.past_due?.length ?? 0) > 0;

          if (isActive) {
            await sendPushToUser(
              userId,
              "Stripe Account Active! 🎉",
              "Your payout account is ready. You can now receive ride payments directly!",
              { type: "stripe", referenceId: userId },
            );
          } else if (hasPastDue || hasCurrentlyDue) {
            await sendPushToUser(
              userId,
              "Complete Your Stripe Setup",
              "A few more details are needed to activate your payout account.",
              { type: "stripe", referenceId: userId },
            );
          }

          break;
        }

        default:
          logger.info(`Unhandled event type: ${event.type}`);
      }

      await webhookEventRef.update({
        status: "processed",
        processedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      res.status(200).json({ received: true });
    } catch (error) {
      logger.error("Error processing webhook", {
        eventType: event.type,
        eventId: event.id,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });

      await webhookEventRef
        .update({
          status: "failed",
          failedAt: FieldValue.serverTimestamp(),
          errorMessage:
            error instanceof Error ? error.message : String(error),
          updatedAt: FieldValue.serverTimestamp(),
        })
        .catch(() => {
          // best-effort
        });

      res.status(500).json({ error: "Webhook processing failed" });
    }
  },
);

// ============================================
// Trigger: Booking Cancelled → Auto-Refund if Already Paid
// ============================================

export const onBookingCancelled = onDocumentUpdated(
  { document: "bookings/{bookingId}", secrets: [stripeSecretKey] },
  async (event) => {
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;
    if (!before || !after) return;

    const beforeStatus = typeof before.status === "string" ? before.status : "";
    const afterStatus = typeof after.status === "string" ? after.status : "";

    // Only fire when the booking transitions TO cancelled
    if (beforeStatus === afterStatus || afterStatus !== "cancelled") return;

    // Only refund if the booking was actually paid
    const paymentIntentId =
      typeof after.paymentIntentId === "string" ? after.paymentIntentId : null;
    const paidAt = after.paidAt;

    if (!paymentIntentId || !paidAt) {
      logger.info("Booking cancelled without payment — no refund needed", {
        bookingId: event.params.bookingId,
      });
      const db = admin.firestore();
      const rideId = typeof after.rideId === "string" ? after.rideId : null;
      const riderId =
        typeof after.passengerId === "string" ? after.passengerId : null;
      if (rideId && riderId) {
        const pendingPayments = await db
          .collection("payments")
          .where("rideId", "==", rideId)
          .where("riderId", "==", riderId)
          .where("status", "==", "pending")
          .get();
        if (!pendingPayments.empty) {
          const batch = db.batch();
          pendingPayments.docs.forEach((doc) => {
            batch.update(doc.ref, {
              status: "cancelled",
              updatedAt: FieldValue.serverTimestamp(),
            });
          });
          await batch.commit();
          logger.info("Marked pending payments as cancelled", {
            bookingId: event.params.bookingId,
            rideId,
            count: pendingPayments.size,
          });
        }
      }
      return;
    }

    logger.info("Paid booking cancelled — initiating refund", {
      bookingId: event.params.bookingId,
      paymentIntentId,
    });

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // GAP-11: No refund if ride is already in progress — prevents mid-trip abuse
    const rideId = typeof after.rideId === "string" ? after.rideId : null;
    if (rideId) {
      const rideSnap = await db.collection("rides").doc(rideId).get();
      const rideStatus = rideSnap.data()?.status as string | undefined;
      if (rideStatus === "inProgress") {
        logger.info("onBookingCancelled: ride inProgress — no refund issued", {
          bookingId: event.params.bookingId,
          rideId,
        });
        const passengerId =
          typeof after.passengerId === "string" ? after.passengerId : null;
        if (passengerId) {
          await sendPushToUser(
            passengerId,
            "Booking Cancelled",
            "Your booking was cancelled after the ride started. Refunds are not available once a ride is in progress.",
            { type: "ride_update", referenceId: event.params.bookingId },
          );
        }
        return;
      }
    }

    try {
      // FIX CF-4: Use a Firestore transaction to atomically claim the
      // "refunding" state before issuing the Stripe refund.  Without this, two
      // concurrent Firestore triggers (e.g. passenger + driver cancelling
      // simultaneously) can both pass the "already refunded?" check and issue
      // two separate Stripe refunds.
      const paymentDocs = await findPaymentDocsByPaymentIntent(db, paymentIntentId);

      if (paymentDocs.length === 0) {
        logger.warn("No payment record found for paymentIntentId", {
          paymentIntentId,
        });
        return;
      }

      // Attempt to atomically transition the payment from "succeeded" →
      // "refunding".  If another trigger already claimed it the transaction
      // will throw and we bail out.
      const paymentRef = paymentDocs[0].ref;
      let paymentData: DocumentData = {};
      try {
        await db.runTransaction(async (txn) => {
          const snap = await txn.get(paymentRef);
          if (!snap.exists) throw new Error("payment_not_found");
          const data = snap.data()!;
          if (
            data.status === "refunded" ||
            data.status === "partiallyRefunded"
          ) {
            throw new Error("already_refunded");
          }
          // "refunding" + stripeRefundId = Stripe accepted it already
          // "refunding" without stripeRefundId = previous attempt failed, retry
          if (data.status === "refunding" && data.stripeRefundId) {
            throw new Error("already_refunded");
          }
          if (data.status !== "succeeded" && data.status !== "refunding") {
            throw new Error("already_refunded");
          }
          paymentData = data;
          txn.update(paymentRef, {
            status: "refunding",
            updatedAt: FieldValue.serverTimestamp(),
          });
        });
      } catch (txnErr) {
        const msg = txnErr instanceof Error ? txnErr.message : String(txnErr);
        if (msg === "already_refunded" || msg === "payment_not_found") {
          logger.info(`onBookingCancelled: skipping refund — ${msg}`, {
            paymentIntentId,
          });
          return;
        }
        throw txnErr;
      }

      // Refund via Stripe (outside the transaction — Stripe is an external call)
      let refund: StripeRefund;
      try {
        refund = await stripe.refunds.create(
          {
            payment_intent: paymentIntentId,
            reason: "requested_by_customer",
            reverse_transfer: true,
            refund_application_fee: true,
            metadata: {
              paymentIntentId,
              bookingId: event.params.bookingId,
              paymentDocId: paymentRef.id,
              driverId:
                typeof paymentData.driverId === "string"
                  ? paymentData.driverId
                  : "",
              riderId:
                typeof paymentData.riderId === "string"
                  ? paymentData.riderId
                  : "",
              source: "sportconnect_booking_cancelled",
            },
          },
          {
            idempotencyKey: `refund_booking_${event.params.bookingId}_${paymentIntentId}`,
          },
        );
      } catch (stripeError) {
        // Stripe rejected — roll back so a retry or manual refund can proceed
        await paymentRef
          .update({ status: "succeeded", updatedAt: FieldValue.serverTimestamp() })
          .catch(() => { /* best-effort */ });
        throw stripeError;
      }

      // Mark the payment as fully refunded
      await paymentRef.update({
        status: "refunding",
        stripeRefundId: refund.id,
        stripeRefundStatus: refund.status ?? "pending",
        refundReason: "requested_by_customer",
        requestedRefundAmountInCents:
          (refund.amount as number | undefined) ??
          (paymentData.amountInCents as number | undefined) ??
          null,
        refundedAt: null,
        updatedAt: FieldValue.serverTimestamp(),
      });

      // Notify rider about the refund
      const passengerId =
        typeof after.passengerId === "string" ? after.passengerId : null;
      if (passengerId) {
        const refundAmount = (refund.amount ?? 0) / 100;
        await sendPushToUser(
          passengerId,
          "Refund Started",
          `Your refund of €${refundAmount.toFixed(2)} has been initiated. Your bank will update the final status.`,
          {
            type: "ride_update",
            referenceId: event.params.bookingId,
            status: "refunding",
          },
        );
      }

      // Notify driver that a passenger cancelled (for awareness)
      const driverId =
        typeof after.driverId === "string" ? after.driverId : null;
      const driverEarnings = (paymentData.driverEarnings as number) ?? 0;
      const driverEarningsInCents =
        (paymentData.driverEarningsInCents as number | undefined) ??
        Math.round(driverEarnings * 100);
      if (driverId) {
        await sendPushToUser(
          driverId,
          "Passenger Cancelled",
          "A passenger cancelled their booking. Their payment has been refunded automatically.",
          {
            type: "ride_update",
            referenceId: event.params.bookingId,
          },
        );

        // Decrement driver_connected_accounts.pendingBalance since the payment
        // that was pending will be reversed.
        const connectedRef = db
          .collection("driver_connected_accounts")
          .doc(driverId);
        const connectedSnap = await connectedRef.get();
        if (connectedSnap.exists && driverEarnings > 0) {
          await connectedRef.update({
            pendingBalance: FieldValue.increment(-driverEarnings),
            pendingBalanceInCents: FieldValue.increment(-driverEarningsInCents),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }

      logger.info("Auto-refund completed", {
        bookingId: event.params.bookingId,
        refundId: refund.id,
        amount: (refund.amount ?? 0) / 100,
      });

      // CF-7: Recompute driver_stats after a refund.
      // Pass negative delta so totalEarnings is decremented atomically.
      if (driverId) {
        try {
          await recomputeDriverStats(db, driverId, -driverEarnings, -1);
        } catch (statsError) {
          logger.warn("Failed to recompute driver_stats after refund", {
            driverId,
            error: statsError,
          });
          // Best-effort — refund already processed successfully
        }
      }
    } catch (error) {
      logger.error("Auto-refund failed", {
        bookingId: event.params.bookingId,
        paymentIntentId,
        error: error instanceof Error ? error.message : String(error),
      });
      // Don't rethrow — the booking is already cancelled. A manual refund
      // can be triggered from the Stripe dashboard if needed.
    }
  },
);

// ============================================
// FIX CF-5: Trigger — Driver Cancels Ride → Refund All Paid Passengers
// When a driver cancels a ride, all passengers with paid bookings must be
// refunded automatically.  The original onBookingCancelled only fires for
// booking-level cancellations; a ride-level cancellation was never handled.
// FIX CF-6: Issue partial refund when the platform policy retains a fee on
// cancellations that occur after the ride has already started.
// ============================================

export const onRideCancelled = onDocumentUpdated(
  { document: "rides/{rideId}", secrets: [stripeSecretKey] },
  async (event) => {
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;
    if (!before || !after) return;

    const beforeStatus = typeof before.status === "string" ? before.status : "";
    const afterStatus = typeof after.status === "string" ? after.status : "";

    // Only fire when a ride transitions TO cancelled
    if (beforeStatus === afterStatus || afterStatus !== "cancelled") return;

    const rideId = event.params.rideId;
    const db = admin.firestore();
    const stripe = getStripeClient(stripeSecretKey.value().trim());

    // RideModel has no driverName field — fetch from users collection.
    let driverName = "The driver";
    const driverIdForName = typeof after.driverId === "string" ? after.driverId : null;
    if (driverIdForName) {
      try {
        const driverSnap = await db.collection("users").doc(driverIdForName).get();
        driverName = (driverSnap.data()?.username as string) || driverName;
      } catch { /* non-critical */ }
    }

    // Find all accepted bookings for this ride
    const [bookingsSnap, pendingBookingsSnap] = await Promise.all([
      db
        .collection("bookings")
        .where("rideId", "==", rideId)
        .where("status", "==", "accepted")
        .get(),
      db
        .collection("bookings")
        .where("rideId", "==", rideId)
        .where("status", "==", "pending")
        .get(),
    ]);

    // GAP-15: Cancel pending bookings immediately (no payment to refund)
    if (!pendingBookingsSnap.empty) {
      const pendingBatch = db.batch();
      pendingBookingsSnap.docs.forEach((doc) => {
        pendingBatch.update(doc.ref, {
          status: "cancelled",
          cancellationReason: "ride_cancelled_by_driver",
          updatedAt: FieldValue.serverTimestamp(),
        });
      });
      await pendingBatch.commit();
      const pendingPassengerIds = pendingBookingsSnap.docs
        .map((d) => d.data().passengerId as string)
        .filter(Boolean);
      if (pendingPassengerIds.length > 0) {
        await sendPushToMultipleUsers(
          pendingPassengerIds,
          "Ride Cancelled",
          `${driverName} cancelled the ride your booking request was for.`,
          { type: "ride_update", referenceId: rideId, status: "cancelled" },
        );
      }
    }

    if (bookingsSnap.empty) {
      logger.info("onRideCancelled: no accepted bookings to refund", {
        rideId,
      });
      return;
    }

    // Determine whether the ride had already started (inProgress → cancelled).
    // Policy: full refund if ride never started; partial (no platform fee)
    // if it was cancelled mid-trip.
    const rideWasInProgress = beforeStatus === "inProgress";

    const passengerIds: string[] = [];

    for (const bookingDoc of bookingsSnap.docs) {
      const booking = bookingDoc.data();
      const paymentIntentId =
        typeof booking.paymentIntentId === "string"
          ? booking.paymentIntentId
          : null;

      // Mark the booking as cancelled first
      await bookingDoc.ref.update({
        status: "cancelled",
        cancellationReason: "ride_cancelled_by_driver",
        updatedAt: FieldValue.serverTimestamp(),
      });

      if (!paymentIntentId || !booking.paidAt) continue;

      const passengerId =
        typeof booking.passengerId === "string" ? booking.passengerId : null;
      if (passengerId) passengerIds.push(passengerId);

      // FIX CF-6: Use a Firestore transaction to prevent double-refund
      const paymentDocs = await findPaymentDocsByPaymentIntent(db, paymentIntentId);

      if (paymentDocs.length === 0) continue;
      const paymentRef = paymentDocs[0].ref;

      try {
        let refundableAmount: number | undefined = undefined;
        let paymentData: DocumentData = {};
        let previousPaymentStatus = "succeeded";

        await db.runTransaction(async (txn) => {
          const snap = await txn.get(paymentRef);
          if (!snap.exists) throw new Error("payment_not_found");
          const data = snap.data()!;
          if (
            data.status === "refunded" ||
            data.status === "partiallyRefunded" ||
            data.status === "refunding"
          ) {
            throw new Error("already_refunded");
          }
          // FIX CF-6: Full refund if ride never started; partial (driver
          // amount only, platform keeps the fee) if cancelled mid-trip.
          if (rideWasInProgress) {
            const originalAmountInCents = paymentAmountInCents(data);
            const platformFeeInCents =
              finiteNumber(data.platformFeeInCents) ??
              Math.round((finiteNumber(data.platformFee) ?? 0) * 100);
            const legacyDriverEarningsInCents = Math.round(
              (finiteNumber(data.driverEarnings) ?? 0) * 100,
            );
            const driverEarningsInCents =
              finiteNumber(data.driverEarningsInCents) ??
              (legacyDriverEarningsInCents > 0
                ? legacyDriverEarningsInCents
                : Math.max(0, originalAmountInCents - platformFeeInCents));
            refundableAmount =
              driverEarningsInCents > 0 ? driverEarningsInCents : 0;
          }
          paymentData = data;
          previousPaymentStatus = stringOrEmpty(data.status) || "succeeded";
          txn.update(paymentRef, {
            status: "refunding",
            updatedAt: FieldValue.serverTimestamp(),
          });
        });

        const refundParams: StripeRefundCreateParams = {
          payment_intent: paymentIntentId,
          reason: "requested_by_customer",
          reverse_transfer: true,
        };
        if (refundableAmount !== undefined) {
          refundParams.amount = Math.round(refundableAmount);
          if (refundParams.amount <= 0) {
            throw new Error("no_refundable_amount");
          }
        } else {
          // BUG-CF-03: Full refund (ride never started) — reclaim the platform
          // application fee so the platform doesn't retain its cut.
          refundParams.refund_application_fee = true;
        }

        let refund: StripeRefund;
        try {
          refund = await stripe.refunds.create(refundParams, {
            idempotencyKey: `refund_ride_${rideId}_${bookingDoc.id}_${paymentIntentId}`,
          });
        } catch (stripeError) {
          await paymentRef
            .update({
              status: previousPaymentStatus,
              updatedAt: FieldValue.serverTimestamp(),
            })
            .catch(() => { /* best-effort */ });
          throw stripeError;
        }
        const isFullRefund = refundableAmount === undefined;

        await paymentRef.update({
          status: "refunding",
          stripeRefundId: refund.id,
          stripeRefundStatus: refund.status ?? "pending",
          requestedRefundAmountInCents:
            (refund.amount as number | undefined) ??
            (isFullRefund ? paymentAmountInCents(paymentData) : refundableAmount),
          refundedAt: null,
          refundReason: "driver_cancelled_ride",
          updatedAt: FieldValue.serverTimestamp(),
        });

        const paymentDriverId =
          typeof paymentData.driverId === "string"
            ? paymentData.driverId
            : typeof after.driverId === "string"
              ? after.driverId
              : null;
        const driverEarnings = (paymentData.driverEarnings as number) ?? 0;
        const driverEarningsInCents =
          (paymentData.driverEarningsInCents as number | undefined) ??
          Math.round(driverEarnings * 100);

        if (paymentDriverId && driverEarnings > 0) {
          const connectedRef = db
            .collection("driver_connected_accounts")
            .doc(paymentDriverId);
          const connectedSnap = await connectedRef.get();
          if (connectedSnap.exists) {
            await connectedRef.update({
              pendingBalance: FieldValue.increment(-driverEarnings),
              pendingBalanceInCents: FieldValue.increment(
                -driverEarningsInCents,
              ),
              updatedAt: FieldValue.serverTimestamp(),
            });
          }

          try {
            await recomputeDriverStats(
              db,
              paymentDriverId,
              -driverEarnings,
              -1,
            );
          } catch (statsError) {
            logger.warn("onRideCancelled: failed to recompute driver_stats", {
              paymentDriverId,
              error: statsError,
            });
          }
        }

        logger.info("onRideCancelled: refunded passenger", {
          rideId,
          paymentIntentId,
          refundId: refund.id,
          partial: !isFullRefund,
        });
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        if (msg === "already_refunded" || msg === "payment_not_found") {
          logger.info("onRideCancelled: skipping refund", {
            paymentIntentId,
            reason: msg,
          });
        } else {
          logger.error("onRideCancelled: refund failed", {
            paymentIntentId,
            error: msg,
          });
        }
      }
    }

    // Notify all affected passengers
    if (passengerIds.length > 0) {
      const driverName = (after.driverName as string) || "The driver";
      await sendPushToMultipleUsers(
        passengerIds,
        "Ride Cancelled",
        `${driverName} cancelled the ride. Eligible payments have been sent for refund.`,
        { type: "ride_update", referenceId: rideId, status: "cancelled" },
      );
    }

    // GAP-5: Track driver cancellation rate (skip for event-triggered cancellations)
    const driverId = typeof after.driverId === "string" ? after.driverId : null;
    const isDriverCancellation =
      (after.cancellationReason as string | undefined) !== "event_cancelled";
    if (driverId && isDriverCancellation) {
      try {
        const driverRef = db.collection("users").doc(driverId);
        await db.runTransaction(async (txn) => {
          const snap = await txn.get(driverRef);
          if (!snap.exists) return;
          const data = snap.data()!;
          const completedRides = (data.totalRidesAsDriver as number) ?? 0;
          const prevCount = (data.cancellationCount as number) ?? 0;
          const newCount = prevCount + 1;
          const total = completedRides + newCount;
          const rate = total > 0 ? newCount / total : 0;
          txn.update(driverRef, {
            cancellationCount: newCount,
            cancellationRate: rate,
            updatedAt: FieldValue.serverTimestamp(),
          });
        });
        logger.info("GAP-5: updated driver cancellation rate", {
          driverId,
          rideId,
        });
      } catch (err) {
        logger.warn("GAP-5: failed to update cancellation rate", {
          driverId,
          error: err,
        });
      }
    }
  },
);

// ============================================
// Sync Driver Stripe Balance
// ============================================

export const syncDriverBalance = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // Rate limit: 20 balance syncs per user per 60 s
    await checkRateLimit(
      admin.firestore(),
      request.auth.uid,
      "syncDriverBalance",
      20,
      60,
    );

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();
    const driverId = request.auth.uid;

    try {
      // Resolve stripeAccountId from driver_connected_accounts first,
      // then fall back to the users doc. The two collections may be out of
      // sync during onboarding, so checking both prevents false "not-found"
      // errors after a driver completes setup.
      const [connectedAccountDoc, userDoc] = await Promise.all([
        db.collection("driver_connected_accounts").doc(driverId).get(),
        db.collection("users").doc(driverId).get(),
      ]);

      const stripeAccountId: string | undefined =
        (connectedAccountDoc.data()?.stripeAccountId as string | undefined) ??
        (userDoc.data()?.stripeAccountId as string | undefined);

      if (!stripeAccountId) {
        throw new HttpsError(
          "not-found",
          "No Stripe account ID found. Driver must complete onboarding first.",
        );
      }

      // Fetch balance from Stripe
      const balance = await stripe.balance.retrieve(
        {},
        {
          stripeAccount: stripeAccountId,
        },
      );

      const defaultCurrency = (
        (connectedAccountDoc.data()?.defaultCurrency as string | undefined) ??
        (userDoc.data()?.defaultCurrency as string | undefined) ??
        "eur"
      ).toLowerCase();
      const availableBalanceInCents = sumBalanceForCurrency(
        balance.available,
        defaultCurrency,
      );
      const pendingBalanceInCents = sumBalanceForCurrency(
        balance.pending,
        defaultCurrency,
      );

      logger.info("Synced balance for driver", {
        driverId,
        stripeAccountId,
        availableBalanceInCents,
        pendingBalanceInCents,
      });

      // Upsert driver_connected_accounts — if the doc was never created
      // (e.g. onboarding completed via the webhook path) set it now.
      await db
        .collection("driver_connected_accounts")
        .doc(driverId)
        .set(
          {
            driverId,
            stripeAccountId,
            availableBalance: availableBalanceInCents / 100,
            pendingBalance: pendingBalanceInCents / 100,
            availableBalanceInCents,
            pendingBalanceInCents,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

      return {
        success: true,
        availableBalance: availableBalanceInCents / 100,
        pendingBalance: pendingBalanceInCents / 100,
        availableBalanceInCents,
        pendingBalanceInCents,
      };
    } catch (error) {
      const e = error as { message?: string };
      logger.error("syncDriverBalance failed", {
        driverId,
        error: e.message,
      });

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        `Failed to sync balance: ${e.message ?? "unknown error"}`,
      );
    }
  },
);

// ============================================
// GAP-6: Scheduled — Expire Old Rides
// Runs every 6 hours. Closes rides where departureTime < now-1h and status=active.
// ============================================

export const expireOldRides = onSchedule("every 6 hours", async () => {
  const db = admin.firestore();
  const cutoff = new Date(Date.now() - 60 * 60 * 1000); // 1 hour ago
  const staleRides = await db
    .collection("rides")
    .where("status", "==", "active")
    .where("schedule.departureTime", "<=", cutoff)
    .get();

  if (staleRides.empty) {
    logger.info("expireOldRides: no stale rides found");
    return;
  }

  for (const rideDoc of staleRides.docs) {
    try {
      // Setting status → cancelled triggers onRideCancelled which handles refunds
      await rideDoc.ref.update({
        status: "cancelled",
        cancellationReason: "expired",
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("expireOldRides: expired ride", { rideId: rideDoc.id });
    } catch (err) {
      logger.error("expireOldRides: failed to expire ride", {
        rideId: rideDoc.id,
        error: err,
      });
    }
  }

  logger.info("expireOldRides: done", { count: staleRides.size });
});

// ============================================
// GAP-7: Scheduled — Expire Pending Bookings
// Runs every 6 hours. Cancels pending bookings older than 48 h.
// ============================================

export const expirePendingBookings = onSchedule("every 6 hours", async () => {
  const db = admin.firestore();
  const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000); // 48 hours ago
  const staleBookings = await db
    .collection("bookings")
    .where("status", "==", "pending")
    .where("createdAt", "<=", cutoff)
    .get();

  if (staleBookings.empty) {
    logger.info("expirePendingBookings: no stale bookings found");
    return;
  }

  const batch = db.batch();
  staleBookings.docs.forEach((doc) => {
    batch.update(doc.ref, {
      status: "cancelled",
      cancellationReason: "expired_no_driver_response",
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  await batch.commit();

  // Notify each affected passenger
  for (const doc of staleBookings.docs) {
    const passengerId = doc.data().passengerId as string | undefined;
    if (passengerId) {
      await sendPushToUser(
        passengerId,
        "Booking Request Expired",
        "Your booking request was not accepted within 48 hours and has been automatically cancelled.",
        {
          type: "ride_update",
          referenceId: doc.id,
          status: "cancelled",
        },
      );
    }
  }

  logger.info("expirePendingBookings: done", { count: staleBookings.size });
});

// ============================================
// GAP-14: Trigger — Review Updated → Recalculate Rating
// Fires when a review doc changes. Recomputes the reviewee's average rating.
// ============================================

export const onReviewUpdated = onDocumentUpdated(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data?.before.data() as
      | Record<string, unknown>
      | undefined;
    const after = event.data?.after.data() as
      | Record<string, unknown>
      | undefined;
    if (!before || !after) return;

    const oldRating = typeof before.rating === "number" ? before.rating : null;
    const newRating = typeof after.rating === "number" ? after.rating : null;

    // Only act when the numeric rating actually changed
    if (oldRating === null || newRating === null || oldRating === newRating)
      return;

    const revieweeId =
      typeof after.revieweeId === "string" ? after.revieweeId : null;
    if (!revieweeId) return;

    const db = admin.firestore();

    // Recompute from all reviews for this user
    const allReviews = await db
      .collection("reviews")
      .where("revieweeId", "==", revieweeId)
      .get();

    if (allReviews.empty) return;

    const ratings = allReviews.docs.map(
      (d) => (d.data().rating as number) ?? 0,
    );
    const avg = ratings.reduce((a, b) => a + b, 0) / ratings.length;
    const rounded = Math.round(avg * 10) / 10;

    await db.collection("users").doc(revieweeId).update({
      averageRating: rounded,
      totalReviews: ratings.length,
      updatedAt: FieldValue.serverTimestamp(),
    });

    logger.info("GAP-14: recalculated rating after review edit", {
      revieweeId,
      newAvg: rounded,
      reviewCount: ratings.length,
    });
  },
);

// ============================================
// Stripe: Customer Sheet Setup
// Creates a SetupIntent + EphemeralKey for managing saved payment methods
// ============================================

export const createCustomerSheetSetup = onCall(
  { secrets: [stripeSecretKey], cors: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { stripeApiVersion } = request.data;
    const userId = request.auth.uid;

    const stripe = getStripeClient(stripeSecretKey.value().trim());
    const db = admin.firestore();

    // Get or verify the user's Stripe customer ID
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (!userData) {
      throw new HttpsError("not-found", "User not found");
    }

    let customerId: string | undefined = userData.stripeCustomerId;

    // If user doesn't have a customer ID, create one
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: userData.email,
        name: (userData.username as string | undefined) ?? (userData.displayName as string | undefined),
        metadata: { userId },
      });
      customerId = customer.id;

      await db.collection("users").doc(userId).update({
        stripeCustomerId: customerId,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } else {
      // Verify the customer still exists
      try {
        const existing = await stripe.customers.retrieve(customerId);
        if (existing.deleted) {
          const customer = await stripe.customers.create({
            email: userData.email,
            name: userData.displayName,
            metadata: { userId },
          });
          customerId = customer.id;
          await db.collection("users").doc(userId).update({
            stripeCustomerId: customerId,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      } catch {
        logger.info("Stored customer invalid, creating new one");
        const customer = await stripe.customers.create({
          email: userData.email,
          name: userData.displayName,
          metadata: { userId },
        });
        customerId = customer.id;
        await db.collection("users").doc(userId).update({
          stripeCustomerId: customerId,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }

    // Create SetupIntent for saving payment methods without charging
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      automatic_payment_methods: { enabled: true },
      metadata: { userId },
    });

    // Create ephemeral key for the customer
    // Must use the client's SDK API version
    const ephemeralKeyVersion = stripeApiVersion || "2026-04-22.dahlia";
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: ephemeralKeyVersion },
    );

    return {
      setupIntentClientSecret: setupIntent.client_secret,
      customerId,
      ephemeralKeySecret: ephemeralKey.secret,
    };
  },
);

// ── Account Deletion Request (Web page → RGPD Art.17 / Apple 5.1.1) ────────
//
// Called by the public delete-account.html page. Records the request in
// Firestore and sends a confirmation e-mail so the user has written proof
// that we received it. The actual account + data deletion is performed by
// a human or a scheduled function within 30 days.
export const requestAccountDeletion = onRequest(
  {
    secrets: [resendApiKey, supportFromEmail, supportInboxEmail],
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const { email, reason, comments, requestedAt, source } = req.body as {
      email?: string;
      reason?: string;
      comments?: string;
      requestedAt?: string;
      source?: string;
    };

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      res.status(400).json({ error: "A valid e-mail address is required." });
      return;
    }

    const db = admin.firestore();

    // Record the deletion request so the ops team can act on it.
    const docRef = await db.collection("deletion_requests").add({
      email: email.trim().toLowerCase(),
      reason: reason ?? null,
      comments: comments ?? null,
      requestedAt: requestedAt ?? new Date().toISOString(),
      source: source ?? "web",
      status: "pending",
      createdAt: FieldValue.serverTimestamp(),
    });

    logger.info(`Deletion request recorded: ${docRef.id} for ${email}`);

    // Send confirmation e-mail to the requester via Resend.
    try {
      const fromAddr = supportFromEmail.value();
      const inboxAddr = supportInboxEmail.value();
      const apiKey = resendApiKey.value();

      const confirmationHtml = `
        <p>Bonjour,</p>
        <p>Nous avons bien reçu votre demande de suppression de compte SportConnect pour l'adresse <strong>${email}</strong>.</p>
        <p>Votre demande sera traitée dans un délai de <strong>30 jours</strong> conformément à l'article 17 du RGPD.
        Vous recevrez un e-mail de confirmation une fois la suppression effectuée.</p>
        <p>Référence de votre demande : <code>${docRef.id}</code></p>
        <p>Si vous n'avez pas effectué cette demande, ignorez cet e-mail ou contactez-nous à
        <a href="mailto:support@sportaxitrip.com">support@sportaxitrip.com</a>.</p>
        <p>— L'équipe SportConnect</p>
      `;

      // Notify the requester
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          from: fromAddr,
          to: [email.trim()],
          subject: "Demande de suppression de compte reçue - SportConnect",
          html: confirmationHtml,
        }),
      });

      // Notify the support inbox so a human can act on it
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          from: fromAddr,
          to: [inboxAddr],
          subject: `[Suppression de compte] ${email}`,
          html: `
            <p><strong>Nouvelle demande de suppression de compte</strong></p>
            <p>E-mail : ${email}</p>
            <p>Motif : ${reason ?? "non précisé"}</p>
            <p>Commentaires : ${comments ?? "aucun"}</p>
            <p>Référence Firestore : ${docRef.id}</p>
            <p>Date : ${requestedAt ?? new Date().toISOString()}</p>
          `,
        }),
      });
    } catch (emailErr) {
      // E-mail failure is non-fatal — the request is already recorded in Firestore.
      logger.warn("Deletion confirmation e-mail failed (non-fatal):", emailErr);
    }

    res.status(200).json({ success: true, requestId: docRef.id });
  },
);
