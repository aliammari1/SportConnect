import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/social_auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─── Step Theme ───────────────────────────────────────────────────────────────

class _StepTheme {  
  // Not const: bg/card read AppColors brightness-aware getters, so the
  // wizard re-themes with dark mode like every other surface.
  _StepTheme({
    required this.bg,
    required this.accent,
    required this.card,
    required this.text,
    required this.label,
  });
  Color bg;
  final Color accent;
  final Color card;
  final Color text;
  final String label;
}

Color get _kText => AppColors.textPrimary;

List<String> _signupStepLabels(AppLocalizations l10n) => [
  l10n.account_setup,
  l10n.identityAndRoleStep,
  l10n.yourProfileStep,
];

String _localizedSignupValidationError(
  AppLocalizations l10n,
  Object error,
) {
  return switch (error.toString()) {
    'name_cannot_contain_numbers' => l10n.name_cannot_contain_numbers,
    'name_contains_invalid_characters' => l10n.name_contains_invalid_characters,
    'include_at_least_one_uppercase_letter' =>
      l10n.include_at_least_one_uppercase_letter,
    'include_at_least_one_lowercase_letter' =>
      l10n.include_at_least_one_lowercase_letter,
    'include_at_least_one_number' => l10n.include_at_least_one_number,
    _ => error.toString(),
  };
}

// UX: 3 steps
final _stepThemes = [
  _StepTheme(
    bg: AppColors.background,
    accent: AppColors.primary,
    card: AppColors.cardBg,
    text: _kText,
    label: 'Account Setup',
  ),
  _StepTheme(
    bg: AppColors.background,
    accent: AppColors.primary,
    card: AppColors.cardBg,
    text: _kText,
    label: 'Identity',
  ),
  _StepTheme(
    bg: AppColors.background,
    accent: AppColors.primary,
    card: AppColors.cardBg,
    text: _kText,
    label: 'Profile',
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class SignupWizardScreen extends ConsumerStatefulWidget {
  const SignupWizardScreen({super.key});

  @override
  ConsumerState<SignupWizardScreen> createState() => _SignupWizardScreenState();
}

class _SignupWizardScreenState extends ConsumerState<SignupWizardScreen> {
  // ── Controllers & State ──
  final List<FormGroup> _forms = [
    // Step 0: Account Setup
    FormGroup(
      {
        'name': FormControl<String>(
          validators: [
            Validators.required,
            Validators.minLength(2),
            Validators.maxLength(60),
            Validators.delegate((control) {
              final value = control.value as String?;
              if (value == null || value.trim().isEmpty) return null;
              final trimmed = value.trim();
              if (RegExp('[0-9]').hasMatch(trimmed)) {
                return {'name': 'name_cannot_contain_numbers'};
              }
              if (!RegExp(
                r"^[\p{L}\s\-'.]+$",
                unicode: true,
              ).hasMatch(trimmed)) {
                return {'name': 'name_contains_invalid_characters'};
              }
              return null;
            }),
          ],
        ),
        'email': FormControl<String>(
          validators: [
            Validators.required,
            Validators.email,
          ],
        ),
        'password': FormControl<String>(
          validators: [
            Validators.required,
            Validators.minLength(8),
            Validators.delegate((control) {
              final value = control.value as String?;
              if (value == null || value.isEmpty) return null;
              if (!RegExp('[A-Z]').hasMatch(value)) {
                return {'password': 'include_at_least_one_uppercase_letter'};
              }
              if (!RegExp('[a-z]').hasMatch(value)) {
                return {'password': 'include_at_least_one_lowercase_letter'};
              }
              if (!RegExp('[0-9]').hasMatch(value)) {
                return {'password': 'include_at_least_one_number'};
              }
              return null;
            }),
          ],
        ),
        'confirm_password': FormControl<String>(
          validators: [Validators.required],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'confirm_password'),
      ],
    ),
    // Step 1: Identity & Role
    FormGroup({
      'expertise': FormControl<Expertise>(),
    }),
    // Step 2: Profile
    FormGroup({}),
  ];
  final _phoneKey = GlobalKey<IntlPhoneInputState>();

  @override
  void initState() {
    super.initState();
    // If the widget is re-mounted (e.g. they left and came back), our new local _forms
    // will be completely blank. Invalidate the global step state to ensure they start at Step 0.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(signupWizardUiViewModelProvider);
    });
  }

  @override
  void dispose() {
    // FormGroup.dispose() closes valueChanges/statusChanges/focusChanges
    // stream controllers and cascades to child FormControls. Calling it
    // for every FormGroup is required by reactive_forms to avoid leaking
    // streams on every navigation away from the wizard.
    for (final form in _forms) {
      form.dispose();
    }
    super.dispose();
  }

  // ── Navigation ──
  Future<void> _goToStep(int target) async {
    final uiState = ref.read(signupWizardUiViewModelProvider);

    // Validate current step
    _forms[uiState.currentStep].markAllAsTouched();
    if (!_forms[uiState.currentStep].valid) {
      return;
    }

    // Step 0 validation: Legal Terms
    if (uiState.currentStep == 0 && !uiState.agreedToTerms) {
      _showError(AppLocalizations.of(context).authAgreeTermsError);
      return;
    }

    // Step 1 validation: Phone
    if (uiState.currentStep == 1) {
      final phoneError = _phoneKey.currentState?.validate();
      if (phoneError != null) return;
    }

    // Move to next step or complete
    if (target >= 3) {
      unawaited(_handleSignup());
      return;
    }

    FocusScope.of(context).unfocus();
    unawaited(HapticFeedback.mediumImpact());
    ref.read(signupWizardUiViewModelProvider.notifier).setCurrentStep(target);
  }

  void _prevStep() {
    final currentStep = ref.read(signupWizardUiViewModelProvider).currentStep;
    if (currentStep == 0) {
      context.pop();
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    ref.read(signupWizardUiViewModelProvider.notifier).previousStep();
  }

  void _showError(String msg) {
    AdaptiveSnackBar.show(
      context,
      message: msg,
      type: AdaptiveSnackBarType.error,
    );
  }

  Future<void> _handleSignup() async {
    final uiState = ref.read(signupWizardUiViewModelProvider);
    final step0Values = _forms[0].value;

    final success = await ref
        .read(registerViewModelProvider.notifier)
        .register(
          email: (step0Values['email'] as String? ?? '').trim(),
          password: step0Values['password'] as String? ?? '',
          username: (step0Values['name'] as String? ?? '').trim(),
          role: uiState.selectedRole,
          phone: uiState.phoneNumber,
          profileImage: uiState.profileImage,
          expertise: uiState.expertise,
        );
    if (!mounted) return;

    if (success) {
      // Reset the provider instance so the next signup starts clean
      ref.invalidate(signupWizardUiViewModelProvider);
      context.go(AppRoutes.emailVerification.path);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xf = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: kMaxWidthFormNarrow,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xf != null) {
      if (!mounted) return;
      ref
          .read(signupWizardUiViewModelProvider.notifier)
          .setProfileImage(File(xf.path));
      unawaited(HapticFeedback.lightImpact());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(socialAuthViewModelProvider.notifier).signInWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(socialAuthViewModelProvider.notifier).signInWithApple();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final theme = _stepThemes[wizardUiState.currentStep];
    final registerState = ref.watch(registerViewModelProvider);
    final socialState = ref.watch(socialAuthViewModelProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(registerViewModelProvider, (previous, next) {
      if (next.hasError && previous?.error != next.error) {
        final error = next.error;
        final msg = error is AuthException
            ? error.message
            : error.toString().replaceFirst('Exception: ', '');
        if (msg.isNotEmpty) _showError(msg);
      }
    });

    ref.listen(socialAuthViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        final e = next.error;
        if (e is AuthException) {
          if (e.code == 'google-sign-in-canceled' ||
              e.code == 'apple-sign-in-canceled') {
            return; // silent
          }
          if (e.code == 'account-exists-with-different-credential') {
            _showError(l10n.accountExistsError);
            return;
          }
          if (e.message.isNotEmpty) _showError(e.message);
          return;
        }
      }
    });

    final isTabletLayout = context.isExpandedOrLarger;

    return PopScope(
      canPop: wizardUiState.currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _prevStep();
      },
      child: AdaptiveScaffold(
        body: isTabletLayout
            ? _buildTabletLayout(theme, registerState, socialState)
            : _buildPhoneLayout(theme, registerState, socialState),
      ),
    );
  }

  Widget _buildPhoneLayout(
    _StepTheme theme,
    AsyncValue<void> registerState,
    SocialAuthState socialState,
  ) {
    return MaxWidthContainer(
      maxWidth: kMaxWidthFormNarrow,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            _buildStepIndicator(),
            Expanded(child: _buildAdaptiveContent(theme)),
            _buildBottomCTA(theme, registerState, socialState),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    _StepTheme theme,
    AsyncValue<void> registerState,
    SocialAuthState socialState,
  ) {
    return MaxWidthContainer(
      maxWidth: 1180,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            _buildStepIndicator(),
            Expanded(
              child: Padding(
                padding: adaptiveScreenPadding(context).copyWith(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.xl,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: _buildTabletOverview(theme)),
                    SizedBox(width: AppSpacing.xxl),
                    Expanded(
                      flex: 5,
                      child: AnimatedPadding(
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: Column(
                          children: [
                            Expanded(child: _buildAdaptiveContent(theme)),
                            _buildBottomCTA(theme, registerState, socialState),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(_StepTheme theme) {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final l10n = AppLocalizations.of(context);
    final stepLabels = _signupStepLabels(l10n);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: _prevStep,
            tooltip: wizardUiState.currentStep == 0
                ? MaterialLocalizations.of(context).closeButtonTooltip
                : MaterialLocalizations.of(context).backButtonTooltip,
            style: IconButton.styleFrom(
              backgroundColor: theme.accent.withValues(alpha: 0.15),
              foregroundColor: theme.accent,
              // Cap at 48 logical pixels so the button doesn't over-scale on
              // tablets and steal horizontal space from the title.
              minimumSize: Size(min(48.w, 48), min(48.w, 48)),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              wizardUiState.currentStep == 0
                  ? Icons.close_rounded
                  : Icons.adaptive.arrow_back_rounded,
              size: 18.sp.clamp(0.0, 20.0),
            ),
          ),
          SizedBox(width: min(10.w, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: 300.ms,
                  child: Text(
                    stepLabels[wizardUiState.currentStep],
                    key: ValueKey(wizardUiState.currentStep),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      // Clamp so on large tablets the title stays readable
                      // without exceeding the available Row width.
                      fontSize: 20.sp.clamp(0.0, 22.0),
                      fontWeight: FontWeight.w800,
                      color: theme.text,
                    ),
                  ),
                ),
                Text(
                  l10n.stepOfCount(
                    wizardUiState.currentStep + 1,
                    3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp.clamp(0.0, 13.0),
                    color: theme.accent.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              3,
              (i) => AnimatedContainer(
                duration: 300.ms,
                // Fixed sizes prevent progress dots from ballooning on tablet
                // and competing with the title for horizontal space.
                margin: const EdgeInsets.only(left: 5),
                width: i == wizardUiState.currentStep ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= wizardUiState.currentStep
                      ? theme.accent
                      : theme.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Speedometer ─────────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: 300.ms,
              margin: EdgeInsets.only(right: i < 2 ? 6.w : 0),
              height: 4.h,
              decoration: BoxDecoration(
                color: i <= wizardUiState.currentStep
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tinder Card Stack ───────────────────────────────────────────────────────
  Widget _buildCard(_StepTheme theme, {bool includeOuterPadding = true}) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: AppSpacing.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusXl,
        child: _buildStepContent(theme),
      ),
    );

    if (!includeOuterPadding) return card;

    return Padding(
      padding: adaptiveScreenPadding(context),
      child: card,
    );
  }

  Widget _buildAdaptiveContent(_StepTheme theme) {
    return _buildCard(
      theme,
      includeOuterPadding: !context.isExpandedOrLarger,
    );
  }

  Widget _buildTabletOverview(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final stepLabels = _signupStepLabels(l10n);
    final stepDescriptions = [
      l10n.authFullNameHint,
      l10n.verification_requirements,
      l10n.addAProfilePhoto,
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.accent.withValues(alpha: 0.12),
            theme.accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: theme.accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              l10n.stepOfCount(
                wizardUiState.currentStep + 1,
                stepLabels.length,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: theme.accent,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            stepLabels[wizardUiState.currentStep],
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: theme.text,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            stepDescriptions[wizardUiState.currentStep],
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: theme.text.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 28.h),
          for (var i = 0; i < stepLabels.length; i++) ...[
            _TabletStepTile(
              index: i + 1,
              title: stepLabels[i],
              description: stepDescriptions[i],
              accent: theme.accent,
              active: wizardUiState.currentStep == i,
              complete: wizardUiState.currentStep > i,
            ),
            if (i < stepLabels.length - 1) SizedBox(height: 12.h),
          ],
          const Spacer(),
          _SecurityBadge(
            accent: theme.accent,
            text: wizardUiState.currentStep == 0
                ? l10n.passwordStrength
                : wizardUiState.currentStep == 1
                ? l10n.verification_requirements
                : l10n.almost_there,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(_StepTheme theme) {
    final currentStep = ref.watch(
      signupWizardUiViewModelProvider.select((s) => s.currentStep),
    );
    return IndexedStack(
      index: currentStep,
      children: [
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          child: _buildStep1(theme),
        ),
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          child: _buildStep2(theme),
        ),
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          child: _buildStep3(theme),
        ),
      ],
    );
  }

  // ── Step 1: Account Setup (Merged Email + Password) ──────────────────────────
  Widget _buildStep1(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    final socialState = ref.watch(socialAuthViewModelProvider);
    final isApplePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return ReactiveForm(
      formGroup: _forms[0],
      child: Column(
        key: const ValueKey('step1'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SSO First
          if (!isApplePlatform)
            _GoogleButton(
              onPressed: socialState.isLoading ? null : _handleGoogleSignIn,
              l10n: l10n,
            ),
          SizedBox(height: 10.h),
          if (isApplePlatform) ...[
            SignInWithAppleButton(
              onPressed: socialState.isLoading ? null : _handleAppleSignIn,
              text: l10n.continueWithApple,
              height: 48.h,
              borderRadius: BorderRadius.circular(14.r),
            ),
            SizedBox(height: 24.h),
          ],
          _Divider(accent: theme.accent, label: l10n.or_continue_with_email),
          SizedBox(height: 24.h),

          // Name
          _StyledField(
            formControlName: 'name',
            label: l10n.authFullName,
            hint: l10n.authFullNameHint,
            icon: Icons.person_outline_rounded,
            validationMessages: {
              ValidationMessage.required: (_) => l10n.nameRequiredError,
              ValidationMessage.minLength: (_) => l10n.nameMinLengthError,
              ValidationMessage.maxLength: (_) => l10n.nameTooLongError,
              'name': (error) => _localizedSignupValidationError(l10n, error),
            },
            theme: theme,
            capitalization: TextCapitalization.words,
          ),
          SizedBox(height: 14.h),

          // Email
          _StyledField(
            formControlName: 'email',
            label: l10n.authEmailAddress,
            hint: l10n.authEmailHint,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validationMessages: {
              ValidationMessage.required: (_) => l10n.email_is_required,
              ValidationMessage.email: (_) =>
                  l10n.please_enter_a_valid_email_address,
            },
            theme: theme,
          ),
          SizedBox(height: 14.h),

          // Password
          _StyledField(
            formControlName: 'password',
            label: l10n.authCreatePassword,
            hint: l10n.authPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscure: wizardUiState.obscurePassword,
            onChanged: (control) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setPasswordText(control.value ?? ''),
            validationMessages: {
              ValidationMessage.required: (_) => l10n.password_is_required,
              ValidationMessage.minLength: (_) => l10n.passwordMinLengthError,
              'password': (error) =>
                  _localizedSignupValidationError(l10n, error),
            },
            theme: theme,
            suffix: IconButton(
              tooltip: wizardUiState.obscurePassword
                  ? l10n.tooltipShowPassword
                  : l10n.tooltipHidePassword,
              icon: Icon(
                wizardUiState.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.accent,
              ),
              onPressed: () => ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .togglePasswordVisibility(),
            ),
          ),
          SizedBox(height: 14.h),

          // Confirm Password
          _StyledField(
            formControlName: 'confirm_password',
            label: l10n.authConfirmPassword,
            hint: l10n.authConfirmPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscure: wizardUiState.obscureConfirmPassword,
            validationMessages: {
              ValidationMessage.required: (_) =>
                  l10n.please_confirm_your_password,
              ValidationMessage.mustMatch: (_) => l10n.passwords_do_not_match,
            },
            theme: theme,
            suffix: IconButton(
              tooltip: wizardUiState.obscureConfirmPassword
                  ? l10n.tooltipShowPassword
                  : l10n.tooltipHidePassword,
              icon: Icon(
                wizardUiState.obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.accent,
              ),
              onPressed: () => ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .toggleConfirmPasswordVisibility(),
            ),
          ),
          SizedBox(height: 20.h),

          _PasswordStrengthBar(
            password: wizardUiState.passwordText,
            accent: theme.accent,
          ),
          SizedBox(height: 28.h),

          _TermsCard(
            agreed: wizardUiState.agreedToTerms,
            accent: theme.accent,
            onToggle: () {
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .toggleTermsAgreement();
              unawaited(HapticFeedback.selectionClick());
            },
            onTermsTap: () => context.push(AppRoutes.terms.path),
            onPrivacyTap: () => context.push(AppRoutes.privacy.path),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Identity & Role ──────────────────────────────────────────────────
  Widget _buildStep2(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return ReactiveForm(
      formGroup: _forms[1],
      child: Column(
        key: const ValueKey('step2'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.iWantTo,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: theme.text,
            ),
          ),
          SizedBox(height: 20.h),
          _RoleCard(
            role: UserRole.rider,
            isSelected: wizardUiState.selectedRole == UserRole.rider,
            accent: theme.accent,
            icon: Icons.person_pin_circle_rounded,
            title: l10n.wizardFindRides,
            desc: l10n.wizardFindRidesDesc,
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .setSelectedRole(UserRole.rider);
            },
          ),
          SizedBox(height: 12.h),
          _RoleCard(
            role: UserRole.driver,
            isSelected: wizardUiState.selectedRole == UserRole.driver,
            accent: theme.accent,
            icon: Icons.drive_eta_rounded,
            title: l10n.wizardOfferRides,
            desc: l10n.wizardOfferRidesDesc,
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              ref
                  .read(signupWizardUiViewModelProvider.notifier)
                  .setSelectedRole(UserRole.driver);
            },
          ),
          SizedBox(height: 28.h),

          Text(
            l10n.verification_requirements,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          SizedBox(height: 14.h),

          // Phone
          IntlPhoneInput(
            key: _phoneKey,
            label: l10n.authPhoneOptional,
            hint: l10n.authPhoneHint,
            accentColor: theme.accent,
            fillColor: theme.accent.withValues(alpha: 0.06),
            onChanged: (phone) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setPhoneNumber(phone.isValid ? phone.fullNumber : null),
          ),
          SizedBox(height: 14.h),

          // Expertise level
          ReactiveExpertisePicker(
            formControlName: 'expertise',
            label: AppLocalizations.of(context).expertiseLevel,
            accent: theme.accent,
            textColor: theme.text,
            cardBg: theme.card,
            onChanged: (expertise) => ref
                .read(signupWizardUiViewModelProvider.notifier)
                .setExpertise(expertise),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Step 3: Profile (Skippable) ─────────────────────────────────────────────
  Widget _buildStep3(_StepTheme theme) {
    final l10n = AppLocalizations.of(context);
    final wizardUiState = ref.watch(signupWizardUiViewModelProvider);
    return ReactiveForm(
      formGroup: _forms[2],
      child: Column(
        key: const ValueKey('step3'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          // Avatar picker
          Center(
            child: Semantics(
              button: true,
              label: wizardUiState.profileImage == null
                  ? l10n.addAProfilePhoto
                  : l10n.changeProfilePhoto,
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 110.w,
                      height: 110.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accent.withValues(alpha: 0.12),
                        image: wizardUiState.profileImage != null
                            ? DecorationImage(
                                image: FileImage(wizardUiState.profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        border: Border.all(color: theme.accent, width: 3),
                      ),
                      child: wizardUiState.profileImage == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 50.sp,
                              color: theme.accent.withValues(alpha: 0.5),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: EdgeInsets.all(7.w),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.card, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.addAProfilePhoto,
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // Summary card
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.almost_there,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.accent,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.emailValue(
                    _forms[0].control('email').value as String? ?? '',
                  ),
                  style: TextStyle(fontSize: 12.sp, color: theme.text),
                ),
                Text(
                  l10n.roleValue(wizardUiState.selectedRole.displayName),
                  style: TextStyle(fontSize: 12.sp, color: theme.text),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // ── Bottom CTA ──────────────────────────────────────────────────────────────
  Widget _buildBottomCTA(
    _StepTheme theme,
    AsyncValue<void> registerState,
    SocialAuthState socialState,
  ) {
    final currentStep = ref.watch(
      signupWizardUiViewModelProvider.select((s) => s.currentStep),
    );
    final isLast = currentStep == 2;
    final isLoading = registerState.isLoading;
    final isDisabled = registerState.isLoading || socialState.isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: isLast
                  ? AppLocalizations.of(context).createAccount
                  : AppLocalizations.of(context).wizardContinue,
              child: GestureDetector(
                onTap: isDisabled ? null : () => _goToStep(currentStep + 1),
                child: AnimatedContainer(
                  duration: 300.ms,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast
                                    ? AppLocalizations.of(context).createAccount
                                    : AppLocalizations.of(
                                        context,
                                      ).wizardContinue,
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                isLast
                                    ? Icons.check_rounded
                                    : Icons.adaptive.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.accent, required this.text});
  final Color accent;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: accent.withValues(alpha: 0.25)),
    ),
    child: Row(
      children: [
        Icon(Icons.verified_user_rounded, color: accent, size: 28.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: accent),
          ),
        ),
      ],
    ),
  );
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.formControlName,
    required this.label,
    required this.hint,
    required this.icon,
    required this.theme,
    this.obscure = false,
    this.keyboardType,
    this.validationMessages,
    this.suffix,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });
  final String formControlName;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Map<String, String Function(Object)>? validationMessages;
  final Widget? suffix;
  final _StepTheme theme;
  final TextCapitalization capitalization;
  final void Function(FormControl<String>)? onChanged;

  @override
  Widget build(BuildContext context) => AdaptiveReactiveTextField(
    formControlName: formControlName,
    obscureText: obscure,
    keyboardType: keyboardType,
    validationMessages: validationMessages,
    textCapitalization: capitalization,
    onChanged: onChanged,
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: theme.accent, size: 20.sp),
    suffixIcon: suffix,
  );
}

class _Divider extends StatelessWidget {
  const _Divider({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: accent.withValues(alpha: 0.2))),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: accent.withValues(alpha: 0.6),
          ),
        ),
      ),
      Expanded(child: Divider(color: accent.withValues(alpha: 0.2))),
    ],
  );
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.l10n});
  final VoidCallback? onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48.h,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        side: BorderSide(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/google_g_logo.svg',
            height: 20.sp,
            width: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            l10n.continueWithGoogle,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password, required this.accent});
  static final _upperCaseRegExp = RegExp('[A-Z]');
  static final _digitRegExp = RegExp('[0-9]');
  static final _specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  final String password;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pw = password;
    var s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(_upperCaseRegExp)) s++;
    if (pw.contains(_digitRegExp)) s++;
    if (pw.contains(_specialCharRegExp)) s++;
    final colors = [Colors.red, Colors.orange, Colors.lightBlue, Colors.green];
    final labels = [
      l10n.passwordStrengthWeak,
      l10n.passwordStrengthFair,
      l10n.passwordStrengthGood,
      l10n.passwordStrengthStrong,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).passwordStrength,
          style: TextStyle(
            fontSize: 12.sp,
            color: accent.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 5.h,
                margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
                decoration: BoxDecoration(
                  color: i < s ? colors[s - 1] : accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
        if (pw.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            labels[s > 0 ? s - 1 : 0],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: s > 0 ? colors[s - 1] : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class _TermsCard extends StatefulWidget {
  const _TermsCard({
    required this.agreed,
    required this.accent,
    required this.onToggle,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });
  final bool agreed;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  State<_TermsCard> createState() => _TermsCardState();
}

class _TermsCardState extends State<_TermsCard> {
  // GestureRecognizers extend ChangeNotifier and hold native resources — they
  // must be disposed. Creating them here and disposing in dispose() prevents
  // the leak that occurs when they are allocated inside build().
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onPrivacyTap;
  }

  @override
  void didUpdateWidget(_TermsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTermsTap != widget.onTermsTap) {
      _termsRecognizer.onTap = widget.onTermsTap;
    }
    if (oldWidget.onPrivacyTap != widget.onPrivacyTap) {
      _privacyRecognizer.onTap = widget.onPrivacyTap;
    }
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${AppLocalizations.of(context).iAgreeToThe}'
        '${AppLocalizations.of(context).termsOfServiceTitle}'
        '${AppLocalizations.of(context).andConnector}'
        '${AppLocalizations.of(context).privacyPolicyTitle}',
    checked: widget.agreed,
    child: GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: widget.agreed
              ? widget.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: widget.agreed
                ? widget.accent
                : widget.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: 200.ms,
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: widget.agreed ? widget.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: widget.accent, width: 2),
              ),
              child: widget.agreed
                  ? Icon(Icons.check_rounded, size: 15.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: widget.accent.withValues(alpha: 0.8),
                  ),
                  children: [
                    TextSpan(text: AppLocalizations.of(context).iAgreeToThe),
                    TextSpan(
                      text: AppLocalizations.of(context).termsOfServiceTitle,
                      style: TextStyle(
                        color: widget.accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _termsRecognizer,
                    ),
                    TextSpan(text: AppLocalizations.of(context).andConnector),
                    TextSpan(
                      text: AppLocalizations.of(context).privacyPolicyTitle,
                      style: TextStyle(
                        color: widget.accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _privacyRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TabletStepTile extends StatelessWidget {
  const _TabletStepTile({
    required this.index,
    required this.title,
    required this.description,
    required this.accent,
    required this.active,
    required this.complete,
  });

  final int index;
  final String title;
  final String description;
  final Color accent;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = active
        ? accent.withValues(alpha: 0.12)
        : AppColors.surface.withValues(alpha: 0.72);

    return AnimatedContainer(
      duration: 250.ms,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: active || complete
              ? accent.withValues(alpha: active ? 0.5 : 0.25)
              : accent.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: active || complete ? accent : AppColors.cardBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: complete
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                  : Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : accent,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.35,
                    color: AppColors.textSecondary,
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.accent,
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });
  final UserRole role;
  final bool isSelected;
  final Color accent;
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    label: title,
    hint: desc,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? accent : accent.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? accent : accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                size: 26.sp,
                color: isSelected ? Colors.white : accent,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accent : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 14.sp,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
