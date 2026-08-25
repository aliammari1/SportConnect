import 'dart:async';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';

part 'chat_view_model.freezed.dart';
part 'chat_view_model.g.dart';

// ── Draft chat helpers ────────────────────────────────────────────────────────

const String kDraftChatPrefix = 'draft-';

String buildDraftChatId(String userId1, String userId2) {
  final sorted = [userId1, userId2]..sort();
  return '$kDraftChatPrefix${sorted[0]}__${sorted[1]}';
}

bool isDraftChatId(String chatId) => chatId.startsWith(kDraftChatPrefix);

// ── ChatActionsViewModel ──────────────────────────────────────────────────────

/// Plain-class wrapper for one-shot chat operations (upload, mute, block, etc.)
/// that don't require reactive state of their own.
// keepAlive: action-only VM - accessed from notification/background contexts.
@Riverpod(keepAlive: true)
class ChatActionsViewModel extends _$ChatActionsViewModel {
  @override
  void build() {
    return;
  }

  Future<void> clearChatHistoryForUser({
    required String chatId,
    required String userId,
  }) => ref
      .read(chatRepositoryProvider)
      .clearChatHistoryForUser(
        chatId: chatId,
        userId: userId,
      );
  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) => ref
      .read(chatRepositoryProvider)
      .uploadChatImage(
        chatId: chatId,
        imageFile: imageFile,
        fileName: fileName,
      );

  Future<void> toggleMute({
    required String chatId,
    required String userId,
    required bool mute,
  }) => ref
      .read(chatRepositoryProvider)
      .toggleMute(
        chatId: chatId,
        userId: userId,
        mute: mute,
      );

  Future<ChatModel?> getChatById(String chatId) =>
      ref.read(chatRepositoryProvider).getChatById(chatId);

  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) => ref
      .read(chatRepositoryProvider)
      .getOrCreatePrivateChat(
        userId1: userId1,
        userId2: userId2,
        userName1: userName1,
        userName2: userName2,
        userPhoto1: userPhoto1,
        userPhoto2: userPhoto2,
      );

  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) => ref
      .read(chatRepositoryProvider)
      .clearChat(
        chatId: chatId,
        userId: userId,
      );

  Future<void> blockUser({
    required String userId,
    required String blockedUserId,
    String? chatId,
  }) {
    final mute =
        (chatId != null && chatId.isNotEmpty)
        ? ref
              .read(chatRepositoryProvider)
              .toggleMute(chatId: chatId, userId: userId, mute: true)
        : Future<void>.value();
    return Future.wait([
      ref.read(profileRepositoryProvider).blockUser(userId, blockedUserId),
      mute,
    ]);
  }

  Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
    String? chatId,
  }) {
    final unmute =
        (chatId != null && chatId.isNotEmpty)
        ? ref
              .read(chatRepositoryProvider)
              .toggleMute(chatId: chatId, userId: userId, mute: false)
        : Future<void>.value();
    return Future.wait([
      ref.read(profileRepositoryProvider).unblockUser(userId, blockedUserId),
      unmute,
    ]);
  }
}

// ── Stream providers ──────────────────────────────────────────────────────────

/// Live stream of the user's chat list, ordered by last message time.
@riverpod
Stream<List<ChatModel>> userChats(Ref ref, String userId) =>
    ref.watch(chatRepositoryProvider).streamUserChats(userId);

@riverpod
Stream<List<String>> blockedUserIds(Ref ref, String userId) {
  return ref.watch(profileRepositoryProvider).streamBlockedUserIds(userId);
}

/// Messages stream for a single chat, filtered to non-deleted only.
@riverpod
Stream<List<MessageModel>> chatMessages(
  Ref ref,
  String chatId,
  String currentUserId,
) {
  return ref
      .watch(chatRepositoryProvider)
      .streamMessagesForUser(
        chatId: chatId,
        userId: currentUserId,
      );
}

/// Typing indicators stream for a single chat, non-expired only.
@riverpod
Stream<List<TypingIndicator>> chatTyping(Ref ref, String chatId) =>
    ref.watch(chatRepositoryProvider).streamTypingIndicators(chatId);

// ── ChatDetailViewModel ───────────────────────────────────────────────────────

@riverpod
class ChatDetailViewModel extends _$ChatDetailViewModel {
  // FIX: Removed _messagesSubscription and _typingSubscription — they were
  // declared but never assigned (the old _listenToMessages / _listenToTyping
  // methods were dead code once build() switched to ref.listen). Manual
  // StreamSubscription management is replaced entirely by ref.listen, which
  // Riverpod cancels automatically on provider disposal.
  Timer? _typingTimer;

  // Tracks whether a typing document is currently written for this user so
  // disposal can flush it. Without this, leaving the screen mid-typing leaves
  // the indicator visible to other participants until the staleness window
  // expires.
  bool _typingActive = false;
  String? _lastTypingUsername;

  @override
  ChatDetailState build(String chatId, String currentUserId) {
    // Cancel the debounce timer and flush any live typing document when the
    // provider is disposed. The repository is a keepAlive singleton, so the
    // fire-and-forget delete is safe after this notifier is torn down.
    ref.onDispose(() {
      _typingTimer?.cancel();
      if (_typingActive && _lastTypingUsername != null) {
        unawaited(
          _flushTypingOnDispose(_lastTypingUsername!),
        );
      }
    });

    // FIX: Draft chats have no Firestore document to stream. Return early
    // with isLoading: false so the UI shows the empty state immediately.
    if (isDraftChatId(chatId)) {
      return const ChatDetailState(isLoading: false);
    }

    ref.listen(chatMessagesProvider(chatId, currentUserId), (_, next) {
      next.whenData((liveMessages) {
        if (!ref.mounted) return;
        // MSG-D4: The live stream only carries the newest window (limit 50).
        // Overwriting state.messages wholesale would discard any older pages
        // fetched via loadMoreMessages. Instead, replace the head window with
        // the fresh live snapshot and keep any previously loaded older pages,
        // de-duplicating by id and re-sorting newest-first.
        state = state.copyWith(
          messages: _mergeLiveWindow(state.messages, liveMessages),
          isLoading: false,
        );
      });
    });

    ref.listen(chatTypingProvider(chatId), (_, next) {
      next.whenData((indicators) {
        if (!ref.mounted) return;
        state = state.copyWith(
          typingUsers: indicators
              .where((t) => t.userId != currentUserId)
              .toList(),
        );
      });
    });

    return const ChatDetailState();
  }

  // ── Read side-effects ───────────────────────────────────────────────────

  /// Marks all visible unread messages as read.
  /// Called by the view via ref.listen when new messages arrive — not in
  /// build() to avoid write side-effects during provider initialization.
  Future<void> markVisibleMessagesAsRead() async {
    if (isDraftChatId(chatId)) return;
    if (!ref.mounted) return;
    await _markMessagesAsRead(state.messages);
  }

  Future<void> _markMessagesAsRead(List<MessageModel> messages) async {
    // Derived-cursor guard: only write when something in the live window is
    // newer than our stored cursor. One tiny write, zero reads.
    final chat = await ref.read(chatRepositoryProvider).getChatById(chatId);
    final cursor = chat?.members[currentUserId]?.lastReadAt;
    final hasNew = messages.any(
      (m) =>
          m.senderId != currentUserId &&
          !m.isTombstone &&
          (cursor == null ||
              m.createdAt == null ||
              m.createdAt!.isAfter(cursor)),
    );
    if (!hasNew) return;
    if (!ref.mounted) return;
    await ref.read(chatRepositoryProvider).markAsRead(chatId, currentUserId);
  }

  // ── Send operations ─────────────────────────────────────────────────────

  // FIX: Renamed `imageUrl` → `mediaUrl` to match the unified field on
  // MessageModel (which replaced the old split imageUrl fields).
  Future<bool> sendMessage({
    required String content,
    required String senderName,
    String? senderPhotoUrl,
    MessageType type = MessageType.text,
    String? mediaUrl,
    double? latitude,
    double? longitude,
    String? replyToMessageId,
    String? replyToContent,
  }) async {
    // FIX: Clear any previous error at the start of a new send operation.
    state = state.copyWith(isSending: true, error: null);

    // Optimistic bubble: show the message immediately with status=sending.
    // The live snapshot replaces the head window on arrival (merge drops
    // non-pending locals newer than the window's oldest entry), and the entry
    // is stripped explicitly if the write fails.
    final optimistic = MessageModel(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: currentUserId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      latitude: latitude,
      longitude: longitude,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [optimistic, ...state.messages]);

    bool committed;
    try {
      await ref.read(chatRepositoryProvider).sendMessage(optimistic);
      committed = true;
    } on Exception catch (e) {
      committed = false;
      if (ref.mounted) {
        // Strip the failed optimistic bubble so only the failure banner and
        // restored composer text remain.
        state = state.copyWith(
          messages: state.messages.where((m) => m.id != optimistic.id).toList(),
          isSending: false,
          error: userFacingError(e),
        );
      }
    }

    if (!ref.mounted) {
      // The write itself may have succeeded even though this provider went
      // away; reporting success prevents the UI from offering a retry that
      // would duplicate an already-delivered message.
      return committed;
    }
    state = state.copyWith(isSending: false);

    await setTyping(false, senderName);

    if (!committed) return false;

    // Fire-and-forget in-app notification. Failures must never block send.
    unawaited(
      _sendNotifications(
        type: type,
        content: content,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
      ),
    );

    return true;
  }

  // Runs after disposal; only touches keepAlive singletons and captured
  // strings, never this notifier's state.
  Future<void> _flushTypingOnDispose(String username) {
    return ref
        .read(chatRepositoryProvider)
        .setTyping(
          chatId: chatId,
          userId: currentUserId,
          username: username,
          isTyping: false,
        );
  }

  // FIX: Extracted notification dispatch from sendMessage to remove ~20 lines
  // of nested try/catch that obscured the main send logic.
  Future<void> _sendNotifications({
    required MessageType type,
    required String content,
    required String senderName,
    String? senderPhotoUrl,
  }) async {
    try {
      if (!ref.mounted) return;
      final chat = await ref.read(chatRepositoryProvider).getChatById(chatId);
      if (!ref.mounted || chat == null) return;

      // Grapheme-aware truncation keeps surrogate pairs (emoji) intact at the
      // cut boundary, unlike raw code-unit substring.
      final characters = content.characters;
      final preview = type == MessageType.text
          ? (characters.length > 60 ? '${characters.take(60)}…' : content)
          : '[${type.name}]';

      final notificationRepo = ref.read(notificationRepositoryProvider);
      // Recipients are independent — dispatch in parallel instead of paying a
      // serial round-trip per participant on group chats.
      await Future.wait(
        chat.participantIds.where((id) => id != currentUserId).map((
          participantId,
        ) async {
          // Respect the recipient's per-chat mute setting (also covers blocked
          // users, since blockUser implicitly mutes). Muted participants must
          // not receive new-message notifications.
          if (chat.isMutedBy(participantId)) return;
          await notificationRepo.sendNewMessageNotification(
            toUserId: participantId,
            fromUserId: currentUserId,
            fromUserName: senderName,
            fromUserPhoto: senderPhotoUrl,
            chatId: chatId,
            messagePreview: preview,
          );
        }),
      );
    } on Exception catch (e, st) {
      // Non-fatal: message send must still succeed if notification dispatch fails.
      TalkerService.warning('Message notification dispatch failed: $e');
      TalkerService.error('Message notification dispatch error', e, st);
    }
  }

  Future<bool> sendImageMessage({
    required File imageFile,
    required String fileName,
    required String senderName,
    String? senderPhotoUrl,
    String? caption,
  }) async {
    if (!ref.mounted) return false;
    state = state.copyWith(isSending: true, error: null);
    try {
      final url = await ref
          .read(chatRepositoryProvider)
          .uploadChatImage(
            chatId: chatId,
            imageFile: imageFile,
            fileName: fileName,
          );
      if (!ref.mounted) return false;
      // Await inside the try so a send failure is surfaced through this
      // method's catch rather than escaping as an unhandled Future.
      return await sendMessage(
        content: caption ?? 'Photo',
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        type: MessageType.image,
        mediaUrl: url,
        replyToMessageId: state.replyToMessage?.id,
        replyToContent: state.replyToMessage?.content,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isSending: false, error: userFacingError(e));
      return false;
    }
  }

  Future<bool> sendLocationMessage({
    required String content,
    required double latitude,
    required double longitude,
    required String senderName,
    String? senderPhotoUrl,
  }) => sendMessage(
    content: content,
    senderName: senderName,
    senderPhotoUrl: senderPhotoUrl,
    type: MessageType.location,
    latitude: latitude,
    longitude: longitude,
    replyToMessageId: state.replyToMessage?.id,
    replyToContent: state.replyToMessage?.content,
  );

  // ── Pagination ──────────────────────────────────────────────────────────

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || state.messages.isEmpty) return;
    // MSG-007: Guard against a null createdAt cursor that can occur while a
    // locally-optimistic message is still pending its server timestamp. Using
    // DateTime.now() as a fallback would cause the query to skip all messages
    // older than now, silently dropping history.
    final cursor = state.messages.last.createdAt;
    if (cursor == null) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      if (!ref.mounted) return;
      final (:messages, :hasMore) = await ref
          .read(chatRepositoryProvider)
          .loadMoreMessagesForUser(
            chatId: chatId,
            userId: currentUserId,
            beforeTimestamp: cursor,
          );
      if (!ref.mounted) return;
      // MSG-D4: Merge the older page into the existing list, de-duplicating by
      // id (the page may overlap the live window) and keeping newest-first order
      // so the page survives subsequent live snapshots.
      state = state.copyWith(
        messages: _mergeMessages(state.messages, messages),
        isLoadingMore: false,
        hasMoreMessages: hasMore,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  // MSG-D4: Reconcile the live (head) window with previously loaded older
  // pages. Messages are ordered newest-first (createdAt descending). The live
  // snapshot is authoritative for the head: it reflects edits, deletions and
  // new arrivals within its window. Anything strictly older than the live
  // window's oldest message is a previously paged tail and is preserved.
  List<MessageModel> _mergeLiveWindow(
    List<MessageModel> current,
    List<MessageModel> liveWindow,
  ) {
    if (liveWindow.isEmpty) return current;
    final oldestLive = liveWindow.last.createdAt;
    // Keep only the previously loaded tail (older than the live window). A null
    // createdAt is a pending optimistic timestamp belonging to the head, so it
    // is dropped here and re-supplied by the live snapshot.
    final tail = oldestLive == null
        ? const <MessageModel>[]
        : current.where((m) {
            final c = m.createdAt;
            return c != null && c.isBefore(oldestLive);
          });
    return _mergeMessages(liveWindow.toList(), tail.toList());
  }

  // MSG-D4: Combine two message lists into a single id-keyed, de-duplicated,
  // newest-first list. When ids collide the entry from [primary] wins.
  List<MessageModel> _mergeMessages(
    List<MessageModel> primary,
    List<MessageModel> secondary,
  ) {
    final byId = <String, MessageModel>{};
    for (final m in secondary) {
      byId[m.id] = m;
    }
    for (final m in primary) {
      byId[m.id] = m;
    }
    final merged = byId.values.toList()
      ..sort((a, b) {
        final ac = a.createdAt;
        final bc = b.createdAt;
        // Pending (null createdAt) messages are newest — keep them at the head.
        if (ac == null && bc == null) return 0;
        if (ac == null) return -1;
        if (bc == null) return 1;
        return bc.compareTo(ac);
      });
    return merged;
  }

  // ── Typing ──────────────────────────────────────────────────────────────

  // FIX: Simplified from two symmetric if/else branches with duplicated
  // mounted checks and repository reads into a single linear flow.
  Future<void> setTyping(bool isTyping, String username) async {
    if (isDraftChatId(chatId)) return;
    _typingTimer?.cancel();
    _typingActive = isTyping;
    if (isTyping) _lastTypingUsername = username;
    if (!ref.mounted) return;

    await ref
        .read(chatRepositoryProvider)
        .setTyping(
          chatId: chatId,
          userId: currentUserId,
          username: username,
          isTyping: isTyping,
        );

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 5), () {
        if (ref.mounted) unawaited(setTyping(false, username));
      });
    }
  }

  void handleComposerTextChanged(String text, String username) {
    final trimmed = text.trim();

    if (trimmed.isNotEmpty && !state.isLocallyTyping) {
      state = state.copyWith(isLocallyTyping: true);
      unawaited(setTyping(true, username));
    }

    _typingTimer?.cancel();

    if (trimmed.isEmpty) {
      if (state.isLocallyTyping) {
        state = state.copyWith(isLocallyTyping: false);
        unawaited(setTyping(false, username));
      }
      return;
    }

    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (!ref.mounted) return;
      state = state.copyWith(isLocallyTyping: false);
      unawaited(setTyping(false, username));
    });
  }

  // ── Message mutations ───────────────────────────────────────────────────

  Future<void> deleteMessage(MessageModel message) async {
    // Defense-in-depth alongside firestore.rules: only the sender may soft-
    // delete. The rules reject non-owner content writes; this guard keeps the
    // failure local and loud instead of a round-trip permission error.
    if (message.senderId != currentUserId) {
      throw ChatException(
        'deleteMessage: ${message.senderId} is not the author of '
        '${message.id}',
      );
    }
    if (!ref.mounted) return;
    await ref
        .read(chatRepositoryProvider)
        .deleteMessage(
          chatId: chatId,
          messageId: message.id,
        );
  }

  Future<void> editMessage(String messageId, String newContent) async {
    if (!ref.mounted) return;
    // MSG-008: Catch write failures and surface them via state.error, consistent
    // with sendMessage and loadMoreMessages which both handle errors the same way.
    try {
      await ref
          .read(chatRepositoryProvider)
          .editMessage(
            chatId: chatId,
            messageId: messageId,
            newContent: newContent,
          );
    } on Exception catch (e) {
      if (ref.mounted) state = state.copyWith(error: userFacingError(e));
    }
  }

  Future<void> addReaction(String messageId, String reaction) async {
    if (!ref.mounted) return;
    await ref
        .read(chatRepositoryProvider)
        .addReaction(
          chatId: chatId,
          messageId: messageId,
          userId: currentUserId,
          reaction: reaction,
        );
  }

  // ── UI state mutations ──────────────────────────────────────────────────

  void setReplyTo(MessageModel? message) {
    if (!ref.mounted) return;
    state = state.copyWith(replyToMessage: message);
  }

  void clearReply() {
    if (!ref.mounted) return;
    state = state.copyWith(replyToMessage: null);
  }

  void setEmojiPickerVisible(bool visible) {
    if (!ref.mounted || state.showEmojiPicker == visible) return;
    state = state.copyWith(showEmojiPicker: visible);
  }
}

// ── ChatDetailState ───────────────────────────────────────────────────────────

/// FIX: Replaced hand-written copyWith with @freezed.
/// The old sentinel `static const _unset = Object()` pattern for nullable
/// fields is gone — freezed generates correct nullable copyWith automatically.
@freezed
abstract class ChatDetailState with _$ChatDetailState {
  const factory ChatDetailState({
    @Default([]) List<MessageModel> messages,
    @Default([]) List<TypingIndicator> typingUsers,
    @Default(true) bool isLoading,
    @Default(false) bool isSending,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMoreMessages,
    @Default(false) bool showEmojiPicker,
    @Default(false) bool isLocallyTyping,
    String? error,
    MessageModel? replyToMessage,
  }) = _ChatDetailState;
}

// ── One-shot providers ────────────────────────────────────────────────────────

/// Returns an existing direct chat or a local draft. The draft is persisted
/// to Firestore on first message send.
@riverpod
Future<ChatModel> getOrCreateChat(
  Ref ref, {
  required String userId1,
  required String userId2,
  required String userName1,
  required String userName2,
  String? userPhoto1,
  String? userPhoto2,
}) async {
  final repository = ref.read(chatRepositoryProvider);
  final existing = await repository.getOrCreateDirectChat(userId1, userId2);
  if (existing != null) return existing;

  return ChatModel(
    id: buildDraftChatId(userId1, userId2),
    participantIds: [userId1, userId2],
    members: {
      userId1: ChatMember(
        userId: userId1,
        username: userName1,
        photoUrl: userPhoto1,
      ),
      userId2: ChatMember(
        userId: userId2,
        username: userName2,
        photoUrl: userPhoto2,
      ),
    },
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Fetches the ride group chat for [rideId] visible to [userId], or null.
@riverpod
Future<ChatModel?> rideChatByRideId(Ref ref, {required String rideId}) async {
  final uid = ref.watch(currentAuthUidProvider).value;
  if (uid == null) return null;
  return ref.read(chatRepositoryProvider).getChatByRideId(rideId, uid);
}
