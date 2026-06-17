import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Achievement model
@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String iconName,
    required int xpReward,
    @Default(false) bool isUnlocked,
    @TimestampConverter() DateTime? unlockedAt,

    // Progress-style achievements (optional, backward-compatible).
    @Default(0) int progress,
    int? target,
  }) = _Achievement;

  const Achievement._();

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  /// Inverse of [isUnlocked].
  bool get isLocked => !isUnlocked;

  /// Whether the achievement has been unlocked at a known time.
  bool get hasBeenUnlocked => isUnlocked && unlockedAt != null;

  /// Progress (0..1) toward [target]. Returns `null` when no target is set,
  /// and is clamped to the 0..1 range.
  double? get progressRatio {
    final goal = target;
    if (goal == null || goal <= 0) return null;
    final ratio = progress / goal;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}
