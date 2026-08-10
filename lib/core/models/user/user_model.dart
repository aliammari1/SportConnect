import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/user/gamification_stats.dart';
import 'package:sport_connect/core/models/user/rating_breakdown.dart';
import 'package:sport_connect/core/models/user/user_enums.dart';
import 'package:sport_connect/core/models/user/user_preferences.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Base User model
@Freezed(unionKey: 'role')
sealed class UserModel with _$UserModel {
  const UserModel._();

  /// Rider user type
  @FreezedUnionValue('rider')
  const factory UserModel.rider({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    String? phoneNumber,
    String? gender,
    @Default('') String fcmToken,

    // Address & location
    String? address,
    double? latitude,
    double? longitude,

    // Verification & status
    @Default(false) bool isEmailVerified,
    @Default(false) bool isBanned,
    @Default(false) bool isPremium,
    String? premiumPlan, // 'monthly' | 'yearly'
    @TimestampConverter() DateTime? premiumUpdatedAt,

    // Social
    @Default([]) List<String> blockedUsers,

    // Rider-specific: Passenger rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Rider-specific: Gamification
    @Default(GamificationStats()) GamificationStats gamification,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie)
    @JsonKey(unknownEnumValue: Expertise.rookie)
    Expertise expertise,

    String? stripeCustomerId,
    @Default(false) bool isStripeCustomerCreated,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = RiderModel;

  /// Driver user type
  @FreezedUnionValue('driver')
  const factory UserModel.driver({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    String? phoneNumber,
    String? gender,
    @Default('') String fcmToken,

    // Address & location
    String? address,
    double? latitude,
    double? longitude,

    // Verification & status
    @Default(false) bool isEmailVerified,
    @Default(false) bool isBanned,
    @Default(false) bool isPremium,
    String? premiumPlan, // 'monthly' | 'yearly'
    @TimestampConverter() DateTime? premiumUpdatedAt,

    // Social
    @Default([]) List<String> blockedUsers,

    // Driver-specific: Driver rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Driver-specific: Gamification
    @Default(GamificationStats()) GamificationStats gamification,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie)
    @JsonKey(unknownEnumValue: Expertise.rookie)
    Expertise expertise,

    // Driver-specific: Vehicle IDs
    @Default([]) List<String> vehicleIds,

    // Driver-specific: Stripe Connect
    String? stripeAccountId,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = DriverModel;

  @FreezedUnionValue('pending')
  const factory UserModel.pending({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    String? phoneNumber,
    @Default(Expertise.rookie)
    @JsonKey(unknownEnumValue: Expertise.rookie)
    Expertise expertise,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isBanned,
    @Default('') String fcmToken,
    String? selectedRoleIntent,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = PendingUserModel;

  /// Auto-generated JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// ==============================================================================
// LOGIC EXTENSIONS
// ==============================================================================

/// Logic for all User types
extension UserModelLogic on UserModel {
  UserRole get role => map(
    rider: (_) => UserRole.rider,
    driver: (_) => UserRole.driver,
    pending: (_) => UserRole.pending,
  );

  // Works because 'totalXP' exists on the base GamificationStats class
  UserLevel get userLevel => map(
    rider: (r) => UserLevel.fromXP(r.gamification.totalXP),
    driver: (d) => UserLevel.fromXP(d.gamification.totalXP),
    pending: (_) => UserLevel.bronze,
  );

  /// Whether the user currently holds premium status. Pending users are never
  /// premium.
  bool get isPremiumUser => map(
    rider: (r) => r.isPremium,
    driver: (d) => d.isPremium,
    pending: (_) => false,
  );

  /// Premium plan slug ('monthly' | 'yearly'), if any. Pending users have none.
  String? get premiumPlan => map(
    rider: (r) => r.premiumPlan,
    driver: (d) => d.premiumPlan,
    pending: (_) => null,
  );

  /// When the premium status was last updated. Pending users have none.
  DateTime? get premiumUpdatedAt => map(
    rider: (r) => r.premiumUpdatedAt,
    driver: (d) => d.premiumUpdatedAt,
    pending: (_) => null,
  );

  /// Typed gender, derived from the persisted free-form [String]. `null` for
  /// pending users or when the stored value is absent/unrecognised.
  Gender? get genderEnum => map(
    rider: (r) => Gender.fromValue(r.gender),
    driver: (d) => Gender.fromValue(d.gender),
    pending: (_) => null,
  );

  /// Human-friendly name for UI surfaces. Falls back to the email's local part
  /// when no username is set, and finally to a generic label.
  String get displayName {
    final name = map(
      rider: (r) => r.username,
      driver: (d) => d.username,
      pending: (p) => p.username,
    );
    if (name.isNotEmpty) return name;
    final emailValue = map(
      rider: (r) => r.email,
      driver: (d) => d.email,
      pending: (p) => p.email,
    );
    final localPart = emailValue.split('@').first;
    if (localPart.isNotEmpty) return localPart;
    return 'User';
  }

  /// Up to two uppercase initials derived from [displayName], for avatars.
  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return '';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.map((p) => p[0].toUpperCase()).take(2).join();
    return letters.isNotEmpty ? letters : source[0].toUpperCase();
  }

  /// Whether the account is usable: email verified and not banned.
  bool get isActive => map(
    rider: (r) => r.isEmailVerified && !r.isBanned,
    driver: (d) => d.isEmailVerified && !d.isBanned,
    pending: (p) => p.isEmailVerified && !p.isBanned,
  );

  /// Whether the user has usable address coordinates. Always `false` for
  /// pending users (they carry no location fields).
  bool get hasLocation => map(
    rider: (r) => r.latitude != null && r.longitude != null,
    driver: (d) => d.latitude != null && d.longitude != null,
    pending: (_) => false,
  );

  /// Profile completion check
  bool get isProfileComplete {
    return map(
      rider: (r) =>
          r.username.isNotEmpty &&
          r.photoUrl != null &&
          r.phoneNumber != null &&
          r.isEmailVerified,
      driver: (d) =>
          d.username.isNotEmpty &&
          d.photoUrl != null &&
          d.phoneNumber != null &&
          d.isEmailVerified &&
          d.vehicleIds.isNotEmpty,
      pending: (_) => false,
    );
  }
}

/// Helper getters for type checking
extension UserTypeCheck on UserModel {
  bool get isRider => role == UserRole.rider;
  bool get isDriver => role == UserRole.driver;
  bool get isPending => role == UserRole.pending;

  RiderModel? get asRider => this is RiderModel ? this as RiderModel : null;
  DriverModel? get asDriver => this is DriverModel ? this as DriverModel : null;
}

/// Rider specific logic
extension RiderLogic on RiderModel {
  /// Bundled [LocationPoint] derived from the loose latitude/longitude/address
  /// primitives. Returns `null` when coordinates are not set.
  LocationPoint? get location {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return null;
    return LocationPoint(latitude: lat, longitude: lng, address: address ?? '');
  }
}

/// Driver specific logic
extension DriverLogic on DriverModel {
  List<String> get vehicles => vehicleIds;
  bool get hasVehicles => vehicleIds.isNotEmpty;
  bool get hasCompletedOnboarding => vehicleIds.isNotEmpty;
  bool get hasStripeAccount => stripeAccountId != null;
}
