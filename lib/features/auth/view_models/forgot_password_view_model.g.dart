// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgotPasswordViewModel)
final forgotPasswordViewModelProvider = ForgotPasswordViewModelProvider._();

final class ForgotPasswordViewModelProvider
    extends $NotifierProvider<ForgotPasswordViewModel, ForgotPasswordState> {
  ForgotPasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordViewModelHash();

  @$internal
  @override
  ForgotPasswordViewModel create() => ForgotPasswordViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPasswordState>(value),
    );
  }
}

String _$forgotPasswordViewModelHash() =>
    r'e1500d6de7e2296e48f88705f7f3f43172b391b6';

abstract class _$ForgotPasswordViewModel
    extends $Notifier<ForgotPasswordState> {
  ForgotPasswordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ForgotPasswordState, ForgotPasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgotPasswordState, ForgotPasswordState>,
              ForgotPasswordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
