import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

part 'ride_request_service.g.dart';

/// Result wrapper for operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.message);
  final String message;
}

/// Booking action service — handles driver accept/reject of pending bookings.
///
/// Replaces the old RideRequestService which maintained a separate
/// `rideRequests` Firestore collection in parallel with `bookings`.
/// Now there is only one source of truth: the `bookings` collection.
@Riverpod(keepAlive: true)
class RideRequestService extends _$RideRequestService {
  @override
  FutureOr<void> build() async {}

  /// Accept a pending booking (driver action).
  Future<Result<RideBooking>> acceptRequest(String bookingId) async {
    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final booking = await bookingRepo.getBookingById(bookingId);
      if (booking == null) return const Failure('Booking not found');
      if (booking.status != BookingStatus.pending) {
        return const Failure('Booking already processed');
      }

      // Increment ride capacity and mark booking accepted atomically.
      if (!ref.mounted) return const Failure('Request was cancelled');
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: booking.rideId,
            bookingId: bookingId,
            newStatus: BookingStatus.accepted,
          );

      if (!ref.mounted) {
        return Success(booking.copyWith(status: BookingStatus.accepted));
      }
      await _sendAcceptedNotification(booking);
      return Success(booking.copyWith(status: BookingStatus.accepted));
    } on Exception catch (e) {
      return Failure('Failed to accept booking: $e');
    }
  }

  /// Reject a pending booking (driver action).
  Future<Result<RideBooking>> rejectRequest(
    String bookingId,
    String reason,
  ) async {
    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final booking = await bookingRepo.getBookingById(bookingId);
      if (booking == null) return const Failure('Booking not found');
      if (booking.status != BookingStatus.pending) {
        return const Failure('Booking already processed');
      }

      if (!ref.mounted) return const Failure('Request was cancelled');
      // F-08: Delegate to RideRepository.updateBookingStatus which uses a
      // transaction and conditionally decrements capacity based on
      // previousStatus — BookingRepository.updateBookingStatus is a plain
      // .update() that does not adjust capacity atomically.
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: booking.rideId,
            bookingId: bookingId,
            newStatus: BookingStatus.rejected,
          );

      if (!ref.mounted) {
        return Success(booking.copyWith(status: BookingStatus.rejected));
      }
      await _sendRejectedNotification(booking, reason);
      return Success(booking.copyWith(status: BookingStatus.rejected));
    } on Exception catch (e) {
      return Failure('Failed to reject booking: $e');
    }
  }

  // ── Notification helpers ─────────────────────────────────────────────────

  Future<void> _sendAcceptedNotification(RideBooking booking) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final rideRepo = ref.read(rideRepositoryProvider);

      final driver = booking.driverId != null
          ? await profileRepo.getUserById(booking.driverId!)
          : null;
      final ride = await rideRepo.getRideById(booking.rideId);

      await notificationRepo.sendRideBookingAccepted(
        toUserId: booking.passengerId,
        driverName: driver?.username ?? 'Driver',
        driverPhoto: driver?.photoUrl,
        rideId: booking.rideId,
        rideName: _formatRideName(ride),
      );
    } on Exception catch (e) {
      TalkerService.error('Failed to send accepted notification: $e');
    }
  }

  Future<void> _sendRejectedNotification(
    RideBooking booking,
    String? reason,
  ) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final rideRepo = ref.read(rideRepositoryProvider);

      final driver = booking.driverId != null
          ? await profileRepo.getUserById(booking.driverId!)
          : null;
      final ride = await rideRepo.getRideById(booking.rideId);

      await notificationRepo.sendRideBookingRejected(
        toUserId: booking.passengerId,
        driverName: driver?.username ?? 'Driver',
        driverPhoto: driver?.photoUrl,
        rideId: booking.rideId,
        rideName: _formatRideName(ride),
        reason: reason,
      );
    } on Exception catch (e) {
      TalkerService.error('Failed to send rejected notification: $e');
    }
  }

  String _formatRideName(RideModel? ride) {
    if (ride == null) return 'ride';
    final origin = ride.origin.city ?? ride.origin.address;
    final dest = ride.destination.city ?? ride.destination.address;
    return '$origin → $dest';
  }
}
