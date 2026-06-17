// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideModel _$RideModelFromJson(Map json) => _RideModel(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  route: RideRoute.fromJson(Map<String, dynamic>.from(json['route'] as Map)),
  schedule: RideSchedule.fromJson(
    Map<String, dynamic>.from(json['schedule'] as Map),
  ),
  capacity: RideCapacity.fromJson(
    Map<String, dynamic>.from(json['capacity'] as Map),
  ),
  pricing: RidePricing.fromJson(
    Map<String, dynamic>.from(json['pricing'] as Map),
  ),
  preferences: RidePreferences.fromJson(
    Map<String, dynamic>.from(json['preferences'] as Map),
  ),
  eventId: json['eventId'] as String?,
  eventName: json['eventName'] as String?,
  status:
      $enumDecodeNullable(_$RideStatusEnumMap, json['status']) ??
      RideStatus.draft,
  ridePhase: json['ridePhase'] as String?,
  vehicleId: json['vehicleId'] as String?,
  vehicleInfo: json['vehicleInfo'] as String?,
  bookingIds:
      (json['bookingIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
  notes: json['notes'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  completedAt: const TimestampConverter().fromJson(json['completedAt']),
  cancelledAt: const TimestampConverter().fromJson(json['cancelledAt']),
  cancellationReason: json['cancellationReason'] as String?,
);

Map<String, dynamic> _$RideModelToJson(_RideModel instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'route': instance.route.toJson(),
      'schedule': instance.schedule.toJson(),
      'capacity': instance.capacity.toJson(),
      'pricing': instance.pricing.toJson(),
      'preferences': instance.preferences.toJson(),
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'status': _$RideStatusEnumMap[instance.status]!,
      'ridePhase': instance.ridePhase,
      'vehicleId': instance.vehicleId,
      'vehicleInfo': instance.vehicleInfo,
      'bookingIds': instance.bookingIds,
      'reviewCount': instance.reviewCount,
      'averageRating': instance.averageRating,
      'xpReward': instance.xpReward,
      'notes': instance.notes,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'completedAt': const TimestampConverter().toJson(instance.completedAt),
      'cancelledAt': const TimestampConverter().toJson(instance.cancelledAt),
      'cancellationReason': instance.cancellationReason,
    };

const _$RideStatusEnumMap = {
  RideStatus.draft: 'draft',
  RideStatus.active: 'active',
  RideStatus.full: 'full',
  RideStatus.inProgress: 'inProgress',
  RideStatus.completed: 'completed',
  RideStatus.cancelled: 'cancelled',
};
