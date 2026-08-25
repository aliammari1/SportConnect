// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists the user's theme preference and exposes it to the root app.
///
/// Defaults to [ThemeMode.system] so dark-mode devices get the dark themes
/// that already ship with the app; the choice survives restarts.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Persists the user's theme preference and exposes it to the root app.
///
/// Defaults to [ThemeMode.system] so dark-mode devices get the dark themes
/// that already ship with the app; the choice survives restarts.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Persists the user's theme preference and exposes it to the root app.
  ///
  /// Defaults to [ThemeMode.system] so dark-mode devices get the dark themes
  /// that already ship with the app; the choice survives restarts.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'80c820449418df8c443533dfc2e8938d103771cd';

/// Persists the user's theme preference and exposes it to the root app.
///
/// Defaults to [ThemeMode.system] so dark-mode devices get the dark themes
/// that already ship with the app; the choice survives restarts.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
