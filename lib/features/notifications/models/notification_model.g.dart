// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map json) => _NotificationModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  title: json['title'] as String,
  body: json['body'] as String,
  priority:
      $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']) ??
      NotificationPriority.normal,
  referenceId: json['referenceId'] as String?,
  referenceType: json['referenceType'] as String?,
  senderId: json['senderId'] as String?,
  senderName: json['senderName'] as String?,
  senderPhotoUrl: json['senderPhotoUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  actionUrl: json['actionUrl'] as String?,
  data:
      (json['data'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
  isRead: json['isRead'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  isPushSent: json['isPushSent'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  readAt: const TimestampConverter().fromJson(json['readAt']),
  expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
);

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'referenceId': instance.referenceId,
      'referenceType': instance.referenceType,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderPhotoUrl': instance.senderPhotoUrl,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
      'data': instance.data,
      'isRead': instance.isRead,
      'isArchived': instance.isArchived,
      'isPushSent': instance.isPushSent,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'readAt': const TimestampConverter().toJson(instance.readAt),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.rideBookingRequest: 'rideBookingRequest',
  NotificationType.rideBookingAccepted: 'rideBookingAccepted',
  NotificationType.rideBookingRejected: 'rideBookingRejected',
  NotificationType.rideBookingCancelled: 'rideBookingCancelled',
  NotificationType.rideStartingSoon: 'rideStartingSoon',
  NotificationType.rideStarted: 'rideStarted',
  NotificationType.rideCompleted: 'rideCompleted',
  NotificationType.rideCancelled: 'rideCancelled',
  NotificationType.rideUpdated: 'rideUpdated',
  NotificationType.newMessage: 'newMessage',
  NotificationType.newGroupMessage: 'newGroupMessage',
  NotificationType.newFollower: 'newFollower',
  NotificationType.followAccepted: 'followAccepted',
  NotificationType.levelUp: 'levelUp',
  NotificationType.achievementUnlocked: 'achievementUnlocked',
  NotificationType.streakMilestone: 'streakMilestone',
  NotificationType.leaderboardRank: 'leaderboardRank',
  NotificationType.xpEarned: 'xpEarned',
  NotificationType.eventCancelled: 'eventCancelled',
  NotificationType.eventUpdated: 'eventUpdated',
  NotificationType.accountVerified: 'accountVerified',
  NotificationType.profileIncomplete: 'profileIncomplete',
  NotificationType.systemAlert: 'systemAlert',
  NotificationType.promotion: 'promotion',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

_NotificationPreferences _$NotificationPreferencesFromJson(Map json) =>
    _NotificationPreferences(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      rideNotifications: json['rideNotifications'] as bool? ?? true,
      messageNotifications: json['messageNotifications'] as bool? ?? true,
      socialNotifications: json['socialNotifications'] as bool? ?? true,
      gamificationNotifications:
          json['gamificationNotifications'] as bool? ?? true,
      promotionNotifications: json['promotionNotifications'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      emailRideSummary: json['emailRideSummary'] as bool? ?? true,
      emailWeeklyDigest: json['emailWeeklyDigest'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '08:00',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'pushEnabled': instance.pushEnabled,
  'rideNotifications': instance.rideNotifications,
  'messageNotifications': instance.messageNotifications,
  'socialNotifications': instance.socialNotifications,
  'gamificationNotifications': instance.gamificationNotifications,
  'promotionNotifications': instance.promotionNotifications,
  'emailEnabled': instance.emailEnabled,
  'emailRideSummary': instance.emailRideSummary,
  'emailWeeklyDigest': instance.emailWeeklyDigest,
  'quietHoursEnabled': instance.quietHoursEnabled,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
};
