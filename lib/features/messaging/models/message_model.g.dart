// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map json) => _MessageModel(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  senderId: json['senderId'] as String,
  clientMsgId: json['clientMsgId'] as String?,
  senderName: json['senderName'] as String?,
  senderPhotoUrl: json['senderPhotoUrl'] as String?,
  content: json['content'] as String,
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
  isEdited: json['isEdited'] as bool? ?? false,
  deletedAt: const TimestampConverter().fromJson(json['deletedAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  editedAt: const TimestampConverter().fromJson(json['editedAt']),
);

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'clientMsgId': instance.clientMsgId,
      'senderName': instance.senderName,
      'senderPhotoUrl': instance.senderPhotoUrl,
      'content': instance.content,
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
      'isEdited': instance.isEdited,
      'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
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
  MessageStatus.failed: 'failed',
};

_ChatMember _$ChatMemberFromJson(Map json) => _ChatMember(
  userId: json['uid'] as String,
  username: json['username'] as String?,
  photoUrl: json['photoUrl'] as String?,
  role:
      $enumDecodeNullable(_$MemberRoleEnumMap, json['role']) ??
      MemberRole.member,
  joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
  lastReadAt: const TimestampConverter().fromJson(json['lastReadAt']),
);

Map<String, dynamic> _$ChatMemberToJson(_ChatMember instance) =>
    <String, dynamic>{
      'uid': instance.userId,
      'username': instance.username,
      'photoUrl': instance.photoUrl,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
      'lastReadAt': const TimestampConverter().toJson(instance.lastReadAt),
    };

const _$MemberRoleEnumMap = {
  MemberRole.member: 'member',
  MemberRole.admin: 'admin',
  MemberRole.owner: 'owner',
};

_ChatModel _$ChatModelFromJson(Map json) => _ChatModel(
  id: json['id'] as String,
  type:
      $enumDecodeNullable(_$ChatTypeEnumMap, json['type']) ?? ChatType.private,
  createdBy: json['createdBy'] as String?,
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  members:
      (json['members'] as Map?)?.map(
        (k, e) => MapEntry(
          k as String,
          ChatMember.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      ) ??
      const {},
  groupName: json['groupName'] as String?,
  groupPhotoUrl: json['groupPhotoUrl'] as String?,
  description: json['description'] as String?,
  rideId: json['rideId'] as String?,
  eventId: json['eventId'] as String?,
  premiumOnly: json['premiumOnly'] as bool? ?? false,
  lastMessageContent: json['lastMessageContent'] as String?,
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
  lastMessageType:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['lastMessageType']) ??
      MessageType.text,
  lastMessageAt: const TimestampConverter().fromJson(json['lastMessageAt']),
  mutedUntil: json['mutedUntil'] == null
      ? const {}
      : const TimestampMapConverter().fromJson(json['mutedUntil']),
  pinnedBy:
      (json['pinnedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  hiddenBy: json['hiddenBy'] == null
      ? const {}
      : const TimestampMapConverter().fromJson(json['hiddenBy']),
  clearedAt: json['clearedAt'] == null
      ? const {}
      : const TimestampMapConverter().fromJson(json['clearedAt']),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ChatModelToJson(
  _ChatModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$ChatTypeEnumMap[instance.type]!,
  'createdBy': instance.createdBy,
  'participantIds': instance.participantIds,
  'members': instance.members.map((k, e) => MapEntry(k, e.toJson())),
  'groupName': instance.groupName,
  'groupPhotoUrl': instance.groupPhotoUrl,
  'description': instance.description,
  'rideId': instance.rideId,
  'eventId': instance.eventId,
  'premiumOnly': instance.premiumOnly,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'lastMessageType': _$MessageTypeEnumMap[instance.lastMessageType]!,
  'lastMessageAt': const TimestampConverter().toJson(instance.lastMessageAt),
  'mutedUntil': const TimestampMapConverter().toJson(instance.mutedUntil),
  'pinnedBy': instance.pinnedBy,
  'hiddenBy': const TimestampMapConverter().toJson(instance.hiddenBy),
  'clearedAt': const TimestampMapConverter().toJson(instance.clearedAt),
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
  username: json['username'] as String? ?? '',
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
