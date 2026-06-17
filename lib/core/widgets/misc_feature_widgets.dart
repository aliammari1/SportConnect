import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Post-ride quick review prompt (#47)
class PostRideReviewPrompt extends StatelessWidget {
  const PostRideReviewPrompt({
    required this.driverName,
    required this.onRate,
    required this.onSkip,
    super.key,
    this.driverPhotoUrl,
  });
  final String driverName;
  final String? driverPhotoUrl;
  final ValueChanged<int> onRate;
  final VoidCallback onSkip;

  static Future<void> show(
    BuildContext context, {
    required String driverName,
    required ValueChanged<int> onRate,
    required VoidCallback onSkip,
    String? driverPhotoUrl,
  }) {
    return showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).rateYourRide,
      builder: (_) => PostRideReviewPrompt(
        driverName: driverName,
        driverPhotoUrl: driverPhotoUrl,
        onRate: onRate,
        onSkip: onSkip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32.r,
              backgroundImage: driverPhotoUrl != null
                  ? NetworkImage(driverPhotoUrl!)
                  : null,
              child: driverPhotoUrl == null
                  ? Icon(Icons.person, size: 28.sp)
                  : null,
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).howWasYourRide,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).rateYourExperienceWith(driverName),
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () {
                    unawaited(HapticFeedback.lightImpact());
                    onRate(i + 1);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36.sp,
                      color: AppColors.border,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                onSkip();
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context).skipForNow,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add to calendar button (#49)
class AddToCalendarButton extends StatelessWidget {
  const AddToCalendarButton({
    required this.departureTime,
    required this.origin,
    required this.destination,
    required this.onAdd,
    super.key,
  });
  final DateTime departureTime;
  final String origin;
  final String destination;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        unawaited(HapticFeedback.lightImpact());
        onAdd();
      },
      icon: Icon(Icons.calendar_today_rounded, size: 16.sp),
      label: Text(AppLocalizations.of(context).addToCalendar),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.info,
        side: BorderSide(color: AppColors.info.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

/// App-wide search bar (#82)
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
    this.onClear,
    this.hintText = 'Search rides, people, places...',
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}

/// Onboarding feature tooltip (#83)
class FeatureTooltip extends StatelessWidget {
  const FeatureTooltip({
    required this.title,
    required this.description,
    required this.onDismiss,
    super.key,
    this.onNext,
    this.currentStep = 1,
    this.totalSteps = 1,
  });
  final String title;
  final String description;
  final VoidCallback onDismiss;
  final VoidCallback? onNext;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      constraints: BoxConstraints(maxWidth: 280.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (totalSteps > 1) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentStep of $totalSteps',
                  style: TextStyle(fontSize: 11.sp, color: Colors.white60),
                ),
                if (onNext != null)
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        currentStep < totalSteps ? 'Next' : 'Got it!',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Traffic-aware ETA display (#89)
class TrafficAwareEta extends StatelessWidget {
  const TrafficAwareEta({
    required this.baseEta,
    required this.trafficEta,
    super.key,
  });
  final Duration baseEta;
  final Duration trafficEta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delay = trafficEta - baseEta;
    final hasTraffic = delay.inMinutes > 2;
    final etaMin = trafficEta.inMinutes;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: hasTraffic
            ? AppColors.warning.withValues(alpha: 0.08)
            : AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasTraffic
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasTraffic ? Icons.traffic_rounded : Icons.timer_rounded,
            size: 18.sp,
            color: hasTraffic ? AppColors.warning : AppColors.success,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$etaMin min ETA',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (hasTraffic)
                Text(
                  '+${delay.inMinutes} min traffic delay',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.warning),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Smart departure reminder (#90)
class SmartReminderCard extends StatelessWidget {
  const SmartReminderCard({
    required this.departureTime,
    required this.minutesBefore,
    required this.isEnabled,
    required this.onToggle,
    super.key,
  });
  final DateTime departureTime;
  final int minutesBefore;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderTime = departureTime.subtract(
      Duration(minutes: minutesBefore),
    );
    final now = DateTime.now();
    final isUpcoming = reminderTime.isAfter(now);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.border.withValues(alpha: 0.3),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 20.sp,
              color: isEnabled ? AppColors.primary : AppColors.border,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departure reminder',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  isUpcoming
                      ? '$minutesBefore min before departure'
                      : 'Reminder sent',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          AdaptiveSwitch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
