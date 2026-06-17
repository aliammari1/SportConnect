// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map json) => _LeaderboardEntry(
  userId: json['userId'] as String,
  username: json['username'] as String,
  totalXP: (json['totalXP'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
  photoUrl: json['photoUrl'] as String?,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'totalXP': instance.totalXP,
      'level': instance.level,
      'rank': instance.rank,
      'photoUrl': instance.photoUrl,
      'totalRides': instance.totalRides,
    };
