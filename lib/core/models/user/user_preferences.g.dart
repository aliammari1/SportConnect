// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreferences _$UserPreferencesFromJson(Map json) => _UserPreferences(
  language:
      $enumDecodeNullable(_$AppLocaleEnumMap, json['language']) ??
      AppLocale.french,
);

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{'language': _$AppLocaleEnumMap[instance.language]!};

const _$AppLocaleEnumMap = {AppLocale.english: 'en', AppLocale.french: 'fr'};
