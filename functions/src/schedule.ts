import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db as firestoreDb } from "./firebase-admin";
import { sendPushToUser } from "./notifications-helper-functions";
// ============================================
// GAP-6: Scheduled — Expire Old Rides
// Runs every 6 hours. Closes rides where departureTime < now-1h and status=active.
// ============================================

export const expireOldRides = onSchedule("every 6 hours", async () => {
  const cutoff = new Date(Date.now() - 60 * 60 * 1000); // 1 hour ago
  const staleRides = await firestoreDb
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
      // Setting status → cancelled triggers onRideUpdated which handles refunds
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
  const cutoff = new Date(Date.now() - 48 * 60 * 60 * 1000); // 48 hours ago
  const staleBookings = await firestoreDb
    .collection("bookings")
    .where("status", "==", "pending")
    .where("createdAt", "<=", cutoff)
    .get();

  if (staleBookings.empty) {
    logger.info("expirePendingBookings: no stale bookings found");
    return;
  }

  const batch = firestoreDb.batch();
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
