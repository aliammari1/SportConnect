import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/view_models/change_password_view_model.dart';
import 'package:sport_connect/features/auth/views/reauth_dialog.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

const _passwordUppercaseError = 'password_uppercase';
const _passwordLowercaseError = 'password_lowercase';
const _passwordNumberError = 'password_number';

/// Change Password screen for authenticated users.
///
/// Allows users to update their password with validation.
/// Shows a re-authentication prompt if the session is too old.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = FormGroup(
    {
      'new_password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.isEmpty) return null;
            if (!RegExp('[A-Z]').hasMatch(value)) {
              return {'password': _passwordUppercaseError};
            }
            if (!RegExp('[a-z]').hasMatch(value)) {
              return {'password': _passwordLowercaseError};
            }
            if (!RegExp('[0-9]').hasMatch(value)) {
              return {'password': _passwordNumberError};
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
      Validators.mustMatch('new_password', 'confirm_password'),
    ],
  );

  Future<void> _changePassword() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;
    await ref
        .read(changePasswordViewModelProvider.notifier)
        .submit(_form.control('new_password').value as String);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(changePasswordViewModelProvider);

    ref.listen(changePasswordViewModelProvider, (previous, next) async {
      if (next.requiresReauth && previous?.requiresReauth != true) {
        final success = await showReauthDialog(context, ref);
        if (!mounted) return;
        if (success) {
          await ref
              .read(changePasswordViewModelProvider.notifier)
              .retryAfterReauth();
          if (!mounted) return;
        } else {
          ref
              .read(changePasswordViewModelProvider.notifier)
              .dismissReauthRequest();
        }
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          context.mounted) {
        final errorText = next.errorMessage == 'weak-password'
            ? l10n.changePasswordWeakError
            : l10n.changePasswordGenericError;
        AdaptiveSnackBar.show(
          context,
          message: errorText,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          tooltip: l10n.goBack,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: l10n.changePasswordTitle,
      ),
      body: SafeArea(
        child: ResponsiveLayoutBuilder(
          phone: (_) => MaxWidthContainer(
            maxWidth: kMaxWidthFormNarrow,
            child: _buildScrollableState(context, l10n, vmState),
          ),
          tablet: (_) => MaxWidthContainer(
            maxWidth: kMaxWidthWide,
            child: _buildWideState(context, l10n, vmState),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableState(
    BuildContext context,
    AppLocalizations l10n,
    ChangePasswordState vmState,
  ) {
    return SingleChildScrollView(
      padding: adaptiveScreenPadding(context),
      child: Column(
        children: [
          if (vmState.isSuccess)
            _buildSuccessState()
          else
            _buildFormState(l10n, vmState),
        ],
      ),
    );
  }

  Widget _buildWideState(
    BuildContext context,
    AppLocalizations l10n,
    ChangePasswordState vmState,
  ) {
    return SingleChildScrollView(
      padding: adaptiveScreenPadding(context).copyWith(top: 24.h, bottom: 32.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: _SecurityPanel(isSuccess: vmState.isSuccess),
          ),
          SizedBox(width: 24.w),
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: AppSpacing.shadowSm,
              ),
              child: vmState.isSuccess
                  ? _buildSuccessState()
                  : _buildFormState(l10n, vmState, showHeader: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormState(
    AppLocalizations l10n,
    ChangePasswordState vmState, {
    bool showHeader = true,
  }) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            SizedBox(height: 24.h),
            GlassPanel(
                  padding: EdgeInsets.all(20.w),
                  color: AppColors.surface.withValues(alpha: 0.62),
                  borderColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48.sp,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            SizedBox(height: 28.h),
            Text(
              l10n.changePasswordHeading,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
            SizedBox(height: 12.h),
            Text(
              l10n.changePasswordDesc,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
            SizedBox(height: 36.h),
          ] else ...[
            Text(
              l10n.changePasswordHeading,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.changePasswordDesc,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28.h),
          ],

          AdaptiveReactiveTextField(
            formControlName: 'new_password',
            labelText: l10n.changePasswordNew,
            hintText: l10n.changePasswordNewHint,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: vmState.obscureNewPassword
                  ? l10n.tooltipShowPassword
                  : l10n.tooltipHidePassword,
              icon: Icon(
                vmState.obscureNewPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () => ref
                  .read(changePasswordViewModelProvider.notifier)
                  .toggleNewPasswordVisibility(),
            ),
            obscureText: vmState.obscureNewPassword,
            validationMessages: {
              ValidationMessage.required: (_) => l10n.password_is_required,
              ValidationMessage.minLength: (_) => l10n.passwordMinLengthError,
              'password': (error) => switch (error as String) {
                _passwordUppercaseError =>
                  l10n.include_at_least_one_uppercase_letter,
                _passwordLowercaseError =>
                  l10n.include_at_least_one_lowercase_letter,
                _passwordNumberError => l10n.include_at_least_one_number,
                _ => error,
              },
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 20.h),

          AdaptiveReactiveTextField(
            formControlName: 'confirm_password',
            labelText: l10n.changePasswordConfirm,
            hintText: l10n.changePasswordConfirmHint,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: vmState.obscureConfirmPassword
                  ? l10n.tooltipShowPassword
                  : l10n.tooltipHidePassword,
              icon: Icon(
                vmState.obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () => ref
                  .read(changePasswordViewModelProvider.notifier)
                  .toggleConfirmPasswordVisibility(),
            ),
            obscureText: vmState.obscureConfirmPassword,
            validationMessages: {
              ValidationMessage.required: (_) =>
                  l10n.please_confirm_your_password,
              ValidationMessage.mustMatch: (_) => l10n.passwords_do_not_match,
            },
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.changePasswordUpdate,
              onPressed: vmState.isLoading ? null : _changePassword,
              isLoading: vmState.isLoading,
              icon: Icons.check_rounded,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(height: 60.h),

        GlassPanel(
              padding: EdgeInsets.all(24.w),
              radius: 999,
              color: AppColors.success.withValues(alpha: 0.12),
              borderColor: AppColors.success.withValues(alpha: 0.25),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 32.h),

        Text(
          l10n.changePasswordSuccess,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.changePasswordSuccessDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 40.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.changePasswordDone,
            onPressed: () => context.pop(),
            icon: Icons.adaptive.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 32.h),
      ],
    );
  }
}

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel({required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          GlassPanel(
            padding: EdgeInsets.all(18.w),
            color: Colors.white.withValues(alpha: 0.72),
            borderColor: AppColors.primary.withValues(alpha: 0.18),
            child: Icon(
              isSuccess
                  ? Icons.verified_user_rounded
                  : Icons.lock_outline_rounded,
              size: 40.sp,
              color: isSuccess ? AppColors.success : AppColors.primary,
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            l10n.changePasswordHeading,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            isSuccess
                ? l10n.changePasswordSuccessDesc
                : l10n.changePasswordDesc,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),
          _SecurityBullet(
            icon: Icons.password_rounded,
            label: l10n.passwordMinLengthError,
          ),
          SizedBox(height: 10.h),
          _SecurityBullet(
            icon: Icons.keyboard_capslock_rounded,
            label: l10n.include_at_least_one_uppercase_letter,
          ),
          SizedBox(height: 10.h),
          _SecurityBullet(
            icon: Icons.pin_rounded,
            label: l10n.include_at_least_one_number,
          ),
        ],
      ),
    );
  }
}

class _SecurityBullet extends StatelessWidget {
  const _SecurityBullet({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
