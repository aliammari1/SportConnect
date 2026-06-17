// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map json) => _MessageModel(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  content: json['content'] as String,
  senderPhotoUrl: json['senderPhotoUrl'] as String?,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sending,
  mediaUrl: json['mediaUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  locationName: json['locationName'] as String?,
  rideId: json['rideId'] as String?,
  replyToMessageId: json['replyToMessageId'] as String?,
  replyToContent: json['replyToContent'] as String?,
  reactions:
      (json['reactions'] as Map?)?.map(
        (k, e) => MapEntry(
          k as String,
          (e as List<dynamic>).map((e) => e as String).toList(),
        ),
      ) ??
      const {},
  readBy:
      (json['readBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  deliveredTo:
      (json['deliveredTo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isEdited: json['isEdited'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  editedAt: const TimestampConverter().fromJson(json['editedAt']),
);

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'senderPhotoUrl': instance.senderPhotoUrl,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationName': instance.locationName,
      'rideId': instance.rideId,
      'replyToMessageId': instance.replyToMessageId,
      'replyToContent': instance.replyToContent,
      'reactions': instance.reactions,
      'readBy': instance.readBy,
      'deliveredTo': instance.deliveredTo,
      'isEdited': instance.isEdited,
      'isDeleted': instance.isDeleted,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'editedAt': const TimestampConverter().toJson(instance.editedAt),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.location: 'location',
  MessageType.ride: 'ride',
  MessageType.system: 'system',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};

_ChatParticipant _$ChatParticipantFromJson(Map json) => _ChatParticipant(
  userId: json['uid'] as String,
  username: json['username'] as String,
  photoUrl: json['photoUrl'] as String?,
  isAdmin: json['isAdmin'] as bool? ?? false,
  isMuted: json['isMuted'] as bool? ?? false,
  role: $enumDecodeNullable(_$ParticipantRoleEnumMap, json['role']),
  lastSeenAt: const TimestampConverter().fromJson(json['lastSeenAt']),
  joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
);

Map<String, dynamic> _$ChatParticipantToJson(_ChatParticipant instance) =>
    <String, dynamic>{
      'uid': instance.userId,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'isAdmin': instance.isAdmin,
      'isMuted': instance.isMuted,
      'role': _$ParticipantRoleEnumMap[instance.role],
      'lastSeenAt': const TimestampConverter().toJson(instance.lastSeenAt),
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
    };

const _$ParticipantRoleEnumMap = {
  ParticipantRole.member: 'member',
  ParticipantRole.admin: 'admin',
  ParticipantRole.owner: 'owner',
};

_ChatModel _$ChatModelFromJson(Map json) => _ChatModel(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$ChatTypeEnumMap, json['type']) ?? ChatType.private,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map(
            (e) =>
                ChatParticipant.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  groupName: json['groupName'] as String?,
  groupPhotoUrl: json['groupPhotoUrl'] as String?,
  description: json['description'] as String?,
  rideId: json['rideId'] as String?,
  eventId: json['eventId'] as String?,
  lastMessageContent: json['lastMessageContent'] as String?,
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
  lastMessageSenderName: json['lastMessageSenderName'] as String?,
  lastMessageType:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['lastMessageType']) ??
      MessageType.text,
  lastMessageAt: const TimestampConverter().fromJson(json['lastMessageAt']),
  unreadCounts:
      (json['unreadCounts'] as Map?)?.map(
        (k, e) => MapEntry(k as String, (e as num).toInt()),
      ) ??
      const {},
  mutedBy:
      (json['mutedBy'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as bool),
      ) ??
      const {},
  pinnedBy:
      (json['pinnedBy'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as bool),
      ) ??
      const {},
  deletedAtBy: json['deletedAtBy'] == null
      ? const {}
      : const TimestampMapConverter().fromJson(json['deletedAtBy']),
  clearedAtBy: json['clearedAtBy'] == null
      ? const {}
      : const TimestampMapConverter().fromJson(json['clearedAtBy']),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ChatModelToJson(
  _ChatModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$ChatTypeEnumMap[instance.type]!,
  'participants': instance.participants.map((e) => e.toJson()).toList(),
  'participantIds': instance.participantIds,
  'groupName': instance.groupName,
  'groupPhotoUrl': instance.groupPhotoUrl,
  'description': instance.description,
  'rideId': instance.rideId,
  'eventId': instance.eventId,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'lastMessageSenderName': instance.lastMessageSenderName,
  'lastMessageType': _$MessageTypeEnumMap[instance.lastMessageType]!,
  'lastMessageAt': const TimestampConverter().toJson(instance.lastMessageAt),
  'unreadCounts': instance.unreadCounts,
  'mutedBy': instance.mutedBy,
  'pinnedBy': instance.pinnedBy,
  'deletedAtBy': const TimestampMapConverter().toJson(instance.deletedAtBy),
  'clearedAtBy': const TimestampMapConverter().toJson(instance.clearedAtBy),
  'isActive': instance.isActive,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$ChatTypeEnumMap = {
  ChatType.private: 'private',
  ChatType.rideGroup: 'rideGroup',
  ChatType.eventGroup: 'eventGroup',
  ChatType.support: 'support',
};

_TypingIndicator _$TypingIndicatorFromJson(Map json) => _TypingIndicator(
  userId: json['userId'] as String,
  username: json['username'] as String,
  chatId: json['chatId'] as String,
  startedAt: const TimestampConverter().fromJson(json['startedAt']),
);

Map<String, dynamic> _$TypingIndicatorToJson(_TypingIndicator instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'chatId': instance.chatId,
      'startedAt': const TimestampConverter().toJson(instance.startedAt),
    };
