import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
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
    @TimestampConverter() DateTime? dateOfBirth,
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

    // Social
    @Default([]) List<String> blockedUsers,

    // Rider-specific: Passenger rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Rider-specific: Gamification
    @Default(GamificationStats()) GamificationStats gamification,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie) Expertise expertise,

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
    @TimestampConverter() DateTime? dateOfBirth,
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

    // Social
    @Default([]) List<String> blockedUsers,

    // Driver-specific: Driver rating
    @Default(RatingBreakdown()) RatingBreakdown rating,

    // Driver-specific: Gamification
    @Default(GamificationStats()) GamificationStats gamification,

    // Preferences
    @Default(UserPreferences()) UserPreferences preferences,

    // Expertise
    @Default(Expertise.rookie) Expertise expertise,

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
    @TimestampConverter() DateTime? dateOfBirth,
    @Default(Expertise.rookie) Expertise expertise,
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

/// Driver specific logic
extension DriverLogic on DriverModel {
  List<String> get vehicles => vehicleIds;
  bool get hasVehicles => vehicleIds.isNotEmpty;
  bool get hasCompletedOnboarding => vehicleIds.isNotEmpty;
  bool get hasStripeAccount => stripeAccountId != null;
}
