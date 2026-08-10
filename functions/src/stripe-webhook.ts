import {
    DocumentData,
    DocumentSnapshot,
    FieldValue,
    QueryDocumentSnapshot,
    Timestamp,
} from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { db as firestoreDb } from "./firebase-admin";
import { sendPushToUser } from "./notifications-helper-functions";
import { calculateFees } from "./payment-helper-functions";
import { findPaymentDocsByPaymentIntent } from "./refund-helper-functions";
import { stripeSecretKey, stripeWebhookSecret } from "./secrets";
import {
    findDriverIdForConnectedAccount,
    finiteNumber,
    getPaymentIntentIdFromRefund,
    getStripeClient,
    recomputeDriverStats,
    stringOrEmpty,
    stripeObjectId,
    syncConnectedAccountSnapshot,
} from "./stripe-helper-functions";
import {
    StripeAccount,
    StripeCharge,
    StripeEvent,
    StripePaymentIntent,
    StripePayout,
    StripeRefund,
    StripeTransferReversal,
} from "./types";
import { mapPayoutStatus } from "./utilities";

// ============================================
// Stripe: Webhook Handler
// ============================================

export const stripeWebhook = onRequest(
  // FIX: Webhooks do NOT need cors:true — they are called by Stripe, not by browsers.
  // Enabling CORS on a webhook can expose it unnecessarily.
  { secrets: [stripeSecretKey, stripeWebhookSecret], cpu: 1 },
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

    const db = firestoreDb;
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
          const reversal = event.data
            .object as unknown as StripeTransferReversal;
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
              await db
                .collection("bookings")
                .doc(bookingId)
                .set(
                  {
                    paymentStatus: isFullRefund
                      ? "refunded"
                      : "partiallyRefunded",
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

            let nextStatus = "";

            const isPartial =
              originalAmountInCents !== undefined &&
              (refund.amount ?? 0) < originalAmountInCents;
            switch (refund.status) {
              case "succeeded":
                nextStatus = isPartial ? "partiallyRefunded" : "refunded";
                break;
              case "pending":
              case "requires_action":
                nextStatus = "refunding";
                break;
              case "failed":
              case "canceled":
                nextStatus = "refundFailed";
                break;
              default:
                nextStatus = "refunding";
            }

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
              await db.collection("bookings").doc(bookingId).set(
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
              await db
                .collection("refund_requests")
                .doc(refundRequestId)
                .set(
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
              //
              // Idempotency: a webhook retry (or a charge.* event firing for the
              // same payment) re-runs this branch. Gate the increment on a
              // per-payment `pendingBalanceCredited` flag set atomically in the
              // same transaction as the credit, so the driver is credited at most
              // once regardless of how many times the event is delivered.
              const connectedRef = db
                .collection("driver_connected_accounts")
                .doc(driverId);
              const paymentDocRef = payments.docs[0]?.ref;
              if (paymentDocRef) {
                await db.runTransaction(async (tx) => {
                  const [paymentSnap, connectedSnap] = await Promise.all([
                    tx.get(paymentDocRef),
                    tx.get(connectedRef),
                  ]);
                  if (!connectedSnap.exists) return;
                  if (paymentSnap.data()?.pendingBalanceCredited === true) {
                    return;
                  }
                  tx.update(connectedRef, {
                    pendingBalance: FieldValue.increment(driverEarnings),
                    pendingBalanceInCents: FieldValue.increment(
                      driverEarningsInCents,
                    ),
                    updatedAt: FieldValue.serverTimestamp(),
                  });
                  tx.set(
                    paymentDocRef,
                    {
                      pendingBalanceCredited: true,
                      pendingBalanceCreditedAt: FieldValue.serverTimestamp(),
                    },
                    { merge: true },
                  );
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
          errorMessage: error instanceof Error ? error.message : String(error),
          updatedAt: FieldValue.serverTimestamp(),
        })
        .catch(() => {
          // best-effort
        });

      res.status(500).json({ error: "Webhook processing failed" });
    }
  },
);
