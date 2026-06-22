import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

/// User preferences
@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    // unknownEnumValue guards against legacy/bad documents that persisted the
    // Dart enum *name* ("french") instead of its wire value ("fr"). Without it,
    // $enumDecodeNullable throws on the unrecognised value and the whole
    // UserModel.fromJson fails — which strands login on an infinite spinner
    // (App Store 2.1). Unknown values now fall back to the default locale.
    @Default(AppLocale.french)
    @JsonKey(unknownEnumValue: AppLocale.french)
    AppLocale language,
  }) = _UserPreferences;

  const UserPreferences._();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// ISO language code (e.g. 'en', 'fr') decoupled from [AppLocale] so callers
  /// don't need to reach into the enum.
  String get languageCode => language.code;
}
