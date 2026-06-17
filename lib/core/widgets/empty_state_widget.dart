import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Custom empty state widget with icon, title, subtitle, and optional action.
///
/// Used across all list screens when no data is available.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.iconColor,
    this.compact = false,
  });

  // ── Preset factories ──

  factory EmptyStateWidget.noRides(
    BuildContext context, {
    VoidCallback? onSearch,
  }) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.directions_car_outlined,
      title: l10n.no_rides_found,
      subtitle: l10n.emptyNoRidesSubtitle,
      actionLabel: onSearch != null ? l10n.searchRides : null,
      onAction: onSearch,
      actionIcon: Icons.search_rounded,
    );
  }

  factory EmptyStateWidget.noEvents(
    BuildContext context, {
    VoidCallback? onCreate,
  }) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.event_outlined,
      title: l10n.no_events_yet,
      subtitle: l10n.emptyNoEventsSubtitle,
      actionLabel: onCreate != null ? l10n.eventCreateButton : null,
      onAction: onCreate,
    );
  }

  factory EmptyStateWidget.noMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline_rounded,
      title: l10n.noMessagesYet,
      subtitle: l10n.emptyNoMessagesSubtitle,
    );
  }

  factory EmptyStateWidget.noNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.notifications_none_rounded,
      title: l10n.all_caught_up,
      subtitle: l10n.emptyNoNotificationsSubtitle,
    );
  }

  factory EmptyStateWidget.noReviews(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.star_outline_rounded,
      title: l10n.no_reviews_yet,
      subtitle: l10n.emptyNoReviewsSubtitle,
    );
  }

  factory EmptyStateWidget.noVehicles(
    BuildContext context, {
    VoidCallback? onAdd,
  }) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.garage_outlined,
      title: l10n.noVehiclesAdded,
      subtitle: l10n.emptyNoVehiclesSubtitle,
      actionLabel: onAdd != null ? l10n.addVehicleButton : null,
      onAction: onAdd,
    );
  }

  factory EmptyStateWidget.noBookings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.bookmark_outline_rounded,
      title: l10n.no_bookings_yet,
      subtitle: l10n.emptyNoBookingsSubtitle,
    );
  }

  factory EmptyStateWidget.noResults(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: l10n.noResultsFound,
      subtitle: l10n.emptyNoResultsSubtitle,
    );
  }

  factory EmptyStateWidget.error(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: l10n.somethingWentWrong,
      subtitle: l10n.please_try_again,
      actionLabel: onRetry != null ? l10n.retry : null,
      onAction: onRetry,
      actionIcon: Icons.refresh_rounded,
      iconColor: AppColors.error,
    );
  }

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Icon for the action button. Defaults to [Icons.add_rounded] for create
  /// flows; presets pass a contextually correct icon (e.g. search, refresh).
  final IconData? actionIcon;
  final Color? iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 48.sp : 64.sp;
    final titleSize = compact ? 15.sp : 18.sp;
    final subtitleSize = compact ? 12.sp : 13.sp;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 40.w,
          vertical: compact ? 24.h : 48.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative icon circle
            Container(
              width: (iconSize + 32).sp,
              height: (iconSize + 32).sp,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.6),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),

            SizedBox(height: compact ? 16.h : 24.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

            // Subtitle
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 20.h),
              TextButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add_rounded, size: 18),
                label: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
