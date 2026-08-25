import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'chat_repository.g.dart';

/// Expected (recoverable) chat failures surfaced to the UI.
///
/// Implements [Exception] rather than extending [Error]: Dart guidance is that
/// `Error` subtypes signal programmer bugs and are not meant to be caught,
/// while these conditions (blocked recipient, non-participant sender, missing
/// ride relationship) are ordinary runtime outcomes the caller must handle.
class ChatException implements Exception {
  const ChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// How two users are connected, per the single shared rule: a direct booking
/// pair (one booked the other as driver), a shared ride (both hold bookings on
/// the same ride), or a shared event (both in the event's participantIds).
enum ConnectionKind { bookingPair, sharedRide, sharedEvent }

/// Result of the connection rule for a user pair.
class ConnectionContext {
  final bool connected;
  final ConnectionKind? kind;
  final String? label;

  const ConnectionContext.connected({required this.kind, this.label})
      : connected = true;
  const ConnectionContext.notConnected()
      : connected = false,
        kind = null,
        label = null;
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return ChatRepository(
    firebase.firestore,
    firebase.storage,
    firebase.database,
  );
}

class ChatRepository {
  ChatRepository(this._firestore, this._storage, this._rtdb);

  final rtdb.FirebaseDatabase _rtdb;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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
      ..['lastMessageAt'] = chat.lastMessageAt != null
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
    final existing = await getChatById(
      _deterministicPrivateChatId(userId1, userId2),
    );
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

    final connection = await getConnectionContext(userId1, userId2);
    if (!connection.connected) {
      throw const ChatException(
        'You can message this person after you share a ride or event.',
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
      members: {
        userId1: ChatMember(
          userId: userId1,
          username: userName1,
          photoUrl: userPhoto1,
          joinedAt: DateTime.now(),
        ),
        userId2: ChatMember(
          userId: userId2,
          username: userName2,
          photoUrl: userPhoto2,
          joinedAt: DateTime.now(),
        ),
      },
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

  /// Resolves how [userId1] and [userId2] are connected: a direct booking
  /// pair (one booked the other as driver) or a shared event (both in the
  /// event's participantIds). Ordered and bounded — stops at the first hit.
  ///
  /// Every bookings query constrains the caller's own identity with plain
  /// equality, the only shape Firestore rules can prove readable here.
  /// Co-passenger "shared ride" detection would require reading another
  /// user's bookings or a participant array on ride docs; neither exists in
  /// the current schema, so [ConnectionKind.sharedRide] stays reserved for a
  /// future server-side implementation.
  Future<ConnectionContext> getConnectionContext(
    String userId1,
    String userId2,
  ) async {
    final myBookings = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('passengerId', isEqualTo: userId1)
        .limit(30)
        .get();
    for (final doc in myBookings.docs) {
      if (doc.data()['driverId'] == userId2) {
        return const ConnectionContext.connected(
          kind: ConnectionKind.bookingPair,
        );
      }
    }

    final myDrivenBookings = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('driverId', isEqualTo: userId1)
        .limit(30)
        .get();
    for (final doc in myDrivenBookings.docs) {
      if (doc.data()['passengerId'] == userId2) {
        return const ConnectionContext.connected(
          kind: ConnectionKind.bookingPair,
        );
      }
    }

    final events = await _firestore
        .collection(AppConstants.eventsCollection)
        .where('participantIds', arrayContains: userId1)
        .limit(30)
        .get();
    for (final doc in events.docs) {
      final data = doc.data();
      final participants = data['participantIds'];
      if (participants is List && participants.contains(userId2)) {
        return ConnectionContext.connected(
          kind: ConnectionKind.sharedEvent,
          label: data['title'] as String?,
        );
      }
    }

    return const ConnectionContext.notConnected();
  }

  /// Batched connection resolution for list rendering. Fixed query budget:
  /// two bounded booking scans of the caller's own docs for direct pairs and
  /// one bounded events query for co-participants; candidates with no hit
  /// map to [ConnectionContext.notConnected]. See [getConnectionContext] for
  /// why co-passenger rides are not resolvable client-side today.
  Future<Map<String, ConnectionContext>> getConnectionContexts(
    String selfUid,
    List<String> candidateUids,
  ) async {
    final candidates = candidateUids.where((uid) => uid != selfUid).toSet();
    final contexts = <String, ConnectionContext>{};
    if (candidates.isEmpty) return contexts;

    void record(String uid, ConnectionKind kind, {String? label}) {
      final existing = contexts[uid];
      if (existing != null &&
          _kindRank(existing.kind!) <= _kindRank(kind)) {
        return;
      }
      contexts[uid] = ConnectionContext.connected(kind: kind, label: label);
    }

    final passengerBookings = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('passengerId', isEqualTo: selfUid)
        .limit(30)
        .get();
    final driverBookings = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('driverId', isEqualTo: selfUid)
        .limit(30)
        .get();

    for (final doc in passengerBookings.docs) {
      final data = doc.data();
      final driverId = data['driverId'];
      if (driverId is String && candidates.contains(driverId)) {
        record(driverId, ConnectionKind.bookingPair);
      }
    }
    for (final doc in driverBookings.docs) {
      final data = doc.data();
      final passengerId = data['passengerId'];
      if (passengerId is String && candidates.contains(passengerId)) {
        record(passengerId, ConnectionKind.bookingPair);
      }
    }

    final events = await _firestore
        .collection(AppConstants.eventsCollection)
        .where('participantIds', arrayContains: selfUid)
        .limit(30)
        .get();
    for (final doc in events.docs) {
      final data = doc.data();
      final participants = data['participantIds'];
      if (participants is! List) continue;
      for (final uid in candidates) {
        if (participants.contains(uid)) {
          record(
            uid,
            ConnectionKind.sharedEvent,
            label: data['title'] as String?,
          );
        }
      }
    }

    for (final uid in candidates) {
      contexts.putIfAbsent(uid, ConnectionContext.notConnected);
    }
    return contexts;
  }

  static int _kindRank(ConnectionKind kind) => switch (kind) {
        ConnectionKind.bookingPair => 0,
        ConnectionKind.sharedRide => 1,
        ConnectionKind.sharedEvent => 2,
      };

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
      members: {
        driverId: ChatMember(
          userId: driverId,
          username: driverName,
          photoUrl: driverPhoto,
          role: MemberRole.owner,
          joinedAt: DateTime.now(),
        ),
      },
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
      members: {
        creatorId: ChatMember(
          userId: creatorId,
          username: creatorName,
          photoUrl: creatorPhoto,
          role: MemberRole.owner,
          joinedAt: DateTime.now(),
        ),
      },
    );
    final chatId = await createChat(chat);
    return chat.copyWith(id: chatId);
  }

  Future<ChatModel?> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    return doc.exists ? doc.data() : null;
  }

  /// Ride group chats are looked up with the caller's membership filter so
  /// the query provably satisfies the chats list rule (uid in
  /// participantIds) — without it Firestore denies the read outright.
  Future<ChatModel?> getChatByRideId(String rideId, String userId) async {
    final query = await _chatsCollection
        .where('type', isEqualTo: ChatType.rideGroup.name)
        .where('rideId', isEqualTo: rideId)
        .where('participantIds', arrayContains: userId)
        .limit(1)
        .get();
    return query.docs.isEmpty ? null : query.docs.first.data();
  }

  /// Over-fetches (150) because `isVisibleFor` filters client-side: hidden
  /// chats would otherwise consume limit slots and silently drop real chats
  /// below the visible cap.
  Stream<List<ChatModel>> streamUserChats(String userId) => _chatsCollection
      .where('participantIds', arrayContains: userId)
      .orderBy('lastMessageAt', descending: true)
      .limit(150)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => d.data())
            .where((chat) => chat.isVisibleFor(userId))
            .take(50)
            .toList(),
      );

  Future<ChatModel?> getOrCreateDirectChat(
    String userId1,
    String userId2,
  ) async {
    // MSG-D5: Resolve by deterministic id first (single doc read) before falling
    // back to the bounded scan, which is both read-heavy and unsound past the
    // 100-cap.
    final existing = await getChatById(
      _deterministicPrivateChatId(userId1, userId2),
    );
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
    required String userId,
    String? displayName,
    String? photoUrl,
    MemberRole role = MemberRole.member,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'members.$userId': ChatMember(
        userId: userId,
        username: displayName,
        photoUrl: photoUrl,
        role: role,
        joinedAt: DateTime.now(),
      ).toJson(),
      // FIX: serverTimestamp instead of DateTime.now() — avoids clock skew
      // on devices whose clocks are wrong.
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
  }

  Future<void> removeParticipant({
    required String chatId,
    required String userId,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'members.$userId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Chat settings ─────────────────────────────────────────────────────────

  Future<void> toggleMute({
    required String chatId,
    required String userId,
    required bool mute,
  }) async {
    await _chatsCollection.doc(chatId).update({
      'mutedUntil.$userId':
          mute ? FieldValue.serverTimestamp() : FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
  }

  Future<void> clearChat({
    required String chatId,
    required String userId,
  }) async {
    await _rawChatRef(chatId).update({
      'hiddenBy.$userId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearChatHistoryForUser({
    required String chatId,
    required String userId,
  }) async {
    await _rawChatRef(chatId).update({
      'clearedAt.$userId': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<String> sendMessage(MessageModel message) async {
    // Enforce message length to prevent Firestore document size abuse.
    if (message.content.length > 2000) {
      throw ChatException(
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
        throw ChatException(
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
          throw ChatException(
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
        throw ChatException('Invalid draft chat id: ${message.chatId}');
      }

      // MSG-D6: Enforce the same ride-interaction authorization gate as
      // getOrCreatePrivateChat before seeding a 1:1 chat from a client-supplied
      // draft id, so a crafted 'draft-{self}__{anyUid}' cannot bypass the
      // relationship requirement at the app layer.
      final otherUserId = participantIds.firstWhere(
        (id) => id != message.senderId,
      );
      final connection = await getConnectionContext(
        message.senderId,
        otherUserId,
      );
      if (!connection.connected) {
        throw const ChatException(
          'You can message this person after you share a ride or event.',
        );
      }

      // Blocked-check also applies on the create path: without it, a first
      // message from a fresh draft would bypass the recipient's block list
      // (the check below only ran when the chat document already existed).
      final draftBlocked = await _hasRecipientBlockedSender(
        recipientId: otherUserId,
        senderId: message.senderId,
      );
      if (draftBlocked) {
        throw ChatException(
          'sendMessage: $otherUserId has blocked ${message.senderId}',
        );
      }
      isCreatingChat = true;
    } else {
      throw ChatException(
        'sendMessage: chat does not exist: ${message.chatId}',
      );
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

    // COST: exactly two writes per send regardless of group size. Unread
    // state is derived from members.{uid}.lastReadAt vs lastMessageAt — no
    // per-recipient increments, so the chat document stays off the
    // single-document contention path Firebase warns about.
    final previewUpdate = <String, dynamic>{
      'lastMessageContent': message.content,
      'lastMessageSenderId': message.senderId,
      'lastMessageType': message.type.name,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'hiddenBy.${message.senderId}': FieldValue.delete(),
    };
    if (isCreatingChat) {
      previewUpdate['participantIds'] = participantIds;
    }
    batch.set(
      _rawChatRef(message.chatId),
      previewUpdate,
      SetOptions(merge: true),
    );

    await batch.commit();
    return docRef.id;
  }

  Future<bool> _hasRecipientBlockedSender({
    required String recipientId,
    required String senderId,
  }) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(recipientId)
        .get();
    final blocked = Set<String>.from(
      doc.data()?['blockedUsers'] as List? ?? const <String>[],
    );
    return blocked.contains(senderId);
  }

  // FIX: Removed pointless try/catch — String.split and replaceFirst never
  // throw checked exceptions. The original catch silenced real errors.
  List<String> _extractParticipantsFromDraftId(String draftChatId) {
    final parts = draftChatId.replaceFirst('draft-', '').split('__');
    return parts.length == 2 ? parts : const [];
  }

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
      unawaited(innerSub?.cancel());

      var query = _messagesCollection(chatId)
          .where('deletedAt', isEqualTo: null)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (clearedAt != null) {
        query = _messagesCollection(chatId)
            .where('deletedAt', isEqualTo: null)
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

    outerSub = _chatsCollection
        .doc(chatId)
        .snapshots()
        .listen(
          (chatSnap) {
            final clearedAt = chatSnap.data()?.clearedAt[userId];
            // Only (re)start the inner stream when clearedAt changes or on first
            // event; other chat-doc writes don't affect the message query.
            if (hasStarted && clearedAt == lastClearedAt) return;
            hasStarted = true;
            lastClearedAt = clearedAt;
            startInner(clearedAt);
          },
          onError: (Object e, StackTrace st) {
            // A permanent outer failure (e.g. chat doc deleted or permission
            // revoked) must also stop the inner message stream, otherwise it keeps
            // emitting orphaned messages after the parent listener is gone.
            unawaited(innerSub?.cancel());
            if (!controller.isClosed) controller.addError(e, st);
          },
        );

    controller.onCancel = () {
      unawaited(outerSub?.cancel());
      unawaited(innerSub?.cancel());
    };
    return controller.stream;
  }

  Future<({List<MessageModel> messages, bool hasMore})> loadMoreMessages({
    required String chatId,
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final snapshot = await _messagesCollection(chatId)
        .where('deletedAt', isEqualTo: null)
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

  /// Advances the member's read cursor — ONE write, zero reads. Every
  /// receipt and badge in the system is derived from this timestamp
  /// (Sendbird/Twilio/Mattermost pattern); nothing per-message is written.
  Future<void> markAsRead(String chatId, String userId) {
    return _rawChatRef(chatId).update({
      'members.$userId.lastReadAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Tombstone stores empty content + a timestamp; the UI renders the
  /// locale-correct "message deleted" text from [MessageModel.isTombstone].
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) => _rawMessageRef(chatId, messageId).update({
    'deletedAt': FieldValue.serverTimestamp(),
    'content': '',
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

  /// Reactions become Firestore map keys (`reactions.<emoji>`), so the value
  /// must be short and free of field-path metacharacters; anything else would
  /// corrupt the document's map structure.
  static final RegExp _reactionForbidden = RegExp(r'[.^$#\[\]/\\]');

  static bool _isValidReaction(String reaction) {
    if (reaction.isEmpty || reaction.length > 8) return false;
    return !_reactionForbidden.hasMatch(reaction);
  }

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) {
    if (!_isValidReaction(reaction)) {
      throw ChatException('Unsupported reaction: $reaction');
    }
    return _messagesCollection(chatId).doc(messageId).update({
      'reactions.$reaction': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) {
    if (!_isValidReaction(reaction)) {
      throw ChatException('Unsupported reaction: $reaction');
    }
    return _messagesCollection(chatId).doc(messageId).update({
      'reactions.$reaction': FieldValue.arrayRemove([userId]),
    });
  }

  // ── Typing indicators (Realtime Database) ─────────────────────────────────
  // Ephemeral signals live in RTDB: flat-rate bandwidth instead of
  // per-write Firestore billing, and onDisconnect() cleans up crashed
  // clients server-side — the official Firebase presence pattern.

  static const Duration _typingStaleAfter = Duration(seconds: 30);

  rtdb.DatabaseReference _typingRef(String chatId, String userId) => _rtdb
      .ref('chat_status/$chatId/typing')
      .child(userId);

  Future<void> setTyping({
    required String chatId,
    required String userId,
    required String username,
    required bool isTyping,
  }) async {
    final ref = _typingRef(chatId, userId);
    if (isTyping) {
      // onDisconnect guarantees removal even if the app is killed mid-typing.
      await ref.onDisconnect().remove();
      await ref.set({
        'userId': userId,
        'username': username,
        'startedAt': rtdb.ServerValue.timestamp,
      });
    } else {
      await ref.remove();
    }
  }

  Stream<List<TypingIndicator>> streamTypingIndicators(String chatId) {
    late StreamSubscription<rtdb.DatabaseEvent> sub;
    final controller = StreamController<List<TypingIndicator>>();
    controller.onListen = () {
      sub = _rtdb
          .ref('chat_status/$chatId/typing')
          .onValue
          .listen((event) {
        if (!controller.isClosed) return;
        final value = event.snapshot.value;
        final list = <TypingIndicator>[];
        if (value is Map<Object?, Object?>) {
          final cutoff = DateTime.now()
              .subtract(_typingStaleAfter)
              .millisecondsSinceEpoch;
          value.forEach((key, raw) {
            if (raw is! Map<Object?, Object?>) return;
            final startedAt = raw['startedAt'];
            if (startedAt is! int || startedAt <= cutoff) return;
            list.add(
              TypingIndicator(
                userId: raw['userId'] as String? ?? key.toString(),
                username: raw['username'] as String? ?? '',
                chatId: chatId,
                startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
              ),
            );
          });
        }
        if (!controller.isClosed) controller.add(list);
      });
    };
    controller.onCancel = () => unawaited(sub.cancel());
    return controller.stream;
  }

  // ── File uploads ──────────────────────────────────────────────────────────

  static const int _maxUploadBytes = 5 * 1024 * 1024; // 5 MB

  static final RegExp _unsafeFileNameChars = RegExp('[^A-Za-z0-9._-]');

  static const Set<String> _allowedImageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
  };

  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
    required String fileName,
  }) async {
    final size = await imageFile.length();
    if (size > _maxUploadBytes) {
      throw const ChatException('Image must be smaller than 5 MB');
    }
    // The picker supplies the original file name; strip any directory or
    // path-hostile characters and verify the extension is an image so a
    // renamed archive cannot be planted under chats/.
    final dotIndex = fileName.lastIndexOf('.');
    final ext = (dotIndex >= 0
        ? fileName.substring(dotIndex).toLowerCase()
        : '');
    if (!_allowedImageExtensions.contains(ext)) {
      throw const ChatException('Only image attachments are supported.');
    }
    final baseName = fileName
        .substring(0, dotIndex >= 0 ? dotIndex : fileName.length)
        .replaceAll(_unsafeFileNameChars, '_');
    if (baseName.isEmpty) {
      throw const ChatException('Invalid file name.');
    }

    final ref = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('attachments')
        .child('$baseName$ext');
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
    final clearedAt = chat?.clearedAt[userId];

    var query = _messagesCollection(chatId)
        .where('deletedAt', isEqualTo: null)
        .where('createdAt', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .orderBy('createdAt', descending: true)
        .limit(limit + 1);

    if (clearedAt != null) {
      query = _messagesCollection(chatId)
          .where('deletedAt', isEqualTo: null)
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

  // ── Event group chats ────────────────────────────────────────────────────
  // Migrated from features/events so every chat-creation path lives here.

  /// Ensures the event group chat exists and contains the requesting user.
  ///
  /// Premium entitlement is enforced inside the transaction; the caller does
  /// not need to pre-check it.
  Future<String> ensureEventGroupChat({
    required EventModel event,
    required String userId,
  }) async {
    final eventRef = _firestore
        .collection(AppConstants.eventsCollection)
        .doc(event.id);

    return _firestore.runTransaction((tx) async {
      final eventSnap = await tx.get(eventRef);
      final latestEvent = eventSnap.exists
          ? EventModel.fromJson(eventSnap.data()! as Map<String, dynamic>)
          : event;

      final isParticipant =
          latestEvent.participantIds.contains(userId) ||
          latestEvent.creatorId == userId;

      if (!isParticipant) {
        throw Exception('Join the event before opening the group chat.');
      }

      final userIsPremium = await _isPremiumSubscriber(
        tx: tx,
        userId: userId,
      );

      if (!userIsPremium) {
        throw Exception(
          'Event group chat is a Premium feature. Upgrade to access attendee chat.',
        );
      }

      final creatorIsPremium = await _isPremiumSubscriber(
        tx: tx,
        userId: latestEvent.creatorId,
      );

      final chatId = _resolveEventChatId(latestEvent);

      final participantIds = _premiumEventChatParticipants(
        creatorId: latestEvent.creatorId,
        creatorIsPremium: creatorIsPremium,
        userIsPremium: userIsPremium,
        userId: userId,
      );

      final chatRef = _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId);

      final chatSnap = await tx.get(chatRef);

      if (chatSnap.exists) {
        tx.set(
          chatRef,
          _eventChatMergePayload(
            participantIds: participantIds,
            creatorId: latestEvent.creatorId,
          ),
          SetOptions(merge: true),
        );
      } else {
        tx.set(
          chatRef,
          _eventChatCreatePayload(
            chatId: chatId,
            creatorId: latestEvent.creatorId,
            event: latestEvent,
            participantIds: participantIds,
          ),
        );
      }

      return chatId;
    });
  }

  Future<bool> _isPremiumSubscriber({
    required Transaction tx,
    required String userId,
  }) async {
    final userSnap = await tx.get(
      _firestore.collection(AppConstants.usersCollection).doc(userId),
    );
    final userData = userSnap.data();
    return userData is Map<String, dynamic> && userData['isPremium'] == true;
  }

  List<String> _premiumEventChatParticipants({
    required String creatorId,
    required bool creatorIsPremium,
    required bool userIsPremium,
    required String userId,
  }) {
    return <String>{
      if (creatorIsPremium) creatorId,
      if (userIsPremium) userId,
    }.toList();
  }

  String _resolveEventChatId(EventModel event) {
    final configuredChatId = event.chatGroupId?.trim();
    if (configuredChatId != null && configuredChatId.isNotEmpty) {
      return configuredChatId;
    }
    return event.id;
  }

  Map<String, dynamic> _eventChatCreatePayload({
    required String chatId,
    required EventModel event,
    required String creatorId,
    required List<String> participantIds,
  }) {
    final joinedAt = DateTime.now();
    return {
      'id': chatId,
      'type': ChatType.eventGroup.name,
      'createdBy': creatorId,
      'eventId': event.id,
      'premiumOnly': true,
      'groupName': event.title,
      if ((event.imageUrl ?? '').isNotEmpty) 'groupPhotoUrl': event.imageUrl,

      'participantIds': participantIds,
      'members': {
        for (final uid in participantIds)
          uid: ChatMember(
            userId: uid,
            role: uid == creatorId ? MemberRole.owner : MemberRole.member,
            joinedAt: joinedAt,
          ).toJson(),
      },

      'lastMessageContent': null,
      'lastMessageSenderId': null,
      'lastMessageType': MessageType.system.name,

      'pinnedBy': <String>[],

      'isActive': true,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _eventChatMergePayload({
    required List<String> participantIds,
    required String creatorId,
  }) {
    final joinedAt = DateTime.now();
    return {
      if (participantIds.isNotEmpty)
        'participantIds': FieldValue.arrayUnion(participantIds),
      // New members get a fresh cursor; existing entries are untouched so
      // read cursors survive re-joins.
      'members': {
        for (final uid in participantIds)
          uid: ChatMember(
            userId: uid,
            role: uid == creatorId ? MemberRole.owner : MemberRole.member,
            joinedAt: joinedAt,
          ).toJson(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}





