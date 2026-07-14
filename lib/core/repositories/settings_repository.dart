import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'Override sharedPreferencesProvider in ProviderScope.',
  );
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
}

/// Repository for user settings persistence.
///
/// Manages app-wide settings that are actually wired into app behavior.
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const String _languageCodeKey = 'language_code';
  static const String _notificationDialogShownKey = 'notification_dialog_shown';
  static const String _analyticsCollectionEnabledKey =
      'analytics_collection_enabled';
  static const String _premiumPromptPrefix = 'premium_prompt_seen_';
  static const String _onboardingDraftPrefix = 'onboarding_setup_draft_';

  final SharedPreferences _prefs;
  // ============================================================
  // Language Settings
  // ============================================================

  String? get languageCode => _prefs.getString(_languageCodeKey);

  Locale? get locale {
    final code = languageCode;
    return code != null ? Locale(code) : null;
  }

  Future<Locale> setLanguage(String languageCode) async {
    await _prefs.setString(_languageCodeKey, languageCode);
    return Locale(languageCode);
  }

  Future<void> clearLanguage() async {
    await _prefs.remove(_languageCodeKey);
  }

  // ============================================================
  // Notification Dialog
  // ============================================================

  bool get notificationDialogShown {
    return _prefs.getBool(_notificationDialogShownKey) ?? false;
  }

  Future<bool> setNotificationDialogShown({bool value = true}) async {
    await _prefs.setBool(_notificationDialogShownKey, value);
    return value;
  }

  // ============================================================
  // Analytics & Crash Reporting Consent
  // ============================================================

  /// Whether the user has opted in to sharing analytics and crash reports.
  ///
  /// Defaults to `true` (opt-out model) so behavior is unchanged for users
  /// who have never visited the toggle in Settings.
  bool get analyticsCollectionEnabled {
    return _prefs.getBool(_analyticsCollectionEnabledKey) ?? true;
  }

  Future<bool> setAnalyticsCollectionEnabled({required bool value}) async {
    await _prefs.setBool(_analyticsCollectionEnabledKey, value);
    return value;
  }

  // ============================================================
  // Premium Prompt
  // ============================================================

  bool premiumPromptSeenFor(String uid) {
    return _prefs.getBool('$_premiumPromptPrefix$uid') ?? false;
  }

  Future<void> setPremiumPromptSeen(String uid) async {
    await _prefs.setBool('$_premiumPromptPrefix$uid', true);
  }

  // ============================================================
  // Onboarding Setup Drafts
  // ============================================================

  String _onboardingDraftKey(String uid, String path) {
    return '$_onboardingDraftPrefix${uid}_$path';
  }

  Map<String, dynamic> onboardingDraftFor(String uid, String path) {
    final raw = _prefs.getString(_onboardingDraftKey(uid, path));
    if (raw == null || raw.isEmpty) return const <String, dynamic>{};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return const <String, dynamic>{};
    return decoded;
  }

  Future<void> saveOnboardingDraft(
    String uid,
    String path,
    Map<String, Object?> draft,
  ) async {
    final sanitized = <String, Object?>{
      ...onboardingDraftFor(uid, path),
    };
    for (final entry in draft.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      sanitized[entry.key] = value;
    }

    await _prefs.setString(
      _onboardingDraftKey(uid, path),
      jsonEncode(sanitized),
    );
  }

  Future<void> clearOnboardingDraft(String uid, String path) async {
    await _prefs.remove(_onboardingDraftKey(uid, path));
  }
}
