import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

/// Verification lifecycle for a vehicle.
///
/// A typed status (rather than a single bool) supports a real verification
/// flow and lets the offer-ride path gate on an unverified/rejected vehicle.
/// Defaults to [unverified] so existing documents (which have no field) decode
/// safely.
enum VehicleVerificationStatus { unverified, pending, verified, rejected }

/// Body / category of a vehicle.
///
/// Typed instead of a free-form string to avoid primitive obsession and to let
/// the UI render consistent labels/icons. Defaults to [unknown] so existing
/// documents (which have no field) decode safely.
enum VehicleType { sedan, suv, hatchback, van, pickup, motorcycle, other, unknown }

/// Fuel / powertrain type of a vehicle.
///
/// Defaults to [unknown] so existing documents decode safely.
enum VehicleFuelType { petrol, diesel, hybrid, electric, lpg, other, unknown }

/// Transmission type of a vehicle.
///
/// Defaults to [unknown] so existing documents decode safely.
enum VehicleTransmission { manual, automatic, unknown }

/// Vehicle model - NO circular dependency with DriverModel
/// Owner resolved through VehicleRepository/Service
@freezed
abstract class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String id,
    required String ownerId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String licensePlate,
    @Default('Unknown') String ownerName,
    String? ownerPhotoUrl,
    @Default(4) int capacity,
    String? imageUrl,
    @Default([]) List<String> imageUrls,
    @Default(false) bool isActive,
    @Default(false) bool isDefault,

    // Specs (optional; captured during onboarding / editing)
    @Default(VehicleType.unknown) VehicleType type,
    @Default(VehicleFuelType.unknown) VehicleFuelType fuelType,
    @Default(VehicleTransmission.unknown) VehicleTransmission transmission,

    // Verification
    @Default(VehicleVerificationStatus.unverified)
    VehicleVerificationStatus verificationStatus,
    @TimestampConverter() DateTime? verifiedAt,
    String? rejectionReason,

    // Stats
    @Default(0) int totalRides,
    @Default(0.0) double averageRating,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _VehicleModel;
  const VehicleModel._();

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  /// Get display name
  String get displayName => '$year $make $model';

  /// Convenience: backward compat for views using vehicle.owner
  String get owner => ownerId;

  /// Get full display with color
  String get fullDisplayName => '$year $color $make $model';

  /// Whether the vehicle has passed verification and may be used to offer rides.
  bool get isVerified =>
      verificationStatus == VehicleVerificationStatus.verified;

  /// Whether verification was explicitly rejected (distinct from never-submitted).
  bool get isRejected =>
      verificationStatus == VehicleVerificationStatus.rejected;

  /// Whether a verification request is awaiting review.
  bool get isPendingVerification =>
      verificationStatus == VehicleVerificationStatus.pending;

  /// Whether this vehicle is eligible to be used to offer rides:
  /// it must be active and have passed verification.
  bool get canOfferRides => isActive && isVerified;

  /// Number of passenger seats available to riders (capacity excludes the
  /// driver's own seat). Never negative.
  int get passengerSeats => capacity > 0 ? capacity - 1 : 0;

  /// Best available image for display: the primary [imageUrl] if set,
  /// otherwise the first entry in [imageUrls], otherwise null.
  String? get primaryImageUrl =>
      imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

  /// Whether this vehicle has any image to show.
  bool get hasImage => primaryImageUrl != null;

  /// Whether the vehicle has accumulated any ratings.
  bool get hasRatings => totalRides > 0 && averageRating > 0;
}
