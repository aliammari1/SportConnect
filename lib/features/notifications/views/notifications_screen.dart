import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/view_models/notification_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Notifications Screen with Firestore real-time updates
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  NotificationModel? _selectedNotification;

  void _showStatusSnackBar(String message, {required Color backgroundColor}) {
    if (!context.mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: backgroundColor == AppColors.success
          ? AdaptiveSnackBarType.success
          : backgroundColor == AppColors.error
          ? AdaptiveSnackBarType.error
          : AdaptiveSnackBarType.info,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    await ref.read(notificationViewModelProvider.notifier).markAllAsRead();
    if (!mounted) return;
    _showStatusSnackBar(
      AppLocalizations.of(context).allNotificationsMarkedAsRead,
      backgroundColor: AppColors.success,
    );
  }

  void _clearAll() {
    final userId = ref.read(notificationViewModelProvider).userId;
    if (userId == null) return;

    final scaffoldContext =
        context; // capture outer context to avoid using a deactivated dialog context
    final l10n = AppLocalizations.of(scaffoldContext);

    showDialog<void>(
      context: scaffoldContext,
      barrierLabel: l10n.clearAllNotifications,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.areYouSureYouWant2),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(notificationViewModelProvider.notifier)
                    .archiveAll();
                if (!scaffoldContext.mounted) return;
                setState(() => _selectedNotification = null);
                AdaptiveSnackBar.show(
                  scaffoldContext,
                  message: l10n.allNotificationsCleared,
                  type: AdaptiveSnackBarType.success,
                );
              } on Object catch (e, st) {
                TalkerService.warning('Archiving notifications failed: $e');
                TalkerService.error('Notification archive error', e, st);
                if (!scaffoldContext.mounted) return;
                AdaptiveSnackBar.show(
                  scaffoldContext,
                  message: l10n.failedToClearNotifications,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).clearAll,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(notificationViewModelProvider);

    if (vmState.userId == null) {
      return AdaptiveScaffold(
        appBar: _buildAppBar(0),
        body: MaxWidthContainer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).pleaseSignInToView,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final userId = vmState.userId!;
    return vmState.notifications.when(
      data: (notifications) => _buildContent(notifications, userId),
      loading: () => AdaptiveScaffold(
        appBar: _buildAppBar(0),
        body: MaxWidthContainer(
          child: _buildLoadingState(),
        ),
      ),
      error: (e, _) => AdaptiveScaffold(
        appBar: _buildAppBar(0),
        body: MaxWidthContainer(
          child: _buildErrorState(
            onRetry: () =>
                ref.read(notificationViewModelProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.h,
                          width: 160.w,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: AppColors.background);
      },
    );
  }

  Widget _buildErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadNotifications,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).checkYourConnectionAndTry,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<NotificationModel> notifications, String userId) {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredAllNotifications = normalizedQuery.isEmpty
        ? notifications
        : notifications.where((n) {
            final sender = n.senderName?.toLowerCase() ?? '';
            return n.title.toLowerCase().contains(normalizedQuery) ||
                n.body.toLowerCase().contains(normalizedQuery) ||
                sender.contains(normalizedQuery);
          }).toList();

    final unreadNotifications = filteredAllNotifications
        .where((n) => !n.isRead)
        .toList();
    final allNotifications = filteredAllNotifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    final selectedNotification = _selectedNotification == null
        ? null
        : notifications.firstWhere(
            (notification) => notification.id == _selectedNotification!.id,
            orElse: () => _selectedNotification!,
          );

    return AdaptiveScaffold(
      appBar: _buildAppBar(unreadCount),
      body: AdaptiveMasterDetailScaffold(
        master: _buildNotificationListPane(
          unreadCount: unreadCount,
          unreadNotifications: unreadNotifications,
          allNotifications: allNotifications,
          userId: userId,
          onNotificationTap: _selectNotificationForTablet,
        ),
        detail: selectedNotification == null
            ? TabletEmptyDetail(
                icon: Icons.notifications_none_rounded,
                title: AppLocalizations.of(context).settingsNotifications,
                message: AppLocalizations.of(context).youReAllCaughtUp,
              )
            : _buildNotificationDetail(selectedNotification),
        phone: MaxWidthContainer(
          child: _buildNotificationListPane(
            unreadCount: unreadCount,
            unreadNotifications: unreadNotifications,
            allNotifications: allNotifications,
            userId: userId,
            onNotificationTap: _handleNotificationTap,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationListPane({
    required int unreadCount,
    required List<NotificationModel> unreadNotifications,
    required List<NotificationModel> allNotifications,
    required String userId,
    required ValueChanged<NotificationModel> onNotificationTap,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).searchConversations,
              hintText: AppLocalizations.of(context).searchConversations,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: AdaptiveTabBarView(
            tabs: [
              if (unreadCount > 0)
                '${AppLocalizations.of(context).unread} ($unreadCount)'
              else
                AppLocalizations.of(context).unread,
              AppLocalizations.of(context).all,
            ],
            selectedColor: Colors.white,
            backgroundColor: AppColors.primary,
            children: [
              _buildNotificationsList(
                unreadNotifications,
                userId,
                onNotificationTap: onNotificationTap,
              ),
              _buildNotificationsList(
                allNotifications,
                userId,
                onNotificationTap: onNotificationTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  AdaptiveAppBar _buildAppBar(int unreadCount) {
    final title = unreadCount > 0
        ? '${AppLocalizations.of(context).settingsNotifications} ($unreadCount)'
        : AppLocalizations.of(context).settingsNotifications;

    return AdaptiveAppBar(
      title: title,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.adaptive.arrow_back,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          AdaptivePopupMenuButton.icon<String>(
            icon: Icons.adaptive.more,
            items: [
              AdaptivePopupMenuItem<String>(
                label: AppLocalizations.of(context).markAllAsRead,
                icon: Icons.done_all,
                value: 'mark_read',
              ),
              AdaptivePopupMenuItem<String>(
                label: AppLocalizations.of(context).clearAll2,
                icon: Icons.delete_outline,
                value: 'clear',
              ),
            ],
            onSelected: (index, entry) {
              if (entry.value == 'mark_read') {
                _markAllAsRead();
              } else if (entry.value == 'clear')
                _clearAll();
            },
          ),
        ],
      ),
      actions: [
        AdaptiveAppBarAction(
          iosSymbol: 'ellipsis.circle',
          icon: Icons.adaptive.more,
          onPressed: _showOptionsSheet,
        ),
      ],
    );
  }

  void _showOptionsSheet() {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).notificationsTooltip,
      maxHeightFactor: 0.35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.done_all, color: AppColors.primary),
            title: Text(AppLocalizations.of(context).markAllAsRead),
            onTap: () {
              context.pop();
              _markAllAsRead();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(AppLocalizations.of(context).clearAll2),
            onTap: () {
              context.pop();
              _clearAll();
            },
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<NotificationModel> notifications,
    String userId, {
    required ValueChanged<NotificationModel> onNotificationTap,
  }) {
    if (notifications.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.read(notificationViewModelProvider.notifier).refresh();
          await Future<void>.delayed(const Duration(milliseconds: 250));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context).noNotifications,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(context).youReAllCaughtUp,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.read(notificationViewModelProvider.notifier).refresh();
        await Future<void>.delayed(const Duration(milliseconds: 250));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationTile(
                notification: notification,
                isSelected: _selectedNotification?.id == notification.id,
                onTap: () => onNotificationTap(notification),
                onDismiss: () => _dismissNotification(notification.id),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX(begin: 0.1, delay: Duration(milliseconds: 50 * index));
        },
      ),
    );
  }

  void _selectNotificationForTablet(NotificationModel notification) {
    if (!notification.isRead) {
      ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notification.id);
    }
    setState(
      () => _selectedNotification = notification.copyWith(isRead: true),
    );
  }

  Widget _buildNotificationDetail(NotificationModel notification) {
    final l10n = AppLocalizations.of(context);
    final isRead =
        notification.isRead || _selectedNotification?.id == notification.id;
    final typeIcon = _notificationTypeIcon(notification.type);
    final typeColor = _notificationTypeColor(notification.type);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.senderPhotoUrl != null)
                  PremiumAvatar(
                    name: notification.senderName ?? '',
                    imageUrl: notification.senderPhotoUrl,
                    size: 56,
                  )
                else
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 28.sp),
                  ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.type.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              notification.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.senderName != null &&
                      notification.senderName!.isNotEmpty)
                    _buildDetailRow(
                      icon: Icons.person_outline_rounded,
                      value: notification.senderName!,
                    ),
                  if (notification.createdAt != null)
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      value:
                          '${l10n.date}: ${AppLocaleFormatters.formatRelativeTime(context, notification.createdAt)}',
                    ),
                  _buildDetailRow(
                    icon: isRead
                        ? Icons.done_all_rounded
                        : Icons.mark_email_unread_outlined,
                    value: isRead
                        ? l10n.allNotificationsMarkedAsRead
                        : l10n.unread,
                    valueColor: isRead ? AppColors.success : AppColors.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openNotificationDestination(notification),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.open),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor ?? AppColors.textSecondary, size: 20.sp),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNotificationDestination(NotificationModel notification) {
    _handleNotificationTap(notification);
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      ref
          .read(notificationViewModelProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.rideBookingRequest:
        context.push(AppRoutes.driverRequests.path);
        return;
      case NotificationType.rideBookingAccepted:
        if (notification.referenceId != null) {
          context.push(
            AppRoutes.rideBookingPending.path.replaceFirst(
              ':rideId',
              notification.referenceId!,
            ),
          );
        }
        return;
      case NotificationType.eventCancelled:
        if (notification.referenceId != null) {
          context.pushNamed(
            AppRoutes.eventDetail.name,
            pathParameters: {'id': notification.referenceId!},
          );
        }
        return;
      case NotificationType.rideBookingCancelled:
      case NotificationType.rideBookingRejected:
      case NotificationType.rideStartingSoon:
      case NotificationType.rideStarted:
      case NotificationType.rideCompleted:
      case NotificationType.rideCancelled:
      case NotificationType.rideUpdated:
        if (notification.referenceId != null) {
          context.pushNamed(
            AppRoutes.rideDetail.name,
            pathParameters: {'id': notification.referenceId!},
          );
        }
        return;
      case NotificationType.newMessage:
      case NotificationType.newGroupMessage:
        if (notification.referenceId != null) {
          // referenceId is the chatId
          // We need to fetch the chat to get participant info, then navigate
          _navigateToChatFromNotification(notification.referenceId!);
        }
        return;
      case NotificationType.newFollower:
      case NotificationType.followAccepted:
        if (notification.senderId != null) {
          context.pushNamed(
            AppRoutes.userProfile.name,
            pathParameters: {'id': notification.senderId!},
          );
        }
        return;
      default:
        break;
    }
  }

  void _dismissNotification(String notificationId) {
    if (_selectedNotification?.id == notificationId) {
      setState(() => _selectedNotification = null);
    }
    ref
        .read(notificationViewModelProvider.notifier)
        .deleteNotification(notificationId);
  }

  Future<void> _navigateToChatFromNotification(String chatId) async {
    final userId = ref.read(notificationViewModelProvider).userId;
    if (userId == null) return;

    try {
      final chat = await ref
          .read(chatActionsViewModelProvider.notifier)
          .getChatById(chatId);

      if (chat != null && mounted) {
        final title = chat.getChatTitle(userId);
        final photoUrl = chat.getChatPhoto(userId);

        // For group chats or if other participant is missing, use chat title
        final otherParticipant = chat.getOtherParticipant(userId);
        final receiverUser = UserModel.rider(
          uid: otherParticipant?.userId ?? chatId,
          email: '',
          username: title,
          photoUrl: photoUrl,
        );

        context.pushNamed(
          AppRoutes.chatDetail.name,
          pathParameters: {'id': chatId},
          extra: receiverUser,
        );
      }
    } on Exception {
      if (!mounted) return;
      _showStatusSnackBar(
        AppLocalizations.of(context).couldNotOpenChat,
        backgroundColor: AppColors.error,
      );
    }
  }
}

IconData _notificationTypeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.rideBookingRequest:
    case NotificationType.rideBookingAccepted:
    case NotificationType.rideStartingSoon:
    case NotificationType.rideStarted:
    case NotificationType.rideCompleted:
      return Icons.directions_car_rounded;
    case NotificationType.rideBookingRejected:
    case NotificationType.rideBookingCancelled:
    case NotificationType.rideCancelled:
      return Icons.cancel_rounded;
    case NotificationType.newMessage:
    case NotificationType.newGroupMessage:
      return Icons.message_rounded;
    case NotificationType.achievementUnlocked:
    case NotificationType.levelUp:
      return Icons.emoji_events_rounded;
    case NotificationType.xpEarned:
      return Icons.star_rounded;
    default:
      return Icons.notifications_rounded;
  }
}

Color _notificationTypeColor(NotificationType type) {
  switch (type) {
    case NotificationType.rideBookingRequest:
    case NotificationType.rideBookingAccepted:
    case NotificationType.rideStartingSoon:
    case NotificationType.rideStarted:
    case NotificationType.rideCompleted:
      return AppColors.primary;
    case NotificationType.rideBookingRejected:
    case NotificationType.rideBookingCancelled:
    case NotificationType.rideCancelled:
      return AppColors.error;
    case NotificationType.newMessage:
    case NotificationType.newGroupMessage:
      return AppColors.info;
    case NotificationType.achievementUnlocked:
    case NotificationType.levelUp:
    case NotificationType.xpEarned:
      return AppColors.warning;
    default:
      return AppColors.textSecondary;
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isSelected,
    required this.onTap,
    required this.onDismiss,
  });
  final NotificationModel notification;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : notification.isRead
                ? AppColors.surface
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : notification.isRead
                  ? AppColors.divider
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Avatar
              _buildNotificationIcon(),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatTime(context, notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    if (notification.senderPhotoUrl != null) {
      return PremiumAvatar(
        name: notification.senderName ?? '',
        imageUrl: notification.senderPhotoUrl,
        size: 44,
      );
    }

    final iconData = _notificationTypeIcon(notification.type);
    final iconColor = _notificationTypeColor(notification.type);

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(iconData, color: iconColor, size: 24.sp),
    );
  }

  String _formatTime(BuildContext context, DateTime? dateTime) {
    return AppLocaleFormatters.formatRelativeTime(context, dateTime);
  }
}
