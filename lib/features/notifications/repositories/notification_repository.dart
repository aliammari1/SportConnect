import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations_en.dart';

part 'notification_repository.g.dart';

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(ref.watch(firebaseServiceProvider).firestore);
}

/// Notification Repository for Firestore operations
class NotificationRepository {
  NotificationRepository(this._firestore);
  final FirebaseFirestore _firestore;
  final AppLocalizationsEn _l10n = AppLocalizationsEn();

  /// Upper bound for bulk mark-as-read / archive operations so they never read
  /// and rewrite an unbounded notification history. Comfortably exceeds the
  /// windows the UI exposes (list limit 50, unread badge cap 100) while keeping
  /// read cost and latency predictable.
  static const int _bulkOpLimit = 500;

  CollectionReference<NotificationModel> get _notificationsCollection =>
      _firestore
          .collection(AppConstants.notificationsCollection)
          .withConverter<NotificationModel>(
            fromFirestore: (snapshot, _) =>
                NotificationModel.fromJson(snapshot.data()!),
            toFirestore: (notification, _) => notification.toJson(),
          );

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Create a notification

  Future<String> createNotification(NotificationModel notification) async {
    final docRef = _notificationsCollection.doc();
    // Use a raw-map write so FieldValue.serverTimestamp() is preserved;
    // the typed converter would reject a FieldValue in place of DateTime.
    final Map<String, dynamic> data = notification
        .copyWith(id: docRef.id)
        .toJson()
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.notificationsCollection)
        .doc(docRef.id)
        .set(data);
    return docRef.id;
  }

  /// Get notification by ID

  Future<NotificationModel?> getNotificationById(String id) async {
    final doc = await _notificationsCollection.doc(id).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Stream user's notifications

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream unread notification count

  Stream<int> streamUnreadCount(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        // Cap at 100 (not 99) so a count of exactly 100 signals ">99 unread"
        // and the badge can render the "99+" label; limiting to 99 would
        // saturate at 99 and make the "99+" branch unreachable.
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get user's notifications (paginated)

  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Mark notification as read

  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
      // Server timestamp avoids client-clock skew corrupting read ordering.
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all user notifications as read.
  /// Chunks into batches of 499 to stay within Firestore's 500-op limit.
  /// Bounded to [_bulkOpLimit] documents so cost/latency stay predictable and
  /// consistent with the windows the UI surfaces (the unread badge caps at 100,
  /// the list at 50); without this cap a long-lived user triggers an unbounded
  /// read+rewrite of their entire notification history.

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .limit(_bulkOpLimit)
        .get();

    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += 499) {
      final chunk = docs.sublist(i, (i + 499).clamp(0, docs.length));
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {
          'isRead': true,
          // Server timestamp keeps read ordering consistent regardless of the
          // device clock, and avoids a single client `now` across batches.
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  /// Archive notification (soft delete)

  Future<void> archiveNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isArchived': true,
    });
  }

  /// Archive all user notifications.
  /// Chunks into batches of 499 to stay within Firestore's 500-op limit.
  /// Bounded to [_bulkOpLimit] documents (see [markAllAsRead]) so this never
  /// reads+rewrites an unbounded notification history.

  Future<void> archiveAll(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .limit(_bulkOpLimit)
        .get();

    final docs = snapshot.docs;
    for (var i = 0; i < docs.length; i += 499) {
      final chunk = docs.sublist(i, (i + 499).clamp(0, docs.length));
      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {'isArchived': true});
      }
      await batch.commit();
    }
  }

  /// Archive a batch of notifications by ID atomically.
  /// Chunks into batches of 499 to stay within Firestore's 500-op limit.

  Future<void> archiveSelected(List<String> ids) async {
    for (var i = 0; i < ids.length; i += 499) {
      final chunk = ids.sublist(i, (i + 499).clamp(0, ids.length));
      final batch = _firestore.batch();
      for (final id in chunk) {
        batch.update(
          _firestore
              .collection(AppConstants.notificationsCollection)
              .doc(id),
          {'isArchived': true},
        );
      }
      await batch.commit();
    }
  }

  /// Delete notification permanently

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsCollection.doc(notificationId).delete();
  }

  /// Send ride booking request notification

  Future<void> sendRideBookingRequest({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String rideId,
    required String rideName,
    String? fromUserPhoto,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingRequest,
        title: _l10n.new_ride_request,
        body: _l10n.notificationRideBookingRequestBody(
          fromUserName,
          rideName,
        ),
        senderId: fromUserId,
        senderName: fromUserName,
        senderPhotoUrl: fromUserPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride booking accepted notification

  Future<void> sendRideBookingAccepted({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingAccepted,
        title: _l10n.booking_accepted,
        body: _l10n.notificationRideBookingAcceptedBody(driverName, rideName),
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride booking rejected notification

  Future<void> sendRideBookingRejected({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? _l10n.notificationRideBookingDeclinedWithReasonBody(
            driverName,
            rideName,
            reason,
          )
        : _l10n.notificationRideBookingDeclinedBody(driverName, rideName);

    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideBookingRejected,
        title: _l10n.booking_declined,
        body: body,
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.high,
      ),
    );
  }

  /// Send ride cancelled notification to a passenger

  Future<void> sendRideCancelled({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? _l10n.notificationRideCancelledWithReasonBody(
            driverName,
            rideName,
            reason,
          )
        : _l10n.notificationRideCancelledBody(driverName, rideName);

    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideCancelled,
        title: _l10n.ride_cancelled,
        body: body,
        senderName: driverName,
        senderPhotoUrl: driverPhoto,
        referenceId: rideId,
        referenceType: 'ride',
        priority: NotificationPriority.urgent,
      ),
    );
  }

  /// Send new message notification

  Future<void> sendNewMessageNotification({
    required String toUserId,
    required String fromUserId,
    required String fromUserName,
    required String chatId,
    required String messagePreview,
    String? fromUserPhoto,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.newMessage,
        title: _l10n.new_message,
        body: _l10n.notificationNewMessageBody(fromUserName, messagePreview),
        senderId: fromUserId,
        senderName: fromUserName,
        senderPhotoUrl: fromUserPhoto,
        referenceId: chatId,
        referenceType: 'chat',
      ),
    );
  }

  /// Send achievement notification

  Future<void> sendAchievementNotification({
    required String userId,
    required String achievementName,
    required String achievementDescription,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: userId,
        type: NotificationType.achievementUnlocked,
        title: _l10n.achievement_unlocked,
        body: _l10n.notificationAchievementBody(
          achievementName,
          achievementDescription,
        ),
      ),
    );
  }

  /// Send level-up notification

  Future<void> sendLevelUpNotification({
    required String userId,
    required int newLevel,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: userId,
        type: NotificationType.levelUp,
        title: _l10n.level_up,
        body: _l10n.notificationLevelUpBody(newLevel),
      ),
    );
  }

  Future<void> sendDriverArrivedAtPickup({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
    String? driverPhoto,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideUpdated,
        title: _l10n.driver_has_arrived,
        body: _l10n.notificationDriverArrivedBody(driverName, rideName),
        priority: NotificationPriority.high,
        referenceId: rideId,
        referenceType: 'ride',
        data: {'driverPhoto': driverPhoto},
      ),
    );
  }

  Future<void> sendDriverArrivingAtDestination({
    required String toUserId,
    required String driverName,
    required String rideId,
    required String rideName,
  }) async {
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.rideUpdated,
        title: _l10n.almost_there,
        body: _l10n.notificationDriverArrivingDestinationBody(
          driverName,
          rideName,
        ),
        priority: NotificationPriority.high,
        referenceId: rideId,
        referenceType: 'ride',
      ),
    );
  }

  /// Send event cancelled notification to a participant.

  Future<void> sendEventCancelled({
    required String toUserId,
    required String organizerName,
    required String eventId,
    required String eventTitle,
    String? organizerPhoto,
    String? reason,
  }) async {
    final body = reason != null && reason.isNotEmpty
        ? _l10n.notificationEventCancelledWithReasonBody(
            organizerName,
            eventTitle,
            reason,
          )
        : _l10n.notificationEventCancelledBody(organizerName, eventTitle);
    await createNotification(
      NotificationModel(
        id: '',
        userId: toUserId,
        type: NotificationType.eventCancelled,
        title: _l10n.event_cancelled,
        body: body,
        senderId: organizerName,
        senderName: organizerName,
        senderPhotoUrl: organizerPhoto,
        referenceId: eventId,
        referenceType: 'event',
        priority: NotificationPriority.high,
      ),
    );
  }
}
