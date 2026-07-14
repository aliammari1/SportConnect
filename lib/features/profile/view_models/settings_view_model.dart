import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

part 'settings_view_model.g.dart';

const Object _unset = Object();

class SettingsState {
  const SettingsState({
    this.languageCode,
    this.locale,
    this.notificationDialogShown = false,
    this.analyticsCollectionEnabled = true,
  });

  factory SettingsState.fromRepository(SettingsRepository repository) {
    return SettingsState(
      languageCode: repository.languageCode,
      locale: repository.locale,
      notificationDialogShown: repository.notificationDialogShown,
      analyticsCollectionEnabled: repository.analyticsCollectionEnabled,
    );
  }

  final String? languageCode;
  final Locale? locale;

  final bool notificationDialogShown;
  final bool analyticsCollectionEnabled;

  SettingsState copyWith({
    Object? languageCode = _unset,
    Object? locale = _unset,
    bool? notificationDialogShown,
    bool? analyticsCollectionEnabled,
  }) {
    return SettingsState(
      languageCode: identical(languageCode, _unset)
          ? this.languageCode
          : languageCode as String?,
      locale: identical(locale, _unset) ? this.locale : locale as Locale?,
      notificationDialogShown:
          notificationDialogShown ?? this.notificationDialogShown,
      analyticsCollectionEnabled:
          analyticsCollectionEnabled ?? this.analyticsCollectionEnabled,
    );
  }
}

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  SettingsState build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return SettingsState.fromRepository(repository);
  }

  Future<void> setLanguage(String languageCode) async {
    final locale = await _repository.setLanguage(languageCode);

    if (!ref.mounted) return;

    state = state.copyWith(
      languageCode: languageCode,
      locale: locale,
    );
  }

  Future<void> clearLanguage() async {
    await _repository.clearLanguage();

    if (!ref.mounted) return;

    state = state.copyWith(
      languageCode: null,
      locale: null,
    );
  }

  Future<void> setNotificationDialogShown({bool value = true}) async {
    final updatedValue = await _repository.setNotificationDialogShown(
      value: value,
    );

    if (!ref.mounted) return;

    state = state.copyWith(notificationDialogShown: updatedValue);
  }

  /// Persists the user's analytics/crash-reporting consent choice and
  /// applies it immediately to the running Firebase Analytics and
  /// Crashlytics SDKs so the change takes effect without an app restart.
  Future<void> setAnalyticsCollectionEnabled({required bool value}) async {
    final updatedValue = await _repository.setAnalyticsCollectionEnabled(
      value: value,
    );

    await ref
        .read(firebaseServiceProvider)
        .setCollectionEnabled(enabled: updatedValue);

    if (!ref.mounted) return;

    state = state.copyWith(analyticsCollectionEnabled: updatedValue);
  }
}
