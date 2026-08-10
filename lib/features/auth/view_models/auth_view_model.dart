import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/models/social_sign_in_result.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

part 'auth_view_model.g.dart';

class SignupWizardUiState {
  const SignupWizardUiState({
    this.currentStep = 0,
    this.passwordText = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.agreedToTerms = false,
    this.selectedRole = UserRole.rider,
    this.profileImage,
    this.phoneNumber,
    this.expertise = Expertise.rookie,
  });

  final int currentStep;
  final String passwordText;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreedToTerms;
  final UserRole selectedRole;
  final File? profileImage;
  final String? phoneNumber;
  final Expertise expertise;

  SignupWizardUiState copyWith({
    int? currentStep,
    String? passwordText,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? agreedToTerms,
    UserRole? selectedRole,
    File? profileImage,
    bool clearProfileImage = false,
    String? phoneNumber,
    Expertise? expertise,
  }) {
    return SignupWizardUiState(
      currentStep: currentStep ?? this.currentStep,
      passwordText: passwordText ?? this.passwordText,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      selectedRole: selectedRole ?? this.selectedRole,
      profileImage: clearProfileImage
          ? null
          : (profileImage ?? this.profileImage),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      expertise: expertise ?? this.expertise,
    );
  }
}

@riverpod
class SignupWizardUiViewModel extends _$SignupWizardUiViewModel {
  @override
  SignupWizardUiState build() => const SignupWizardUiState();

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step.clamp(0, 3));
  }

  void previousStep() {
    setCurrentStep(state.currentStep - 1);
  }

  void setPasswordText(String value) {
    state = state.copyWith(passwordText: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void toggleTermsAgreement() {
    state = state.copyWith(agreedToTerms: !state.agreedToTerms);
  }

  void setSelectedRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  void setProfileImage(File? image) {
    state = state.copyWith(
      profileImage: image,
      clearProfileImage: image == null,
    );
  }

  void setPhoneNumber(String? phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void setExpertise(Expertise expertise) {
    state = state.copyWith(expertise: expertise);
  }
}

/// Login view model
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      if (!ref.mounted) return false;

      final uid = ref.read(authRepositoryProvider).currentUserId;
      final analyticsService = ref.read(firebaseServiceProvider);
      if (uid != null) await analyticsService.setUserId(uid);
      await analyticsService.logLogin('email');
      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;

      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    } on Exception catch (e, st) {
      if (!ref.mounted) rethrow;
      state = AsyncValue.error(e, st);
      // Rethrow so calling widgets (e.g. ForgotPasswordScreen) can also
      // handle the error directly (e.g. show a snackbar with the message).
      rethrow;
    }
  }
}

/// Register view model
@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required UserRole role,
    String? phone,
    File? profileImage,
    Expertise expertise = Expertise.rookie,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmail(
            email: email,
            password: password,
            username: username,
            role: role,
            phone: phone,
            expertise: expertise,
            profileImage: profileImage,
          );
      if (!ref.mounted) return false;

      final uid = ref.read(authRepositoryProvider).currentUserId;
      final analyticsService = ref.read(firebaseServiceProvider);
      if (uid != null) {
        await analyticsService.setUserId(uid);
      }
      await analyticsService.logSignUp('email');
      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;

      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.
@Riverpod(keepAlive: true)
class AuthActionsViewModel extends _$AuthActionsViewModel {
  @override
  void build() {
    return;
  }

  Future<void> signOut() {
    ref.invalidate(signupWizardUiViewModelProvider);
    return ref.read(authRepositoryProvider).signOut();
  }

  Future<void> deleteAccount() {
    return ref.read(authRepositoryProvider).deleteAccount();
  }

  User? get currentUser {
    return ref.read(authRepositoryProvider).currentUser;
  }

  Future<void> createUserDocument(UserModel user) {
    return ref.read(authRepositoryProvider).createUserDocument(user);
  }

  Future<SocialSignInResult> signInWithGoogle() async {
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (!ref.mounted) return result;
    final uid = ref.read(authRepositoryProvider).currentUserId;
    final analyticsService = ref.read(firebaseServiceProvider);
    if (uid != null) await analyticsService.setUserId(uid);
    await analyticsService.logLogin('google');
    return result;
  }

  /// Used during onboarding when a user wants to pick a different Google
  /// account.
  ///
  /// Does NOT sign out of Firebase first: [signInWithGoogle]'s
  /// `signInWithCredential` replaces the current Firebase user on success, so a
  /// cancelled switch must leave the existing session intact (signing out first
  /// would strand the user on /login). Only the Google provider session is
  /// cleared so the account chooser reappears and a different account can be
  /// picked.
  ///
  /// Returns `true` if sign-in succeeds, `false` if the picker is cancelled.
  Future<bool> switchGoogleAccountForOnboarding() async {
    try {
      await ref.read(authRepositoryProvider).signOutGoogleProvider();
      await signInWithGoogle();
      return true;
    } on AuthException catch (e) {
      if (e.code == 'google-sign-in-canceled') {
        return false;
      }
      rethrow;
    }
  }

  /// Used during onboarding when a user wants to pick a different Apple
  /// account.
  ///
  /// Does NOT sign out first: the Apple sheet appears regardless, and
  /// [signInWithApple]'s `signInWithCredential` switches the Firebase user on
  /// success. A cancel then leaves the current session intact instead of
  /// logging the user out and stranding them on /login.
  ///
  /// Returns `true` if sign-in succeeds, `false` if the sheet is cancelled.
  Future<bool> switchAppleAccountForOnboarding() async {
    try {
      await signInWithApple();
      return true;
    } on AuthException catch (e) {
      if (e.code == 'apple-sign-in-canceled') {
        return false;
      }
      rethrow;
    }
  }

  Future<SocialSignInResult> signInWithApple() async {
    final result = await ref.read(authRepositoryProvider).signInWithApple();
    if (!ref.mounted) return result;
    final uid = ref.read(authRepositoryProvider).currentUserId;
    final analyticsService = ref.read(firebaseServiceProvider);
    if (uid != null) await analyticsService.setUserId(uid);
    await analyticsService.logLogin('apple');
    return result;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> reauthenticateWithPassword(String password) {
    return ref
        .read(authRepositoryProvider)
        .reauthenticateWithPassword(password);
  }

  Future<void> reauthenticateWithGoogle() {
    return ref.read(authRepositoryProvider).reauthenticateWithGoogle();
  }

  Future<void> reauthenticateWithApple() {
    return ref.read(authRepositoryProvider).reauthenticateWithApple();
  }

  Future<UserModel> finalizeRoleAs(String uid, UserRole role) {
    return ref.read(authRepositoryProvider).finalizeRoleAs(uid, role);
  }

  // ── Email verification ──────────────────────────────────────────────

  Future<void> sendEmailVerification() {
    return ref.read(authRepositoryProvider).sendEmailVerification();
  }

  Future<bool> isEmailVerified() {
    return ref.read(authRepositoryProvider).isEmailVerified();
  }

  Future<void> reloadUser() {
    return ref.read(authRepositoryProvider).reloadUser();
  }

  /// Updates the current user's password.
  ///
  /// Throws [AuthException] with code `requires-recent-login` if the session
  /// is too old — callers should show a re-auth dialog and retry.
  Future<void> updatePassword(String newPassword) {
    return ref.read(authRepositoryProvider).updatePassword(newPassword);
  }
}
