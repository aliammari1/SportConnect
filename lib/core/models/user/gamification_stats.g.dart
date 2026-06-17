// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GamificationStats _$GamificationStatsFromJson(Map json) => _GamificationStats(
  totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  ridesOffered: (json['ridesOffered'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
  unlockedBadges:
      (json['unlockedBadges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  achievements:
      (json['achievements'] as List<dynamic>?)
          ?.map(
            (e) => Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$GamificationStatsToJson(_GamificationStats instance) =>
    <String, dynamic>{
      'totalXP': instance.totalXP,
      'totalRides': instance.totalRides,
      'ridesOffered': instance.ridesOffered,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalDistance': instance.totalDistance,
      'unlockedBadges': instance.unlockedBadges,
      'achievements': instance.achievements.map((e) => e.toJson()).toList(),
    };
