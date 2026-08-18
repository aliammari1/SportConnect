// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangePasswordViewModel)
final changePasswordViewModelProvider = ChangePasswordViewModelProvider._();

final class ChangePasswordViewModelProvider
    extends $NotifierProvider<ChangePasswordViewModel, ChangePasswordState> {
  ChangePasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordViewModelHash();

  @$internal
  @override
  ChangePasswordViewModel create() => ChangePasswordViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordState>(value),
    );
  }
}

String _$changePasswordViewModelHash() =>
    r'b991de23667057220babb0fbab1f0d7e889d686a';

abstract class _$ChangePasswordViewModel
    extends $Notifier<ChangePasswordState> {
  ChangePasswordState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChangePasswordState, ChangePasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangePasswordState, ChangePasswordState>,
              ChangePasswordState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
