import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';
part 'leaderboard_entry.g.dart';

/// Leaderboard entry model for gamification / profile feature.
@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String username,
    required int totalXP,
    required int level,
    required int rank,
    String? photoUrl,
    // Lifetime total rides. Renamed from the former `ridesThisMonth`, which was
    // mislabeled: it has always been fed from GamificationStats.totalRides (a
    // lifetime counter) because no monthly ride bucket exists in the model.
    @Default(0) int totalRides,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
