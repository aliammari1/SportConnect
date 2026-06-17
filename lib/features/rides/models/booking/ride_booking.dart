import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'ride_booking.freezed.dart';
part 'ride_booking.g.dart';

/// Booking status enum
enum BookingStatus { pending, accepted, rejected, cancelled, completed }

/// Booking model for ride reservations
/// Now stored separately from rides for better scalability
@freezed
abstract class RideBooking with _$RideBooking {
  const factory RideBooking({
    required String id,
    required String rideId,
    required String passengerId,
    String? driverId,
    @Default(1) int seatsBooked,
    @Default(BookingStatus.pending) BookingStatus status,
    LocationPoint? pickupLocation,
    LocationPoint? dropoffLocation,
    String? note,
    // No denormalized user data - fetch via passengerId for single source of truth
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? respondedAt,
    // Payment tracking — stamped when Stripe payment succeeds
    String? paymentIntentId,
    @TimestampConverter() DateTime? paidAt,
    // Pickup OTP — shown to passenger, driver enters this to confirm pickup
    String? pickupOtp,
    // Per-seat price snapshot captured at booking time (defends against the
    // driver editing the ride price after a passenger has booked).
    int? pricePerSeatInCents,
    // Stamped when the booking is cancelled (by passenger or driver).
    @TimestampConverter() DateTime? cancelledAt,
  }) = _RideBooking;
  const RideBooking._();

  factory RideBooking.fromJson(Map<String, dynamic> json) =>
      _$RideBookingFromJson(json);

  /// Whether the booking is still awaiting a driver decision.
  bool get isPending => status == BookingStatus.pending;

  /// Whether the booking has been confirmed by the driver.
  bool get isAccepted => status == BookingStatus.accepted;

  /// Whether the booking is in a terminal state (no further transitions).
  bool get isTerminal =>
      status == BookingStatus.rejected ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.completed;

  /// Whether the booking is still "live" (counts against ride seats).
  bool get isActive =>
      status == BookingStatus.pending || status == BookingStatus.accepted;

  /// Whether a Stripe payment has been captured for this booking.
  bool get isPaid => paidAt != null && paymentIntentId != null;

  /// Total amount due for this booking, when a price snapshot is available.
  int? get totalAmountInCents =>
      pricePerSeatInCents != null ? pricePerSeatInCents! * seatsBooked : null;

  /// A paid booking is refundable until it has been completed.
  bool get isRefundable => isPaid && status != BookingStatus.completed;
}
