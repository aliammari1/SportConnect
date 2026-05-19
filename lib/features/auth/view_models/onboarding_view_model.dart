import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'onboarding_view_model.g.dart';

enum OnboardingAction {
  riderDone,
  profileSaved,
  vehicleSaved,
  finalized,
  finalizedStripe,
}

/// Shared state for both rider and driver onboarding flows.
///
/// [completedAction] is set after each successful async operation so the
/// UI's `ref.listen` callback can decide what to do next (advance a page,
/// navigate to home, etc.).  Possible values:
/// - `'riderDone'` - rider onboarding completed → navigate to home
/// - `'profileSaved'` - driver profile saved → advance to vehicle step
/// - `'vehicleSaved'` - vehicle saved → advance to stripe step
/// - `'finalized'` - driver setup finalized → navigate to driver home
/// - `'finalizedStripe'` - driver setup finalized → navigate to stripe onboarding
class OnboardingState {
  const OnboardingState({
    this.isLoading = false,
    this.completedAction,
    this.errorMessage,
    this.driverCurrentStep = 0,
    this.driverProfilePopulated = false,
    this.riderProfilePopulated = false,
    this.driverPhoneNumber,
    this.driverCity,
    this.riderPhoneNumber,
    this.riderCity,
    this.riderCountry,
  });
  final bool isLoading;
  final OnboardingAction? completedAction;
  final String? errorMessage;
  final int driverCurrentStep;
  final bool driverProfilePopulated;
  final bool riderProfilePopulated;
  final String? driverPhoneNumber;
  final String? driverCity;
  final String? riderPhoneNumber;
  final String? riderCity;
  final String? riderCountry;

  bool get isSuccess => completedAction != null;

  OnboardingState copyWith({
    bool? isLoading,
    OnboardingAction? completedAction,
    String? errorMessage,
    int? driverCurrentStep,
    bool? driverProfilePopulated,
    bool? riderProfilePopulated,
    String? driverPhoneNumber,
    String? driverCity,
    String? riderPhoneNumber,
    String? riderCity,
    String? riderCountry,
    bool clearDriverPhoneNumber = false,
    bool clearDriverCity = false,
    bool clearRiderPhoneNumber = false,
    bool clearRiderCity = false,
    bool clearRiderCountry = false,
    bool clearAction = false,
    bool clearError = false,
  }) => OnboardingState(
    isLoading: isLoading ?? this.isLoading,
    completedAction: clearAction
        ? null
        : (completedAction ?? this.completedAction),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    driverCurrentStep: driverCurrentStep ?? this.driverCurrentStep,
    driverProfilePopulated:
        driverProfilePopulated ?? this.driverProfilePopulated,
    riderProfilePopulated: riderProfilePopulated ?? this.riderProfilePopulated,
    driverPhoneNumber: clearDriverPhoneNumber
        ? null
        : (driverPhoneNumber ?? this.driverPhoneNumber),
    driverCity: clearDriverCity ? null : (driverCity ?? this.driverCity),
    riderPhoneNumber: clearRiderPhoneNumber
        ? null
        : (riderPhoneNumber ?? this.riderPhoneNumber),
    riderCity: clearRiderCity ? null : (riderCity ?? this.riderCity),
    riderCountry: clearRiderCountry
        ? null
        : (riderCountry ?? this.riderCountry),
  );
}

@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  OnboardingState build() => const OnboardingState();

  void setDriverCurrentStep(int step) {
    state = state.copyWith(driverCurrentStep: step.clamp(0, 2));
  }

  void advanceDriverStep() {
    setDriverCurrentStep(state.driverCurrentStep + 1);
  }

  void retreatDriverStep() {
    setDriverCurrentStep(state.driverCurrentStep - 1);
  }

  void markDriverProfilePopulated() {
    if (state.driverProfilePopulated) return;
    state = state.copyWith(driverProfilePopulated: true);
  }

  void markRiderProfilePopulated() {
    if (state.riderProfilePopulated) return;
    state = state.copyWith(riderProfilePopulated: true);
  }

  void setDriverDraftContact({String? phoneNumber, String? city}) {
    state = state.copyWith(driverPhoneNumber: phoneNumber, driverCity: city);
  }

  void setRiderDraftContact({
    String? phoneNumber,
    String? city,
    String? country,
  }) {
    state = state.copyWith(
      riderPhoneNumber: phoneNumber,
      riderCity: city,
      riderCountry: country,
    );
  }

  Map<String, dynamic> setupDraftFor(String uid, UserRole path) {
    return ref
        .read(settingsRepositoryProvider)
        .onboardingDraftFor(
          uid,
          path.name,
        );
  }

  Future<void> saveSetupDraft(
    String uid,
    UserRole path,
    Map<String, Object?> draft,
  ) {
    return ref
        .read(settingsRepositoryProvider)
        .saveOnboardingDraft(
          uid,
          path.name,
          draft,
        );
  }

  Future<void> clearSetupDraft(String uid, UserRole path) {
    return ref
        .read(settingsRepositoryProvider)
        .clearOnboardingDraft(
          uid,
          path.name,
        );
  }

  /// Saves a rider profile and clears the needsRoleSelection flag.
  Future<void> completeRiderOnboarding(
    String uid,
    Map<String, dynamic> profileJson,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearAction: true,
      clearError: true,
    );
    try {
      // Finalize role first, then persist onboarding profile fields so we don't
      // lose data from pending -> rider conversion.
      await ref
          .read(authActionsViewModelProvider.notifier)
          .finalizeRoleAs(uid, UserRole.rider);
      if (!ref.mounted) return;

      await ref
          .read(profileActionsViewModelProvider.notifier)
          .updateProfile(uid, profileJson);
      if (!ref.mounted) return;

      await clearSetupDraft(uid, UserRole.rider);
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        completedAction: OnboardingAction.riderDone,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  /// Saves a driver profile (step 1 of driver onboarding).
  Future<void> saveDriverProfile(
    String uid,
    Map<String, dynamic> profileJson,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearAction: true,
      clearError: true,
    );
    try {
      await ref
          .read(profileActionsViewModelProvider.notifier)
          .updateProfile(uid, profileJson);
      if (!ref.mounted) return;
      await saveSetupDraft(uid, UserRole.driver, {
        'profileSaved': true,
        'currentStep': 1,
      });
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        completedAction: OnboardingAction.profileSaved,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  /// Saves a vehicle (step 2 of driver onboarding).
  Future<void> saveVehicle(String uid, VehicleModel vehicle) async {
    state = state.copyWith(
      isLoading: true,
      clearAction: true,
      clearError: true,
    );
    try {
      await ref
          .read(profileActionsViewModelProvider.notifier)
          .addVehicle(uid, vehicle);
      if (!ref.mounted) return;
      await saveSetupDraft(uid, UserRole.driver, {
        'vehicleSaved': true,
        'currentStep': 2,
      });
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        completedAction: OnboardingAction.vehicleSaved,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  /// Clears the role-selection flag and signals navigation to Stripe setup.
  Future<void> finalizeDriverSetupForStripe() async {
    state = state.copyWith(
      isLoading: true,
      clearAction: true,
      clearError: true,
    );
    try {
      final authActions = ref.read(authActionsViewModelProvider.notifier);
      final uid = authActions.currentUser?.uid;
      if (uid == null) {
        throw StateError('User not authenticated');
      }
      await authActions.finalizeRoleAs(uid, UserRole.driver);
      if (!ref.mounted) return;
      await clearSetupDraft(uid, UserRole.driver);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        completedAction: OnboardingAction.finalizedStripe,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  /// Clears the role-selection flag and signals navigation to driver home.
  Future<void> finalizeDriverSetup() async {
    state = state.copyWith(
      isLoading: true,
      clearAction: true,
      clearError: true,
    );
    try {
      final authActions = ref.read(authActionsViewModelProvider.notifier);
      final uid = authActions.currentUser?.uid;
      if (uid == null) {
        throw StateError('User not authenticated');
      }
      await authActions.finalizeRoleAs(uid, UserRole.driver);
      if (!ref.mounted) return;
      await clearSetupDraft(uid, UserRole.driver);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        completedAction: OnboardingAction.finalized,
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
