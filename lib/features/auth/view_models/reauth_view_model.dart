import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'reauth_view_model.g.dart';

/// Lightweight state for re-authentication dialogs.
///
/// The [errorCode] is an untranslated key so the UI can map it to
/// the correct localised string. Possible values:
/// - `'wrong-password'`
/// - `'google'`
/// - `'apple'`
/// - `'generic'`
class ReauthState {
  const ReauthState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorCode,
  });
  final bool isLoading;
  final bool isSuccess;
  final String? errorCode;

  ReauthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorCode,
    bool clearError = false,
  }) => ReauthState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );
}

/// Manages the re-authentication flow for sensitive operations.
///
/// Supports password and Google re-authentication.  The dialog watches
/// this provider's state for loading / error display and listens for
/// [isSuccess] to dismiss itself.
@riverpod
class ReauthViewModel extends _$ReauthViewModel {
  @override
  ReauthState build() => const ReauthState();

  Future<void> reauthWithPassword(String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authActionsViewModelProvider.notifier)
          .reauthenticateWithPassword(password);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        // Re-auth is not an email-enumeration surface (the account is already
        // signed in), so the repository's generic 'invalid-credential' mapping
        // here means the password was wrong.
        errorCode:
            e is AuthException &&
                (e.code == 'wrong-password' || e.code == 'invalid-credential')
            ? 'wrong-password'
            : 'generic',
      );
    }
  }

  Future<void> reauthWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authActionsViewModelProvider.notifier)
          .reauthenticateWithGoogle();
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorCode: 'google');
    }
  }

  Future<void> reauthWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authActionsViewModelProvider.notifier)
          .reauthenticateWithApple();
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorCode: 'apple');
    }
  }
}
