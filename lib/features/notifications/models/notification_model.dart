import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification type enum
enum NotificationType {
  // Ride notifications
  rideBookingRequest,
  rideBookingAccepted,
  rideBookingRejected,
  rideBookingCancelled,
  rideStartingSoon,
  rideStarted,
  rideCompleted,
  rideCancelled,
  rideUpdated,

  // Message notifications
  newMessage,
  newGroupMessage,

  // Social notifications
  newFollower,
  followAccepted,

  // Gamification
  levelUp,
  achievementUnlocked,
  streakMilestone,
  leaderboardRank,
  xpEarned,

  // Event notifications
  eventCancelled,

  // System
  accountVerified,
  profileIncomplete,
  systemAlert,
  promotion,
}

/// Notification priority
enum NotificationPriority { low, normal, high, urgent }

/// High-level grouping of notification types.
///
/// Mirrors the implicit groupings already used in the icon/color switches and
/// the per-category [NotificationPreferences] toggles, giving them a single
/// source of truth.
enum NotificationCategory { ride, message, social, gamification, event, system }

/// Notification model
@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    @Default(NotificationPriority.normal) NotificationPriority priority,

    // Related entity
    String? referenceId,
    String? referenceType,

    // Sender info (for social notifications)
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,

    // Rich media (e.g. promotion banners, achievement art); distinct from the
    // sender's avatar.
    String? imageUrl,

    // Action
    String? actionUrl,
    @Default({}) Map<String, dynamic> data,

    // Status
    @Default(false) bool isRead,
    @Default(false) bool isArchived,
    @Default(false) bool isPushSent,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? readAt,
    @TimestampConverter() DateTime? expiresAt,
  }) = _NotificationModel;
  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.rideBookingRequest:
        return 'person_add';
      case NotificationType.rideBookingAccepted:
        return 'check_circle';
      case NotificationType.rideBookingRejected:
        return 'cancel';
      case NotificationType.rideBookingCancelled:
        return 'event_busy';
      case NotificationType.rideStartingSoon:
        return 'schedule';
      case NotificationType.rideStarted:
        return 'directions_car';
      case NotificationType.rideCompleted:
        return 'flag';
      case NotificationType.rideCancelled:
        return 'block';
      case NotificationType.rideUpdated:
        return 'update';
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        return 'chat_bubble';
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        return 'person';
      case NotificationType.levelUp:
        return 'arrow_upward';
      case NotificationType.achievementUnlocked:
        return 'emoji_events';
      case NotificationType.streakMilestone:
        return 'local_fire_department';
      case NotificationType.leaderboardRank:
        return 'leaderboard';
      case NotificationType.xpEarned:
        return 'star';
      case NotificationType.accountVerified:
        return 'verified';
      case NotificationType.profileIncomplete:
        return 'warning';
      case NotificationType.systemAlert:
        return 'notifications';
      case NotificationType.promotion:
        return 'campaign';
      case NotificationType.eventCancelled:
        return 'event_busy';
    }
  }

  /// Get color for notification type
  String get colorName {
    switch (type) {
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideCompleted:
      case NotificationType.accountVerified:
      case NotificationType.levelUp:
      case NotificationType.achievementUnlocked:
        return 'success';
      case NotificationType.rideBookingRejected:
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideCancelled:
      case NotificationType.eventCancelled:
        return 'error';
      case NotificationType.rideStartingSoon:
      case NotificationType.profileIncomplete:
        return 'warning';
      case NotificationType.xpEarned:
      case NotificationType.streakMilestone:
        return 'gold';
      default:
        return 'primary';
    }
  }

  /// Is expired
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether this notification should appear in the inbox: it must be neither
  /// archived nor expired.
  bool get isVisible => !isArchived && !isExpired;

  /// Whether this notification counts toward unread badges. Archived items are
  /// excluded even if never read.
  bool get isUnread => !isRead && !isArchived;

  /// Whether tapping this notification should trigger navigation/CTA.
  bool get isActionable => actionUrl != null && actionUrl!.isNotEmpty;

  /// Whether this notification has a sender (e.g. to show an avatar).
  bool get hasSender => senderId != null && senderId!.isNotEmpty;

  /// High-level category derived from [type], mirroring the groupings used in
  /// the icon/color switches and the preference toggles.
  NotificationCategory get category {
    switch (type) {
      case NotificationType.rideBookingRequest:
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideBookingRejected:
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideStartingSoon:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
      case NotificationType.rideCancelled:
      case NotificationType.rideUpdated:
        return NotificationCategory.ride;
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        return NotificationCategory.message;
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        return NotificationCategory.social;
      case NotificationType.levelUp:
      case NotificationType.achievementUnlocked:
      case NotificationType.streakMilestone:
      case NotificationType.leaderboardRank:
      case NotificationType.xpEarned:
        return NotificationCategory.gamification;
      case NotificationType.eventCancelled:
        return NotificationCategory.event;
      case NotificationType.accountVerified:
      case NotificationType.profileIncomplete:
      case NotificationType.systemAlert:
      case NotificationType.promotion:
        return NotificationCategory.system;
    }
  }
}

/// Notification preferences
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    // Push notifications
    @Default(true) bool pushEnabled,
    @Default(true) bool rideNotifications,
    @Default(true) bool messageNotifications,
    @Default(true) bool socialNotifications,
    @Default(true) bool gamificationNotifications,
    @Default(true) bool promotionNotifications,

    // Email notifications
    @Default(true) bool emailEnabled,
    @Default(true) bool emailRideSummary,
    @Default(true) bool emailWeeklyDigest,

    // Quiet hours
    @Default(false) bool quietHoursEnabled,
    @Default('22:00') String quietHoursStart,
    @Default('08:00') String quietHoursEnd,

    // Sound & vibration
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
  }) = _NotificationPreferences;
  const NotificationPreferences._();

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  /// Whether the given [category] is enabled by its per-category toggle.
  ///
  /// [NotificationCategory.event] and [NotificationCategory.system] have no
  /// dedicated toggle and are always allowed (subject to [pushEnabled] in
  /// [isTypeEnabled]).
  bool isCategoryEnabled(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.ride:
        return rideNotifications;
      case NotificationCategory.message:
        return messageNotifications;
      case NotificationCategory.social:
        return socialNotifications;
      case NotificationCategory.gamification:
        return gamificationNotifications;
      case NotificationCategory.event:
      case NotificationCategory.system:
        return true;
    }
  }

  /// Whether a notification of the given [type] should be delivered/shown,
  /// combining the master [pushEnabled] switch with the relevant category
  /// toggle. Promotions are gated by [promotionNotifications].
  bool isTypeEnabled(NotificationType type) {
    if (!pushEnabled) return false;
    if (type == NotificationType.promotion) return promotionNotifications;
    return isCategoryEnabled(_categoryOf(type));
  }

  /// Maps a [NotificationType] to its [NotificationCategory] (same mapping as
  /// [NotificationModel.category]).
  static NotificationCategory _categoryOf(NotificationType type) {
    switch (type) {
      case NotificationType.rideBookingRequest:
      case NotificationType.rideBookingAccepted:
      case NotificationType.rideBookingRejected:
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideStartingSoon:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
      case NotificationType.rideCancelled:
      case NotificationType.rideUpdated:
        return NotificationCategory.ride;
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        return NotificationCategory.message;
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        return NotificationCategory.social;
      case NotificationType.levelUp:
      case NotificationType.achievementUnlocked:
      case NotificationType.streakMilestone:
      case NotificationType.leaderboardRank:
      case NotificationType.xpEarned:
        return NotificationCategory.gamification;
      case NotificationType.eventCancelled:
        return NotificationCategory.event;
      case NotificationType.accountVerified:
      case NotificationType.profileIncomplete:
      case NotificationType.systemAlert:
      case NotificationType.promotion:
        return NotificationCategory.system;
    }
  }

  /// Whether [now] (default [DateTime.now]) falls within the configured quiet
  /// hours window. Returns false when quiet hours are disabled or the stored
  /// times cannot be parsed. Correctly handles windows that wrap past midnight
  /// (e.g. 22:00 -> 08:00).
  bool isWithinQuietHours([DateTime? now]) {
    if (!quietHoursEnabled) return false;

    final start = _parseMinutes(quietHoursStart);
    final end = _parseMinutes(quietHoursEnd);
    if (start == null || end == null) return false;

    final at = now ?? DateTime.now();
    final current = at.hour * 60 + at.minute;

    if (start == end) return false; // zero-length window
    if (start < end) {
      // Same-day window, e.g. 08:00 -> 22:00.
      return current >= start && current < end;
    }
    // Wraps past midnight, e.g. 22:00 -> 08:00.
    return current >= start || current < end;
  }

  /// Parses an 'HH:mm' string into minutes-since-midnight, or null if invalid.
  static int? _parseMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
    return hours * 60 + minutes;
  }
}
