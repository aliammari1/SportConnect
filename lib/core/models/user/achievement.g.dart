// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map json) => _Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconName: json['iconName'] as String,
  xpReward: (json['xpReward'] as num).toInt(),
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  unlockedAt: const TimestampConverter().fromJson(json['unlockedAt']),
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  target: (json['target'] as num?)?.toInt(),
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'xpReward': instance.xpReward,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': const TimestampConverter().toJson(instance.unlockedAt),
      'progress': instance.progress,
      'target': instance.target,
    };
