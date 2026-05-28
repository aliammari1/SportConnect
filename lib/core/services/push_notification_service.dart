import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';

part 'push_notification_service.g.dart';

/// Android notification channel IDs
class NotificationChannels {
  NotificationChannels._();

  static const String messagesId = 'sport_connect_messages';
  static const String messagesName = 'Messages';
  static const String messagesDesc = 'New chat message notifications';

  static const String ridesId = 'sport_connect_rides';
  static const String ridesName = 'Rides';
  static const String ridesDesc = 'Ride booking and status notifications';

  static const String generalId = 'sport_connect_general';
  static const String generalName = 'General';
  static const String generalDesc = 'General app notifications';
}

/// Service that bridges Firebase Cloud Messaging with local notifications.
///
/// Handles foreground display, navigation on tap, and FCM token management.
class PushNotificationService {
  PushNotificationService({
    required FirebaseService firebaseService,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _firebaseService = firebaseService,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static final PushNotificationService _instance = PushNotificationService(
    firebaseService: FirebaseService.instance,
  );

  static PushNotificationService get instance => _instance;

  final FirebaseService _firebaseService;
  final FlutterLocalNotificationsPlugin _localNotifications;

  CollectionReference<UserModel> get _usersCollection => _firebaseService
      .firestore
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  CollectionReference<ChatModel> get _chatsCollection => _firebaseService
      .firestore
      .collection(AppConstants.chatsCollection)
      .withConverter<ChatModel>(
        fromFirestore: (snap, _) => ChatModel.fromJson(snap.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  StreamSubscription<RemoteMessage>? _notificationOpenedSub;

  Future<bool> hasPermission() async {
    final settings = await _firebaseService.messaging.getNotificationSettings();
    final s = settings.authorizationStatus;
    return s == AuthorizationStatus.authorized ||
        s == AuthorizationStatus.provisional;
  }

  Future<void> requestPermission() =>
      _firebaseService.messaging.requestPermission();

  /// Initialize the service — call once from main.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Create Android notification channels
    await _createNotificationChannels();

    // 2. Initialize flutter_local_notifications
    await _initLocalNotifications();

    // 3. Set foreground notification presentation (iOS)
    await _firebaseService.messaging
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 4. Listen for foreground messages
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // 5. Listen for notification taps (app was in background)
    _notificationOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );

    // 6. Check for initial message (app opened from terminated state)
    final initialMessage = await _firebaseService.messaging.getInitialMessage();
    if (initialMessage != null) {
      // Defer navigation until the router is ready
      _pendingInitialMessage = initialMessage;
    }

    TalkerService.info('PushNotificationService initialized');
  }

  /// Pending message that arrived when the app was terminated.
  RemoteMessage? _pendingInitialMessage;

  /// Call this once the router is mounted to handle the initial message.
  void handlePendingInitialMessage(BuildContext context) {
    if (_pendingInitialMessage != null) {
      unawaited(_navigateFromPayload(context, _pendingInitialMessage!.data));
      _pendingInitialMessage = null;
    }
  }

  // ---------------------------------------------------------------------------
  // FCM Token Management
  // ---------------------------------------------------------------------------

  /// Save the current FCM token to the user's Firestore document.
  ///
  /// Uses `set` with merge so it works even if the document does not yet
  /// contain an `fcmToken` field (avoids the `update`-on-missing-field
  /// silent failure).
  /// Revoke the current device FCM token and clear it from Firestore.
  ///
  /// Call on every logout so the device stops receiving notifications after
  /// sign-out. Firebase does not remove stale tokens automatically.
  Future<void> deleteFcmToken(String userId) async {
    try {
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
      await _foregroundMessageSub?.cancel();
      _foregroundMessageSub = null;
      await _notificationOpenedSub?.cancel();
      _notificationOpenedSub = null;
      await _firebaseService.messaging.deleteToken();
      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
      TalkerService.info('FCM token deleted for user $userId');
    } on Exception catch (e) {
      TalkerService.warning('FCM token cleanup failed (best-effort): $e');
    }
  }

  Future<void> saveFcmToken(String userId) async {
    try {
      // FIX PN-1 / PN-2: Check that the user has granted notification
      // permission before storing the token.  If permission was revoked after
      // initial grant the token stored in Firestore would be dead — skip it
      // so we don't accumulate stale tokens that waste FCM quota.
      final settings = await _firebaseService.messaging
          .getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        TalkerService.info(
          'saveFcmToken: notification permission denied for $userId — skipping token save.',
        );
        return;
      }

      final token = await _firebaseService.messaging.getToken();
      if (token == null) {
        TalkerService.warning(
          'FCM getToken() returned null for user $userId — '
          'push notifications will not work.',
        );
        return;
      }
      var user = await _usersCollection
          .doc(userId)
          .get()
          .then((snap) => snap.data());
      if (user == null) {
        TalkerService.warning(
          'User document not found for user $userId — cannot save FCM token.',
        );
        return;
      }
      user = user.copyWith(fcmToken: token);
      await _usersCollection.doc(userId).set(user, SetOptions(merge: true));

      TalkerService.info('FCM token saved for user $userId');

      // Cancel any previous listener before registering a new one
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _firebaseService.messaging.onTokenRefresh.listen(
        (newToken) async {
          try {
            await _usersCollection
                .doc(userId)
                .set(
                  user!.copyWith(fcmToken: newToken),
                  SetOptions(merge: true),
                );
            TalkerService.info('FCM token refreshed for user $userId');
          } on Object catch (e) {
            TalkerService.warning('FCM token refresh save failed: $e');
          }
        },
      );
    } on Exception catch (e) {
      TalkerService.error('Failed to save FCM token', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Channel & Local Notification Setup
  // ---------------------------------------------------------------------------

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        NotificationChannels.messagesId,
        NotificationChannels.messagesName,
        description: NotificationChannels.messagesDesc,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.ridesId,
        NotificationChannels.ridesName,
        description: NotificationChannels.ridesDesc,
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        description: NotificationChannels.generalDesc,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle tap on local notification
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _navigateFromData(data);
          } on Exception catch (e, st) {
            TalkerService.warning(
              'Failed to parse notification tap payload: $e $st',
            );
          }
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Message Handlers
  // ---------------------------------------------------------------------------

  /// Display a local notification when a message arrives in the foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    TalkerService.info('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    final channelId = _channelForType(message.data['type'] as String?);

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName(channelId),
          icon: '@drawable/ic_notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap when the app was in the background.
  void _handleNotificationTap(RemoteMessage message) {
    TalkerService.info('Notification tapped: ${message.data}');
    _navigateFromData(message.data);
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Global navigator key — set from MaterialApp.router. Used when no
  /// BuildContext is available (e.g. notification tap from background).
  static GlobalKey<NavigatorState>? navigatorKey;

  void _navigateFromData(Map<String, dynamic> data) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;
    unawaited(_navigateFromPayload(context, data));
  }

  Future<void> _navigateFromPayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (type == null || referenceId == null) return;

    // FIX N-1: Auto-mark matching Firestore notification docs as read when
    // the user opens the notification, so the unread badge clears automatically.
    final uid = _firebaseService.auth.currentUser?.uid;
    if (uid != null) {
      try {
        final notifSnap = await _firebaseService.firestore
            .collection(AppConstants.notificationsCollection)
            .where('userId', isEqualTo: uid)
            .where('referenceId', isEqualTo: referenceId)
            .where('isRead', isEqualTo: false)
            .limit(10)
            .get();
        for (final doc in notifSnap.docs) {
          unawaited(
            doc.reference.update({
              'isRead': true,
              'readAt': FieldValue.serverTimestamp(),
            }),
          );
        }
      } on Exception {
        // Best-effort — navigation must not fail if this read fails.
      }
    }

    if (!context.mounted) return;

    switch (type) {
      case 'message':
        final (:receiver, :chatType) = await _resolveReceiverForChat(
          chatId: referenceId,
          hintUserId:
              (data['senderId'] as String?) ?? (data['userId'] as String?),
          hintDisplayName:
              (data['senderName'] as String?) ?? (data['userName'] as String?),
          hintPhotoUrl:
              (data['senderPhotoUrl'] as String?) ??
              (data['userPhotoUrl'] as String?),
        );
        if (!context.mounted) return;

        if (receiver == null) {
          TalkerService.warning(
            'Could not resolve chat receiver for notification; '
            'redirecting to notifications.',
          );
          if (context.mounted) {
            await context.pushNamed(AppRoutes.notifications.name);
          }
          return;
        }

        // Route to the correct chat screen based on chat type
        final routeName = switch (chatType) {
          ChatType.rideGroup => AppRoutes.chatGroup.name,
          ChatType.eventGroup => AppRoutes.chatGroup.name,
          _ => AppRoutes.chatDetail.name,
        };

        if (context.mounted) {
          await context.pushNamed(
            routeName,
            pathParameters: {'id': referenceId},
            extra: receiver,
          );
        }
        return;
      case 'ride_request':
      case 'ride_booking_request':
        await context.push(AppRoutes.driverRequests.path);
        return;
      case 'ride_booking_accepted':
        // Navigate to the pending screen so the rider can complete payment
        await context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(
            ':rideId',
            referenceId,
          ),
        );
        return;
      case 'ride_update':
      case 'ride_booking_rejected':
      case 'ride_booking_cancelled':
      case 'ride_starting_soon':
      case 'ride_started':
      case 'ride_completed':
      case 'ride_cancelled':
        await context.push(
          AppRoutes.rideDetail.path.replaceFirst(':id', referenceId),
        );
        return;
      default:
        await context.push(AppRoutes.notifications.path);
    }
  }

  Future<({UserModel? receiver, ChatType chatType})> _resolveReceiverForChat({
    required String chatId,
    String? hintUserId,
    String? hintDisplayName,
    String? hintPhotoUrl,
  }) async {
    try {
      final currentUserId = _firebaseService.auth.currentUser?.uid;
      final chat = await _chatsCollection
          .doc(chatId)
          .get()
          .then((s) => s.data());

      if (chat == null) {
        if (hintUserId == null && hintDisplayName == null) {
          return (receiver: null, chatType: ChatType.private);
        }
        return (
          receiver: UserModel.rider(
            uid: hintUserId ?? chatId,
            email: '',
            username: hintDisplayName ?? 'User',
            photoUrl: hintPhotoUrl,
          ),
          chatType: ChatType.private,
        );
      }

      if (chat.type != ChatType.private) {
        final title =
            hintDisplayName ??
            chat.groupName ??
            chat.getChatTitle(currentUserId ?? '');
        return (
          receiver: UserModel.rider(
            uid: chatId,
            email: '',
            username: title.isEmpty ? 'Group Chat' : title,
            photoUrl: hintPhotoUrl ?? chat.groupPhotoUrl,
          ),
          chatType: chat.type,
        );
      }

      final otherParticipant = currentUserId == null
          ? null
          : chat.getOtherParticipant(currentUserId);
      final participantId = hintUserId ?? otherParticipant?.userId;

      if (participantId != null && participantId.isNotEmpty) {
        final fullUser = await _usersCollection
            .doc(participantId)
            .get()
            .then((s) => s.data());
        if (fullUser != null) {
          return (receiver: fullUser, chatType: ChatType.private);
        }
      }

      final displayName =
          hintDisplayName ??
          otherParticipant?.username ??
          chat.getChatTitle(currentUserId ?? '');
      return (
        receiver: UserModel.rider(
          uid: participantId ?? chatId,
          email: '',
          username: displayName.isEmpty ? 'User' : displayName,
          photoUrl: hintPhotoUrl ?? otherParticipant?.photoUrl,
        ),
        chatType: ChatType.private,
      );
    } on Exception catch (e) {
      TalkerService.error(
        'Failed to resolve chat receiver from notification',
        e,
      );
      return (receiver: null, chatType: ChatType.private);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _channelForType(String? type) {
    switch (type) {
      case 'message':
        return NotificationChannels.messagesId;
      case 'ride_request':
      case 'ride_update':
      case 'ride_booking_request':
      case 'ride_booking_accepted':
      case 'ride_booking_rejected':
      case 'ride_booking_cancelled':
      case 'ride_starting_soon':
      case 'ride_started':
      case 'ride_completed':
      case 'ride_cancelled':
        return NotificationChannels.ridesId;
      default:
        return NotificationChannels.generalId;
    }
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case NotificationChannels.messagesId:
        return NotificationChannels.messagesName;
      case NotificationChannels.ridesId:
        return NotificationChannels.ridesName;
      default:
        return NotificationChannels.generalName;
    }
  }
}

/// Riverpod provider for push notification service.
@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService.instance;
}
