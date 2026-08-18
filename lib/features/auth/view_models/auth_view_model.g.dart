// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignupWizardUiViewModel)
final signupWizardUiViewModelProvider = SignupWizardUiViewModelProvider._();

final class SignupWizardUiViewModelProvider
    extends $NotifierProvider<SignupWizardUiViewModel, SignupWizardUiState> {
  SignupWizardUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signupWizardUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signupWizardUiViewModelHash();

  @$internal
  @override
  SignupWizardUiViewModel create() => SignupWizardUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignupWizardUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignupWizardUiState>(value),
    );
  }
}

String _$signupWizardUiViewModelHash() =>
    r'b6157cee935b53d8f920aba0d68553accb5e1c60';

abstract class _$SignupWizardUiViewModel
    extends $Notifier<SignupWizardUiState> {
  SignupWizardUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SignupWizardUiState, SignupWizardUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignupWizardUiState, SignupWizardUiState>,
              SignupWizardUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Login view model

@ProviderFor(LoginViewModel)
final loginViewModelProvider = LoginViewModelProvider._();

/// Login view model
final class LoginViewModelProvider
    extends $NotifierProvider<LoginViewModel, AsyncValue<void>> {
  /// Login view model
  LoginViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginViewModelHash();

  @$internal
  @override
  LoginViewModel create() => LoginViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$loginViewModelHash() => r'2c78819bbc477d5d368bbafde80c516552400e6d';

/// Login view model

abstract class _$LoginViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Register view model

@ProviderFor(RegisterViewModel)
final registerViewModelProvider = RegisterViewModelProvider._();

/// Register view model
final class RegisterViewModelProvider
    extends $NotifierProvider<RegisterViewModel, AsyncValue<void>> {
  /// Register view model
  RegisterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerViewModelHash();

  @$internal
  @override
  RegisterViewModel create() => RegisterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$registerViewModelHash() => r'88ccac5f9e9b29017d8c55f9ca927d2b704762e1';

/// Register view model

abstract class _$RegisterViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.

@ProviderFor(AuthActionsViewModel)
final authActionsViewModelProvider = AuthActionsViewModelProvider._();

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.
final class AuthActionsViewModelProvider
    extends $NotifierProvider<AuthActionsViewModel, void> {
  /// Provides shared auth actions (sign-out, social sign-in, role management).
  ///
  /// Declaring this as a [Provider] at global scope is intentional: the class
  /// is a thin pass-through over [authRepositoryProvider] and carries no local
  /// state, so it does not need to be auto-disposed per-widget.
  AuthActionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authActionsViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authActionsViewModelHash();

  @$internal
  @override
  AuthActionsViewModel create() => AuthActionsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$authActionsViewModelHash() =>
    r'5398df8c5035070c5cba797c10c0e03631d3b7bc';

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.

abstract class _$AuthActionsViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
