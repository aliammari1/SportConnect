import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/view_models/role_selection_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(roleSelectionViewModelProvider);

    ref.listen(roleSelectionViewModelProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        if (next.selectedRole == UserRole.driver) {
          context.go(AppRoutes.driverOnboarding.path);
        } else {
          context.go(AppRoutes.riderOnboarding.path);
        }
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AdaptiveSnackBar.show(
          context,
          // Surface the actual reason (already mapped to a user-facing message
          // by userFacingError in the view model) rather than a generic banner,
          // so failures like permission-denied are diagnosable instead of an
          // opaque "Something went wrong".
          message: next.errorMessage ?? l10n.roleSelectionError,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    void continueWithRole() {
      if (vmState.selectedRole == null) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.pleaseSelectARoleTo,
          type: AdaptiveSnackBarType.warning,
        );
        return;
      }
      ref.read(roleSelectionViewModelProvider.notifier).continueWithRole();
    }

    Future<void> changeGoogleAccount() async {
      try {
        final switched = await ref
            .read(authActionsViewModelProvider.notifier)
            .switchGoogleAccountForOnboarding();
        if (!context.mounted) return;
        // Cancelled: the original session is still intact (no sign-out
        // happened), so stay on role selection rather than navigating away.
        if (!switched) return;
        context.go(AppRoutes.roleSelection.path);
      } on AuthException catch (e) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: e.message,
          type: AdaptiveSnackBarType.error,
        );
      } on Exception catch (e) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: userFacingError(e),
          type: AdaptiveSnackBarType.error,
        );
      }
    }

    Future<void> changeAppleAccount() async {
      try {
        final switched = await ref
            .read(authActionsViewModelProvider.notifier)
            .switchAppleAccountForOnboarding();
        if (!context.mounted) return;
        // Cancelled: the original session is still intact (no sign-out
        // happened), so stay on role selection rather than navigating away.
        if (!switched) return;
        context.go(AppRoutes.roleSelection.path);
      } on AuthException catch (e) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: e.message,
          type: AdaptiveSnackBarType.error,
        );
      } on Exception catch (e) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: userFacingError(e),
          type: AdaptiveSnackBarType.error,
        );
      }
    }

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: adaptiveScreenPadding(context),
            child: Column(
              children: [
                SizedBox(height: 32.h),

                // Header
                _buildHeader(l10n)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2, curve: Curves.easeOutCubic),

                SizedBox(height: 32.h),

                // Role options — side-by-side on tablet, stacked on phone
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = responsiveValue<int>(
                      context,
                      phone: 1,
                      tablet: 2,
                      desktop: 3,
                    );
                    final riderCard =
                        _buildRoleCard(
                              onRoleSelected: (role) => ref
                                  .read(roleSelectionViewModelProvider.notifier)
                                  .selectRole(role),
                              selectedRole: vmState.selectedRole,
                              role: UserRole.rider,
                              icon: Icons.person_rounded,
                              title: l10n.iMARider,
                              description: l10n.riderRoleDescription,
                              features: [
                                l10n.riderFeatureSearch,
                                l10n.riderFeatureBook,
                                l10n.riderFeatureChat,
                                l10n.riderFeatureTrack,
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 200.ms)
                            .slideX(begin: -0.2, curve: Curves.easeOutCubic);

                    final driverCard =
                        _buildRoleCard(
                              onRoleSelected: (role) => ref
                                  .read(roleSelectionViewModelProvider.notifier)
                                  .selectRole(role),
                              selectedRole: vmState.selectedRole,
                              role: UserRole.driver,
                              icon: Icons.directions_car_rounded,
                              title: l10n.iMADriver,
                              description: l10n.driverRoleDescription,
                              features: [
                                l10n.driverFeatureCreate,
                                l10n.driverFeaturePrice,
                                l10n.driverFeatureAccept,
                                l10n.driverFeatureEarn,
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 300.ms)
                            .slideX(begin: 0.2, curve: Curves.easeOutCubic);

                    if (crossAxisCount >= 2) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: riderCard),
                          SizedBox(width: AppSpacing.md),
                          Expanded(child: driverCard),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        riderCard,
                        SizedBox(height: AppSpacing.md),
                        driverCard,
                      ],
                    );
                  },
                ),

                SizedBox(height: 32.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8.w,
                    children: [
                      // Mirror the login screen's social options: Apple
                      // platforms sign in with Apple (no Google), every other
                      // platform signs in with Google. Showing "Change Google
                      // account" on iOS/macOS is misleading because no Google
                      // sign-in is offered there.
                      if (Platform.isIOS || Platform.isMacOS)
                        PremiumButton(
                          onPressed: vmState.isLoading
                              ? null
                              : changeAppleAccount,
                          icon: Icons.switch_account_rounded,
                          text: l10n.changeAppleAccount,
                          style: PremiumButtonStyle.outline,
                        )
                      else
                        PremiumButton(
                          onPressed: vmState.isLoading
                              ? null
                              : changeGoogleAccount,
                          icon: Icons.switch_account_rounded,
                          text: l10n.changeGoogleAccount,
                          style: PremiumButtonStyle.outline,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Continue button
                SizedBox(
                      width: double.infinity,
                      child: PremiumButton(
                        text: l10n.continueButton,
                        onPressed:
                            vmState.selectedRole == null || vmState.isLoading
                            ? null
                            : continueWithRole,
                        isLoading: vmState.isLoading,
                        style: PremiumButtonStyle.gradient,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pure helper widgets (no state, no ref dependency)
// ---------------------------------------------------------------------------

Widget _buildHeader(AppLocalizations l10n) {
  return Column(
    children: [
      GlassPanel(
        radius: 999,
        padding: EdgeInsets.all(20.w),
        color: AppColors.surface.withValues(alpha: 0.62),
        borderColor: AppColors.primary.withValues(alpha: 0.2),
        child: Icon(
          Icons.person_add_rounded,
          size: 48.sp,
          color: AppColors.primary,
        ),
      ),
      SizedBox(height: 24.h),
      Text(
        l10n.howWillYouUseSportconnect,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12.h),
      Text(
        l10n.chooseYourRoleToGet,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildRoleCard({
  required ValueChanged<UserRole> onRoleSelected,
  required UserRole? selectedRole,
  required UserRole role,
  required IconData icon,
  required String title,
  required String description,
  required List<String> features,
}) {
  final isSelected = selectedRole == role;

  return GestureDetector(
    onTap: () {
      unawaited(HapticFeedback.selectionClick());
      onRoleSelected(role);
    },
    child: AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isSelected ? 1.01 : 1,
      child: GlassPanel(
        padding: EdgeInsets.all(16.w),
        radius: 16,
        color: isSelected
            ? AppColors.primarySurface.withValues(alpha: 0.72)
            : AppColors.surface.withValues(alpha: 0.62),
        borderColor: isSelected ? AppColors.primary : AppColors.border,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              )
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: features.map((feature) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 12.sp,
                          ),
                          SizedBox(width: 3.w),
                          Flexible(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
