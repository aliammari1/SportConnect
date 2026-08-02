import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

part 'role_selection_view_model.g.dart';

/// State for the role-selection screen.
class RoleSelectionState {
  const RoleSelectionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.selectedRole,
    this.errorMessage,
  });
  final bool isLoading;
  final bool isSuccess;
  final UserRole? selectedRole;
  final String? errorMessage;

  RoleSelectionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    UserRole? selectedRole,
    String? errorMessage,
    bool clearError = false,
  }) => RoleSelectionState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    selectedRole: selectedRole ?? this.selectedRole,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

@riverpod
class RoleSelectionViewModel extends _$RoleSelectionViewModel {
  @override
  RoleSelectionState build() => const RoleSelectionState();

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, clearError: true);
  }

  /// Saves the selected role and returns the chosen role on success.
  Future<void> continueWithRole() async {
    final role = state.selectedRole;
    if (role == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Keep user role as `pending`; persist the Onboarding Path so refreshes
      // and native app restarts resume the correct setup flow.
      final authActions = ref.read(authActionsViewModelProvider.notifier);
      final currentUser = authActions.currentUser;
      if (currentUser == null) {
        // Must be an Exception, not an Error/StateError: this is a real
        // runtime condition (session expired), and the `on Exception catch`
        // below only catches Exception subtypes — a StateError here would
        // crash the app uncaught instead of showing an error message.
        throw const AuthException(
          code: 'not-authenticated',
          message: 'Your session has expired. Please sign in again.',
        );
      }

      await ref.read(profileActionsViewModelProvider.notifier).updateProfile(
        currentUser.uid,
        {'selectedRoleIntent': role.name, 'onboardingPath': role.name},
      );
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        clearError: true,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }
}
