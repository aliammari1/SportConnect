// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiderModel _$RiderModelFromJson(Map json) => RiderModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
  gender: json['gender'] as String?,
  fcmToken: json['fcmToken'] as String? ?? '',
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isBanned: json['isBanned'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rating: json['rating'] == null
      ? const RatingBreakdown()
      : RatingBreakdown.fromJson(
          Map<String, dynamic>.from(json['rating'] as Map),
        ),
  gamification: json['gamification'] == null
      ? const GamificationStats()
      : GamificationStats.fromJson(
          Map<String, dynamic>.from(json['gamification'] as Map),
        ),
  preferences: json['preferences'] == null
      ? const UserPreferences()
      : UserPreferences.fromJson(
          Map<String, dynamic>.from(json['preferences'] as Map),
        ),
  expertise:
      $enumDecodeNullable(_$ExpertiseEnumMap, json['expertise']) ??
      Expertise.rookie,
  stripeCustomerId: json['stripeCustomerId'] as String?,
  isStripeCustomerCreated: json['isStripeCustomerCreated'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  $type: json['role'] as String?,
);

Map<String, dynamic> _$RiderModelToJson(RiderModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'gender': instance.gender,
      'fcmToken': instance.fcmToken,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isEmailVerified': instance.isEmailVerified,
      'isBanned': instance.isBanned,
      'isPremium': instance.isPremium,
      'blockedUsers': instance.blockedUsers,
      'rating': instance.rating.toJson(),
      'gamification': instance.gamification.toJson(),
      'preferences': instance.preferences.toJson(),
      'expertise': _$ExpertiseEnumMap[instance.expertise]!,
      'stripeCustomerId': instance.stripeCustomerId,
      'isStripeCustomerCreated': instance.isStripeCustomerCreated,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'role': instance.$type,
    };

const _$ExpertiseEnumMap = {
  Expertise.rookie: 'rookie',
  Expertise.intermediate: 'intermediate',
  Expertise.advanced: 'advanced',
  Expertise.expert: 'expert',
};

DriverModel _$DriverModelFromJson(Map json) => DriverModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
  gender: json['gender'] as String?,
  fcmToken: json['fcmToken'] as String? ?? '',
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isBanned: json['isBanned'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rating: json['rating'] == null
      ? const RatingBreakdown()
      : RatingBreakdown.fromJson(
          Map<String, dynamic>.from(json['rating'] as Map),
        ),
  gamification: json['gamification'] == null
      ? const GamificationStats()
      : GamificationStats.fromJson(
          Map<String, dynamic>.from(json['gamification'] as Map),
        ),
  preferences: json['preferences'] == null
      ? const UserPreferences()
      : UserPreferences.fromJson(
          Map<String, dynamic>.from(json['preferences'] as Map),
        ),
  expertise:
      $enumDecodeNullable(_$ExpertiseEnumMap, json['expertise']) ??
      Expertise.rookie,
  vehicleIds:
      (json['vehicleIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  stripeAccountId: json['stripeAccountId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  $type: json['role'] as String?,
);

Map<String, dynamic> _$DriverModelToJson(DriverModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'gender': instance.gender,
      'fcmToken': instance.fcmToken,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isEmailVerified': instance.isEmailVerified,
      'isBanned': instance.isBanned,
      'isPremium': instance.isPremium,
      'blockedUsers': instance.blockedUsers,
      'rating': instance.rating.toJson(),
      'gamification': instance.gamification.toJson(),
      'preferences': instance.preferences.toJson(),
      'expertise': _$ExpertiseEnumMap[instance.expertise]!,
      'vehicleIds': instance.vehicleIds,
      'stripeAccountId': instance.stripeAccountId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'role': instance.$type,
    };

PendingUserModel _$PendingUserModelFromJson(Map json) => PendingUserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
  expertise:
      $enumDecodeNullable(_$ExpertiseEnumMap, json['expertise']) ??
      Expertise.rookie,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isBanned: json['isBanned'] as bool? ?? false,
  fcmToken: json['fcmToken'] as String? ?? '',
  selectedRoleIntent: json['selectedRoleIntent'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  $type: json['role'] as String?,
);

Map<String, dynamic> _$PendingUserModelToJson(PendingUserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'expertise': _$ExpertiseEnumMap[instance.expertise]!,
      'isEmailVerified': instance.isEmailVerified,
      'isBanned': instance.isBanned,
      'fcmToken': instance.fcmToken,
      'selectedRoleIntent': instance.selectedRoleIntent,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'role': instance.$type,
    };
