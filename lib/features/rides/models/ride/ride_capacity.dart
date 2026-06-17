import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_capacity.freezed.dart';
part 'ride_capacity.g.dart';

/// Ride capacity management
@freezed
abstract class RideCapacity with _$RideCapacity {
  const factory RideCapacity({
    @Default(3) int available,
    @Default(0) int booked,
  }) = _RideCapacity;
  const RideCapacity._();

  factory RideCapacity.fromJson(Map<String, dynamic> json) =>
      _$RideCapacityFromJson(json);

  /// Remaining seats
  int get remaining => available - booked;

  /// Remaining seats (alias for [remaining], reads naturally at call sites).
  int get seatsRemaining => remaining;

  /// Is ride full
  bool get isFull => remaining <= 0;

  /// Has at least one bookable seat left.
  bool get hasAvailability => remaining > 0;

  /// Only a single seat remains — useful for urgency messaging in the UI.
  bool get isAlmostFull => remaining == 1;

  /// Can book requested seats
  bool canBook(int seats) => remaining >= seats && seats > 0;

  /// Percentage filled
  double get percentageFilled => available > 0 ? (booked / available) * 100 : 0;

  /// Book seats (returns new capacity or null if not possible)
  RideCapacity? bookSeats(int seats) {
    if (!canBook(seats)) return null;
    return copyWith(booked: booked + seats);
  }

  /// Release seats
  RideCapacity releaseSeats(int seats) {
    final newBooked = (booked - seats).clamp(0, available);
    return copyWith(booked: newBooked);
  }
}
