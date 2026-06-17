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

    // 4. Listen for foreground messages.
    // 5. Listen for notification taps (app was in background).
    // These are app-level streams registered once for the process lifetime and
    // are intentionally never cancelled (see deleteFcmToken), so the
    // subscriptions are not retained.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

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
      // Only the token-refresh subscription is user-scoped. The
      // onMessage/onMessageOpenedApp subscriptions are app-level streams
      // registered once in initialize(); cancelling them here would
      // permanently break foreground display and tap-navigation after a
      // logout->login within the same process, so they must persist.
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
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

      // Targeted merge: only touch the two token fields to avoid a
      // read-then-write race that could overwrite concurrent profile updates.
      // fcmTokenUpdatedAt uses a server timestamp so stale-token pruning jobs
      // can reliably compare age regardless of device clock skew.
      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(
            {
              'fcmToken': token,
              'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

      TalkerService.info('FCM token saved for user $userId');

      // Cancel any previous listener before registering a new one
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _firebaseService.messaging.onTokenRefresh.listen(
        (newToken) async {
          try {
            await _firebaseService.firestore
                .collection(AppConstants.usersCollection)
                .doc(userId)
                .set(
                  {
                    'fcmToken': newToken,
                    'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
                  },
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
        if (notifSnap.docs.isNotEmpty) {
          final batch = _firebaseService.firestore.batch();
          for (final doc in notifSnap.docs) {
            batch.update(doc.reference, {
              'isRead': true,
              'readAt': FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        }
      } on Exception catch (e) {
        // Best-effort — navigation must not fail if this read fails — but log
        // so a missing composite index (FAILED_PRECONDITION) or other failure
        // that silently prevents the unread badge from clearing is observable.
        TalkerService.warning(
          'Auto-mark-read query failed for referenceId=$referenceId: $e',
        );
      }
    }

    if (!context.mounted) return;

    // Optional discriminator the backend may attach to disambiguate what
    // `referenceId` points at. See the contract notes on [_navigateForType].
    final referenceType = data['referenceType'] as String?;
    final status = data['status'] as String?;

    await _navigateForType(
      context: context,
      type: type,
      referenceId: referenceId,
      referenceType: referenceType,
      status: status,
      data: data,
    );
  }

  /// Maps an FCM `type` + `referenceId` to a destination route.
  ///
  /// FCM `type` → `referenceId` contract (mirrors functions/src/index.ts and
  /// notifications_screen._handleNotificationTap — keep all three in sync):
  ///
  /// | type                  | referenceId points at | route                |
  /// |-----------------------|-----------------------|----------------------|
  /// | message               | chatId                | chat detail/group    |
  /// | ride_request          | rideId/driverId       | driver requests      |
  /// | ride_booking_accepted | rideId                | ride booking pending |
  /// | ride_update           | rideId OR bookingId   | ride detail*         |
  /// |                       | OR eventId            | (see note)           |
  /// | ride_completed        | rideId                | ride detail          |
  /// | event_created/joined/ | eventId               | event detail         |
  /// |   full/cancelled      |                       |                      |
  /// | payment/payment_failed| paymentIntentId/docId | payment history      |
  /// | stripe                | driverId/userId       | driver earnings      |
  ///
  /// NOTE on `ride_update`: the backend overloads this single type with three
  /// different `referenceId` semantics (rideId, bookingId, eventId). Until the
  /// backend attaches an explicit `referenceType` discriminator, the client
  /// cannot reliably tell a rideId from a bookingId/eventId, so a `ride_update`
  /// whose referenceId is actually a bookingId/eventId would land the user on a
  /// broken/empty ride screen. We disambiguate using the optional
  /// [referenceType] (preferred) and fall back to routing event-scoped updates
  /// to the event screen via [status] heuristics; otherwise we degrade to the
  /// notifications list rather than a known-broken ride screen.
  Future<void> _navigateForType({
    required BuildContext context,
    required String type,
    required String referenceId,
    required String? referenceType,
    required String? status,
    required Map<String, dynamic> data,
  }) async {
    // If the backend supplied an explicit discriminator, honour it first so
    // overloaded `type` values route deterministically.
    switch (referenceType) {
      case 'event':
        if (context.mounted) {
          await context.pushNamed(
            AppRoutes.eventDetail.name,
            pathParameters: {'id': referenceId},
          );
        }
        return;
      case 'booking':
        // A bookingId cannot resolve the rideDetail route; the booking-pending
        // screen is keyed by rideId, not bookingId, so the safest deterministic
        // destination is the notifications list.
        if (context.mounted) {
          await context.push(AppRoutes.notifications.path);
        }
        return;
      case 'ride':
        if (context.mounted) {
          await context.push(
            AppRoutes.rideDetail.path.replaceFirst(':id', referenceId),
          );
        }
        return;
      default:
        break;
    }

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
      case 'ride_booking_rejected':
      case 'ride_booking_cancelled':
      case 'ride_starting_soon':
      case 'ride_started':
      case 'ride_completed':
      case 'ride_cancelled':
        // These types reliably carry a rideId.
        await context.push(
          AppRoutes.rideDetail.path.replaceFirst(':id', referenceId),
        );
        return;
      case 'ride_update':
        // Overloaded type: referenceId may be a rideId, bookingId or eventId.
        // The explicit referenceType branch above already handled the
        // disambiguated cases. Without a discriminator we cannot safely assume
        // the referenceId is a rideId — sending a bookingId/eventId to
        // rideDetail lands the user on a broken/empty ride screen. Route to the
        // notifications list as a safe fallback. (Fix requires the backend to
        // attach `referenceType`; see notes above.)
        await context.push(AppRoutes.notifications.path);
        return;
      case 'event_created':
      case 'event_joined':
      case 'event_full':
      case 'event_cancelled':
        // referenceId is an eventId.
        await context.pushNamed(
          AppRoutes.eventDetail.name,
          pathParameters: {'id': referenceId},
        );
        return;
      case 'payment':
      case 'payment_failed':
        // referenceId is a paymentIntentId / payment doc id — not a route
        // param. Surface the user's payment history so they can review status.
        await context.push(AppRoutes.paymentHistory.path);
        return;
      case 'stripe':
      case 'account_onboarding':
      case 'express':
      case 'individual':
        // Driver Stripe/payout updates — take the driver to their earnings
        // (payout) screen.
        await context.push(AppRoutes.driverEarnings.path);
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
