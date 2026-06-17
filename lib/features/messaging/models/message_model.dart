import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType { text, image, location, ride, system }

enum MessageStatus { sending, sent, delivered, read, failed }

enum ChatType { private, rideGroup, eventGroup, support }

enum ParticipantRole {
  @JsonValue('member')
  member,
  @JsonValue('admin')
  admin,
  @JsonValue('owner')
  owner,
}

// ── MessageModel ──────────────────────────────────────────────────────────────

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    String? senderPhotoUrl,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sending) MessageStatus status,

    String? mediaUrl,
    String? thumbnailUrl,

    // Location
    double? latitude,
    double? longitude,
    String? locationName,

    // Ride attachment
    String? rideId,

    // Reply context
    String? replyToMessageId,
    String? replyToContent,

    // Reactions: emoji → [userId, ...]
    @Default({}) Map<String, List<String>> reactions,

    // Read receipts
    @Default([]) List<String> readBy,
    @Default([]) List<String> deliveredTo,

    // Metadata
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? editedAt,
  }) = _MessageModel;
  // FIX: private constructor BEFORE the factory — required by freezed so that
  // custom methods below can reference `this` on the generated concrete class.
  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  bool isFromUser(String userId) => senderId == userId;
  bool isReadBy(String userId) => readBy.contains(userId);

  int get totalReactions =>
      reactions.values.fold(0, (sum, list) => sum + list.length);

  /// Whether this message carries an image/media attachment.
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  /// Whether this message is a reply to another message.
  bool get isReply => replyToMessageId != null;

  /// Whether this message carries a (complete) location attachment.
  bool get hasLocation => latitude != null && longitude != null;

  /// Whether this message has any emoji reactions.
  bool get hasReactions => reactions.isNotEmpty;

  /// Whether the message is still being sent (optimistic/in-flight).
  bool get isPending => status == MessageStatus.sending;

  /// Whether the message failed to send.
  bool get hasFailed => status == MessageStatus.failed;

  /// Whether every participant other than the sender has read this message.
  bool isReadByAll(Iterable<String> participantIds) =>
      participantIds.where((id) => id != senderId).every(readBy.contains);
}

// ── ChatParticipant ───────────────────────────────────────────────────────────

@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    @JsonKey(name: 'uid') required String userId,
    required String username,
    String? photoUrl,
    @Default(false) bool isAdmin,
    @Default(false) bool isMuted,
    // Role distinguishes the group owner/creator from regular admins/members.
    // Optional & nullable: legacy docs without this key deserialize to null.
    ParticipantRole? role,
    @TimestampConverter() DateTime? lastSeenAt,
    @TimestampConverter() DateTime? joinedAt,
  }) = _ChatParticipant;
  // Private constructor before factory — required to host custom methods.
  const ChatParticipant._();

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);

  /// Whether the participant was recently seen within [window].
  bool isOnline({Duration window = const Duration(minutes: 2)}) =>
      lastSeenAt != null && DateTime.now().difference(lastSeenAt!) < window;
}

// ── ChatModel ─────────────────────────────────────────────────────────────────

@freezed
abstract class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    @Default(ChatType.private) ChatType type,

    // Participants
    @Default([]) List<ChatParticipant> participants,
    @Default([]) List<String> participantIds,

    // Group
    String? groupName,
    String? groupPhotoUrl,
    String? description,

    // Ride / event
    String? rideId,
    String? eventId,

    // Last message preview
    String? lastMessageContent,
    String? lastMessageSenderId,
    String? lastMessageSenderName,
    @Default(MessageType.text) MessageType lastMessageType,
    @TimestampConverter() DateTime? lastMessageAt,

    // Unread counts: userId → count
    @Default({}) Map<String, int> unreadCounts,

    // Per-user settings
    @Default({}) Map<String, bool> mutedBy,
    @Default({}) Map<String, bool> pinnedBy,

    // One-sided deletion: userId → true
    // User removed the conversation from their chat list.
    // If a newer message arrives after this timestamp, the chat appears again.
    @TimestampMapConverter() @Default({}) Map<String, DateTime> deletedAtBy,

    // User cleared message history up to this timestamp.
    // The chat can stay visible, but older messages are hidden for this user.
    @TimestampMapConverter() @Default({}) Map<String, DateTime> clearedAtBy,

    @Default(true) bool isActive,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ChatModel;
  // FIX: private constructor before factory — required for custom methods below.
  const ChatModel._();

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  /// Returns the other participant in a private 1:1 chat, or null for groups.
  ChatParticipant? getOtherParticipant(String currentUserId) {
    if (type != ChatType.private || participants.length != 2) return null;
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }

  String getChatTitle(String currentUserId) {
    return switch (type) {
      ChatType.rideGroup => groupName ?? 'Ride Chat',
      ChatType.eventGroup => groupName ?? 'Event Chat',
      ChatType.support => 'Support',
      _ =>
        groupName ?? getOtherParticipant(currentUserId)?.username ?? 'Unknown',
    };
  }

  String? getChatPhoto(String currentUserId) =>
      groupPhotoUrl ?? getOtherParticipant(currentUserId)?.photoUrl;

  /// Whether this chat is a multi-participant group (ride or event).
  bool get isGroup => type == ChatType.rideGroup || type == ChatType.eventGroup;

  /// Whether this chat is a 1:1 private conversation.
  bool get isPrivate => type == ChatType.private;

  /// Participant count derived from whichever list is populated.
  int get participantCount =>
      participantIds.isNotEmpty ? participantIds.length : participants.length;

  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;
  bool hasUnread(String userId) => getUnreadCount(userId) > 0;
  bool isMutedBy(String userId) => mutedBy[userId] ?? false;
  bool isPinnedBy(String userId) => pinnedBy[userId] ?? false;
  bool isVisibleFor(String userId) {
    final deletedAt = deletedAtBy[userId];

    if (deletedAt == null) return true;

    final latestActivity = lastMessageAt ?? updatedAt ?? createdAt;

    if (latestActivity == null) return false;

    return latestActivity.isAfter(deletedAt);
  }

  DateTime? messagesClearedBefore(String userId) {
    return clearedAtBy[userId];
  }
}

// ── TypingIndicator ───────────────────────────────────────────────────────────

@freezed
abstract class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required String userId,
    required String username,
    required String chatId,
    @TimestampConverter() DateTime? startedAt,
  }) = _TypingIndicator;
  // Private constructor before factory — required to host custom methods.
  const TypingIndicator._();

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);

  /// Whether the typing record is still fresh (not a stale lingering entry).
  bool isActive({Duration ttl = const Duration(seconds: 6)}) =>
      startedAt != null && DateTime.now().difference(startedAt!) < ttl;
}
