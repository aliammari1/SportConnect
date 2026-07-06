import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/gender_segmented_field.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/onboarding_view_model.dart';
import 'package:sport_connect/features/auth/views/driver_onboarding_vehicle_widgets.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

abstract final class _PF {
  static const name = 'name';
  static const gender = 'gender';
  static const ageConfirmed = 'ageConfirmed';
  static const expertise = 'expertise';
  static const terms = 'terms';
}

const _kDriverOnboardingWideMaxWidth = 1180.0;

String? _normalizeGenderValue(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'male':
      return 'Male';
    case 'female':
      return 'Female';
    default:
      return null;
  }
}

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() =>
      _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState
    extends ConsumerState<DriverOnboardingScreen> {
  // ── Localization ─────────────────────────────────────────────────────
  AppLocalizations get l10n => AppLocalizations.of(context);

  // ── Forms ────────────────────────────────────────────────────────────
  late final FormGroup _profileForm;
  late final FormGroup _vehicleForm;

  Future<void> _showAccountSwitcherMenu() async {
    final l10n = AppLocalizations.of(context);

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.g_mobiledata_rounded),
                title: Text(l10n.continueWithGoogle),
                onTap: () => Navigator.of(sheetContext).pop('google'),
              ),
              if (Platform.isIOS || Platform.isMacOS)
                ListTile(
                  leading: const Icon(Icons.apple),
                  title: Text(l10n.continueWithApple),
                  onTap: () => Navigator.of(sheetContext).pop('apple'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    switch (selected) {
      case 'google':
        await _changeGoogleAccount();
      case 'apple':
        await _changeAppleAccount();
    }
  }

  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();
  StreamSubscription<dynamic>? _profileDraftSubscription;
  StreamSubscription<dynamic>? _vehicleDraftSubscription;
  String? _draftUid;

  FormGroup _buildProfileForm() {
    return FormGroup({
      _PF.name: FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.trim().isEmpty) return null;

            final trimmed = value.trim();

            if (RegExp('[0-9]').hasMatch(trimmed)) {
              return {'nameHasNumbers': true};
            }

            if (!RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(trimmed)) {
              return {'nameInvalidCharacters': true};
            }

            return null;
          }),
        ],
      ),
      _PF.gender: FormControl<String>(),
      _PF.ageConfirmed: FormControl<bool>(
        value: false,
        validators: [Validators.requiredTrue],
      ),
      _PF.expertise: FormControl<Expertise>(
        value: Expertise.rookie,
        validators: [Validators.required],
      ),
      _PF.terms: FormControl<bool>(
        value: false,
        validators: [Validators.requiredTrue],
      ),
    });
  }

  FormGroup _buildVehicleForm() {
    return FormGroup({
      VehicleFormFields.make: FormControl<String>(
        validators: [Validators.required],
      ),
      VehicleFormFields.model: FormControl<String>(
        validators: [Validators.required],
      ),
      VehicleFormFields.year: FormControl<String>(
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.trim().isEmpty) return null;

            final year = int.tryParse(value.trim());

            if (year == null) {
              return {'vehicleYearInvalid': true};
            }

            if (year < 1980) {
              return {'vehicleYearTooOld': true};
            }

            if (year > DateTime.now().year) {
              return {'vehicleYearFuture': true};
            }

            return null;
          }),
        ],
      ),
      VehicleFormFields.color: FormControl<String>(
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = (control.value as String? ?? '').trim();
            if (value.isEmpty) return null;

            if (value.length > 32) {
              return {'vehicleColorTooLong': true};
            }

            if (!RegExp(r"^[\p{L}\s\-']+$", unicode: true).hasMatch(value)) {
              return {'vehicleColorInvalidCharacters': true};
            }

            return null;
          }),
        ],
      ),
      VehicleFormFields.licensePlate: FormControl<String>(
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.trim().isEmpty) return null;

            final trimmed = value.trim().toUpperCase();

            if (trimmed.length < 2) {
              return {'licensePlateTooShort': true};
            }

            if (trimmed.length > 12) {
              return {'licensePlateTooLong': true};
            }

            if (!RegExp(r'^[A-Z0-9\-\s]+$').hasMatch(trimmed)) {
              return {'licensePlateInvalidFormat': true};
            }

            return null;
          }),
        ],
      ),
      VehicleFormFields.seats: FormControl<String>(
        value: '3',
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final raw = control.value as String?;
            if (raw == null || raw.isEmpty) return null;

            final parsed = int.tryParse(raw);

            if (parsed == null) {
              return {'seatsInvalid': true};
            }

            if (parsed < 1 || parsed > 4) {
              return {'seatsOutOfRange': true};
            }

            return null;
          }),
        ],
      ),
    });
  }

  @override
  void initState() {
    super.initState();

    _profileForm = _buildProfileForm();
    _vehicleForm = _buildVehicleForm();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final skipProfileStep = _skipProfileStep(context);
      final notifier = ref.read(onboardingViewModelProvider.notifier);
      final state = ref.read(onboardingViewModelProvider);

      if (!state.driverProfilePopulated) {
        notifier.markDriverProfilePopulated();
        _populateProfileFields(user);
      }

      _restoreSetupDraft(user.uid);
      _startDraftAutosave(user.uid);

      if (skipProfileStep && state.driverCurrentStep == 0) {
        notifier.setDriverCurrentStep(1);
      }
    });
  }

  bool _skipProfileStep(BuildContext context) {
    final state = GoRouterState.of(context);
    return state.uri.queryParameters['skipProfile'] == 'true';
  }

  /// Computes the correct effective step, accounting for:
  /// - skipProfile flag (profile already filled → skip to vehicle)
  /// - driver already having vehicles (refresh at stripe step → jump to stripe)
  int _effectiveStep(
    OnboardingState vmState,
    bool skipProfileStep,
    UserModel? currentUser,
  ) {
    final driver = currentUser is DriverModel ? currentUser : null;

    // If driver already has vehicles, they must be on the stripe step.
    if (driver != null && driver.vehicleIds.isNotEmpty) {
      // Sync the VM step so back-button logic is also correct.
      if (vmState.driverCurrentStep < 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(onboardingViewModelProvider.notifier)
                .setDriverCurrentStep(2);
          }
        });
        return 2;
      }
      return vmState.driverCurrentStep;
    }

    // Profile already filled but no vehicles yet → vehicle step.
    if (skipProfileStep && vmState.driverCurrentStep == 0) {
      return 1;
    }

    return vmState.driverCurrentStep;
  }

  // ── Navigation helpers ──────────────────────────────────────────────

  void _nextStep(OnboardingState vmState) {
    if (vmState.driverCurrentStep == 0) {
      _profileForm.markAllAsTouched();
      if (!_profileForm.valid) return;

      final phoneError = _phoneKey.currentState?.validate();
      if (phoneError != null) return;

      final addressError = _addressKey.currentState?.validate();
      if (addressError != null) return;
    } else if (vmState.driverCurrentStep == 1) {
      _vehicleForm.markAllAsTouched();
      if (!_vehicleForm.valid) return;
    }

    if (vmState.driverCurrentStep < 2) {
      ref.read(onboardingViewModelProvider.notifier).advanceDriverStep();
    }
  }

  void _previousStep(OnboardingState vmState, {required bool skipProfileStep}) {
    final currentUser = ref.read(currentUserProvider).value;
    final effectiveStep = _effectiveStep(vmState, skipProfileStep, currentUser);

    if (skipProfileStep && effectiveStep <= 1) {
      context.go(AppRoutes.roleSelection.path);
      return;
    }

    if (effectiveStep > 0) {
      ref.read(onboardingViewModelProvider.notifier).retreatDriverStep();
    }
  }

  // ── Profile helpers (Step 0) ───────────────────────────────────────

  void _populateProfileFields(UserModel user) {
    final existingName = _profileForm.control(_PF.name).value as String?;
    final existingGender = _profileForm.control(_PF.gender).value as String?;
    final patchedName = user.username.trim();
    final patchedGender = switch (user) {
      DriverModel(:final gender) => _normalizeGenderValue(gender),
      RiderModel(:final gender) => _normalizeGenderValue(gender),
      _ => null,
    };

    _profileForm.patchValue({
      _PF.name: patchedName.isNotEmpty ? patchedName : existingName,
      _PF.gender: patchedGender ?? existingGender,
      _PF.expertise: user.expertise,
    });
  }

  Future<void> _saveProfileAndContinue() async {
    _profileForm.markAllAsTouched();
    if (!_profileForm.valid) return;

    final phoneError = _phoneKey.currentState?.validate();
    if (phoneError != null) return;

    final addressError = _addressKey.currentState?.validate();
    if (addressError != null) return;

    final values = _profileForm.value;
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final vmState = ref.read(onboardingViewModelProvider);
    final phoneInputValue = _phoneKey.currentState?.fullNumber;
    final phoneNumber = (phoneInputValue?.trim().isNotEmpty ?? false)
        ? phoneInputValue!.trim()
        : vmState.driverPhoneNumber;

    final profileUpdates = <String, dynamic>{
      'username': (values[_PF.name] as String? ?? '').trim(),
      'phoneNumber': phoneNumber,
      'address': _addressKey.currentState?.text.trim() ?? '',
      'gender': values[_PF.gender] as String?,
      'expertise':
          ((values[_PF.expertise] as Expertise?) ?? Expertise.rookie).name,
    };

    await _saveSetupDraft(currentUser.uid);
    if (!mounted) return;

    await ref
        .read(onboardingViewModelProvider.notifier)
        .saveDriverProfile(currentUser.uid, profileUpdates);
  }

  // ── Vehicle + Stripe helpers ───────────────────────────────────────

  Future<void> _saveVehicleAndContinue() async {
    _vehicleForm.markAllAsTouched();
    if (!_vehicleForm.valid) return;
    final values = _vehicleForm.value;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final vehicle = VehicleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: currentUser.uid,
      ownerName: currentUser.username,
      ownerPhotoUrl: currentUser.photoUrl,
      make: (values[VehicleFormFields.make] as String?)!,
      model: (values[VehicleFormFields.model] as String?)!,
      year: int.parse((values[VehicleFormFields.year] as String?)!),
      color: (values[VehicleFormFields.color] as String?)!,
      licensePlate: (values[VehicleFormFields.licensePlate] as String?)!,
      capacity: int.parse((values[VehicleFormFields.seats] as String?)!),
      isActive: true,
    );

    await _saveSetupDraft(currentUser.uid);
    if (!mounted) return;

    await ref
        .read(onboardingViewModelProvider.notifier)
        .saveVehicle(currentUser.uid, vehicle);
  }

  Future<void> _setupStripe() async {
    await ref
        .read(onboardingViewModelProvider.notifier)
        .finalizeDriverSetupForStripe();
  }

  Future<void> _changeGoogleAccount() async {
    try {
      final switched = await ref
          .read(authActionsViewModelProvider.notifier)
          .switchGoogleAccountForOnboarding();
      if (!mounted) return;
      if (!switched) {
        context.go(AppRoutes.onboarding.path);
        return;
      }
      context.go(AppRoutes.roleSelection.path);
    } on AuthException catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.message,
        type: AdaptiveSnackBarType.error,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: userFacingError(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _changeAppleAccount() async {
    try {
      final switched = await ref
          .read(authActionsViewModelProvider.notifier)
          .switchAppleAccountForOnboarding();
      if (!mounted) return;
      if (!switched) {
        context.go(AppRoutes.onboarding.path);
        return;
      }
      context.go(AppRoutes.roleSelection.path);
    } on AuthException catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.message,
        type: AdaptiveSnackBarType.error,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: userFacingError(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _profileDraftSubscription?.cancel();
    _vehicleDraftSubscription?.cancel();
    _profileForm.dispose();
    _vehicleForm.dispose();
    super.dispose();
  }

  void _startDraftAutosave(String uid) {
    if (_draftUid == uid) return;
    _draftUid = uid;
    _profileDraftSubscription?.cancel();
    _vehicleDraftSubscription?.cancel();
    _profileDraftSubscription = _profileForm.valueChanges.listen((_) {
      unawaited(_saveSetupDraft(uid));
    });
    _vehicleDraftSubscription = _vehicleForm.valueChanges.listen((_) {
      unawaited(_saveSetupDraft(uid));
    });
  }

  void _restoreSetupDraft(String uid) {
    final draft = ref
        .read(onboardingViewModelProvider.notifier)
        .setupDraftFor(uid, UserRole.driver);
    if (draft.isEmpty) return;

    final expertiseText = draft['expertise'] as String?;
    final expertise = switch (expertiseText) {
      'intermediate' => Expertise.intermediate,
      'advanced' => Expertise.advanced,
      'expert' => Expertise.expert,
      'rookie' => Expertise.rookie,
      _ => null,
    };

    _profileForm.patchValue({
      _PF.name: draft['name'] as String?,
      _PF.gender: draft['gender'] as String?,
      _PF.expertise: expertise,
    });
    _vehicleForm.patchValue({
      VehicleFormFields.make: draft['vehicleMake'] as String?,
      VehicleFormFields.model: draft['vehicleModel'] as String?,
      VehicleFormFields.year: draft['vehicleYear'] as String?,
      VehicleFormFields.color: draft['vehicleColor'] as String?,
      VehicleFormFields.licensePlate: draft['licensePlate'] as String?,
      VehicleFormFields.seats: draft['vehicleSeats'] as String?,
    });
    _phoneKey.currentState?.setValue(draft['phoneNumber'] as String?);
    _addressKey.currentState?.setText(draft['address'] as String?);

    final currentStep = draft['currentStep'];
    if (currentStep is int) {
      ref
          .read(onboardingViewModelProvider.notifier)
          .setDriverCurrentStep(
            currentStep,
          );
    }
  }

  Future<void> _saveSetupDraft(String uid) {
    final profileValues = _profileForm.value;
    final vehicleValues = _vehicleForm.value;
    return ref.read(onboardingViewModelProvider.notifier).saveSetupDraft(
      uid,
      UserRole.driver,
      {
        'currentStep': ref.read(onboardingViewModelProvider).driverCurrentStep,
        'name': (profileValues[_PF.name] as String?)?.trim(),
        'gender': profileValues[_PF.gender] as String?,
        'expertise': (profileValues[_PF.expertise] as Expertise?)?.name,
        'phoneNumber': _phoneKey.currentState?.fullNumber,
        'address': _addressKey.currentState?.text.trim(),
        'vehicleMake': (vehicleValues[VehicleFormFields.make] as String?)
            ?.trim(),
        'vehicleModel': (vehicleValues[VehicleFormFields.model] as String?)
            ?.trim(),
        'vehicleYear': (vehicleValues[VehicleFormFields.year] as String?)
            ?.trim(),
        'vehicleColor': (vehicleValues[VehicleFormFields.color] as String?)
            ?.trim(),
        'licensePlate':
            (vehicleValues[VehicleFormFields.licensePlate] as String?)?.trim(),
        'vehicleSeats': (vehicleValues[VehicleFormFields.seats] as String?)
            ?.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider.select((a) => a.value));
    final vmState = ref.watch(onboardingViewModelProvider);
    final skipProfileStep = _skipProfileStep(context);
    final effectiveStep = _effectiveStep(vmState, skipProfileStep, currentUser);

    ref
      ..listen(currentUserProvider, (prev, next) {
        final user = next.value;
        if (user == null) return;

        final notifier = ref.read(onboardingViewModelProvider.notifier);
        final state = ref.read(onboardingViewModelProvider);

        if (!state.driverProfilePopulated) {
          notifier.markDriverProfilePopulated();
          _populateProfileFields(user);
        } else {
          // Keep name/gender in sync if user data arrives slightly later.
          _populateProfileFields(user);
        }

        if (skipProfileStep && state.driverCurrentStep == 0) {
          notifier.setDriverCurrentStep(1);
        }
      })
      ..listen(onboardingViewModelProvider, (prev, next) {
        final action = next.completedAction;
        if (action != null && action != prev?.completedAction) {
          switch (action) {
            case OnboardingAction.profileSaved:
            case OnboardingAction.vehicleSaved:
              _nextStep(next);
            case OnboardingAction.finalizedStripe:
              context.go(AppRoutes.driverStripeOnboarding.path);
            case OnboardingAction.finalized:
              context.go(AppRoutes.driverHome.path);
            case OnboardingAction.riderDone:
              break;
          }
        }

        if (next.errorMessage != null &&
            next.errorMessage != prev?.errorMessage) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage!,
            type: AdaptiveSnackBarType.error,
          );
        }
      });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) =>
          _previousStep(vmState, skipProfileStep: skipProfileStep),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          // Disable the iOS 26 native Liquid Glass toolbar: with no title it
          // renders an empty white glass pill, and the package warns it breaks
          // GoRouter. The standard translucent CupertinoNavigationBar is clean.
          useNativeToolbar: false,
          leading: IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: effectiveStep > 0
                ? l10n.previousStepTooltip
                : l10n.goBackTooltip,
            onPressed: () => effectiveStep > 0
                ? _previousStep(vmState, skipProfileStep: skipProfileStep)
                : context.go(AppRoutes.roleSelection.path),
            icon: Icon(
              Icons.adaptive.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 22.sp,
            ),
          ),
          // Title intentionally omitted: the body already shows a prominent
          // "Complete Your Profile" header plus the step progress indicator,
          // and the iOS 26 nav bar renders a leading title that overlaps the
          // back button. The back action + account switcher are enough here.
          actions: [
            AdaptiveAppBarAction(
              iosSymbol: 'person.crop.circle.badge.arrow.forward',
              icon: Icons.switch_account_rounded,
              onPressed: _showAccountSwitcherMenu,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Only use the two-column "wide" layout when there is genuinely
              // enough width — i.e. a tablet in landscape. iPad portrait
              // (~820pt) and phones use the single-column form so it is never
              // crushed into an unreadable two-column squeeze.
              final useWide =
                  MediaQuery.sizeOf(context).shortestSide >=
                      Breakpoints.compact &&
                  constraints.maxWidth >= 900;
              if (useWide) {
                return MaxWidthContainer(
                  maxWidth: _kDriverOnboardingWideMaxWidth,
                  child: _buildWideBody(
                    vmState,
                    currentUser,
                    skipProfileStep: skipProfileStep,
                    effectiveStep: effectiveStep,
                  ),
                );
              }
              return MaxWidthContainer(
                maxWidth: kMaxWidthForm,
                child: _buildCompactBody(
                  vmState,
                  currentUser,
                  skipProfileStep: skipProfileStep,
                  effectiveStep: effectiveStep,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactBody(
    OnboardingState vmState,
    UserModel? currentUser, {
    required bool skipProfileStep,
    required int effectiveStep,
  }) {
    return Column(
      children: [
        _buildProgressIndicator(
          vmState,
          skipProfileStep: skipProfileStep,
          effectiveStep: effectiveStep,
        ),
        Expanded(
          child: _buildAnimatedStepContent(vmState, currentUser, effectiveStep),
        ),
      ],
    );
  }

  Widget _buildWideBody(
    OnboardingState vmState,
    UserModel? currentUser, {
    required bool skipProfileStep,
    required int effectiveStep,
  }) {
    return Padding(
      padding: adaptiveScreenPadding(context).copyWith(top: 12.h, bottom: 24.h),
      child: Column(
        children: [
          _buildProgressIndicator(
            vmState,
            skipProfileStep: skipProfileStep,
            effectiveStep: effectiveStep,
          ),
          SizedBox(height: 18.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: ColoredBox(
                      color: AppColors.surface.withValues(alpha: 0.28),
                      child: _buildAnimatedStepContent(
                        vmState,
                        currentUser,
                        effectiveStep,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 24.w),
                SizedBox(
                  width: 320.w,
                  child: _DriverOnboardingAside(
                    currentUser: currentUser,
                    effectiveStep: effectiveStep,
                    skipProfileStep: skipProfileStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStepContent(
    OnboardingState vmState,
    UserModel? currentUser,
    int effectiveStep,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(effectiveStep),
        child: switch (effectiveStep) {
          0 => _buildProfileStep(vmState, currentUser),
          1 => _buildVehicleStep(vmState),
          _ => _buildStripeStep(vmState),
        },
      ),
    );
  }

  // ── Step progress bar ──────────────────────────────────────────────

  Widget _buildProgressIndicator(
    OnboardingState vmState, {
    required bool skipProfileStep,
    required int effectiveStep,
  }) {
    final steps = skipProfileStep
        ? [
            (
              l10n.vehicle,
              Icons.directions_car_outlined,
              1,
            ),
            (
              l10n.payouts,
              Icons.account_balance_outlined,
              2,
            ),
          ]
        : [
            (
              l10n.navProfile,
              Icons.person_outline_rounded,
              0,
            ),
            (
              l10n.vehicle,
              Icons.directions_car_outlined,
              1,
            ),
            (
              l10n.payouts,
              Icons.account_balance_outlined,
              2,
            ),
          ];

    return Padding(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 0),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildStepIndicator(
                  steps[i].$3,
                  steps[i].$1,
                  steps[i].$2,
                  effectiveStep,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                        gradient: effectiveStep > steps[i].$3
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              )
                            : null,
                        color: effectiveStep > steps[i].$3
                            ? null
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _stepSubtitle(context, effectiveStep),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                l10n.stepOf(
                  skipProfileStep ? effectiveStep : effectiveStep + 1,
                  skipProfileStep ? 2 : 3,
                ),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stepSubtitle(BuildContext context, int step) => switch (step) {
    0 => l10n.driverProfileSubtitle,
    1 => l10n.addYourVehicle,
    _ => l10n.setupPayouts,
  };

  Widget _buildStepIndicator(
    int step,
    String label,
    IconData icon,
    int currentStep,
  ) {
    final isCompleted = currentStep > step;
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 44.w : 40.w,
          height: isCurrent ? 44.w : 40.w,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  )
                : null,
            color: isActive ? null : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                : Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.textTertiary,
                    size: 18.sp,
                  ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ── Section label helper ──────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 10.h, top: 4.h),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.textSecondary,
      ),
    ),
  );

  // ── Step 0: Profile ────────────────────────────────────────────────

  Widget _buildProfileStep(OnboardingState vmState, UserModel? currentUser) {
    final l10n = AppLocalizations.of(context);
    final displayName = (currentUser?.username ?? '').trim();
    final photoUrl = currentUser?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final needsManualName = displayName.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: ReactiveForm(
        formGroup: _profileForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header panel ─────────────────────────────────────────────
            GlassPanel(
              padding: EdgeInsets.all(16.w),
              color: AppColors.surface.withValues(alpha: 0.62),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.drive_eta_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.driverProfileTitle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.driverProfileSubtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // ── Section: Personal Info ───────────────────────────────────
            _sectionLabel(l10n.personalInfo),

            if (!needsManualName) ...[
              _buildNameDisplay(displayName, hasPhoto, photoUrl),
            ] else ...[
              AdaptiveReactiveTextField(
                    formControlName: _PF.name,
                    textInputAction: TextInputAction.next,
                    labelText: l10n.authFullName,
                    hintText: l10n.authFullNameHint,
                    prefixIcon: const Icon(Icons.person_rounded),
                    validationMessages: {
                      ValidationMessage.required: (_) => l10n.nameRequiredError,
                      ValidationMessage.minLength: (_) =>
                          l10n.nameMinLengthError,
                      ValidationMessage.maxLength: (_) => l10n.name_is_too_long,
                      'nameHasNumbers': (_) => l10n.name_cannot_contain_numbers,
                      'nameInvalidCharacters': (_) =>
                          l10n.name_contains_invalid_characters,
                    },
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 0.ms)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                  ),
            ],

            SizedBox(height: 16.h),

            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenderSegmentedField(
                      formControlName: _PF.gender,
                      label: l10n.genderOptional,
                      maleLabel: l10n.genderMale,
                      femaleLabel: l10n.genderFemale,
                      validationMessages: const {},
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 60.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 24.h),

            // ── Section: Contact & Address ──────────────────────────────
            _sectionLabel(l10n.contactAndAddress),

            IntlPhoneInput(
                  key: _phoneKey,
                  initialValue: switch (currentUser) {
                    final DriverModel driver => driver.phoneNumber,
                    final RiderModel rider => rider.phoneNumber,
                    final PendingUserModel pending => pending.phoneNumber,
                    _ => null,
                  },
                  label: l10n.authPhoneOptional,
                  hint: l10n.authPhoneHint,
                  accentColor: AppColors.primary,
                  fillColor: AppColors.background,
                  onChanged: (phone) {
                    ref
                        .read(onboardingViewModelProvider.notifier)
                        .setDriverDraftContact(
                          phoneNumber: phone.isValid ? phone.fullNumber : null,
                        );
                    final uid = _draftUid;
                    if (uid != null) {
                      unawaited(_saveSetupDraft(uid));
                    }
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 180.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 16.h),

            AddressAutocompleteField(
                  key: _addressKey,
                  label: l10n.address,
                  hint: l10n.searchAddressCityOrPlace,
                  initialValue: switch (currentUser) {
                    final DriverModel driver => driver.address,
                    final RiderModel rider => rider.address,
                    _ => null,
                  },
                  accentColor: AppColors.primary,
                  fillColor: AppColors.background,
                  onSelected: (_) {
                    final uid = _draftUid;
                    if (uid != null) {
                      unawaited(_saveSetupDraft(uid));
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.address_is_required;
                    }
                    return null;
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 240.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 20.h),

            // ── Section: Driving Details ─────────────────────────────────
            _sectionLabel(l10n.drivingDetails),

            ReactiveExpertisePicker(
                  formControlName: _PF.expertise,
                  label: l10n.expertiseLevel,
                  accent: AppColors.primary,
                  textColor: AppColors.textPrimary,
                  cardBg: AppColors.surface,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.expertiseLevelRequired,
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .slideY(
                  begin: 0.04,
                  end: 0,
                ),

            SizedBox(height: 20.h),

            // ── Terms ────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: ReactiveCheckboxListTile(
                  formControlName: _PF.ageConfirmed,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: Text(
                    l10n.ageConfirmation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 360.ms),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final ageCtrl = form.control(_PF.ageConfirmed);
                final showError = ageCtrl.touched && ageCtrl.invalid;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showError
                      ? Padding(
                          key: const ValueKey('age-error'),
                          padding: EdgeInsets.only(top: 6.h, left: 14.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 14.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  l10n.ageConfirmationRequired,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('age-ok')),
                );
              },
            ),

            SizedBox(height: 8.h),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: ReactiveCheckboxListTile(
                  formControlName: _PF.terms,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: Text.rich(
                    TextSpan(
                      text: l10n.i_agree_to_the,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.terms_conditions,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push(AppRoutes.terms.path),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 360.ms),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final ctrl = form.control(_PF.terms);
                final showError = ctrl.touched && ctrl.invalid;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showError
                      ? Padding(
                          key: const ValueKey('terms-error'),
                          padding: EdgeInsets.only(top: 6.h, left: 14.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 14.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  l10n.you_must_accept_the_terms_to_continue,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('terms-ok')),
                );
              },
            ),

            SizedBox(height: 28.h),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final isFormReady = form.valid;
                final isLoading = ref.watch(
                  onboardingViewModelProvider.select((s) => s.isLoading),
                );

                return Semantics(
                  button: true,
                  label: l10n.save_driver_profile_and_continue,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isFormReady ? 1.0 : 0.55,
                    child: PremiumButton(
                      text: isLoading
                          ? l10n.loading
                          : l10n.save_driver_profile_and_continue,
                      onPressed: isLoading ? null : _saveProfileAndContinue,
                      isLoading: isLoading,
                      style: isFormReady
                          ? PremiumButtonStyle.ghost
                          : PremiumButtonStyle.primary,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 300.ms, delay: 420.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Displays the user's name from Google/Apple sign-in as a read-only card.
  Widget _buildNameDisplay(String name, bool hasPhoto, String? photoUrl) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              if (hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                    errorWidget: (ctx, url, err) => _defaultAvatar(name),
                    placeholder: (ctx, url) => _defaultAvatar(name),
                  ),
                )
              else
                _defaultAvatar(name),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : l10n.yourName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            l10n.from_your_signin_account,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 30.ms)
        .slideY(
          begin: 0.04,
          end: 0,
        );
  }

  Widget _defaultAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Step 1: Vehicle ─────────────────────────────────────────────────

  Widget _buildVehicleStep(OnboardingState vmState) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: ReactiveForm(
        formGroup: _vehicleForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(
              padding: EdgeInsets.all(16.w),
              color: AppColors.surface.withValues(alpha: 0.62),
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addYourVehicle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.help_riders_recognize_your_car_at_pickup,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 20.h),

            ReactiveFormConsumer(
                  builder: (context, form, _) {
                    return VehicleLiveSummary(
                      form: form,
                      accent: AppColors.primary,
                    );
                  },
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 40.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 24.h),

            _sectionLabel(l10n.carIdentity),

            VehicleSectionCard(
                  icon: Icons.directions_car_rounded,
                  title: l10n.what_car_should_riders_look_for,
                  subtitle:
                      l10n.keep_this_simple_make_and_model_are_enough_here,
                  accent: AppColors.primary,
                  children: [
                    VehicleTextField(
                      formControlName: VehicleFormFields.make,
                      label: l10n.make,
                      hintText: l10n.vehicleMakeHint,
                      icon: Icons.business_rounded,
                      textInputAction: TextInputAction.next,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterVehicleMake,
                      },
                    ),
                    VehicleTextField(
                      formControlName: VehicleFormFields.model,
                      label: l10n.model,
                      hintText: l10n.vehicleModelHint,
                      icon: Icons.drive_eta_rounded,
                      textInputAction: TextInputAction.next,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterVehicleModel,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 80.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel(l10n.recognition),

            VehicleSectionCard(
                  icon: Icons.visibility_rounded,
                  title: l10n.help_passengers_find_you,
                  subtitle:
                      l10n.color_and_plate_are_the_details_riders_use_at_pickup,
                  accent: AppColors.primary,
                  children: [
                    VehicleColorSelector(
                      formControlName: VehicleFormFields.color,
                      label: l10n.color,
                      validationMessages: {
                        ValidationMessage.required: (_) => l10n.requiredField,
                        'vehicleColorTooLong': (_) =>
                            l10n.colorDescriptionIsTooLong,
                        'vehicleColorInvalidCharacters': (_) =>
                            l10n.useAClearColorNameLikeGreyBlueOrPearlWhite,
                      },
                    ),
                    LicensePlateInput(
                      formControlName: VehicleFormFields.licensePlate,
                      label: l10n.licensePlate,
                      hintText: l10n.licensePlateHint,
                      helperText: l10n.onlyUsedWhenNeededForPickupVerification,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterLicensePlate,
                        'licensePlateTooShort': (_) =>
                            l10n.license_plate_is_too_short,
                        'licensePlateTooLong': (_) =>
                            l10n.license_plate_is_too_long,
                        'licensePlateInvalidFormat': (_) =>
                            l10n.invalid_license_plate_format,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 140.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel(l10n.passengerSeats),

            VehicleSectionCard(
                  icon: Icons.event_seat_rounded,
                  title: l10n.how_many_passengers_can_you_take,
                  subtitle: l10n
                      .this_is_available_passenger_seats_not_total_car_seats,
                  accent: AppColors.primary,
                  children: [
                    SeatChipSelector(
                      formControlName: VehicleFormFields.seats,
                      label: l10n.seatsLabel,
                      validationMessages: {
                        ValidationMessage.required: (_) =>
                            l10n.pleaseEnterNumberOfSeats,
                        'seatsInvalid': (_) =>
                            l10n.please_select_number_of_seats,
                        'seatsOutOfRange': (_) =>
                            l10n.seats_must_be_between_1_and_4,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 22.h),

            _sectionLabel(l10n.moreDetails),

            VehicleSectionCard(
                  icon: Icons.tune_rounded,
                  title: l10n.vehicle_details,
                  subtitle: l10n
                      .kept_quieter_because_they_are_less_important_at_pickup,
                  accent: AppColors.primary,
                  children: [
                    VehicleTextField(
                      formControlName: VehicleFormFields.year,
                      label: l10n.year,
                      hintText: DateTime.now().year.toString(),
                      helperText: l10n.registrationYear,
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validationMessages: {
                        ValidationMessage.required: (_) => l10n.requiredField,
                        'vehicleYearInvalid': (_) =>
                            l10n.please_enter_a_valid_year,
                        'vehicleYearTooOld': (_) => l10n.vehicle_is_too_old,
                        'vehicleYearFuture': (_) => l10n.invalid_year,
                      },
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: 260.ms)
                .slideY(begin: 0.04, end: 0),

            SizedBox(height: 30.h),

            ReactiveFormConsumer(
              builder: (context, form, _) {
                final isFormReady = form.valid;
                final isLoading = ref.watch(
                  onboardingViewModelProvider.select((s) => s.isLoading),
                );

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isFormReady ? 1.0 : 0.55,
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: isLoading
                          ? l10n.loading
                          : l10n.save_driver_profile_and_continue,
                      onPressed: isLoading ? null : _saveVehicleAndContinue,
                      isLoading: isLoading,
                      size: PremiumButtonSize.large,
                      style: isFormReady
                          ? PremiumButtonStyle.success
                          : PremiumButtonStyle.primary,
                      trailingIcon: Icons.adaptive.arrow_forward_rounded,
                    ),
                  ),
                );
              },
            ).animate().fadeIn(duration: 300.ms, delay: 320.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Stripe payouts ─────────────────────────────────────────

  Widget _buildStripeStep(OnboardingState vmState) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header panel ───────────────────────────────────────────────
          GlassPanel(
            padding: EdgeInsets.all(16.w),
            color: AppColors.surface.withValues(alpha: 0.62),
            borderColor: AppColors.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.setupPayouts,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.driverStripeStepSubtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: 24.h),

          _sectionLabel(l10n.whyConnectPayouts),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.06),
                  AppColors.secondary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.security_rounded,
                  title: l10n.securePayments,
                  description: l10n.stripePoweredByMillions,
                  delay: 60,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildBenefitItem(
                  icon: Icons.flash_on_rounded,
                  title: l10n.fastTransfers,
                  description: l10n.stripeFastTransfersDesc,
                  delay: 120,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildBenefitItem(
                  icon: Icons.receipt_long_rounded,
                  title: l10n.easyTracking,
                  description: l10n.stripeEarningsDesc,
                  delay: 180,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.connectWithStripe,
              onPressed: vmState.isLoading ? null : _setupStripe,
              isLoading: vmState.isLoading,
              size: PremiumButtonSize.large,
              style: PremiumButtonStyle.success,
              icon: Icons.link_rounded,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    int delay = 0,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverOnboardingAside extends StatelessWidget {
  const _DriverOnboardingAside({
    required this.currentUser,
    required this.effectiveStep,
    required this.skipProfileStep,
  });

  final UserModel? currentUser;
  final int effectiveStep;
  final bool skipProfileStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = (currentUser?.username ?? '').trim();
    final photoUrl = currentUser?.photoUrl;

    final title = switch (effectiveStep) {
      0 => l10n.driverProfileTitle,
      1 => l10n.addYourVehicle,
      _ => l10n.setupPayouts,
    };

    final subtitle = switch (effectiveStep) {
      0 => l10n.driverProfileSubtitle,
      1 => l10n.help_riders_recognize_your_car_at_pickup,
      _ => l10n.driverStripeStepSubtitle,
    };

    final highlights = switch (effectiveStep) {
      0 => [
        l10n.contactAndAddress,
        l10n.drivingDetails,
        l10n.terms_conditions,
      ],
      1 => [
        l10n.carIdentity,
        l10n.vehicle_details,
        l10n.seatsCapacity,
      ],
      _ => [
        l10n.securePayments,
        l10n.fastTransfers,
        l10n.easyTracking,
      ],
    };

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.05),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty) ...[
            Row(
              children: [
                if (photoUrl != null && photoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26.r),
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 52.w,
                      height: 52.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => PremiumAvatar(
                        name: name,
                        size: 52,
                      ),
                    ),
                  )
                else
                  PremiumAvatar(
                    name: name,
                    size: 52,
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.driverSetup,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              l10n.stepOf(
                skipProfileStep ? effectiveStep : effectiveStep + 1,
                skipProfileStep ? 2 : 3,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          SizedBox(height: 24.h),
          for (final item in highlights) ...[
            _AsideBullet(label: item),
            SizedBox(height: 10.h),
          ],
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              switch (effectiveStep) {
                0 => l10n.completeDriverProfileMessage,
                1 => l10n.color_and_plate_are_the_details_riders_use_at_pickup,
                _ => l10n.youCanStillOfferRides,
              },
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AsideBullet extends StatelessWidget {
  const _AsideBullet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2.h),
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
