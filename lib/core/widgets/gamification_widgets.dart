import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// XP Progress Bar
class XPProgressBar extends StatelessWidget {
  const XPProgressBar({
    required this.currentXP,
    required this.maxXP,
    required this.level,
    super.key,
    this.showLabel = true,
  });
  final int currentXP;
  final int maxXP;
  final int level;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    // 1. Safety check to ensure progress is between 0.0 and 1.0
    final safeMax = maxXP > 0 ? maxXP.toDouble() : 1.0;
    final progress = (currentXP / safeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.xpGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context).lvlValue(level),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).valueValueXp(currentXP, maxXP),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context).value((progress * 100).toInt()),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        if (showLabel) SizedBox(height: 8.h),

        // 2. LayoutBuilder gives us the constraints
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            // 3. FIX: Calculate finite width instead of using infinity
            // If maxWidth is somehow infinite (unbounded), we default to 0 to prevent crash
            final fillWidth = maxWidth.isFinite ? maxWidth * progress : 0.0;

            return Container(
              height: 10.h,
              width: maxWidth,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    // REPLACED: width: progress * double.infinity,
                    width: fillWidth, // <--- THIS WAS THE FIX
                    height: 10.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.xpGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Achievement Badge
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
    this.isUnlocked = true,
    this.color,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (color ?? AppColors.primary).withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: isUnlocked
              ? Border.all(
                  color: (color ?? AppColors.primary).withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          color ?? AppColors.primary,
                          (color ?? AppColors.primary).withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isUnlocked
                    ? null
                    : AppColors.textTertiary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? AppSpacing.primaryShadow(color ?? AppColors.primary)
                    : null,
              ),
              child: Icon(
                icon,
                color: isUnlocked ? Colors.white : AppColors.textTertiary,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Streak Counter
class StreakCounter extends StatelessWidget {
  const StreakCounter({required this.days, super.key, this.isActive = true});
  final int days;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.accentGradient : null,
        color: isActive ? null : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isActive ? AppSpacing.primaryShadow(AppColors.accent) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: isActive ? Colors.white : AppColors.textTertiary,
            size: 28.sp,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).value2(days),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: isActive ? Colors.white : AppColors.textTertiary,
                ),
              ),
              Text(
                AppLocalizations.of(context).dayStreak,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Points Badge
class PointsBadge extends StatelessWidget {
  const PointsBadge({required this.points, super.key, this.animate = false});
  final int points;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.xpGold.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber.shade900, size: 18.sp),
          SizedBox(width: 4.w),
          Text(
            AppLocalizations.of(context).value2(points),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Leaderboard Position
class LeaderboardPosition extends StatelessWidget {
  const LeaderboardPosition({
    required this.position,
    required this.name,
    required this.points,
    super.key,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
  final int position;
  final String name;
  final int points;
  final String? avatarUrl;
  final bool isCurrentUser;

  Color get _positionColor {
    switch (position) {
      case 1:
        return AppColors.levelGold;
      case 2:
        return AppColors.levelSilver;
      case 3:
        return AppColors.levelBronze;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: isCurrentUser
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: _positionColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: position <= 3
                  ? Icon(
                      Icons.emoji_events_rounded,
                      color: _positionColor,
                      size: 20.sp,
                    )
                  : Text(
                      AppLocalizations.of(context).value3(position),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _positionColor,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isCurrentUser)
                  Text(
                    AppLocalizations.of(context).you,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          PointsBadge(points: points),
        ],
      ),
    );
  }
}

/// Daily Challenge Card
class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.xpReward,
    required this.icon,
    super.key,
    this.isCompleted = false,
    this.onClaim,
  });
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int xpReward;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    // Ensure target is not 0 to avoid division by zero
    final safeTarget = targetProgress > 0 ? targetProgress : 1;
    final progress = (currentProgress / safeTarget).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: isCompleted
            ? Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : icon,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  AppLocalizations.of(context).valueXp(xpReward),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                AppLocalizations.of(
                  context,
                ).valueValue(currentProgress, targetProgress),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
