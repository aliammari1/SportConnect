// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verification_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EmailVerificationViewModel)
final emailVerificationViewModelProvider =
    EmailVerificationViewModelProvider._();

final class EmailVerificationViewModelProvider
    extends
        $NotifierProvider<EmailVerificationViewModel, EmailVerificationState> {
  EmailVerificationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emailVerificationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emailVerificationViewModelHash();

  @$internal
  @override
  EmailVerificationViewModel create() => EmailVerificationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmailVerificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmailVerificationState>(value),
    );
  }
}

String _$emailVerificationViewModelHash() =>
    r'0edda45f8e6d0d7a5c0cf6f5b968fd0ca582ec3f';

abstract class _$EmailVerificationViewModel
    extends $Notifier<EmailVerificationState> {
  EmailVerificationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<EmailVerificationState, EmailVerificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EmailVerificationState, EmailVerificationState>,
              EmailVerificationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
