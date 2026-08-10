import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/view_models/forgot_password_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Dedicated Forgot Password screen with email-based password reset.
///
/// Delegates all async and timer logic to [ForgotPasswordViewModel].
/// The widget remains a thin UI shell.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  Future<void> _sendResetEmail() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;
    final email = (_form.control('email').value as String).trim();
    await ref
        .read(forgotPasswordViewModelProvider.notifier)
        .sendResetEmail(email);
  }

  @override
  void dispose() {
    // FormGroup.dispose() closes the underlying stream controllers and
    // disposes child controls. Skipping this leaks StreamControllers every
    // time the screen is popped.
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(forgotPasswordViewModelProvider);

    ref.listen(forgotPasswordViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.forgotPasswordSendError,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: adaptiveScreenPadding(context),
            child: vmState.emailSent
                ? _buildSuccessState(l10n, vmState)
                : _buildFormState(l10n, vmState),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(AppLocalizations l10n, ForgotPasswordState vmState) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Icon
          GlassPanel(
                padding: EdgeInsets.all(20.w),
                color: AppColors.surface.withValues(alpha: 0.62),
                borderColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: 28.h),

          Text(
            l10n.authResetPassword,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          SizedBox(height: 12.h),

          Text(
            l10n.enterYourEmailAddressAnd,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          SizedBox(height: 36.h),

          AdaptiveReactiveTextField(
            formControlName: 'email',
            labelText: l10n.authEmail,
            hintText: l10n.authEmailHint,
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validationMessages: {
              ValidationMessage.required: (_) => l10n.email_is_required,
              ValidationMessage.email: (_) =>
                  l10n.please_enter_a_valid_email_address,
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.authResetPassword,
              onPressed: vmState.isLoading ? null : _sendResetEmail,
              isLoading: vmState.isLoading,
              icon: Icons.send_rounded,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 24.h),

          // Back to login link
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.adaptive.arrow_back_rounded, size: 18.sp),
              label: Text(
                l10n.forgotPasswordBackToLogin,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    AppLocalizations l10n,
    ForgotPasswordState vmState,
  ) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        // Success icon
        GlassPanel(
              padding: EdgeInsets.all(24.w),
              radius: 999,
              color: AppColors.success.withValues(alpha: 0.12),
              borderColor: AppColors.success.withValues(alpha: 0.25),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 32.h),

        Text(
          l10n.forgotPasswordCheckEmail,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.passwordResetEmailSentCheck,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 16.h),

        // Show email sent to
        GlassPanel(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          radius: 12,
          color: AppColors.surface.withValues(alpha: 0.62),
          borderColor: AppColors.primary.withValues(alpha: 0.2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                vmState.sentEmail,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 40.h),

        // Resend button
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: vmState.resendCooldown > 0
                ? l10n.forgotPasswordResendIn(vmState.resendCooldown)
                : l10n.forgotPasswordResendEmail,
            onPressed: vmState.resendCooldown > 0 || vmState.isLoading
                ? null
                : _sendResetEmail,
            style: PremiumButtonStyle.secondary,
            icon: Icons.refresh_rounded,
          ),
        ).animate().fadeIn(delay: 500.ms),

        SizedBox(height: 16.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.forgotPasswordBackToLogin,
            onPressed: () => context.pop(),
            icon: Icons.login_rounded,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
