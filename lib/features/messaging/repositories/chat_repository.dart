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

  CollectionReference<TypingIndicator> _typingCollection(String chatId) =>
      _chatsCollection
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .withConverter(
            fromFirestore: (snap, _) => TypingIndicator.fromJson(snap.data()!),
            toFirestore: (t, _) => t.toJson(),
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
    final now = DateTime.now();
    await docRef.set(
      chat.copyWith(
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
        lastMessageAt: chat.lastMessageAt ?? now,
      ),
    );
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

    final newChat = ChatModel(
      id: '',
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

    final chatId = await createChat(newChat);
    return newChat.copyWith(id: chatId);
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
    await _chatsCollection.doc(chatId).update({
      'deletedAtBy.$userId': FieldValue.serverTimestamp(),
      'unreadCounts.$userId': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _chatCache.remove(chatId);
  }

  Future<void> clearChatHistoryForUser({
    required String chatId,
    required String userId,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'clearedAtBy.$userId': FieldValue.serverTimestamp(),
      'unreadCounts.$userId': 0,
      'updatedAt': FieldValue.serverTimestamp(),
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
    } else if (message.chatId.startsWith('draft-')) {
      participantIds = _extractParticipantsFromDraftId(message.chatId);

      if (participantIds.length != 2 ||
          !participantIds.contains(message.senderId)) {
        throw StateError('Invalid draft chat id: ${message.chatId}');
      }
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
    batch.set(
      _rawChatRef(message.chatId),
      {
        'lastMessageContent': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageSenderName': message.senderName,
        'lastMessageType': message.type.name,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'participantIds': participantIds,
        'deletedAtBy.${message.senderId}': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );

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
    return _chatsCollection.doc(chatId).snapshots().asyncExpand((chatSnap) {
      final chat = chatSnap.data();
      final clearedAt = chat?.clearedAtBy[userId];

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

      return query.snapshots().map(
        (snap) => snap.docs.map((d) => d.data()).toList(),
      );
    });
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
    final snapshot = await _messagesCollection(chatId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(100)
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
    batch.update(_rawChatRef(chatId), {'unreadCounts.$userId': 0});
    await batch.commit();
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
        'startedAt': FieldValue.serverTimestamp(),
        // FIX M-3: expiresAt lets the server-side query filter out stale
        // indicators from users who killed the app without calling setTyping(false).
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(seconds: 30)),
        ),
      });
    } else {
      await ref.delete();
    }
  }

  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) =>
      _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.typingCollection)
          .where('expiresAt', isGreaterThan: Timestamp.now())
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
