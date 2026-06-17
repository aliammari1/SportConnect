import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'chat_repository.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

class ChatRepository {
  ChatRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Map<String, ({ChatModel chat, DateTime expiresAt})> _chatCache = {};
  final Map<String, ({Set<String> blockedUsers, DateTime expiresAt})>
  _blockedUsersCache = {};
  static const Duration _cacheTtl = Duration(seconds: 20);

  // ── Collection references ────────────────────────────────────────────────

  CollectionReference<ChatModel> get _chatsCollection => _firestore
      .collection(AppConstants.chatsCollection)
      .withConverter(
        fromFirestore: (snap, _) => ChatModel.fromJson(snap.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  CollectionReference<MessageModel> _messagesCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .withConverter(
            fromFirestore: (snap, _) => MessageModel.fromJson(snap.data()!),
            toFirestore: (msg, _) => msg.toJson(),
          );

  // ── Raw doc references (used when FieldValue sentinels are needed) ────────

  DocumentReference<Map<String, dynamic>> _rawChatRef(String chatId) =>
      _firestore.collection(AppConstants.chatsCollection).doc(chatId);

  DocumentReference<Map<String, dynamic>> _rawMessageRef(
    String chatId,
    String messageId,
  ) => _firestore
      .collection(AppConstants.chatsCollection)
      .doc(chatId)
      .collection(AppConstants.messagesCollection)
      .doc(messageId);

  // ── Chat CRUD ─────────────────────────────────────────────────────────────

  Future<String> createChat(ChatModel chat) async {
    final docRef = _chatsCollection.doc();
    // MSG-003: Use FieldValue.serverTimestamp() instead of client DateTime.now()
    // to avoid clock skew corrupting lastMessageAt ordering in streamUserChats.
    final map = chat.copyWith(id: docRef.id).toJson()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..['lastMessageAt'] =
          chat.lastMessageAt != null
              ? Timestamp.fromDate(chat.lastMessageAt!)
              : FieldValue.serverTimestamp();
    await _rawChatRef(docRef.id).set(map);
    return docRef.id;
  }

  Future<ChatModel> getOrCreatePrivateChat({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) async {
    // MSG-D5: Look up the existing DM directly by its deterministic id (single
    // doc read) instead of scanning up to 100 private chats. The scan both
    // amplified reads and could miss a target chat beyond the 100-cap, creating
    // duplicates. Fall back to the legacy scan only if the deterministic doc is
    // absent, to still find chats created before deterministic ids existed.
    final existing =
        await getChatById(_deterministicPrivateChatId(userId1, userId2));
    if (existing != null) return existing;

    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .limit(100)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) return chat;
    }

    final hasRideInteraction = await _hasRideInteractionBetween(
      userId1,
      userId2,
    );
    if (!hasRideInteraction) {
      throw StateError(
        'Direct chat requires a booking request or ride participation.',
      );
    }

    // MSG-D5: Use a deterministic document id derived from the sorted uids and
    // create-if-absent inside a transaction, so two concurrent invocations
    // (e.g. a double-tap or both users tapping) converge on a single document
    // instead of each missing the existence check and writing a duplicate.
    final chatId = _deterministicPrivateChatId(userId1, userId2);
    final docRef = _rawChatRef(chatId);

    final newChat = ChatModel(
      id: chatId,
      participantIds: [userId1, userId2],
      participants: [
        ChatParticipant(
          userId: userId1,
          username: userName1,
          photoUrl: userPhoto1,
          joinedAt: DateTime.now(),
        ),
        ChatParticipant(
          userId: userId2,
          username: userName2,
          photoUrl: userPhoto2,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    final created = await _firestore.runTransaction((txn) async {
      final snap = await txn.get(docRef);
      if (snap.exists) {
        return ChatModel.fromJson(snap.data()!);
      }
      // MSG-003: serverTimestamp() rather than client DateTime.now() to avoid
      // clock skew corrupting lastMessageAt ordering in streamUserChats.
      final map = newChat.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp()
        ..['lastMessageAt'] = FieldValue.serverTimestamp();
      txn.set(docRef, map);
      return newChat;
    });
    return created;
  }

  /// Deterministic document id for a 1:1 chat, derived from the sorted
  /// participant uids so concurrent get-or-create calls converge on one doc.
  /// Note: intentionally NOT prefixed with `draft-`, since that prefix is
  /// reserved for not-yet-persisted local drafts handled specially in
  /// sendMessage / streamMessagesForUser.
  static String _deterministicPrivateChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return 'dm_${sorted[0]}__${sorted[1]}';
  }

  Future<bool> _hasRideInteractionBetween(
    String userId1,
    String userId2,
  ) async {
    final firstDirection = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('passengerId', isEqualTo: userId1)
        .where('driverId', isEqualTo: userId2)
        .limit(1)
        .get();
    if (firstDirection.docs.isNotEmpty) return true;

    final secondDirection = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('passengerId', isEqualTo: userId2)
        .where('driverId', isEqualTo: userId1)
        .limit(1)
        .get();
    return secondDirection.docs.isNotEmpty;
  }

  Future<ChatModel> createRideChat({
    required String rideId,
    required String driverId,
    required String driverName,
    required String rideName,
    String? driverPhoto,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.rideGroup,
      rideId: rideId,
      groupName: rideName,
      participantIds: [driverId],
      participants: [
        ChatParticipant(
          userId: driverId,
          username: driverName,
          photoUrl: driverPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );
    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  Future<ChatModel> createEventChat({
    required String eventId,
    required String creatorId,
    required String creatorName,
    required String eventName,
    String? creatorPhoto,
  }) async {
    final chat = ChatModel(
      id: '',
      type: ChatType.eventGroup,
      eventId: eventId,
      groupName: eventName,
      participantIds: [creatorId],
      participants: [
        ChatParticipant(
          userId: creatorId,
          username: creatorName,
          photoUrl: creatorPhoto,
          isAdmin: true,
          joinedAt: DateTime.now(),
        ),
      ],
    );
    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  Future<ChatModel?> getChatById(String chatId) async {
    final now = DateTime.now();
    final cached = _chatCache[chatId];
    if (cached != null && now.isBefore(cached.expiresAt)) {
      return cached.chat;
    }

    final doc = await _chatsCollection.doc(chatId).get();
    final chat = doc.exists ? doc.data() : null;
    if (chat != null) {
      _chatCache[chatId] = (chat: chat, expiresAt: now.add(_cacheTtl));
    }
    return chat;
  }

  Future<ChatModel?> getChatByRideId(String rideId) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.rideGroup.name)
        .where('rideId', isEqualTo: rideId)
        .limit(1)
        .get();
    return query.docs.isEmpty ? null : query.docs.first.data();
  }

  Stream<List<ChatModel>> streamUserChats(String userId) => _chatsCollection
      .where('participantIds', arrayContains: userId)
      .orderBy('lastMessageAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => d.data())
            .where((chat) => chat.isVisibleFor(userId))
            .toList(),
      );

  Future<ChatModel?> getOrCreateDirectChat(
    String userId1,
    String userId2,
  ) async {
    // MSG-D5: Resolve by deterministic id first (single doc read) before falling
    // back to the bounded scan, which is both read-heavy and unsound past the
    // 100-cap.
    final existing =
        await getChatById(_deterministicPrivateChatId(userId1, userId2));
    if (existing != null) return existing;

    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.private.name)
        .where('participantIds', arrayContains: userId1)
        .limit(100)
        .get();

    for (final doc in query.docs) {
      final chat = doc.data();
      if (chat.participantIds.contains(userId2)) return chat;
    }
    return null;
  }

  // ── Participant management ────────────────────────────────────────────────

  Future<void> addParticipant({
    required String chatId,
    required ChatParticipant participant,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayUnion([participant.userId]),
      // FIX: serverTimestamp instead of DateTime.now() — avoids clock skew
      // on devices whose clocks are wrong.
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _chatCache.remove(chatId);
  }

  /// Idempotent — adds [userId] to participants only if not already present.
  ///
  /// [FieldValue.arrayUnion] is atomic and idempotent at the Firestore server
  /// level, so no read-then-write transaction is required. This also sidesteps
  /// the [Transaction.get] return-type ambiguity in some cloud_firestore
  /// versions where [DocumentSnapshot.data] is typed as [Object?] rather than
  /// [Map<String, dynamic>?], causing a compile error on the `[]` operator.

  Future<void> ensureParticipant({
    required String chatId,
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      'participantIds': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _chatsCollection.doc(chatId).update(updates);
    _chatCache.remove(chatId);
  }

  Future<void> removeParticipant({
    required String chatId,
    required String userId,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _chatCache.remove(chatId);
  }

  // ── Chat settings ─────────────────────────────────────────────────────────

  Future<void> toggleMute({
    required String chatId,
    required String userId,
    required bool mute,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'mutedBy.$userId': mute,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _chatCache.remove(chatId);
  }

  Future<void> togglePin({
    required String chatId,
    required String userId,
    required bool pin,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'pinnedBy.$userId': pin,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _chatCache.remove(chatId);
  }

  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) async {
    // MSG-D9: Read-then-write inside a transaction so a concurrent
    // FieldValue.increment from sendMessage forces a retry instead of being
    // silently clobbered by a blind set-0 update. The get() establishes the
    // read that Firestore tracks for conflict detection.
    final ref = _rawChatRef(chatId);
    await _firestore.runTransaction((txn) async {
      await txn.get(ref);
      txn.update(ref, {
        'deletedAtBy.$userId': FieldValue.serverTimestamp(),
        'unreadCounts.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    _chatCache.remove(chatId);
  }

  Future<void> clearChatHistoryForUser({
    required String chatId,
    required String userId,
  }) async {
    // MSG-D9: See clearChat — read-then-write inside a transaction so a racing
    // increment from sendMessage cannot be clobbered.
    final ref = _rawChatRef(chatId);
    await _firestore.runTransaction((txn) async {
      await txn.get(ref);
      txn.update(ref, {
        'clearedAtBy.$userId': FieldValue.serverTimestamp(),
        'unreadCounts.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    _chatCache.remove(chatId);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<String> sendMessage(MessageModel message) async {
    // Enforce message length to prevent Firestore document size abuse.
    if (message.content.length > 2000) {
      throw ArgumentError(
        'Message content must not exceed 2000 characters '
        '(got ${message.content.length}).',
      );
    }

    final chat = await getChatById(message.chatId);
    final List<String> participantIds;
    // MSG-D3: Whether this send creates the chat doc (draft path). Only then do
    // we write the full participantIds array; for an existing chat the array is
    // maintained atomically by add/removeParticipant via arrayUnion/arrayRemove,
    // so overwriting it here with cached data would clobber concurrent changes.
    final bool isCreatingChat;

    if (chat != null) {
      // Verify sender is a participant — prevents message injection by
      // authenticated users who happen to know a chatId.
      if (!chat.participantIds.contains(message.senderId)) {
        throw StateError(
          'sendMessage: ${message.senderId} is not a participant '
          'in chat ${message.chatId}',
        );
      }

      // FIX: Parallel fetch — was sequential (N+1). Fetches all recipient
      // docs concurrently before checking blocked status.
      final recipientIds = chat.participantIds
          .where((id) => id != message.senderId)
          .toList(growable: false);
      final blockedChecks = await Future.wait(
        recipientIds.map(
          (recipientId) => _hasRecipientBlockedSender(
            recipientId: recipientId,
            senderId: message.senderId,
          ),
        ),
      );

      for (var i = 0; i < blockedChecks.length; i++) {
        if (blockedChecks[i]) {
          throw StateError(
            'sendMessage: ${recipientIds[i]} has blocked ${message.senderId}',
          );
        }
      }

      participantIds = chat.participantIds;
      isCreatingChat = false;
    } else if (message.chatId.startsWith('draft-')) {
      participantIds = _extractParticipantsFromDraftId(message.chatId);

      if (participantIds.length != 2 ||
          !participantIds.contains(message.senderId)) {
        throw StateError('Invalid draft chat id: ${message.chatId}');
      }

      // MSG-D6: Enforce the same ride-interaction authorization gate as
      // getOrCreatePrivateChat before seeding a 1:1 chat from a client-supplied
      // draft id, so a crafted 'draft-{self}__{anyUid}' cannot bypass the
      // relationship requirement at the app layer.
      final otherUserId = participantIds.firstWhere(
        (id) => id != message.senderId,
      );
      final hasRideInteraction = await _hasRideInteractionBetween(
        message.senderId,
        otherUserId,
      );
      if (!hasRideInteraction) {
        throw StateError(
          'Direct chat requires a booking request or ride participation.',
        );
      }
      isCreatingChat = true;
    } else {
      throw StateError('sendMessage: chat does not exist: ${message.chatId}');
    }

    final docRef = _messagesCollection(message.chatId).doc();
    final messageWithId = message.copyWith(
      id: docRef.id,
      // Local DateTime for optimistic UI — overridden with serverTimestamp below.
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );

    final batch = _firestore.batch();

    // FIX M-2: Override createdAt with serverTimestamp so clients with wrong
    // clocks cannot backdate or forward-date messages.
    final messageJson = messageWithId.toJson()
      ..['createdAt'] = FieldValue.serverTimestamp();
    batch.set(_rawMessageRef(message.chatId, docRef.id), messageJson);
    // MSG-D3: Only write the full participantIds array when this send is
    // creating the chat doc (draft path). For an existing chat the array is
    // owned by add/removeParticipant (arrayUnion/arrayRemove); overwriting it
    // here with up-to-20s cached data clobbers concurrent membership changes.
    final previewUpdate = <String, dynamic>{
      'lastMessageContent': message.content,
      'lastMessageSenderId': message.senderId,
      'lastMessageSenderName': message.senderName,
      'lastMessageType': message.type.name,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAtBy.${message.senderId}': FieldValue.delete(),
    };
    if (isCreatingChat) {
      previewUpdate['participantIds'] = participantIds;
    }
    batch.set(
      _rawChatRef(message.chatId),
      previewUpdate,
      SetOptions(merge: true),
    );

    // MSG-001: Increment unread count for every recipient atomically so that
    // concurrent sends from different clients compose correctly.
    for (final recipientId in participantIds.where(
      (id) => id != message.senderId,
    )) {
      batch.update(_rawChatRef(message.chatId), {
        'unreadCounts.$recipientId': FieldValue.increment(1),
      });
    }

    await batch.commit();
    _chatCache.remove(message.chatId);
    return docRef.id;
  }

  Future<bool> _hasRecipientBlockedSender({
    required String recipientId,
    required String senderId,
  }) async {
    final now = DateTime.now();
    final cached = _blockedUsersCache[recipientId];
    if (cached != null && now.isBefore(cached.expiresAt)) {
      return cached.blockedUsers.contains(senderId);
    }

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(recipientId)
        .get();
    final blocked = Set<String>.from(
      doc.data()?['blockedUsers'] as List? ?? const <String>[],
    );
    _blockedUsersCache[recipientId] = (
      blockedUsers: blocked,
      expiresAt: now.add(_cacheTtl),
    );
    return blocked.contains(senderId);
  }

  // FIX: Removed pointless try/catch — String.split and replaceFirst never
  // throw checked exceptions. The original catch silenced real errors.
  List<String> _extractParticipantsFromDraftId(String draftChatId) {
    final parts = draftChatId.replaceFirst('draft-', '').split('__');
    return parts.length == 2 ? parts : const [];
  }

  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) =>
      _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<MessageModel>> streamMessagesForUser({
    required String chatId,
    required String userId,
    int limit = 50,
  }) {
    // MSG-002: Use a manual switchMap so that each new outer event (chat doc
    // change, e.g. clearedAtBy updated) cancels the previous inner subscription
    // and opens a new one. asyncExpand pauses the outer stream while the inner
    // Firestore stream is active, meaning subsequent outer events are silently
    // dropped.
    // MSG-003: A broadcast controller does not buffer events, so any emission
    // that arrives before Riverpod attaches its (single) listener is silently
    // dropped, leaving the chat stuck loading/empty until the next snapshot. Use
    // the default single-subscription controller, which buffers until a listener
    // attaches.
    final controller = StreamController<List<MessageModel>>();
    StreamSubscription<DocumentSnapshot<ChatModel>>? outerSub;
    StreamSubscription<List<MessageModel>>? innerSub;
    // MSG-002: Track the value that actually affects the inner query so we only
    // re-subscribe when it changes, instead of re-reading the whole message
    // window on every chat-doc metadata write (lastMessage*, unreadCounts, …).
    var hasStarted = false;
    DateTime? lastClearedAt;

    void startInner(DateTime? clearedAt) {
      innerSub?.cancel();

      var query = _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (clearedAt != null) {
        query = _messagesCollection(chatId)
            .where('isDeleted', isEqualTo: false)
            .where('createdAt', isGreaterThan: Timestamp.fromDate(clearedAt))
            .orderBy('createdAt', descending: true)
            .limit(limit);
      }

      innerSub = query
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList())
          .listen(
            (msgs) {
              if (!controller.isClosed) controller.add(msgs);
            },
            onError: (Object e, StackTrace st) {
              if (!controller.isClosed) controller.addError(e, st);
            },
          );
    }

    outerSub = _chatsCollection.doc(chatId).snapshots().listen(
      (chatSnap) {
        final clearedAt = chatSnap.data()?.clearedAtBy[userId];
        // Only (re)start the inner stream when clearedAt changes or on first
        // event; other chat-doc writes don't affect the message query.
        if (hasStarted && clearedAt == lastClearedAt) return;
        hasStarted = true;
        lastClearedAt = clearedAt;
        startInner(clearedAt);
      },
      onError: (Object e, StackTrace st) {
        if (!controller.isClosed) controller.addError(e, st);
      },
    );

    controller.onCancel = () {
      outerSub?.cancel();
      innerSub?.cancel();
    };

    return controller.stream;
  }

  Future<({List<MessageModel> messages, bool hasMore})> loadMoreMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final snapshot = await _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .orderBy('createdAt', descending: true)
        .limit(limit + 1)
        .get();

    return (
      messages: snapshot.docs.take(limit).map((d) => d.data()).toList(),
      hasMore: snapshot.docs.length > limit,
    );
  }

  // FIX: Was using `whereNotIn: [userId]` which checks the scalar field value
  // rather than array membership — always returned nothing or threw.
  // Replaced with a client-side filter after a bounded fetch.

  Future<void> markAsRead(String chatId, String userId) async {
    // MSG-005: "Mark visible as read" means the NEWEST messages, so order purely
    // by createdAt desc. A senderId inequality would force senderId to be the
    // first orderBy (Firestore constraint), making the 50-doc window the
    // alphabetically-first senders rather than the most recent messages — in
    // group chats with >50 messages that permanently strands later-uid senders'
    // unread messages. Filter senderId != userId client-side instead.
    final snapshot = await _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final unreadDocs = snapshot.docs.where((doc) {
      final msg = doc.data();
      return msg.senderId != userId && !msg.isReadBy(userId);
    }).toList();

    if (unreadDocs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadDocs) {
      batch.update(doc.reference, {
        'readBy': FieldValue.arrayUnion([userId]),
        'status': MessageStatus.read.name,
      });
    }
    await batch.commit();

    // MSG-D1/MSG-D2: Reconcile the per-user badge in a transaction and clamp at
    // zero. The 50-doc window is not aligned with how unreadCounts was
    // incremented (sendMessage adds +1 per recipient per message) and clearChat
    // may have already zeroed the counter, so a blind FieldValue.increment(-n)
    // can drive the badge negative. max(0, current - n) keeps it authoritative
    // and non-negative.
    final chatRef = _rawChatRef(chatId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(chatRef);
      final data = snap.data();
      final raw = (data?['unreadCounts'] as Map<String, dynamic>?)?[userId];
      final current = (raw is num) ? raw.toInt() : 0;
      final next = current - unreadDocs.length;
      txn.update(chatRef, {
        'unreadCounts.$userId': next < 0 ? 0 : next,
      });
    });
    _chatCache.remove(chatId);
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'isDeleted': true,
    'content': 'This message was deleted',
  });

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newContent,
  }) => _rawMessageRef(chatId, messageId).update({
    'content': newContent,
    'isEdited': true,
    // FIX: serverTimestamp instead of DateTime.now().
    'editedAt': FieldValue.serverTimestamp(),
  });

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'reactions.$reaction': FieldValue.arrayUnion([userId]),
  });

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) => _messagesCollection(chatId).doc(messageId).update({
    'reactions.$reaction': FieldValue.arrayRemove([userId]),
  });

  // ── Typing indicators ─────────────────────────────────────────────────────

  Future<void> setTyping({
    required String chatId,
    required String userId,
    required String username,
    required bool isTyping,
  }) async {
    final ref = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.typingCollection)
        .doc(userId);

    if (isTyping) {
      await ref.set({
        'userId': userId,
        'username': username,
        'chatId': chatId,
        // MSG-D8: startedAt is a server timestamp, so the staleness filter in
        // streamTypingIndicators is immune to device clock skew. The previous
        // client-written 'expiresAt' (DateTime.now()+30s) made the indicator
        // expire instantly or linger depending on the sender's clock.
        'startedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  // MSG-D8: Typing indicators older than this are treated as stale. Compared
  // against the server-written startedAt rather than a client-written expiry.
  static const Duration _typingStaleAfter = Duration(seconds: 30);

  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) =>
      _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .where(
            'startedAt',
            isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(_typingStaleAfter),
            ),
          )
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => TypingIndicator.fromJson(d.data()))
                .toList(),
          );

  // ── File uploads ──────────────────────────────────────────────────────────

  static const int _maxUploadBytes = 5 * 1024 * 1024; // 5 MB

  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) async {
    final size = await imageFile.length();
    if (size > _maxUploadBytes) {
      throw Exception('Image must be smaller than 5 MB');
    }
    final ref = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('attachments')
        .child(fileName);
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  Future<({List<MessageModel> messages, bool hasMore})>
  loadMoreMessagesForUser({
    required String chatId,
    required String userId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final chat = await getChatById(chatId);
    final clearedAt = chat?.clearedAtBy[userId];

    var query = _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .orderBy('createdAt', descending: true)
        .limit(limit + 1);

    if (clearedAt != null) {
      query = _messagesCollection(chatId)
          .where('isDeleted', isEqualTo: false)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(clearedAt))
          .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
          .orderBy('createdAt', descending: true)
          .limit(limit + 1);
    }

    final snapshot = await query.get();
    return (
      messages: snapshot.docs.take(limit).map((d) => d.data()).toList(),
      hasMore: snapshot.docs.length > limit,
    );
  }
}
