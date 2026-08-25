import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_mode_provider.g.dart';

/// Persists the user's theme preference and exposes it to the root app.
///
/// Defaults to [ThemeMode.system] so dark-mode devices get the dark themes
/// that already ship with the app; the choice survives restarts.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const String _key = 'app_theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    final mode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (mode != state && ref.mounted) state = mode;
  }

  Future<void> setMode(ThemeMode mode) async {
    if (!ref.mounted) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
  }
}
