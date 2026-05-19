import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/social_auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Professional Login Screen with clean, modern design
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final FormGroup _form;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isAppleSignInAvailable = false;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'email': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(8)],
      ),
    });
    _loadAppleSignInAvailability();
    _setupAnimations();
  }

  Future<void> _loadAppleSignInAvailability() async {
    final isAvailable = await SignInWithApple.isAvailable();
    if (!mounted) return;
    setState(() {
      _isAppleSignInAvailable = isAvailable;
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    if (!mounted) return;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;

    final email = (_form.control('email').value as String).trim();
    final password = _form.control('password').value as String;
    await ref.read(loginViewModelProvider.notifier).login(email, password);
  }

  void _handleGoogleSignIn() {
    ref.read(socialAuthViewModelProvider.notifier).signInWithGoogle();
  }

  void _handleAppleSignIn() {
    ref.read(socialAuthViewModelProvider.notifier).signInWithApple();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final socialState = ref.watch(socialAuthViewModelProvider);
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final hasApple = _isAppleSignInAvailable;
    final hasSocialOption = !isIos || hasApple;

    ref
      ..listen(loginViewModelProvider, (previous, next) {
        if (next.hasError && previous?.error != next.error) {
          final errorMessage = _getAuthErrorMessage(next.error);
          _showAdaptiveMessage(errorMessage, isError: true);
        }
      })
      ..listen(socialAuthViewModelProvider, (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          final errorMessage = _getAuthErrorMessage(next.error);
          if (errorMessage.isEmpty) return; // user canceled — no snackbar
          _showAdaptiveMessage(errorMessage, isError: true);
        }
      });

    return AdaptiveScaffold(
      body: context.isExpandedOrLarger
          ? _buildTabletLoginBody(loginState, socialState, hasSocialOption)
          : _buildPhoneLoginBody(loginState, socialState, hasSocialOption),
    );
  }

  Widget _buildPhoneLoginBody(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
    bool hasSocialOption,
  ) {
    final loginBody = SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: adaptiveScreenPadding(context).copyWith(
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
            ),
            child: _buildLoginForm(
              loginState,
              socialState,
              hasSocialOption,
              includeLogoHeader: true,
              includeBottomSpacer: true,
            ),
          ),
        ),
      ),
    );

    return MaxWidthContainer(maxWidth: kMaxWidthFormNarrow, child: loginBody);
  }

  Widget _buildTabletLoginBody(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
    bool hasSocialOption,
  ) {
    return MaxWidthContainer(
      maxWidth: 1180,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: adaptiveScreenPadding(context).copyWith(
                      top: AppSpacing.xxl,
                      bottom:
                          MediaQuery.viewInsetsOf(context).bottom +
                          AppSpacing.xxl,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabletBrandPane()),
                        SizedBox(width: AppSpacing.massive),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: kMaxWidthFormNarrow,
                              ),
                              child: _buildLoginCard(
                                loginState,
                                socialState,
                                hasSocialOption,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
    bool hasSocialOption,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppSpacing.shadowLg,
      ),
      child: _buildLoginForm(loginState, socialState, hasSocialOption),
    );
  }

  Widget _buildLoginForm(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
    bool hasSocialOption, {
    bool includeLogoHeader = false,
    bool includeBottomSpacer = false,
  }) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (includeLogoHeader) ...[
            SizedBox(height: 40.h),
            _buildLogoHeader(),
            SizedBox(height: 20.h),
          ],
          _buildWelcomeText(),
          SizedBox(height: 32.h),
          _buildEmailField(),
          SizedBox(height: 16.h),
          _buildPasswordField(),
          SizedBox(height: 14.h),
          _buildOptionsRow(),
          SizedBox(height: 12.h),
          _buildSignInButton(loginState, socialState),
          if (hasSocialOption) ...[
            SizedBox(height: 24.h),
            _buildDivider(),
            SizedBox(height: 16.h),
            _buildSocialButtons(socialState),
            SizedBox(height: 28.h),
          ] else
            SizedBox(height: 20.h),
          _buildSignUpLink(),
          SizedBox(height: 24.h),
          _buildLegalFooter(),
          if (includeBottomSpacer) SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildTabletBrandPane() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.massive),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySurface, AppColors.secondarySurface],
        ),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoHeader(),
          SizedBox(height: AppSpacing.xxxl),
          Text(
            l10n.signInToContinueYour,
            style: TextStyle(
              fontSize: 34.sp,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          _LoginValueTile(
            icon: Icons.directions_run_rounded,
            title: l10n.wizardFindRides,
            description: l10n.wizardFindRidesDesc,
          ),
          SizedBox(height: AppSpacing.lg),
          _LoginValueTile(
            icon: Icons.directions_car_filled_rounded,
            title: l10n.wizardOfferRides,
            description: l10n.wizardOfferRidesDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // The logo container is purely decorative — the app name Text below
        // already communicates the brand. We give it a label so VoiceOver
        // reads "SportConnect logo" once, and exclude the inner Icon so its
        // raw name isn't announced as a second node.
        Semantics(
          label: AppLocalizations.of(context).appTitle,
          image: true,
          child:
              ClipRRect(
                    borderRadius: BorderRadius.circular(200.r),
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      padding: EdgeInsets.all(16.w),
                      child: ExcludeSemantics(
                        child: Image.asset(
                          'assets/images/branding.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    curve: Curves.easeOutBack,
                    duration: 600.ms,
                  ),
        ),
        SizedBox(height: 16.h),

        // App name — plain Text, no changes needed.
        Text(
          AppLocalizations.of(context).sportconnect,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildWelcomeText() {
    // Plain text nodes — no semantics changes needed.
    return Column(
      children: [
        Text(
              AppLocalizations.of(context).welcomeBack,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: 150.ms)
            .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context).signInToContinueYour,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildEmailField() {
    final emailLabel = AppLocalizations.of(context).email;
    final emailHint = AppLocalizations.of(context).enterYourEmail;

    // The prefixIcon is purely decorative — excluded so SR does not read it.
    return AdaptiveReactiveTextField(
      formControlName: 'email',
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validationMessages: {
        ValidationMessage.required: (_) =>
            AppLocalizations.of(context).email_is_required,
        ValidationMessage.email: (_) =>
            AppLocalizations.of(context).please_enter_a_valid_email_address,
      },
      labelText: emailLabel,
      hintText: emailHint,
      prefixIcon: const ExcludeSemantics(child: Icon(Icons.email_outlined)),
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms);
  }

  Widget _buildPasswordField() {
    final passwordLabel = AppLocalizations.of(context).password;
    final passwordHint = AppLocalizations.of(context).enterYourPassword;

    final toggleLabel = _obscurePassword
        ? AppLocalizations.of(context).showPasswordTooltip
        : AppLocalizations.of(context).hidePasswordTooltip;

    return AdaptiveReactiveTextField(
      formControlName: 'password',
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validationMessages: {
        ValidationMessage.required: (_) =>
            AppLocalizations.of(context).password_is_required,
        ValidationMessage.minLength: (_) => AppLocalizations.of(
          context,
        ).password_must_be_at_least_8_characters,
      },
      labelText: passwordLabel,
      hintText: passwordHint,
      prefixIcon: const ExcludeSemantics(
        child: Icon(Icons.lock_outline_rounded),
      ),
      suffixIcon: IconButton(
        tooltip: toggleLabel,
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Forgot password button — interactive, label is already descriptive.
        TextButton(
          onPressed: () => context.push(AppRoutes.forgotPassword.path),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            AppLocalizations.of(context).authForgotPassword,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }

  Widget _buildSignInButton(
    AsyncValue<void> loginState,
    SocialAuthState socialState,
  ) {
    final isEmailLoading = loginState.isLoading;
    final isDisabled = loginState.isLoading || socialState.isLoading;
    final signInLabel = AppLocalizations.of(context).authSignIn;

    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handleLogin,
        child: isEmailLoading
            ? Semantics(
                label: AppLocalizations.of(context).signingInMessage,
                liveRegion: true,
                child: SizedBox(
                  height: 18.h,
                  width: 18.w,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Text(
                signInLabel,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildDivider() {
    return TextDivider(
      text: AppLocalizations.of(context).orContinueWith,
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildSocialButtons(SocialAuthState socialState) {
    final isApplePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Column(
          children: [
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
          ],
        ),
        if (socialState.isLoading)
          Positioned.fill(
            child: Semantics(
              label: AppLocalizations.of(context).signingInMessage,
              liveRegion: true,
              excludeSemantics: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    final l10n = AppLocalizations.of(context);

    // Keep the child text as the only accessible label to avoid duplicate
    // screen-reader announcements for the sign-up action.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.donTHaveAnAccount,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.signupWizard.path),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                l10n.authSignUp,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 550.ms);
  }

  Widget _buildLegalFooter() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4.w,
        runSpacing: 2.h,
        children: [
          Text(
            l10n.legalConsentPrefix,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.terms.path),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              l10n.termsOfServiceTitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            l10n.andConnector,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.privacy.path),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              l10n.privacyPolicyTitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  String _getAuthErrorMessage(Object? error) {
    final l10n = AppLocalizations.of(context);
    if (error is AuthException) {
      switch (error.code) {
        case 'google-sign-in-canceled':
        case 'apple-sign-in-canceled':
          return ''; // user dismissed — treat as silent, no snackbar
        case 'google-sign-in-failed':
          return error.message; // contains the raw code name for visibility
        case 'account-disabled':
          return l10n.your_account_has_been_suspended_please_contact_support;
        case 'user-not-found':
          return l10n.loginErrorUserNotFound;
        case 'wrong-password' || 'invalid-credential':
          return l10n.loginErrorWrongPassword;
        case 'too-many-requests':
          return l10n.loginErrorTooManyRequests;
        case 'invalid-email':
          return l10n.loginErrorInvalidEmail;
        case 'account-exists-with-different-credential':
          return l10n.accountExistsError;
        case 'network-request-failed':
          return l10n.loginErrorNetwork;
        default:
          return error.message;
      }
    }
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('user-not-found')) {
      return l10n.loginErrorUserNotFound;
    } else if (errorStr.contains('wrong-password') ||
        errorStr.contains('invalid-credential')) {
      return l10n.loginErrorWrongPassword;
    } else if (errorStr.contains('too-many-requests')) {
      return l10n.loginErrorTooManyRequests;
    } else if (errorStr.contains('network')) {
      return l10n.loginErrorNetwork;
    } else if (errorStr.contains('invalid-email')) {
      return l10n.loginErrorInvalidEmail;
    } else if (errorStr.contains('account-exists-with-different-credential')) {
      return l10n.accountExistsError;
    }
    return l10n.signInFailedPleaseTry;
  }

  Future<void> _showAdaptiveMessage(
    String message, {
    bool isError = false,
  }) async {
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: isError ? AdaptiveSnackBarType.error : AdaptiveSnackBarType.success,
    );
  }
}

class _LoginValueTile extends StatelessWidget {
  const _LoginValueTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        side: const BorderSide(color: Color(0xFF747775)),
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
              color: const Color(0xFF1F1F1F),
            ),
          ),
        ],
      ),
    ),
  );
}
