// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reauth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the re-authentication flow for sensitive operations.
///
/// Supports password and Google re-authentication.  The dialog watches
/// this provider's state for loading / error display and listens for
/// [isSuccess] to dismiss itself.

@ProviderFor(ReauthViewModel)
final reauthViewModelProvider = ReauthViewModelProvider._();

/// Manages the re-authentication flow for sensitive operations.
///
/// Supports password and Google re-authentication.  The dialog watches
/// this provider's state for loading / error display and listens for
/// [isSuccess] to dismiss itself.
final class ReauthViewModelProvider
    extends $NotifierProvider<ReauthViewModel, ReauthState> {
  /// Manages the re-authentication flow for sensitive operations.
  ///
  /// Supports password and Google re-authentication.  The dialog watches
  /// this provider's state for loading / error display and listens for
  /// [isSuccess] to dismiss itself.
  ReauthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reauthViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reauthViewModelHash();

  @$internal
  @override
  ReauthViewModel create() => ReauthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReauthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReauthState>(value),
    );
  }
}

String _$reauthViewModelHash() => r'ee589d18c46562b6333b12171fd2f2a7f3c6b43a';

/// Manages the re-authentication flow for sensitive operations.
///
/// Supports password and Google re-authentication.  The dialog watches
/// this provider's state for loading / error display and listens for
/// [isSuccess] to dismiss itself.

abstract class _$ReauthViewModel extends $Notifier<ReauthState> {
  ReauthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReauthState, ReauthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReauthState, ReauthState>,
              ReauthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
