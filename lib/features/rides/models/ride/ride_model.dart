import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_capacity.dart';
import 'package:sport_connect/features/rides/models/ride/ride_preferences.dart';
import 'package:sport_connect/features/rides/models/ride/ride_pricing.dart';
import 'package:sport_connect/features/rides/models/ride/ride_route.dart';
import 'package:sport_connect/features/rides/models/ride/ride_schedule.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

/// Ride status enum
enum RideStatus { draft, active, full, inProgress, completed, cancelled }

/// Refactored Ride model using composition
/// Follows Single Responsibility Principle
///
/// Convenience getters bridge old flat field names to composed sub-models,
/// so the view layer doesn't need hundreds of changes.
@freezed
abstract class RideModel with _$RideModel {
  const factory RideModel({
    @JsonKey(includeToJson: false) required String id,
    required String driverId,
    // Composed sub-models
    required RideRoute route,
    required RideSchedule schedule,
    required RideCapacity capacity,
    required RidePricing pricing,
    required RidePreferences preferences,
    String? eventId,
    String? eventName,

    // Status
    @Default(RideStatus.draft) RideStatus status,

    // Phase (persisted so passengers see granular driver progress)
    String? ridePhase,

    // Vehicle reference (resolved through VehicleRepository)
    String? vehicleId,
    String? vehicleInfo,

    // Bookings (lightweight - detailed bookings stored separately)
    @Default([]) List<String> bookingIds,

    // Bookings list (populated by service layer when full booking data is needed)
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default([])
    List<RideBooking> bookings,

    // Reviews (count only - detailed reviews stored separately)
    @Default(0) int reviewCount,
    @Default(0.0) double averageRating,

    // XP Rewards
    @Default(50) int xpReward,

    // Metadata
    String? notes,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    // Lifecycle stamps (optional — set as the ride moves through its states).
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() DateTime? cancelledAt,
    String? cancellationReason,
  }) = _RideModel;
  const RideModel._();

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);

  // ── Convenience getters (bridge old flat API → composed sub-models) ──

  /// Origin location
  LocationPoint get origin => route.origin;

  /// Destination location
  LocationPoint get destination => route.destination;

  bool get hasRequiredEvent => eventId != null && eventId!.trim().isNotEmpty;

  /// Departure time
  DateTime get departureTime => schedule.departureTime;

  /// Price per seat (as double for backward compat)
  int get pricePerSeatInCents => pricing.pricePerSeatInCents;

  /// Available seats
  int get availableSeats => capacity.available;

  /// Booked seats
  int get bookedSeats => capacity.booked;

  /// Remaining seats
  int get remainingSeats => capacity.remaining;

  /// Duration in minutes
  int? get durationMinutes => route.durationMinutes;

  /// Distance in km
  double? get distanceKm => route.distanceKm;

  // ── Business logic getters ──

  /// Is ride bookable
  bool get isBookable =>
      status == RideStatus.active && !capacity.isFull && !schedule.isPast;

  /// Is ride upcoming (within 24h)
  bool get isUpcoming => schedule.isUpcoming && status == RideStatus.active;

  /// Is ride happening soon
  bool get isHappeningSoon => schedule.isHappeningSoon;

  /// Get formatted price
  String get formattedPrice => pricing.formattedPrice;

  // ── Preference convenience getters ──

  /// Allow pets
  bool get allowPets => preferences.allowPets;

  /// Allow smoking
  bool get allowSmoking => preferences.allowSmoking;

  /// Allow luggage
  bool get allowLuggage => preferences.allowLuggage;

  /// Women only
  bool get isWomenOnly => preferences.isWomenOnly;

  /// Arrival time
  DateTime? get arrivalTime => schedule.arrivalTime;

  ///Is ride full
  bool get isFull => capacity.isFull;

  /// Ride has been completed.
  bool get isCompleted => status == RideStatus.completed;

  /// Ride has been cancelled.
  bool get isCancelled => status == RideStatus.cancelled;

  /// Ride is currently underway.
  bool get isInProgress => status == RideStatus.inProgress;

  /// Ride is in an active, future-facing state (not finished or cancelled).
  bool get isActive =>
      status == RideStatus.active || status == RideStatus.full;

  /// Whether the driver can still cancel the ride (not already finished).
  bool get isCancellable =>
      status != RideStatus.completed && status != RideStatus.cancelled;

  /// Whether this ride has any reviews.
  bool get hasReviews => reviewCount > 0;

  /// Pending bookings awaiting a driver decision.
  List<RideBooking> get pendingBookings =>
      bookings.where((b) => b.status == BookingStatus.pending).toList();

  /// Number of seats locked in by accepted bookings.
  int get confirmedSeatsCount =>
      acceptedBookings.fold(0, (sum, b) => sum + b.seatsBooked);

  /// Total fare collectible if every available seat is booked.
  int get maxPotentialEarningsInCents =>
      pricing.totalForSeats(capacity.available);

  /// Is a premium ride (tagged by driver as premium)
  bool get isPremium => tags.contains('premium');

  /// Is an eco-friendly ride (driver tagged it as eco)
  bool get isEco => tags.contains('eco');

  /// Accepted bookings (bookings with accepted status)
  List<RideBooking> get acceptedBookings =>
      bookings.where((b) => b.status == BookingStatus.accepted).toList();
}

