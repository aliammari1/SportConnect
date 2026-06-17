import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/models/user/achievement.dart';
import 'package:sport_connect/core/models/user/user_enums.dart';

part 'gamification_stats.freezed.dart';
part 'gamification_stats.g.dart';

@freezed
abstract class GamificationStats with _$GamificationStats {
  const factory GamificationStats({
    @Default(0) int totalXP,
    @Default(0) int totalRides,
    @Default(0) int ridesOffered,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
  }) = _GamificationStats;

  const GamificationStats._();

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatsFromJson(json);

  /// Tiered level derived from [UserLevel] thresholds (single source of truth).
  UserLevel get userLevel => UserLevel.fromXP(totalXP);

  int get level => userLevel.level;

  /// XP earned within the current tier.
  int get currentLevelXP => totalXP - userLevel.minXP.toInt();

  /// Progress (0..1) through the current tier toward the next one.
  /// Returns 1.0 for the highest (unbounded) tier.
  double get levelProgress {
    final tier = userLevel;
    if (tier.maxXP.isInfinite) return 1;
    final span = tier.maxXP - tier.minXP;
    if (span <= 0) return 1;
    return (totalXP - tier.minXP) / span;
  }

  /// XP remaining to reach the next tier. Returns 0 at the highest tier.
  int get xpToNextLevel {
    final tier = userLevel;
    if (tier.maxXP.isInfinite) return 0;
    return tier.maxXP.toInt() - totalXP;
  }

  /// Whether any achievements have been recorded.
  bool get hasAchievements => achievements.isNotEmpty;

  /// Number of achievements that have been unlocked.
  int get unlockedAchievementsCount =>
      achievements.where((a) => a.isUnlocked).length;

  /// Number of badges earned.
  int get badgeCount => unlockedBadges.length;

  /// Whether the user has reached the highest [UserLevel] tier.
  bool get isAtMaxLevel => userLevel == UserLevel.values.last;
}
