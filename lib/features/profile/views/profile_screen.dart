import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/gamification_widgets.dart';
import 'package:sport_connect/core/widgets/icon_stat_card.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/rating_and_profile_widgets.dart';
import 'package:sport_connect/core/widgets/safety_widgets.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Profile Screen - Clean carpooling-style design
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;
  bool get _isOwnProfile => userId == null;

  int _calculateCompletionFields(UserModel user) {
    var count = 0;
    if (user.username.isNotEmpty) count++;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) count++;
    if (user.isEmailVerified) count++;
    return count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = userId != null
        ? ref.watch(currentUserProfileProvider(userId!))
        : ref.watch(currentUserProvider);

    final totalEarningsInCents = _isOwnProfile
        ? ref
                  .watch(driverStatsProvider.select((a) => a.value))
                  ?.totalEarningsInCents ??
              0
        : 0;

    return AdaptiveScaffold(
      body: userAsync.when(
        data: (user) => _buildContent(
          context,
          ref,
          user,
          totalEarningsInCents,
        ),
        loading: () => const SkeletonLoader(type: SkeletonType.profileCard),
        error: (e, _) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).failedToLoadProfile,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).pleaseCheckYourConnectionAnd,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                if (userId != null) {
                  ref.invalidate(currentUserProfileProvider(userId!));
                } else {
                  ref.invalidate(currentUserProvider);
                }
              },
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
    int totalEarningsInCents,
  ) {
    if (user == null) {
      return _buildUserNotFoundState(context, ref);
    }

    if (context.isTabletOrLarger && context.isLandscape) {
      return _buildTabletLandscapeLayout(
        context,
        ref,
        user,
        totalEarningsInCents,
      );
    }

    return _buildPhoneLayout(context, ref, user, totalEarningsInCents);
  }

  Widget _buildTabletLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    int totalEarningsInCents,
  ) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left panel: profile header + stats.
          // `.w` scales the panel width with the ~1.5× tablet content scale —
          // a fixed raw-px width was too narrow for the scaled stat cards/XP
          // row and squeezed their text (overlap + overflow stripes).
          SizedBox(
            width: responsiveValue<double>(
              context,
              compact: 380,
              medium: 380,
              expanded: 420,
              large: 460,
            ).w,
            child: SingleChildScrollView(
              padding: adaptiveScreenPadding(context),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildProfileHeader(context, ref, user)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  SizedBox(height: 24.h),
                  if (_isOwnProfile)
                    ProfileCompletionBar(
                          completedFields: _calculateCompletionFields(user),
                          totalFields: 6,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 80.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  if (_isOwnProfile) SizedBox(height: 16.h),
                  if (_isOwnProfile)
                    _buildXPSection(context, user)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 90.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  SizedBox(height: 16.h),
                  _buildRideStats(context, user, totalEarningsInCents)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  if (!_isOwnProfile && user is DriverModel) ...[
                    SizedBox(height: 16.h),
                    _buildDriverHistoryCard(context, ref, user)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 250.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  ],
                ],
              ),
            ),
          ),
          // Divider
          Container(width: 1, color: AppColors.border.withValues(alpha: 0.3)),
          // Right panel: quick actions
          Expanded(
            child: SingleChildScrollView(
              padding: adaptiveScreenPadding(context),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  if (_isOwnProfile)
                    _buildQuickActions(context, user)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    int totalEarningsInCents,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          pinned: true,
          centerTitle: true,
          leading: _isOwnProfile
              ? null
              : IconButton(
                  tooltip: AppLocalizations.of(context).goBackTooltip,
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.adaptive.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
          title: Text(
            _isOwnProfile
                ? AppLocalizations.of(context).myProfile
                : AppLocalizations.of(context).navProfile,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            if (_isOwnProfile) ...[
              IconButton(
                tooltip: AppLocalizations.of(context).actionSearch,
                onPressed: () => context.push(AppRoutes.profileSearch.path),
                icon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).navSettings,
                onPressed: () => context.push(AppRoutes.settings.path),
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
            ],
            if (!_isOwnProfile)
              AdaptivePopupMenuButton.icon<String>(
                icon: Icons.adaptive.more_rounded,
                items: [
                  AdaptivePopupMenuItem<String>(
                    label: AppLocalizations.of(context).reportUser,
                    icon: Icons.flag_outlined,
                    value: 'report',
                  ),
                  AdaptivePopupMenuItem<String>(
                    label: AppLocalizations.of(context).blockUser,
                    icon: Icons.block_outlined,
                    value: 'block',
                  ),
                ],
                onSelected: (index, entry) async {
                  if (entry.value == 'report') {
                    await context.push<void>(
                      AppRoutes.reportIssue.path,
                      extra: {
                        'reportedUserId': userId,
                        'reason': 'User profile report',
                      },
                    );
                  } else if (entry.value == 'block') {
                    _showBlockUserDialog(context, ref);
                  }
                },
              ),
          ],
        ),

        SliverToBoxAdapter(
          child: _buildProfileHeader(context, ref, user)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        if (_isOwnProfile)
          SliverToBoxAdapter(
            child:
                Padding(
                      padding: adaptiveScreenPadding(context),
                      child: ProfileCompletionBar(
                        completedFields: _calculateCompletionFields(user),
                        totalFields: 6,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (_isOwnProfile) SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        if (_isOwnProfile)
          SliverToBoxAdapter(
            child: _buildXPSection(context, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 90.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (_isOwnProfile) SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        SliverToBoxAdapter(
          child: _buildRideStats(context, user, totalEarningsInCents)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        if (!_isOwnProfile && user is DriverModel)
          SliverToBoxAdapter(
            child: _buildDriverHistoryCard(context, ref, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (!_isOwnProfile && user is DriverModel)
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        if (_isOwnProfile)
          SliverToBoxAdapter(
            child: _buildQuickActions(context, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }

  Widget _buildDriverHistoryCard(
    BuildContext context,
    WidgetRef ref,
    DriverModel user,
  ) {
    final reliability = ref.watch(
      userRideReliabilityProvider(user.uid),
    );

    final rating = user.asDriver?.rating ?? const RatingBreakdown();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: DriveHistoryCard(
        totalRides: user.gamification.totalRides,
        averageRating: rating.average,
        cancelCount: reliability.value?.cancelCount ?? 0,
        noShowCount: reliability.value?.noShowCount ?? 0,
        memberSince: user.createdAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> _changeProfilePhoto(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: AppLocalizations.of(context).permissionCameraPhotosMessage,
    );

    if (!accepted) return;

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !context.mounted) return;

    try {
      await ref
          .read(profileActionsViewModelProvider.notifier)
          .updateProfilePhoto(user.uid, File(image.path));

      ref.invalidate(currentUserProvider);

      if (!context.mounted) return;

      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).profileUpdated,
        type: AdaptiveSnackBarType.success,
      );
    } on Object catch (error) {
      if (!context.mounted) return;

      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).errorValue(error.toString()),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    final rating = switch (user) {
      final RiderModel rider =>
        rider.asRider?.rating ?? const RatingBreakdown(),
      final DriverModel driver =>
        driver.asDriver?.rating ?? const RatingBreakdown(),
      _ => const RatingBreakdown(),
    };

    final address = switch (user) {
      final RiderModel rider => rider.asRider?.address,
      final DriverModel driver => driver.asDriver?.address,
      _ => null,
    };

    final memberSince = user.createdAt;
    final premiumMeta = ref.watch(premiumMetadataProvider);

    final showUpgradeButton = premiumMeta.maybeWhen(
      data: (meta) => !meta.isPremium,
      orElse: () => false,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              LevelAvatar(
                name: user.username,
                level: user.userLevel.level,
                size: 100,
                imageUrl: user.photoUrl,
              ),
              if (_isOwnProfile)
                GestureDetector(
                  onTap: () async {
                    unawaited(HapticFeedback.lightImpact());
                    await _changeProfilePhoto(context, ref, user);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            user.username,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating.average > 0) ...[
                GestureDetector(
                  onTap: () => context.push(
                    '${AppRoutes.reviewsList.path.replaceFirst(':userId', user.uid)}'
                    '?userName=${Uri.encodeComponent(user.username)}'
                    '${user.photoUrl != null ? '&userPhotoUrl=${Uri.encodeComponent(user.photoUrl!)}' : ''}',
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.xpGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.xpGold,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          rating.average.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textTertiary,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                memberSince != null
                    ? AppLocalizations.of(
                        context,
                      ).memberSinceValue(_formatDate(context, memberSince))
                    : AppLocalizations.of(context).newMember,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (address != null && address.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textTertiary,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    address.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 20.h),

          if (_isOwnProfile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: AppLocalizations.of(context).settingsEditProfile,
                    icon: Icons.edit_outlined,
                    onPressed: () => context.push(AppRoutes.editProfile.path),
                    style: PremiumButtonStyle.outline,
                    size: ButtonSize.medium,
                  ),
                ),
                if (showUpgradeButton) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: AppLocalizations.of(context).upgrade_to_premium,
                      icon: Icons.workspace_premium_rounded,
                      onPressed: () =>
                          context.push(AppRoutes.premiumSubscribe.path),
                      style: PremiumButtonStyle.gradient,
                      size: ButtonSize.medium,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return AppLocaleFormatters.formatMonthYear(context, date);
  }

  Widget _buildRideStats(
    BuildContext context,
    UserModel user,
    int totalEarningsInCents,
  ) {
    final totalRides = switch (user) {
      final RiderModel rider => rider.asRider?.gamification.totalRides ?? 0,
      final DriverModel driver => driver.asDriver?.gamification.totalRides ?? 0,
      _ => 0,
    };

    final double totalDistance;
    final int currentStreak;

    switch (user) {
      case RiderModel(:final gamification):
        totalDistance = gamification.totalDistance;
        currentStreak = gamification.currentStreak;
      case DriverModel(:final gamification):
        totalDistance = gamification.totalDistance;
        currentStreak = gamification.currentStreak;
      case _:
        totalDistance = 0;
        currentStreak = 0;
    }

    final moneyStatValue = AppLocalizations.of(
      context,
    ).value5((totalEarningsInCents / 100).toStringAsFixed(0));
    final moneyStatLabel = AppLocalizations.of(context).earned2;
    const moneyStatIcon = Icons.euro_rounded;

    return Padding(
      padding: adaptiveScreenPadding(context),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).rideStatistics,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: IconStatCard.tinted(
                    icon: Icons.route_rounded,
                    value: totalRides.toString(),
                    label: AppLocalizations.of(context).totalRides,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: IconStatCard.tinted(
                    icon: Icons.route_rounded,
                    value: AppLocalizations.of(
                      context,
                    ).distanceKmValue(totalDistance.toStringAsFixed(0)),
                    label: AppLocalizations.of(context).distance,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: IconStatCard.tinted(
                    icon: Icons.local_fire_department_rounded,
                    value: '$currentStreak',
                    label: AppLocalizations.of(context).dayStreak,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(width: 12.w),
                if (user.isDriver)
                  Expanded(
                    child: IconStatCard.tinted(
                      icon: moneyStatIcon,
                      value: moneyStatValue,
                      label: moneyStatLabel,
                      color: AppColors.info,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPSection(BuildContext context, UserModel user) {
    final level = user.userLevel;

    final totalXP = switch (user) {
      final RiderModel rider => rider.asRider?.gamification.totalXP ?? 0,
      final DriverModel driver => driver.asDriver?.gamification.totalXP ?? 0,
      _ => 0,
    };

    final int currentStreak;

    switch (user) {
      case RiderModel(:final gamification):
        currentStreak = gamification.currentStreak;
      case DriverModel(:final gamification):
        currentStreak = gamification.currentStreak;
      case _:
        currentStreak = 0;
    }

    return Padding(
      padding: adaptiveScreenPadding(context),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.achievements.path),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.xpGold,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).levelAndXp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StreakCounter(
                    days: currentStreak,
                    isActive: currentStreak > 0,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              XPProgressBar(
                currentXP: totalXP,
                maxXP: level.maxXP.isFinite ? level.maxXP.toInt() : totalXP,
                level: level.level,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      level.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context).viewAchievements,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context);
    final isDriver = user.role == UserRole.driver;

    final menuItems = [
      if (isDriver)
        _MenuItem(
          icon: Icons.directions_car_outlined,
          title: l10n.myVehicles,
          subtitle: l10n.manage_your_vehicles,
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.driverVehicles.path),
        ),
      _MenuItem(
        icon: Icons.event_rounded,
        title: l10n.myEventsTitle,
        subtitle: l10n.created_joined_events,
        color: AppColors.primaryLight,
        onTap: () => context.push(AppRoutes.myEvents.path),
      ),
      _MenuItem(
        icon: Icons.emoji_events_outlined,
        title: l10n.achievements,
        subtitle: l10n.view_your_badges_rewards,
        color: AppColors.xpGold,
        onTap: () => context.push(AppRoutes.achievements.path),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: l10n.notifications,
        subtitle: l10n.view_your_notifications,
        color: AppColors.warning,
        onTap: () => context.push(AppRoutes.notifications.path),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: l10n.settings,
        subtitle: l10n.app_preferences_privacy,
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRoutes.settings.path),
      ),
    ];

    return Padding(
      padding: adaptiveScreenPadding(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == menuItems.length - 1;

            return Column(
              children: [
                AdaptiveTapSurface(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                    bottom: isLast ? Radius.circular(16.r) : Radius.zero,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 60.w,
                    endIndent: 16.w,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBlockUserDialog(BuildContext context, WidgetRef ref) {
    unawaited(
      showDialog<void>(
        context: context,
        barrierLabel: AppLocalizations.of(context).blockUserDialogTitle,
        builder: (ctx) => AlertDialog.adaptive(
          title: Text(AppLocalizations.of(context).blockUserDialogTitle),
          content: Text(
            AppLocalizations.of(context).blockUserDialogMessageGeneric,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx);

                try {
                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null || userId == null) return;

                  await ref
                      .read(
                        socialActionsViewModelProvider(
                          currentUser.uid,
                          userId!,
                        ).notifier,
                      )
                      .toggleBlock();

                  if (context.mounted) {
                    AdaptiveSnackBar.show(
                      context,
                      message: AppLocalizations.of(context).userBlocked,
                      type: AdaptiveSnackBarType.success,
                    );
                    context.pop();
                  }
                } on Exception {
                  if (context.mounted) {
                    AdaptiveSnackBar.show(
                      context,
                      message: AppLocalizations.of(context).somethingWentWrong,
                      type: AdaptiveSnackBarType.error,
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context).actionBlock),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNotFoundState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 64.sp,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppLocalizations.of(context).profileNotFound,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).yourProfileDataCouldNot,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            PremiumButton(
              text: AppLocalizations.of(context).syncProfile,
              icon: Icons.refresh_rounded,
              onPressed: () async {
                final authActions = ref.read(
                  authActionsViewModelProvider.notifier,
                );

                final currentUser = authActions.currentUser;

                if (currentUser != null) {
                  final profileActions = ref.read(
                    profileActionsViewModelProvider.notifier,
                  );

                  final existingUser = await profileActions.getUserById(
                    currentUser.uid,
                  );

                  if (existingUser == null) {
                    await authActions.createUserDocument(
                      UserModel.rider(
                        uid: currentUser.uid,
                        email: currentUser.email ?? '',
                        username:
                            currentUser.displayName ??
                            AppLocalizations.of(context).user,
                        photoUrl: currentUser.photoURL,
                        createdAt: DateTime.now(),
                      ),
                    );
                  }

                  if (!context.mounted) return;

                  ref.invalidate(currentUserProvider);
                }
              },
              style: PremiumButtonStyle.gradient,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () async {
                await ref.read(authActionsViewModelProvider.notifier).signOut();
              },
              child: Text(
                AppLocalizations.of(context).signOutTryAgain,
                style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _MenuItem {
  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
