import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(AppLocale.french) AppLocale language,
  }) = _UserPreferences;

  const UserPreferences._();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// ISO language code (e.g. 'en', 'fr') decoupled from [AppLocale] so callers
  /// don't need to reach into the enum.
  String get languageCode => language.code;
}
