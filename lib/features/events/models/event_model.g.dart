// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventModel _$EventModelFromJson(Map json) => _EventModel(
  id: json['id'] as String,
  creatorId: json['creatorId'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  location: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['location'] as Map),
  ),
  startsAt: const RequiredTimestampConverter().fromJson(json['startsAt']),
  endsAt: const TimestampConverter().fromJson(json['endsAt']),
  description: json['description'] as String?,
  organizerName: json['organizerName'] as String?,
  imageUrl: json['imageUrl'] as String?,
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  rideStatuses:
      (json['rideStatuses'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ) ??
      const {},
  meetupPinLocation: json['meetupPinLocation'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['meetupPinLocation'] as Map),
        ),
  chatGroupId: json['chatGroupId'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringPattern: $enumDecodeNullable(
    _$RecurrencePatternEnumMap,
    json['recurringPattern'],
  ),
  recurringEndDate: const TimestampConverter().fromJson(
    json['recurringEndDate'],
  ),
  costSplitEnabled: json['costSplitEnabled'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'title': instance.title,
      'type': _$EventTypeEnumMap[instance.type]!,
      'location': instance.location.toJson(),
      'startsAt': const RequiredTimestampConverter().toJson(instance.startsAt),
      'endsAt': const TimestampConverter().toJson(instance.endsAt),
      'description': instance.description,
      'organizerName': instance.organizerName,
      'imageUrl': instance.imageUrl,
      'participantIds': instance.participantIds,
      'maxParticipants': instance.maxParticipants,
      'isActive': instance.isActive,
      'rideStatuses': instance.rideStatuses,
      'meetupPinLocation': instance.meetupPinLocation?.toJson(),
      'chatGroupId': instance.chatGroupId,
      'isRecurring': instance.isRecurring,
      'recurringPattern': _$RecurrencePatternEnumMap[instance.recurringPattern],
      'recurringEndDate': const TimestampConverter().toJson(
        instance.recurringEndDate,
      ),
      'costSplitEnabled': instance.costSplitEnabled,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$EventTypeEnumMap = {EventType.running: 'running'};

const _$RecurrencePatternEnumMap = {
  RecurrencePattern.daily: 'daily',
  RecurrencePattern.weekly: 'weekly',
  RecurrencePattern.biweekly: 'biweekly',
  RecurrencePattern.monthly: 'monthly',
  RecurrencePattern.yearly: 'yearly',
};
