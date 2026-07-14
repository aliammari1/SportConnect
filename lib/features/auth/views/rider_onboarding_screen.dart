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
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/gender_segmented_field.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/onboarding_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

abstract final class _FormFields {
  static const name = 'name';
  static const gender = 'gender';
  static const ageConfirmed = 'ageConfirmed';
  static const expertise = 'expertise';
  static const terms = 'terms';
}

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

class RiderOnboardingScreen extends ConsumerStatefulWidget {
  const RiderOnboardingScreen({super.key});

  @override
  ConsumerState<RiderOnboardingScreen> createState() =>
      _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends ConsumerState<RiderOnboardingScreen> {
  final _form = FormGroup({
    _FormFields.name: FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(60),
        Validators.delegate((control) {
          final value = control.value as String?;
          if (value == null || value.trim().isEmpty) return null;

          final trimmed = value.trim();

          if (RegExp('[0-9]').hasMatch(trimmed)) {
            return {'name': 'Name cannot contain numbers'};
          }

          if (!RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(trimmed)) {
            return {'name': 'Name contains invalid characters'};
          }

          return null;
        }),
      ],
    ),
    _FormFields.gender: FormControl<String>(),
    _FormFields.ageConfirmed: FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
    _FormFields.expertise: FormControl<Expertise>(
      value: Expertise.rookie,
    ),
    _FormFields.terms: FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });

  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();
  StreamSubscription<dynamic>? _draftSubscription;
  String? _draftUid;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final notifier = ref.read(onboardingViewModelProvider.notifier);
      final state = ref.read(onboardingViewModelProvider);

      _populateProfileFields(user);
      _restoreSetupDraft(user.uid);
      _startDraftAutosave(user.uid);

      if (!state.riderProfilePopulated) {
        notifier.markRiderProfilePopulated();
      }
    });
  }

  @override
  void dispose() {
    _draftSubscription?.cancel();
    _form.dispose();
    super.dispose();
  }

  void _startDraftAutosave(String uid) {
    if (_draftUid == uid) return;
    _draftUid = uid;
    _draftSubscription?.cancel();
    _draftSubscription = _form.valueChanges.listen((_) {
      unawaited(_saveSetupDraft(uid));
    });
  }

  void _restoreSetupDraft(String uid) {
    final draft = ref
        .read(onboardingViewModelProvider.notifier)
        .setupDraftFor(uid, UserRole.rider);
    if (draft.isEmpty) return;

    final expertiseText = draft['expertise'] as String?;
    final expertise = switch (expertiseText) {
      'intermediate' => Expertise.intermediate,
      'advanced' => Expertise.advanced,
      'expert' => Expertise.expert,
      'rookie' => Expertise.rookie,
      _ => null,
    };

    _form.patchValue({
      _FormFields.name: draft['name'] as String?,
      _FormFields.gender: draft['gender'] as String?,
      _FormFields.expertise: expertise,
      _FormFields.terms: draft['termsAccepted'] as bool?,
    });
    _phoneKey.currentState?.setValue(draft['phoneNumber'] as String?);
    _addressKey.currentState?.setText(draft['address'] as String?);
  }

  Future<void> _saveSetupDraft(String uid) {
    final values = _form.value;
    return ref.read(onboardingViewModelProvider.notifier).saveSetupDraft(
      uid,
      UserRole.rider,
      {
        'name': (values[_FormFields.name] as String?)?.trim(),
        'gender': values[_FormFields.gender] as String?,
        'expertise': (values[_FormFields.expertise] as Expertise?)?.name,
        'termsAccepted': values[_FormFields.terms] as bool?,
        'phoneNumber': _phoneKey.currentState?.fullNumber,
        'address': _addressKey.currentState?.text.trim(),
      },
    );
  }

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

  void _populateProfileFields(UserModel user) {
    final existingName = _form.control(_FormFields.name).value as String?;
    final existingGender = _form.control(_FormFields.gender).value as String?;

    final patchedName = user.username.trim();

    final patchedGender = switch (user) {
      final RiderModel rider => _normalizeGenderValue(rider.gender),
      final DriverModel driver => _normalizeGenderValue(driver.gender),
      _ => null,
    };

    _form.patchValue({
      _FormFields.name: patchedName.isNotEmpty ? patchedName : existingName,
      _FormFields.gender: patchedGender ?? existingGender,
      _FormFields.expertise: user.expertise,
    });
  }

  Widget _buildNameDisplay(String name, bool hasPhoto, String? photoUrl) {
    final l10n = AppLocalizations.of(context);
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
                      name.isNotEmpty ? name : l10n.authFullName,
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
        .slideY(begin: 0.04, end: 0);
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

  Future<void> _handleBack() async {
    final hasData =
        _form.dirty ||
        (_phoneKey.currentState?.phoneNumber.number.isNotEmpty ?? false);

    if (!hasData) {
      context.go(AppRoutes.roleSelection.path);
      return;
    }

    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).discardChangesTitle),
        content: Text(
          AppLocalizations.of(
            context,
          ).your_profile_info_will_not_be_saved_if_you_go_back,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).keepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context).discard,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      context.go(AppRoutes.roleSelection.path);
    }
  }

  Future<void> _completeOnboarding(OnboardingState vmState) async {
    final currentUser = ref.read(currentUserProvider).value;
    final signedInName = currentUser?.username.trim() ?? '';
    final currentNameValue =
        (_form.control(_FormFields.name).value as String?)?.trim() ?? '';

    if (signedInName.isNotEmpty && currentNameValue.isEmpty) {
      _form.control(_FormFields.name).updateValue(signedInName);
    }

    if (currentUser == null) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(
          context,
        ).profile_not_loaded_yet_please_wait_a_moment,
        type: AdaptiveSnackBarType.warning,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!_form.valid) {
      _form.markAllAsTouched();

      final errors = <String>[];
      final needsManualName = currentUser.username.trim().isEmpty;

      if (needsManualName && _form.control(_FormFields.name).invalid) {
        errors.add(AppLocalizations.of(context).authFullName);
      }
      if (_form.control(_FormFields.ageConfirmed).invalid) {
        errors.add(AppLocalizations.of(context).ageConfirmation);
      }
      if (_form.control(_FormFields.expertise).invalid) {
        errors.add(AppLocalizations.of(context).expertiseLevel);
      }
      if (_form.control(_FormFields.terms).invalid) {
        errors.add(AppLocalizations.of(context).settingsTermsConditions);
      }

      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(
          context,
        ).pleaseFixFields(errors.join(', ')),
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    final phoneValid = _phoneKey.currentState?.validate() == null;
    final addressValid = _addressKey.currentState?.validate() == null;

    if (!phoneValid) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).please_enter_a_valid_phone_number,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    if (!addressValid) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).please_enter_your_address,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    final values = _form.value;
    final phoneInputValue = _phoneKey.currentState?.fullNumber;
    final phoneNumber = (phoneInputValue?.trim().isNotEmpty ?? false)
        ? phoneInputValue!.trim()
        : vmState.riderPhoneNumber;

    final profileUpdates = <String, dynamic>{
      'username':
          ((values[_FormFields.name] as String?)?.trim().isNotEmpty ?? false)
          ? (values[_FormFields.name]! as String).trim()
          : currentUser.username.trim(),
      'phoneNumber': phoneNumber,
      'address': _addressKey.currentState?.text.trim(),
      'gender': values[_FormFields.gender] as String?,
      'expertise':
          ((values[_FormFields.expertise] as Expertise?) ?? Expertise.rookie)
              .name,
    };

    await _saveSetupDraft(currentUser.uid);
    if (!mounted) return;

    await ref
        .read(onboardingViewModelProvider.notifier)
        .completeRiderOnboarding(currentUser.uid, profileUpdates);
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider.select((a) => a.value));
    final l10n = AppLocalizations.of(context);
    final displayName = (currentUser?.username ?? '').trim();
    final photoUrl = currentUser?.photoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final needsManualName = displayName.isEmpty;

    ref
      ..listen(onboardingViewModelProvider, (prev, next) {
        if (next.completedAction == OnboardingAction.riderDone &&
            prev?.completedAction != OnboardingAction.riderDone) {
          AdaptiveSnackBar.show(
            context,
            message: l10n.profile_complete_welcome_aboard,
            type: AdaptiveSnackBarType.success,
            duration: const Duration(seconds: 2),
          );

          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) context.go(AppRoutes.home.path);
          });
          return;
        }

        if (next.errorMessage != null &&
            next.errorMessage != prev?.errorMessage) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage!,
            type: AdaptiveSnackBarType.error,
            duration: const Duration(seconds: 5),
            action: l10n.retry,
            onActionPressed: () => _completeOnboarding(next),
          );
        }
      })
      ..listen(currentUserProvider, (prev, next) {
        final user = next.value;

        if (user != null) {
          final notifier = ref.read(onboardingViewModelProvider.notifier);
          final state = ref.read(onboardingViewModelProvider);

          if (!state.riderProfilePopulated) {
            notifier.markRiderProfilePopulated();

            AdaptiveSnackBar.show(
              context,
              message: l10n.your_saved_info_has_been_prefilled,
              duration: const Duration(seconds: 2),
            );
          }

          _populateProfileFields(user);
        }

        if (next.hasError) {
          AdaptiveSnackBar.show(
            context,
            message: l10n.failed_to_load_your_profile_some_fields_may_be_empty,
            type: AdaptiveSnackBarType.warning,
          );
        }
      });

    final useTabletLayout = context.screenWidth >= Breakpoints.medium;
    final maxWidth = useTabletLayout ? 1120.0 : kMaxWidthForm;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _handleBack(),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          useNativeToolbar: false,
          leading: IconButton(
            tooltip: l10n.goBackTooltip,
            onPressed: _handleBack,
            icon: Icon(Icons.adaptive.arrow_back_rounded),
          ),
          title: l10n.riderOnboardingTitle,
          actions: [
            AdaptiveAppBarAction(
              iosSymbol: 'person.crop.circle.badge.arrow.forward',
              icon: Icons.switch_account_rounded,
              onPressed: _showAccountSwitcherMenu,
            ),
          ],
        ),
        body: MaxWidthContainer(
          maxWidth: maxWidth,
          child: SafeArea(
            child: Semantics(
              container: true,
              label: l10n.riderOnboardingFormLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: adaptiveScreenPadding(context).copyWith(
                      bottom: 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.complete_your_profile,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              l10n.stepOf(2, 2),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: 1,
                            minHeight: 4.h,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReactiveForm(
                      formGroup: _form,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassPanel(
                              padding: EdgeInsets.all(16.w),
                              color: AppColors.surface.withValues(alpha: 0.62),
                              borderColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: AppColors.primary,
                                      size: 28.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.completeRiderProfile,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          l10n.riderProfileDescription,
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
                            ),
                            SizedBox(height: 24.h),

                            _sectionLabel(l10n.personalInfo),

                            if (!needsManualName) ...[
                              _buildNameDisplay(
                                displayName,
                                hasPhoto,
                                photoUrl,
                              ),
                            ] else ...[
                              AdaptiveReactiveTextField(
                                    formControlName: _FormFields.name,
                                    labelText: l10n.authFullName,
                                    hintText: l10n.authFullNameHint,
                                    prefixIcon: const Icon(
                                      Icons.person_rounded,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validationMessages: {
                                      ValidationMessage.required: (_) =>
                                          l10n.nameRequiredError,
                                      ValidationMessage.minLength: (_) =>
                                          l10n.nameMinLengthError,
                                      ValidationMessage.maxLength: (_) =>
                                          l10n.nameTooLongError,
                                      'name': (error) => error as String,
                                    },
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 0.ms)
                                  .slideY(begin: 0.04, end: 0),
                            ],

                            SizedBox(height: 16.h),
                            Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GenderSegmentedField(
                                      formControlName: _FormFields.gender,
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

                            _sectionLabel(l10n.contactAndAddress),

                            IntlPhoneInput(
                                  key: _phoneKey,
                                  initialValue: switch (currentUser) {
                                    final RiderModel rider => rider.phoneNumber,
                                    final DriverModel driver =>
                                      driver.phoneNumber,
                                    final PendingUserModel pending =>
                                      pending.phoneNumber,
                                    _ => null,
                                  },
                                  label: l10n.authPhoneOptional,
                                  hint: l10n.authPhoneHint,
                                  accentColor: AppColors.primary,
                                  fillColor: AppColors.background,
                                  onChanged: (phone) {
                                    ref
                                        .read(
                                          onboardingViewModelProvider.notifier,
                                        )
                                        .setRiderDraftContact(
                                          phoneNumber: phone.isValid
                                              ? phone.fullNumber
                                              : null,
                                        );
                                    final uid = _draftUid;
                                    if (uid != null) {
                                      unawaited(_saveSetupDraft(uid));
                                    }
                                  },
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 180.ms)
                                .slideY(begin: 0.04, end: 0),

                            SizedBox(height: 16.h),

                            AddressAutocompleteField(
                                  key: _addressKey,
                                  label: l10n.addressOptional,
                                  hint: l10n.searchAddressCityOrPlace,
                                  initialValue: switch (currentUser) {
                                    final RiderModel rider => rider.address,
                                    final DriverModel driver => driver.address,
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
                                )
                                .animate()
                                .fadeIn(duration: 300.ms, delay: 240.ms)
                                .slideY(begin: 0.04, end: 0),

                            SizedBox(height: 24.h),

                            _sectionLabel(l10n.ridingDetails),

                            ReactiveExpertisePicker(
                                  formControlName: _FormFields.expertise,
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
                                .slideY(begin: 0.04, end: 0),

                            SizedBox(height: 24.h),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Material(
                                type: MaterialType.transparency,
                                child: ReactiveCheckboxListTile(
                                  formControlName: _FormFields.ageConfirmed,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
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
                            ),

                            ReactiveFormConsumer(
                              builder: (context, form, _) {
                                final ageCtrl = form.control(
                                  _FormFields.ageConfirmed,
                                );
                                final showError =
                                    ageCtrl.touched && ageCtrl.invalid;
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: showError
                                      ? Padding(
                                          key: const ValueKey('age-error'),
                                          padding: EdgeInsets.only(
                                            top: 6.h,
                                            left: 14.w,
                                          ),
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
                                      : const SizedBox.shrink(
                                          key: ValueKey('age-ok'),
                                        ),
                                );
                              },
                            ),

                            SizedBox(height: 8.h),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Material(
                                type: MaterialType.transparency,
                                child: ReactiveCheckboxListTile(
                                  formControlName: _FormFields.terms,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  activeColor: AppColors.primary,
                                  title: Text.rich(
                                    TextSpan(
                                      text: l10n.iAgreeToThe,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: l10n.terms_conditions,
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => context.push(
                                              AppRoutes.terms.path,
                                            ),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            ReactiveFormConsumer(
                              builder: (context, form, _) {
                                final termsControl = form.control(
                                  _FormFields.terms,
                                );
                                final showError =
                                    termsControl.touched &&
                                    termsControl.invalid;

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: showError
                                      ? Padding(
                                          key: const ValueKey('terms-error'),
                                          padding: EdgeInsets.only(
                                            top: 6.h,
                                            left: 14.w,
                                          ),
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
                                      : const SizedBox.shrink(
                                          key: ValueKey('terms-ok'),
                                        ),
                                );
                              },
                            ),

                            SizedBox(height: 28.h),

                            ReactiveFormConsumer(
                              builder: (context, form, _) {
                                final isFormReady = form.valid;
                                final isVmLoading = ref.watch(
                                  onboardingViewModelProvider.select(
                                    (s) => s.isLoading,
                                  ),
                                );

                                return Semantics(
                                  button: true,
                                  label: l10n.completeSetupButton,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity: isFormReady ? 1.0 : 0.55,
                                    child: PremiumButton(
                                      text: isVmLoading
                                          ? l10n.processing
                                          : l10n.completeSetupButton,
                                      onPressed: isVmLoading
                                          ? null
                                          : () => _completeOnboarding(
                                              ref.read(
                                                onboardingViewModelProvider,
                                              ),
                                            ),
                                      isLoading: isVmLoading,
                                      style: isFormReady
                                          ? PremiumButtonStyle.gradient
                                          : PremiumButtonStyle.primary,
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
