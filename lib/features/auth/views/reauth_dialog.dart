import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/auth/view_models/reauth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Shows a re-authentication dialog for sensitive operations.
///
/// Returns `true` if re-authentication succeeded, `false` otherwise.
/// Used before delete-account and change-password when Firebase
/// throws `requires-recent-login`.
Future<bool> showReauthDialog(BuildContext context, WidgetRef ref) async {
  final result = await AppModalSheet.show<bool>(
    context: context,
    title: AppLocalizations.of(context).reauthTitle,
    child: const _ReauthBottomSheet(),
  );
  return result ?? false;
}

class _ReauthBottomSheet extends ConsumerStatefulWidget {
  const _ReauthBottomSheet();

  @override
  ConsumerState<_ReauthBottomSheet> createState() => _ReauthBottomSheetState();
}

class _ReauthBottomSheetState extends ConsumerState<_ReauthBottomSheet> {
  final _form = FormGroup({
    'password': FormControl<String>(validators: [Validators.required]),
  });
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(reauthViewModelProvider);

    // Pop the dialog on successful re-auth.
    ref.listen(reauthViewModelProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        Navigator.of(context).pop(true);
      }
    });

    // Map error codes to localised messages.
    String? errorText;
    if (vmState.errorCode != null) {
      switch (vmState.errorCode) {
        case 'wrong-password':
          errorText = l10n.reauthWrongPassword;
        case 'google':
          errorText = l10n.reauthGoogleFailed;
        case 'apple':
          errorText = l10n.reauthFailed;
        default:
          errorText = l10n.reauthFailed;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxWidthFormNarrow),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.xl),
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Icon
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 28.sp,
                    color: AppColors.warning,
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  l10n.reauthTitle,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  l10n.reauthSubtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                // Password field
                AdaptiveReactiveTextField(
                  formControlName: 'password',
                  labelText: l10n.reauthPassword,
                  hintText: l10n.reauthPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? l10n.showPasswordTooltip
                        : l10n.hidePasswordTooltip,
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  obscureText: _obscure,
                  validationMessages: {
                    ValidationMessage.required: (_) =>
                        l10n.reauthPasswordRequired,
                  },
                ),

                if (errorText != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    errorText,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                  ),
                ],

                SizedBox(height: 24.h),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: l10n.reauthConfirm,
                    onPressed: vmState.isLoading
                        ? null
                        : () {
                            _form.markAllAsTouched();
                            if (!_form.valid) return;
                            ref
                                .read(reauthViewModelProvider.notifier)
                                .reauthWithPassword(
                                  _form.control('password').value as String,
                                );
                          },
                    isLoading: vmState.isLoading,
                    icon: Icons.check_rounded,
                  ),
                ),

                SizedBox(height: 12.h),

                // Google re-auth option
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: l10n.reauthWithGoogle,
                    onPressed: vmState.isLoading
                        ? null
                        : () => ref
                              .read(reauthViewModelProvider.notifier)
                              .reauthWithGoogle(),
                    style: PremiumButtonStyle.secondary,
                    icon: Icons.g_mobiledata_rounded,
                  ),
                ),

                if (Platform.isIOS || Platform.isMacOS) ...[
                  SizedBox(height: 12.h),

                  // Apple re-auth option
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: l10n.continueWithApple,
                      onPressed: vmState.isLoading
                          ? null
                          : () => ref
                                .read(reauthViewModelProvider.notifier)
                                .reauthWithApple(),
                      style: PremiumButtonStyle.secondary,
                      icon: Icons.apple_rounded,
                    ),
                  ),
                ],

                SizedBox(height: 8.h),

                // Cancel
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      l10n.reauthCancel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
