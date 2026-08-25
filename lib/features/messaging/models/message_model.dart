import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType { text, image, location, ride, system }

/// Local, client-only send pipeline state. Server-side read/delivery truth
/// lives on [ChatModel.members].{uid}.lastReadAt — never persisted here.
enum MessageStatus { sending, sent, failed }

enum ChatType { private, rideGroup, eventGroup, support }

enum MemberRole {
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

    /// Idempotency key: deterministic doc id = hash(chatId, clientMsgId) so
    /// offline retries overwrite instead of duplicating (zero extra reads).
    String? clientMsgId,

    /// Hydrated display copy; bubbles fall back to chat.profiles when null.
    String? senderName,
    String? senderPhotoUrl,

    required String content,
    @Default(MessageType.text) MessageType type,

    /// Local send-pipeline state only (sending/sent/failed).
    @Default(MessageStatus.sending) MessageStatus status,

    String? mediaUrl,
    String? thumbnailUrl,

    // Location attachment
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

    // Metadata
    @Default(false) bool isEdited,
    @TimestampConverter() DateTime? deletedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? editedAt,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  bool get isTombstone => deletedAt != null;

  bool isFromUser(String userId) => senderId == userId;

  int get totalReactions =>
      reactions.values.fold(0, (sum, list) => sum + list.length);

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  bool get isReply => replyToMessageId != null;

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasReactions => reactions.isNotEmpty;

  bool get isPending => status == MessageStatus.sending;

  bool get hasFailed => status == MessageStatus.failed;
}

// ── ChatMember ────────────────────────────────────────────────────────────────

/// Per-member channel state — the single source of truth for read cursors.
@freezed
abstract class ChatMember with _$ChatMember {
  const factory ChatMember({
    @JsonKey(name: 'uid') required String userId,
    String? username,
    String? photoUrl,
    @Default(MemberRole.member) MemberRole role,
    @TimestampConverter() DateTime? joinedAt,

    /// Read cursor: everything with createdAt <= this is read by this member.
    /// Derived receipts/badges compare against this — no per-message writes.
    @TimestampConverter() DateTime? lastReadAt,
  }) = _ChatMember;

  const ChatMember._();

  factory ChatMember.fromJson(Map<String, dynamic> json) =>
      _$ChatMemberFromJson(json);
}

// ── ChatModel ─────────────────────────────────────────────────────────────────

@freezed
abstract class ChatModel with _$ChatModel {
  const factory ChatModel({
    required String id,
    @Default(ChatType.private) ChatType type,
    String? createdBy,

    // Membership: primitive array powers arrayContains queries; the map holds
    // per-member state and is patched via dot-paths (members.{uid}.lastReadAt).
    @Default([]) List<String> participantIds,
    @Default({}) Map<String, ChatMember> members,

    // Group display
    String? groupName,
    String? groupPhotoUrl,
    String? description,

    // Linked context
    String? rideId,
    String? eventId,
    @Default(false) bool premiumOnly,

    // Last message preview
    String? lastMessageContent,
    String? lastMessageSenderId,
    @Default(MessageType.text) MessageType lastMessageType,
    @TimestampConverter() DateTime? lastMessageAt,

    // Per-user settings
    @TimestampMapConverter() @Default({}) Map<String, DateTime> mutedUntil,
    @Default([]) List<String> pinnedBy,

    // One-sided hide: userId → hidden-at timestamp
    @TimestampMapConverter() @Default({}) Map<String, DateTime> hiddenBy,

    // One-sided history clear: userId → cleared-up-to timestamp
    @TimestampMapConverter() @Default({}) Map<String, DateTime> clearedAt,

    @Default(true) bool isActive,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ChatModel;

  const ChatModel._();

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  ChatMember? member(String userId) => members[userId];

  ChatMember? getOtherParticipant(String currentUserId) {
    if (type != ChatType.private || participantIds.length != 2) return null;
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );
    return members[otherId];
  }

  String getChatTitle(String currentUserId) {
    return switch (type) {
      ChatType.rideGroup => groupName ?? 'Ride Chat',
      ChatType.eventGroup => groupName ?? 'Event Chat',
      ChatType.support => 'Support',
      _ =>
        groupName ??
            getOtherParticipant(currentUserId)?.username ??
            'Unknown',
    };
  }

  String? getChatPhoto(String currentUserId) =>
      groupPhotoUrl ?? getOtherParticipant(currentUserId)?.photoUrl;

  bool get isGroup => type == ChatType.rideGroup || type == ChatType.eventGroup;

  bool get isPrivate => type == ChatType.private;

  int get memberCount => participantIds.length;

  /// Unread indicator, derived — never stored. True when the latest activity
  /// is newer than this member's read cursor and wasn't authored by them.
  bool hasUnread(String userId) {
    final at = lastMessageAt;
    if (at == null) return false;
    if (lastMessageSenderId == userId) return false;
    final cursor = members[userId]?.lastReadAt;
    return cursor == null || at.isAfter(cursor);
  }

  /// Derived receipt: [message] counts as read by [otherUid] once their
  /// cursor covers it. Replaces per-message readBy arrays entirely.
  bool isMessageReadBy(MessageModel message, String otherUid) {
    final cursor = members[otherUid]?.lastReadAt;
    if (cursor == null) return false;
    final at = message.createdAt;
    if (at == null) return false;
    return !at.isAfter(cursor);
  }

  bool isMutedBy(String userId) => mutedUntil[userId] != null;

  bool isPinnedBy(String userId) => pinnedBy.contains(userId);

  bool isVisibleFor(String userId) {
    final hiddenAt = hiddenBy[userId];
    if (hiddenAt == null) return true;
    final latestActivity = lastMessageAt ?? updatedAt ?? createdAt;
    if (latestActivity == null) return false;
    return latestActivity.isAfter(hiddenAt);
  }

  DateTime? messagesClearedBefore(String userId) => clearedAt[userId];
}

// ── TypingIndicator ───────────────────────────────────────────────────────────

/// DTO for RTDB typing nodes at `chat_status/{chatId}/typing/{uid}`.
/// Freshness is enforced by the repository against server-written
/// startedAt millis; crashed clients are cleaned up by onDisconnect().
@freezed
abstract class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required String userId,
    @Default('') String username,
    required String chatId,
    @TimestampConverter() DateTime? startedAt,
  }) = _TypingIndicator;

  const TypingIndicator._();

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);

  bool isActive({Duration ttl = const Duration(seconds: 30)}) =>
      startedAt != null && DateTime.now().difference(startedAt!) < ttl;
}
