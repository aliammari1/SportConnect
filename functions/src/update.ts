import {
  DocumentData,
  FieldValue,
} from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import {
  onDocumentUpdated,
  onDocumentWritten,
} from "firebase-functions/v2/firestore";
import { db as firestoreDb } from "./firebase-admin";
import {
  sendPushToMultipleUsers,
  sendPushToUser,
} from "./notifications-helper-functions";
import {
  findPaymentDocsByPaymentIntent,
  paymentAmountInCents,
} from "./refund-helper-functions";
import { getRidePricePerSeatInCents } from "./ride-helper-functions";
import { stripeSecretKey } from "./secrets";
import {
  finiteNumber,
  getStripeClient,
  recomputeDriverStats,
  stringOrEmpty,
} from "./stripe-helper-functions";
import { StripeRefund, StripeRefundCreateParams } from "./types";

// ============================================
// Trigger: Booking Written (created / accepted / rejected / cancelled)
//
// COST NOTE: This combines what used to be three separate Cloud Functions
// (onNewRideRequest, onRideRequestUpdated, onBookingCancelled) — all of
// which fired on the same "bookings/{bookingId}" document — into a single
// onDocumentWritten trigger. Fewer deployed functions means fewer idle
// Cloud Run services and less exposure to per-region CPU/quota limits.
// ============================================

export const onBookingWritten = onDocumentWritten(
  { document: "bookings/{bookingId}", secrets: [stripeSecretKey] },
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!afterSnap?.exists) return; // booking deleted — nothing to do

    // ── Created: notify the driver of a new ride request ─────────────────
    if (!beforeSnap?.exists) {
      const booking = afterSnap.data();
      if (!booking) return;

      // CF-12: Deduplication — Firestore triggers can be retried on transient
      // errors, sending the same push twice.  We write notificationSentAt
      // before sending; on retry the field is already present and we bail.
      if (booking.notificationSentAt) return;
      try {
        await afterSnap.ref.update({
          notificationSentAt: FieldValue.serverTimestamp(),
        });
      } catch {
        // Document may have been deleted between trigger and update — abort.
        return;
      }

      const rideId =
        typeof booking.rideId === "string" ? booking.rideId : null;
      const passengerId =
        typeof booking.passengerId === "string" ? booking.passengerId : null;
      const seatsBooked = (booking.seatsBooked as number) ?? 1;

      if (!rideId || !passengerId) return;

      const db = firestoreDb;

      const rideSnap = await db.collection("rides").doc(rideId).get();
      const rideData = rideSnap.data();
      if (!rideData) return;

      const driverId =
        typeof rideData.driverId === "string" ? rideData.driverId : null;
      if (!driverId) return;

      let riderName = "A rider";
      try {
        const userSnap = await db.collection("users").doc(passengerId).get();
        riderName = (userSnap.data()?.username as string) || riderName;
      } catch {
        // Non-critical — fallback to generic name
      }

      const pickupLocation = booking.pickupLocation as
        | Record<string, unknown>
        | undefined;
      const pickup =
        (pickupLocation?.name as string) ||
        (pickupLocation?.address as string) ||
        "";

      // CF-10: Include the fare amount so the driver can evaluate the
      // booking value without opening the app.
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
      return;
    }

    // ── Updated ────────────────────────────────────────────────────────
    const before = beforeSnap.data() as Record<string, unknown> | undefined;
    const after = afterSnap.data() as Record<string, unknown> | undefined;
    if (!before || !after) return;

    const beforeStatus = typeof before.status === "string" ? before.status : "";
    const afterStatus = typeof after.status === "string" ? after.status : "";
    if (beforeStatus === afterStatus) return;

    // ── Driver accept/reject notification ─────────────────────────────
    // The cancellation → refund flow below only handles transitions TO
    // "cancelled"; this branch handles everything else.
    if (afterStatus !== "cancelled") {
      const passengerId =
        typeof after.passengerId === "string" ? after.passengerId : null;
      const rideId = typeof after.rideId === "string" ? after.rideId : null;
      if (!passengerId || !rideId) return;

      let title = "";
      let body = "";

      switch (afterStatus) {
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
        status: afterStatus,
      });
      return;
    }

    // ── Booking cancelled → auto-refund if already paid ─────────────────
    // Only refund if the booking was actually paid
    const paymentIntentId =
      typeof after.paymentIntentId === "string" ? after.paymentIntentId : null;
    const paidAt = after.paidAt;

    if (!paymentIntentId || !paidAt) {
      logger.info("Booking cancelled without payment — no refund needed", {
        bookingId: event.params.bookingId,
      });
      const db = firestoreDb;
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
    const db = firestoreDb;

    // GAP-11: No refund if ride is already in progress — prevents mid-trip abuse
    const rideId = typeof after.rideId === "string" ? after.rideId : null;
    if (rideId) {
      const rideSnap = await db.collection("rides").doc(rideId).get();
      const rideStatus = rideSnap.data()?.status as string | undefined;
      if (rideStatus === "inProgress") {
        logger.info("onBookingWritten: ride inProgress — no refund issued", {
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
      const paymentDocs = await findPaymentDocsByPaymentIntent(
        db,
        paymentIntentId,
      );

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
          logger.info(`onBookingWritten: skipping refund — ${msg}`, {
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
          .update({
            status: "succeeded",
            updatedAt: FieldValue.serverTimestamp(),
          })
          .catch(() => {
            /* best-effort */
          });
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
// Trigger: Ride Updated (started / completed / cancelled)
//
// COST NOTE: Combines the former onRideStatusChanged and onRideCancelled
// functions, which both fired on "rides/{rideId}" updates, into one.
// ============================================

export const onRideUpdated = onDocumentUpdated(
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

    // ── Ride cancelled → refund all paid passengers ───────────────────────
    // FIX CF-5: When a driver cancels a ride, all passengers with paid
    // bookings must be refunded automatically.
    // FIX CF-6: Issue partial refund when the platform policy retains a fee
    // on cancellations that occur after the ride has already started.
    if (beforeStatus !== afterStatus && afterStatus === "cancelled") {
      const rideId = event.params.rideId;
      const db = firestoreDb;
      const stripe = getStripeClient(stripeSecretKey.value().trim());

      // RideModel has no driverName field — fetch from users collection.
      let driverName = "The driver";
      const driverIdForName =
        typeof after.driverId === "string" ? after.driverId : null;
      if (driverIdForName) {
        try {
          const driverSnap = await db
            .collection("users")
            .doc(driverIdForName)
            .get();
          driverName = (driverSnap.data()?.username as string) || driverName;
        } catch {
          /* non-critical */
        }
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
        logger.info("onRideUpdated: no accepted bookings to refund", {
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
        const paymentDocs = await findPaymentDocsByPaymentIntent(
          db,
          paymentIntentId,
        );

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
              .catch(() => {
                /* best-effort */
              });
            throw stripeError;
          }
          const isFullRefund = refundableAmount === undefined;

          await paymentRef.update({
            status: "refunding",
            stripeRefundId: refund.id,
            stripeRefundStatus: refund.status ?? "pending",
            requestedRefundAmountInCents:
              (refund.amount as number | undefined) ??
              (isFullRefund
                ? paymentAmountInCents(paymentData)
                : refundableAmount),
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
              logger.warn("onRideUpdated: failed to recompute driver_stats", {
                paymentDriverId,
                error: statsError,
              });
            }
          }

          logger.info("onRideUpdated: refunded passenger", {
            rideId,
            paymentIntentId,
            refundId: refund.id,
            partial: !isFullRefund,
          });
        } catch (err) {
          const msg = err instanceof Error ? err.message : String(err);
          if (msg === "already_refunded" || msg === "payment_not_found") {
            logger.info("onRideUpdated: skipping refund", {
              paymentIntentId,
              reason: msg,
            });
          } else {
            logger.error("onRideUpdated: refund failed", {
              paymentIntentId,
              error: msg,
            });
          }
        }
      }

      // Notify all affected passengers
      if (passengerIds.length > 0) {
        const notifyDriverName = (after.driverName as string) || "The driver";
        await sendPushToMultipleUsers(
          passengerIds,
          "Ride Cancelled",
          `${notifyDriverName} cancelled the ride. Eligible payments have been sent for refund.`,
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
      return;
    }

    // ── Ride started / completed → notify passengers ─────────────────────
    // Notify passengers when ride starts or completes.
    // passengerIds are NOT embedded on the ride document — they live in the
    // separate `bookings` collection.  Query accepted bookings to get them.
    const isStarting = beforeStatus !== "active" && afterStatus === "active";
    const isCompleting =
      beforeStatus !== "completed" && afterStatus === "completed";

    if (!isStarting && !isCompleting) return;

    const db = firestoreDb;
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
      const driverId =
        typeof after.driverId === "string" ? after.driverId : null;
      if (driverId) {
        try {
          const driverSnap = await db.collection("users").doc(driverId).get();
          driverName = (driverSnap.data()?.username as string) || driverName;
        } catch {
          /* non-critical */
        }
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
// Trigger: Event Written (created / participant joined / cancelled / full)
//
// COST NOTE: Combines the former onNewEvent (create) and onEventUpdated
// (update) functions, which both fired on "events/{eventId}", into one.
// ============================================

export const onEventWritten = onDocumentWritten(
  "events/{eventId}",
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!afterSnap?.exists) return; // event deleted — nothing to do

    // ── Created → notify the creator their event is live ─────────────────
    if (!beforeSnap?.exists) {
      const data = afterSnap.data();
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
      return;
    }

    // ── Updated: participant joined / event cancelled / event full ───────
    const before = beforeSnap.data();
    const after = afterSnap.data();
    if (!before || !after) return;

    const eventId = event.params.eventId;
    const eventTitle = (after.title as string) || "An event";
    const creatorId = after.creatorId as string;
    const db = firestoreDb;

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
          const userDoc = await firestoreDb
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
        logger.error("onEventWritten: failed to cancel linked rides", {
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

    const db = firestoreDb;

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
