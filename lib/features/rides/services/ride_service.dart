import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

part 'ride_service.g.dart';

/// Ride service - handles ride business logic
@Riverpod(keepAlive: true)
class RideService extends _$RideService {
  @override
  FutureOr<void> build() async {}

  /// Create a new ride with validation
  Future<String> createRide(RideModel ride) async {
    // Validate ride data
    if (ride.schedule.isPast) {
      throw ArgumentError('Cannot create ride with past departure time');
    }

    if (ride.capacity.available < 1) {
      throw ArgumentError('Ride must have at least 1 available seat');
    }

    if (ride.pricing.pricePerSeatInCents < 0) {
      throw ArgumentError('Price cannot be negative');
    }

    if (!ride.hasRequiredEvent) {
      throw ArgumentError('Ride must be linked to an event');
    }

    // Save to repository
    final repo = ref.read(rideRepositoryProvider);
    final rideId = await repo.createRide(ride);

    // Award XP for creating a ride
    if (!ref.mounted) return rideId;
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.addXP(ride.driverId, 10);
    } on Exception catch (e) {
      TalkerService.error('Failed to award ride creation XP: $e');
    }

    return rideId;
  }

  /// Update ride with business rules
  Future<void> updateRide(RideModel ride) async {
    final repo = ref.read(rideRepositoryProvider);

    // Get existing ride
    final existing = await repo.getRideById(ride.id);
    if (existing == null) {
      throw ArgumentError('Ride not found');
    }

    if (!ride.hasRequiredEvent) {
      throw ArgumentError('Ride must be linked to an event');
    }

    // Requested Ride Lock: ride details cannot change once demand exists.
    if (existing.bookingIds.isNotEmpty) {
      throw ArgumentError(
        'Cannot edit ride details after a booking request exists',
      );
    }

    await repo.updateRide(ride);
  }

  /// Cancel a ride
  Future<void> cancelRide(String rideId, String reason) async {
    final repo = ref.read(rideRepositoryProvider);

    final ride = await repo.getRideById(rideId);
    if (ride == null) {
      throw ArgumentError('Ride not found');
    }

    if (ride.status == RideStatus.cancelled) {
      throw ArgumentError('Ride already cancelled');
    }

    if (ride.status == RideStatus.completed) {
      throw ArgumentError('Cannot cancel completed ride');
    }

    // Cancel the ride
    final cancelled = ride.copyWith(
      status: RideStatus.cancelled,
      notes: ride.notes != null
          ? '${ride.notes}\nCancelled: $reason'
          : 'Cancelled: $reason',
      updatedAt: DateTime.now(),
    );

    await repo.updateRide(cancelled);

    // Cancel all pending/accepted bookings for this ride
    if (!ref.mounted) return;
    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final bookings = await bookingRepo.getBookingsByRideId(
        rideId,
        ride.driverId,
      );
      for (final booking in bookings) {
        if (booking.status == BookingStatus.pending ||
            booking.status == BookingStatus.accepted) {
          await repo.cancelBooking(rideId: rideId, bookingId: booking.id);
        }
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to cancel bookings for ride $rideId: $e');
    }

    // Notify all passengers about the cancellation
    await _notifyPassengersOfCancellation(ride: ride, reason: reason);
  }

  /// Complete a ride, award XP and record driver stats.
  ///
  /// This is the business-logic entry point for ride completion.
  /// Call this instead of going directly to the repository so that
  /// XP rewards and driver stats are always recorded.
  Future<void> completeRide(String rideId) async {
    final repo = ref.read(rideRepositoryProvider);

    final ride = await repo.getRideById(rideId);
    if (ride == null) {
      throw ArgumentError('Ride not found');
    }

    if (ride.status != RideStatus.inProgress) {
      throw ArgumentError('Only in-progress rides can be completed');
    }

    // Mark ride as completed in Firestore
    await repo.completeRide(rideId);

    // Mark all accepted bookings as completed and collect passenger IDs
    if (!ref.mounted) return;
    final completedPassengerIds = <String>[];
    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final bookings = await bookingRepo.getBookingsByRideId(
        rideId,
        ride.driverId,
      );
      for (final booking in bookings) {
        if (booking.status == BookingStatus.accepted) {
          await repo.updateBookingStatus(
            rideId: rideId,
            bookingId: booking.id,
            newStatus: BookingStatus.completed,
          );
          completedPassengerIds.add(booking.passengerId);
        }
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to update booking statuses: $e');
    }
    if (!ref.mounted) return;

    // FIX RC-1: Only award XP when the ride was genuinely completed with at
    // least one passenger who was picked up.  A force-completed or corrupted
    // ride (zero completed passengers) must not grant rewards.
    if (completedPassengerIds.isEmpty) {
      TalkerService.warning(
        'completeRide $rideId: no completed passengers — skipping XP/stats.',
      );
      return;
    }

    // Award XP, update stats, streaks, and achievements
    try {
      final xp = calculateXpReward(ride);
      final distanceKm = ride.route.distanceKm ?? 0.0;
      final estimatedFareInCents =
          ride.pricing.pricePerSeatInCents * ride.capacity.booked;
      // Driver earnings are owned by Stripe webhook aggregation from the
      // payments collection. Do not write gross fare estimates here.

      final profileRepo = ref.read(profileRepositoryProvider);
      final notificationRepo = ref.read(notificationRepositoryProvider);

      // Driver gamification
      final driverLevelUp = await profileRepo.addXP(ride.driverId, xp);
      await profileRepo.updateStreak(ride.driverId);
      await profileRepo.updateRideStats(
        uid: ride.driverId,
        asDriver: true,
        distance: distanceKm,
      );

      // Passenger gamification: each passenger earns 60% of driver XP
      final passengerXp = (xp * 0.6).round();
      for (final passengerId in completedPassengerIds) {
        final passengerLevelUp = await profileRepo.addXP(
          passengerId,
          passengerXp,
        );
        await profileRepo.updateStreak(passengerId);
        await profileRepo.updateRideStats(
          uid: passengerId,
          asDriver: false,
          distance: distanceKm,
          fareAmountPaidInCents:
              ride.pricing.pricePerSeatInCents * ride.capacity.booked,
        );
        if (passengerLevelUp != null) {
          await notificationRepo.sendLevelUpNotification(
            userId: passengerId,
            newLevel: passengerLevelUp,
          );
        }
      }

      // Evaluate achievements for driver and all passengers
      final driverBadges = await profileRepo.evaluateAchievements(
        ride.driverId,
      );
      for (final passengerId in completedPassengerIds) {
        final passengerBadges = await profileRepo.evaluateAchievements(
          passengerId,
        );
        for (final badgeId in passengerBadges) {
          final info = _badgeInfo[badgeId];
          if (info != null) {
            await notificationRepo.sendAchievementNotification(
              userId: passengerId,
              achievementName: info.$1,
              achievementDescription: info.$2,
            );
          }
        }
      }

      // Send driver level-up and badge notifications
      if (driverLevelUp != null) {
        await notificationRepo.sendLevelUpNotification(
          userId: ride.driverId,
          newLevel: driverLevelUp,
        );
      }
      for (final badgeId in driverBadges) {
        final info = _badgeInfo[badgeId];
        if (info != null) {
          await notificationRepo.sendAchievementNotification(
            userId: ride.driverId,
            achievementName: info.$1,
            achievementDescription: info.$2,
          );
        }
      }

      TalkerService.info(
        'Ride $rideId completed. XP awarded: $xp, estimated fare: ${estimatedFareInCents / 100}',
      );
    } on Exception catch (e) {
      // Stats failure should NOT roll back the completion
      TalkerService.error('Failed to record ride completion stats: $e');
    }
  }

  /// Badge ID → (name, description) for achievement notifications.
  static const _badgeInfo = <String, (String, String)>{
    'first_ride': ('First Ride', 'Complete your first carpool ride'),
    'road_tripper': ('Road Tripper', 'Travel 50 km total'),
    'speed_demon': ('Speed Demon', 'Maintain a 7-day ride streak'),
    'road_master': ('Road Master', 'Complete 100 rides'),
    'marathon_driver': ('Marathon Driver', 'Travel 1000 km total'),
  };

  /// Calculate XP reward based on ride characteristics
  int calculateXpReward(RideModel ride) {
    var xp = 50; // Base XP

    // Distance bonus
    final distanceKm = ride.route.distanceKm;
    if (distanceKm != null && distanceKm.isFinite && distanceKm > 0) {
      xp += (distanceKm / 10).round();
    }

    // Recurring ride bonus
    if (ride.schedule.isRecurring) {
      xp += 20;
    }

    // Full capacity bonus
    if (ride.capacity.percentageFilled >= 80) {
      xp += 30;
    }

    // High rating bonus
    if (ride.averageRating >= 4.5) {
      xp += 25;
    }

    return xp;
  }

  // ==================== NOTIFICATION HELPERS ====================

  /// Notifies all booked passengers that a ride has been cancelled.
  Future<void> _notifyPassengersOfCancellation({
    required RideModel ride,
    required String reason,
  }) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final bookingRepo = ref.read(bookingRepositoryProvider);

      // Fetch driver info for the notification
      final driver = await profileRepo.getUserById(ride.driverId);
      final driverName = driver?.username ?? 'Driver';
      final driverPhoto = driver?.photoUrl;

      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;
      final rideName = '$origin \u2192 $dest';

      // Fetch all bookings for this ride and notify each passenger
      final bookings = await bookingRepo.getBookingsByRideId(
        ride.id,
        ride.driverId,
      );
      for (final booking in bookings) {
        await notificationRepo.sendRideCancelled(
          toUserId: booking.passengerId,
          driverName: driverName,
          driverPhoto: driverPhoto,
          rideId: ride.id,
          rideName: rideName,
          reason: reason,
        );
      }
    } on Exception catch (e) {
      // Notification failure should not break the main cancellation flow
      TalkerService.error('Failed to notify passengers of cancellation: $e');
    }
  }

  // ==================== 7B: NO-SHOW HANDLING ====================

  /// Mark a passenger as no-show, cancel their booking, deduct XP, reset streak, and notify them.
  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  }) async {
    final repo = ref.read(rideRepositoryProvider);
    await repo.markPassengerNoShow(
      rideId: rideId,
      bookingId: bookingId,
      passengerId: passengerId,
    );

    // GAP-13: Penalize no-show in gamification — deduct 20 XP + reset streak
    if (!ref.mounted) return;
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.addXP(passengerId, -20);
      await profileRepo.resetStreak(passengerId);
    } on Exception catch (e) {
      TalkerService.error('Failed to apply no-show gamification penalty: $e');
    }

    // Notify the passenger
    try {
      final ride = await repo.getRideById(rideId);
      if (ride == null) return;
      if (!ref.mounted) return;
      final profileRepo = ref.read(profileRepositoryProvider);
      final driver = await profileRepo.getUserById(ride.driverId);
      if (!ref.mounted) return;
      final driverName = driver?.username ?? 'Driver';
      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;

      final notificationRepo = ref.read(notificationRepositoryProvider);
      await notificationRepo.createNotification(
        NotificationModel(
          id: '',
          userId: passengerId,
          type: NotificationType.rideCancelled,
          title: 'Marked as No-Show',
          body:
              '$driverName marked you as no-show for "$origin → $dest". '
              'Your booking has been cancelled and 20 XP deducted.',
          senderName: driverName,
          referenceId: rideId,
          referenceType: 'ride',
          priority: NotificationPriority.high,
        ),
      );
    } on Exception catch (e) {
      TalkerService.error('Failed to send no-show notification: $e');
    }
  }

  // ==================== 7G: RIDE TIMEOUT ====================

  /// Check if a ride has exceeded its estimated duration.
  /// Returns null if no timeout, or the minutes exceeded.
  int? checkRideTimeout(RideModel ride) {
    if (ride.status != RideStatus.inProgress) return null;
    final actualDeparture = ride.schedule.actualDepartureTime;
    if (actualDeparture == null) return null;

    final estimatedDuration = ride.durationMinutes ?? 120;
    final elapsed = DateTime.now().difference(actualDeparture).inMinutes;
    final threshold = estimatedDuration * 2;

    if (elapsed > threshold) {
      return elapsed - estimatedDuration;
    }
    return null;
  }

  /// Force-complete a ride that has timed out.
  Future<void> forceCompleteTimedOutRide(String rideId) async {
    final repo = ref.read(rideRepositoryProvider);
    final ride = await repo.getRideById(rideId);
    if (ride == null || ride.status != RideStatus.inProgress) return;

    TalkerService.warning('Force-completing timed-out ride $rideId');
    await completeRide(rideId);
  }

  // ==================== 7J: DELAY DETECTION ====================

  /// Notify all passengers of a ride delay.
  Future<void> notifyRideDelay({
    required RideModel ride,
    required int delayMinutes,
  }) async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final driver = await profileRepo.getUserById(ride.driverId);
      if (!ref.mounted) return;
      final driverName = driver?.username ?? 'Driver';
      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;
      final rideName = '$origin → $dest';

      final notificationRepo = ref.read(notificationRepositoryProvider);
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final bookings = await bookingRepo.getBookingsByRideId(
        ride.id,
        ride.driverId,
      );

      for (final booking in bookings) {
        if (booking.status != BookingStatus.accepted) continue;
        await notificationRepo.createNotification(
          NotificationModel(
            id: '',
            userId: booking.passengerId,
            type: NotificationType.rideUpdated,
            title: 'Ride Delayed',
            body:
                '$driverName\'s ride "$rideName" is running ~$delayMinutes min late.',
            senderName: driverName,
            referenceId: ride.id,
            referenceType: 'ride',
            priority: NotificationPriority.high,
          ),
        );
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to send delay notifications: $e');
    }
  }

  // ==================== 7H: RETURN RIDE ====================

  /// Create a return ride from a completed ride.
  Future<String> createReturnRide(String originalRideId) async {
    final repo = ref.read(rideRepositoryProvider);
    return repo.createReturnRide(originalRideId);
  }
}
