import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Star distribution breakdown — shows how many 5-star, 4-star, etc.
///
/// #72: Rating Breakdown Display
class RatingBreakdownWidget extends StatelessWidget {
  const RatingBreakdownWidget({
    required this.distribution,
    required this.totalReviews,
    required this.averageRating,
    super.key,
  });

  /// Map of star count (5, 4, 3, 2, 1) to number of reviews
  final Map<int, int> distribution;
  final int totalReviews;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    if (totalReviews == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Average + stars
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  if (averageRating >= starValue) {
                    return Icon(
                      Icons.star_rounded,
                      size: 16.sp,
                      color: AppColors.xpGold,
                    );
                  } else if (averageRating >= starValue - 0.5) {
                    return Icon(
                      Icons.star_half_rounded,
                      size: 16.sp,
                      color: AppColors.xpGold,
                    );
                  }
                  return Icon(
                    Icons.star_outline_rounded,
                    size: 16.sp,
                    color: AppColors.textTertiary,
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text(
                '$totalReviews reviews',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: 20.w),
          // Right: Bar distribution
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = distribution[star] ?? 0;
                final percentage = totalReviews > 0
                    ? count / totalReviews
                    : 0.0;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.5.h),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.star_rounded,
                        size: 11.sp,
                        color: AppColors.xpGold,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.xpGold,
                            ),
                            minHeight: 6.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 28.w,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// #96: Profile Completion Progress Bar
class ProfileCompletionBar extends StatelessWidget {
  const ProfileCompletionBar({
    required this.completedFields,
    required this.totalFields,
    super.key,
    this.missingHint,
    this.onTap,
  });

  final int completedFields;
  final int totalFields;
  final String? missingHint;
  final VoidCallback? onTap;

  double get _percentage =>
      totalFields > 0 ? completedFields / totalFields : 0.0;

  @override
  Widget build(BuildContext context) {
    if (_percentage >= 1.0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Profile ${(_percentage * 100).round()}% complete',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _percentage),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 8.h,
                ),
              ),
            ),
            if (missingHint != null) ...[
              SizedBox(height: 8.h),
              Text(
                missingHint!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// #65/#66: Verification Badge Row — shows ID, phone, email, driver license badges
class VerificationBadges extends StatelessWidget {
  const VerificationBadges({
    required this.isEmailVerified,
    super.key,
    this.isIdVerified = false,
    this.isPhoneVerified = false,
    this.isDriverLicenseVerified = false,
    this.compact = false,
  });

  final bool isEmailVerified;
  final bool isIdVerified;
  final bool isPhoneVerified;
  final bool isDriverLicenseVerified;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badges = <_BadgeInfo>[
      if (isIdVerified)
        const _BadgeInfo(
          Icons.verified_user_rounded,
          'ID Verified',
          AppColors.success,
        ),
      if (isDriverLicenseVerified)
        const _BadgeInfo(
          Icons.badge_rounded,
          'License Verified',
          AppColors.info,
        ),
      if (isPhoneVerified)
        const _BadgeInfo(
          Icons.phone_android_rounded,
          'Phone Verified',
          AppColors.primary,
        ),
      if (isEmailVerified)
        const _BadgeInfo(
          Icons.email_rounded,
          'Email Verified',
          AppColors.secondary,
        ),
    ];

    if (badges.isEmpty) return const SizedBox.shrink();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final b in badges)
            Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: AdaptiveTooltip(
                message: b.label,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: b.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(b.icon, size: 14.sp, color: b.color),
                ),
              ),
            ),
        ],
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        for (final b in badges)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: b.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: b.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(b.icon, size: 14.sp, color: b.color),
                SizedBox(width: 6.w),
                Text(
                  b.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: b.color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BadgeInfo {
  const _BadgeInfo(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}
