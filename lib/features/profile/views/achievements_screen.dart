import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────────────────

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(
      currentUserProvider.select(
        (value) => value.whenData((user) {
          if (user == null) return null;
          return switch (user) {
            RiderModel(:final gamification) => gamification,
            DriverModel(:final gamification) => gamification,
            _ => null,
          };
        }),
      ),
    );

    return statsAsync.when(
      loading: () => _AchievementsLoadingShell(l10n: l10n),
      error: (e, _) =>
          _AchievementsErrorShell(l10n: l10n, message: e.toString()),
      data: (stats) {
        if (stats == null) {
          return _AchievementsErrorShell(
            l10n: l10n,
            message: l10n.signInToSeeYourRides,
          );
        }
        return _AchievementsContent(
          stats: stats,
          l10n: l10n,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MAIN CONTENT
// ─────────────────────────────────────────────────────────────────

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent({
    required this.stats,
    required this.l10n,
  });

  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final levelName = _levelName(l10n, stats.level);

    return AdaptiveScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _AchievementsSliverHeader(
            stats: stats,
            levelName: levelName,
            l10n: l10n,
          ),
        ],
        body: AdaptiveTabBarView(
          tabs: [l10n.badges, l10n.challenges, l10n.leaderboard],
          selectedColor: Colors.white,
          backgroundColor: AppColors.primary,
          children: [
            _BadgesTab(stats: stats, l10n: l10n),
            _ChallengesTab(stats: stats, l10n: l10n),
            _LeaderboardTab(stats: stats, l10n: l10n),
          ],
        ),
      ),
    );
  }

  static String _levelName(AppLocalizations l10n, int level) {
    if (level >= 20) return l10n.diamond;
    if (level >= 15) return l10n.platinum;
    if (level >= 10) return l10n.gold;
    if (level >= 5) return l10n.silver;
    return l10n.bronze;
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIVER HEADER
// ─────────────────────────────────────────────────────────────────

class _AchievementsSliverHeader extends StatelessWidget {
  const _AchievementsSliverHeader({
    required this.stats,
    required this.levelName,
    required this.l10n,
  });

  final GamificationStats stats;
  final String levelName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final xpProgress = stats.xpToNextLevel > 0
        ? (stats.currentLevelXP / stats.xpToNextLevel).clamp(0.0, 1.0)
        : 1.0;
    final isMaxLevel = stats.level >= 25;
    final expandedHeight = responsiveValue<double>(
      context,
      compact: 280,
      medium: 320,
      expanded: 340,
      large: 360,
    );
    final horizontalPadding = responsiveValue<double>(
      context,
      compact: 20,
      medium: 28,
      expanded: 36,
      large: 48,
    );
    final tabletStatWidth = responsiveValue<double>(
      context,
      compact: 140,
      medium: 150,
      expanded: 170,
      large: 185,
    );

    return SliverAppBar(
      expandedHeight: expandedHeight.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.background,
        onPressed: () => context.pop(),
        tooltip: l10n.goBackTooltip,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding.w,
                56.h,
                horizontalPadding.w,
                40.h,
              ),
              child: ResponsiveLayoutBuilder(
                phone: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _LevelBadge(level: stats.level),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: _HeaderSummary(
                            title: l10n.levelValueValue(stats.level, levelName),
                            subtitle: l10n.viewYourBadgesAndRewards,
                            xpProgress: xpProgress,
                            progressLabel: isMaxLevel
                                ? l10n.maxLevel
                                : l10n.valueXpToLevelValue(
                                    stats.xpToNextLevel - stats.currentLevelXP,
                                    stats.level + 1,
                                  ),
                            isMaxLevel: isMaxLevel,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.bolt_rounded,
                          value: l10n.valueXp2(stats.totalXP),
                          label: l10n.total_xp,
                        ),
                        const _StatDivider(),
                        _StatItem(
                          icon: Icons.directions_car_rounded,
                          value: '${stats.totalRides}',
                          label: l10n.navRides,
                        ),
                        const _StatDivider(),
                        _StatItem(
                          icon: Icons.local_fire_department_rounded,
                          value: '${stats.currentStreak}',
                          label: l10n.streak,
                        ),
                        const _StatDivider(),
                        _StatItem(
                          icon: Icons.emoji_events_rounded,
                          value: '${stats.unlockedBadges.length}',
                          label: l10n.badges,
                        ),
                      ],
                    ),
                  ],
                ),
                tablet: (context) => Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Row(
                        children: [
                          _LevelBadge(level: stats.level),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _HeaderSummary(
                              title: l10n.levelValueValue(
                                stats.level,
                                levelName,
                              ),
                              subtitle: l10n.viewYourBadgesAndRewards,
                              xpProgress: xpProgress,
                              progressLabel: isMaxLevel
                                  ? l10n.maxLevel
                                  : l10n.valueXpToLevelValue(
                                      stats.xpToNextLevel -
                                          stats.currentLevelXP,
                                      stats.level + 1,
                                    ),
                              isMaxLevel: isMaxLevel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      flex: 9,
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          _HeaderStatCard(
                            width: tabletStatWidth,
                            icon: Icons.bolt_rounded,
                            value: l10n.valueXp2(stats.totalXP),
                            label: l10n.total_xp,
                          ),
                          _HeaderStatCard(
                            width: tabletStatWidth,
                            icon: Icons.directions_car_rounded,
                            value: '${stats.totalRides}',
                            label: l10n.navRides,
                          ),
                          _HeaderStatCard(
                            width: tabletStatWidth,
                            icon: Icons.local_fire_department_rounded,
                            value: '${stats.currentStreak}',
                            label: l10n.streak,
                          ),
                          _HeaderStatCard(
                            width: tabletStatWidth,
                            icon: Icons.emoji_events_rounded,
                            value: '${stats.unlockedBadges.length}',
                            label: l10n.badges,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LEVEL BADGE
// ─────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (level >= 20) {
      badgeColor = AppColors.info;
    } else if (level >= 15) {
      badgeColor = AppColors.levelPlatinum;
    } else if (level >= 10) {
      badgeColor = AppColors.levelGold;
    } else if (level >= 5) {
      badgeColor = AppColors.levelSilver;
    } else {
      badgeColor = AppColors.levelBronze;
    }

    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: badgeColor, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 18.sp, color: badgeColor),
          Text(
            '$level',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGES TAB
// ─────────────────────────────────────────────────────────────────

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final badges = _getBadgeDefinitions(stats, l10n);
    final unlocked = badges.where((b) => b.unlocked).length;
    final total = badges.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    final padding = adaptiveScreenPadding(context);
    return ResponsiveLayoutBuilder(
      phone: (context) => ListView(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          16.h,
          padding.right,
          24.h,
        ),
        children: [
          _BadgesOverviewCard(
            l10n: l10n,
            unlocked: unlocked,
            total: total,
            progress: progress,
          ),
          _BadgeGrid(badges: badges, l10n: l10n),
        ],
      ),
      tablet: (context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          20.h,
          padding.right,
          28.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: responsiveValue<double>(
                context,
                compact: 240,
                medium: 260,
                expanded: 280,
                large: 300,
              ).w,
              child: _BadgesOverviewCard(
                l10n: l10n,
                unlocked: unlocked,
                total: total,
                progress: progress,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: _BadgeGrid(badges: badges, l10n: l10n),
            ),
          ],
        ),
      ),
    );
  }

  List<_BadgeData> _getBadgeDefinitions(
    GamificationStats stats,
    AppLocalizations l10n,
  ) {
    final unlockedBadges = stats.unlockedBadges;
    final totalRides = stats.totalRides;
    final totalDistance = stats.totalDistance;
    final longestStreak = stats.longestStreak;

    return [
      _BadgeData(
        l10n.badgeFirstRide,
        l10n.badgeFirstRideDesc,
        Icons.directions_car_rounded,
        totalRides >= 1 || unlockedBadges.contains('first_ride'),
        'bronze',
      ),
      _BadgeData(
        l10n.badgeRoadWarrior,
        l10n.badgeRoadWarriorDesc,
        Icons.emoji_transportation_rounded,
        totalRides >= 10 || unlockedBadges.contains('road_warrior'),
        'silver',
        totalRides < 10 ? totalRides / 10 : null,
      ),
      _BadgeData(
        l10n.badgeEcoHero,
        l10n.badgeEcoHeroDesc,
        Icons.eco_rounded,
        unlockedBadges.contains('eco_hero'),
        'gold',
        0.6,
      ),
      _BadgeData(
        l10n.badgeSocialButterfly,
        l10n.badgeSocialButterflyDesc,
        Icons.people_rounded,
        unlockedBadges.contains('social_butterfly'),
        'silver',
      ),
      _BadgeData(
        l10n.badgeRoadTripper,
        l10n.badgeRoadTripperDesc,
        Icons.map_rounded,
        totalDistance >= 50 || unlockedBadges.contains('road_tripper'),
        'gold',
        totalDistance < 50 ? totalDistance / 50 : null,
      ),
      _BadgeData(
        l10n.badgeSpeedDemon,
        l10n.badgeSpeedDemonDesc,
        Icons.speed_rounded,
        longestStreak >= 7 || unlockedBadges.contains('speed_demon'),
        'gold',
      ),
      _BadgeData(
        l10n.badgePerfectScore,
        l10n.badgePerfectScoreDesc,
        Icons.star_rounded,
        unlockedBadges.contains('perfect_score'),
        'platinum',
      ),
      _BadgeData(
        l10n.badgeRoadMaster,
        l10n.badgeRoadMasterDesc,
        Icons.route_rounded,
        totalRides >= 100 || unlockedBadges.contains('road_master'),
        'gold',
        totalRides < 100 ? totalRides / 100 : null,
      ),
      _BadgeData(
        l10n.badgeNightOwl,
        l10n.badgeNightOwlDesc,
        Icons.nightlight_rounded,
        unlockedBadges.contains('night_owl'),
        'silver',
        0.3,
      ),
      _BadgeData(
        l10n.badgeEarlyBird,
        l10n.badgeEarlyBirdDesc,
        Icons.wb_sunny_rounded,
        unlockedBadges.contains('early_bird'),
        'bronze',
        0.45,
      ),
      _BadgeData(
        l10n.badgeMarathonDriver,
        l10n.badgeMarathonDriverDesc,
        Icons.straighten_rounded,
        totalDistance >= 1000 || unlockedBadges.contains('marathon_driver'),
        'diamond',
        totalDistance < 1000 ? totalDistance / 1000 : null,
      ),
      _BadgeData(
        l10n.badgeVerifiedPro,
        l10n.badgeVerifiedProDesc,
        Icons.verified_rounded,
        unlockedBadges.contains('verified_pro'),
        'silver',
      ),
    ];
  }
}

class _BadgesOverviewCard extends StatelessWidget {
  const _BadgesOverviewCard({
    required this.l10n,
    required this.unlocked,
    required this.total,
    required this.progress,
  });

  final AppLocalizations l10n;
  final int unlocked;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  size: 20.sp,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '$unlocked / $total ${l10n.badges} ${l10n.unlocked.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              color: AppColors.accent,
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            l10n.view_your_badges_rewards,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({
    required this.badges,
    required this.l10n,
  });

  final List<_BadgeData> badges;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsiveValue(
          context,
          compact: 3,
          medium: 4,
          expanded: 5,
          large: 6,
        ),
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: responsiveValue(
          context,
          compact: 0.82,
          medium: 0.9,
          expanded: 0.96,
          large: 1.02,
        ),
      ),
      itemCount: badges.length,
      itemBuilder: (context, i) =>
          _BadgeCard(data: badges[i], index: i, l10n: l10n),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGE CARD
// ─────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.data,
    required this.index,
    required this.l10n,
  });
  final _BadgeData data;
  final int index;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(data.tier);
    final locked = !data.unlocked;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: locked ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: locked ? AppColors.border : tierColor.withValues(alpha: 0.4),
          width: locked ? 1 : 1.5,
        ),
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked
                  ? AppColors.border.withValues(alpha: 0.4)
                  : tierColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              locked ? Icons.lock_rounded : data.icon,
              size: 22.sp,
              color: locked ? AppColors.textTertiary : tierColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data.name,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: locked ? AppColors.textTertiary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (context.isTabletOrLarger) ...[
            SizedBox(height: 4.h),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 9.sp,
                color: locked
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!locked)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _tierLabel(l10n, data.tier).toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (locked && data.progress != null)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: data.progress,
                  backgroundColor: AppColors.border,
                  color: tierColor,
                  minHeight: 4.h,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'diamond':
        return AppColors.info;
      case 'platinum':
        return AppColors.levelPlatinum;
      case 'gold':
        return AppColors.levelGold;
      case 'silver':
        return AppColors.levelSilver;
      default:
        return AppColors.levelBronze;
    }
  }

  String _tierLabel(AppLocalizations l10n, String tier) {
    switch (tier) {
      case 'diamond':
        return l10n.diamond;
      case 'platinum':
        return l10n.platinum;
      case 'gold':
        return l10n.gold;
      case 'silver':
        return l10n.silver;
      default:
        return l10n.bronze;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// CHALLENGES TAB
// ─────────────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final challenges = _getChallenges(stats);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        adaptiveScreenPadding(context).left,
        16.h,
        adaptiveScreenPadding(context).right,
        24.h,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsiveValue(
            context,
            compact: 1,
            medium: 2,
            expanded: 2,
            large: 3,
          ),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: responsiveValue(
            context,
            compact: 2.55,
            medium: 2.1,
            expanded: 2.25,
            large: 2.35,
          ),
        ),
        itemCount: challenges.length,
        itemBuilder: (context, i) =>
            _ChallengeCard(data: challenges[i], index: i, l10n: l10n),
      ),
    );
  }

  List<_ChallengeData> _getChallenges(GamificationStats stats) {
    return [
      _ChallengeData(
        l10n.challengeDailyCommuter,
        l10n.challengeDailyCommuterDesc,
        '0/1',
        0,
        50,
        Icons.today_rounded,
        l10n.challengeResetsInHours('12'),
      ),
      _ChallengeData(
        l10n.challengeWeekWarrior,
        l10n.challengeWeekWarriorDesc,
        '${stats.totalRides.clamp(0, 5)}/5',
        stats.totalRides.clamp(0, 5) / 5,
        200,
        Icons.calendar_view_week_rounded,
        l10n.challengeResetsInDays('3'),
      ),
      _ChallengeData(
        l10n.challengeStreakKeeper,
        l10n.challengeStreakKeeperDesc,
        '${stats.currentStreak.clamp(0, 3)}/3',
        stats.currentStreak.clamp(0, 3) / 3,
        150,
        Icons.local_fire_department_rounded,
        l10n.challengeKeepGoing,
      ),
      _ChallengeData(
        l10n.challengeExplorer,
        l10n.challengeExplorerDesc,
        '0/3',
        0.1,
        300,
        Icons.explore_rounded,
        l10n.challengeResetsInDays('23'),
      ),
      _ChallengeData(
        l10n.challengeSocialRider,
        l10n.challengeSocialRiderDesc,
        '0/5',
        0,
        100,
        Icons.star_half_rounded,
        l10n.challengeResetsInDays('3'),
      ),
      _ChallengeData(
        l10n.challengeEcoWarrior,
        l10n.challengeEcoWarriorDesc,
        '0/3',
        0,
        75,
        Icons.eco_rounded,
        l10n.challengeResetsInHours('12'),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// CHALLENGE CARD
// ─────────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.data,
    required this.index,
    required this.l10n,
  });
  final _ChallengeData data;
  final int index;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isComplete = data.progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
          width: isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check_circle_rounded : data.icon,
              size: 22.sp,
              color: isComplete ? AppColors.success : AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // XP chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        l10n.valueXp(data.xpReward),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: data.progress,
                          backgroundColor: AppColors.border,
                          color: isComplete
                              ? AppColors.success
                              : AppColors.primary,
                          minHeight: 5.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      data.progressText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.timeLeft,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 350.ms);
  }
}

// ─────────────────────────────────────────────────────────────────
// LEADERBOARD TAB
// ─────────────────────────────────────────────────────────────────

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(16.w),
        child: const SkeletonLoader(
          type: SkeletonType.compactTile,
          itemCount: 8,
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 40.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.errorLoadingAchievements,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              l10n.noResultsFound,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          );
        }
        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();
        final padding = adaptiveScreenPadding(context);

        return ResponsiveLayoutBuilder(
          phone: (context) => ListView.builder(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              16.h,
              padding.right,
              24.h,
            ),
            itemCount: 1 + rest.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    _Podium(top3: top3, l10n: l10n),
                    SizedBox(height: 16.h),
                  ],
                );
              }
              final entry = rest[index - 1];
              return _LeaderboardRow(
                entry: entry,
                index: index - 1,
                l10n: l10n,
              );
            },
          ),
          tablet: (context) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              20.h,
              padding.right,
              28.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300.w,
                  child: _Podium(top3: top3, l10n: l10n),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    children: rest
                        .asMap()
                        .entries
                        .map(
                          (e) => _LeaderboardRow(
                            entry: e.value,
                            index: e.key,
                            l10n: l10n,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PODIUM (top 3)
// ─────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.l10n});
  final List<LeaderboardEntry> top3;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primarySurface, AppColors.background],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (second != null)
            _PodiumSpot(
              entry: second,
              height: 80.h,
              medal: AppColors.levelSilver,
              l10n: l10n,
            ),
          _PodiumSpot(
            entry: first,
            height: 110.h,
            medal: AppColors.levelGold,
            isCrown: true,
            l10n: l10n,
          ),
          if (third != null)
            _PodiumSpot(
              entry: third,
              height: 60.h,
              medal: AppColors.levelBronze,
              l10n: l10n,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({
    required this.entry,
    required this.height,
    required this.medal,
    required this.l10n,
    this.isCrown = false,
  });
  final LeaderboardEntry entry;
  final double height;
  final Color medal;
  final AppLocalizations l10n;
  final bool isCrown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCrown)
          Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.levelGold,
            size: 20.sp,
          ),
        CircleAvatar(
          radius: isCrown ? 24.r : 20.r,
          backgroundImage: entry.photoUrl != null
              ? CachedNetworkImageProvider(entry.photoUrl!)
              : null,
          backgroundColor: medal.withValues(alpha: 0.2),
          child: entry.photoUrl == null
              ? Text(
                  entry.username.isNotEmpty
                      ? entry.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: medal,
                    fontSize: isCrown ? 16.sp : 13.sp,
                  ),
                )
              : null,
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: 70.w,
          child: Text(
            entry.username,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          l10n.valueXp(_formatNumber(entry.totalXP)),
          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 64.w,
          height: height,
          decoration: BoxDecoration(
            color: medal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            border: Border.all(color: medal.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: medal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────
// LEADERBOARD ROW
// ─────────────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.index,
    required this.l10n,
  });
  final LeaderboardEntry entry;
  final int index;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankBgColors = [
      AppColors.levelGold,
      AppColors.levelSilver,
      AppColors.levelBronze,
    ];
    final rankColor = isTop3
        ? rankBgColors[entry.rank - 1]
        : AppColors.textTertiary;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isTop3 ? rankColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isTop3
                  ? rankColor.withValues(alpha: 0.15)
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: rankColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Avatar
          CircleAvatar(
            radius: 16.r,
            backgroundImage: entry.photoUrl != null
                ? CachedNetworkImageProvider(entry.photoUrl!)
                : null,
            backgroundColor: AppColors.primarySurface,
            child: entry.photoUrl == null
                ? Text(
                    entry.username.isNotEmpty
                        ? entry.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.levelValue(entry.level),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(entry.totalXP),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                l10n.valueRides(entry.ridesThisMonth),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms);
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED STAT WIDGETS
// ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({
    required this.title,
    required this.subtitle,
    required this.xpProgress,
    required this.progressLabel,
    required this.isMaxLevel,
  });

  final String title;
  final String subtitle;
  final double xpProgress;
  final String progressLabel;
  final bool isMaxLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsiveValue<double>(
              context,
              compact: 15,
              medium: 17,
              expanded: 18,
            ).sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
        SizedBox(height: 10.h),
        if (!isMaxLevel) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        Text(
          progressLabel,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isMaxLevel ? FontWeight.w600 : FontWeight.w400,
            color: isMaxLevel
                ? AppColors.accentLight
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  const _HeaderStatCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
  });

  final double width;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.white),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHELL STATES
// ─────────────────────────────────────────────────────────────────

class _AchievementsLoadingShell extends StatelessWidget {
  const _AchievementsLoadingShell({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.badges,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const SkeletonLoader(itemCount: 1),
            SizedBox(height: 16.h),
            const SkeletonLoader(type: SkeletonType.compactTile, itemCount: 5),
          ],
        ),
      ),
    );
  }
}

class _AchievementsErrorShell extends StatelessWidget {
  const _AchievementsErrorShell({required this.l10n, required this.message});
  final AppLocalizations l10n;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.badges,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.errorLoadingAchievements,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────────────────────

class _BadgeData {
  const _BadgeData(
    this.name,
    this.description,
    this.icon,
    this.unlocked,
    this.tier, [
    this.progress,
  ]);
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final String tier;
  final double? progress;
}

class _ChallengeData {
  const _ChallengeData(
    this.name,
    this.description,
    this.progressText,
    this.progress,
    this.xpReward,
    this.icon,
    this.timeLeft,
  );
  final String name;
  final String description;
  final String progressText;
  final double progress;
  final int xpReward;
  final IconData icon;
  final String timeLeft;
}
