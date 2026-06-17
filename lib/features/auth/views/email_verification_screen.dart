import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/view_models/email_verification_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Start polling / initial verification check after the first frame so the
    // notifier's build() stays side-effect-free. start() is idempotent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emailVerificationViewModelProvider.notifier).start();
    });

    final isEmailVerified = ref.watch(
      emailVerificationViewModelProvider.select((s) => s.isEmailVerified),
    );

    final userEmail = ref.watch(
      emailVerificationViewModelProvider.select((s) => s.userEmail),
    );

    ref.listen(
      emailVerificationViewModelProvider.select(
        (s) => (
          isEmailVerified: s.isEmailVerified,
          errorMessage: s.errorMessage,
        ),
      ),
      (previous, next) {
        if (next.isEmailVerified &&
            !(previous?.isEmailVerified ?? false) &&
            context.mounted) {
          context.go(AppRoutes.splash.path);
        }

        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage &&
            context.mounted) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage ?? l10n.emailVerificationError,
            type: AdaptiveSnackBarType.error,
          );
        }
      },
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.emailVerifyTitle,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SafeArea(
          child: Padding(
            padding: adaptiveScreenPadding(context),
            child: Column(
              children: [
                const Spacer(flex: 2),
                if (isEmailVerified)
                  const _VerifiedState()
                else
                  _PendingState(email: userEmail),
                const Spacer(flex: 3),
                const _VerificationActions(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationActions extends ConsumerWidget {
  const _VerificationActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final state = ref.watch(
      emailVerificationViewModelProvider.select(
        (s) => (
          isEmailVerified: s.isEmailVerified,
          resendCooldown: s.resendCooldown,
          isSending: s.isSending,
        ),
      ),
    );

    if (state.isEmailVerified) {
      return const SizedBox.shrink();
    }

    final canResend = state.resendCooldown <= 0 && !state.isSending;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: state.resendCooldown > 0
                ? l10n.emailVerifyResendIn(state.resendCooldown)
                : l10n.emailVerifyResend,
            onPressed: canResend
                ? () => ref
                      .read(emailVerificationViewModelProvider.notifier)
                      .resendVerification()
                : null,
            isLoading: state.isSending,
            icon: Icons.email_outlined,
            style: PremiumButtonStyle.secondary,
          ),
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.emailVerifyCheckButton,
            onPressed: () => ref
                .read(emailVerificationViewModelProvider.notifier)
                .checkEmailVerified(showErrors: true),
            icon: Icons.check_circle_outline_rounded,
          ),
        ).animate().fadeIn(delay: 700.ms),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () =>
              ref.read(emailVerificationViewModelProvider.notifier).signOut(),
          child: Text(
            l10n.useDifferentAccount,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ).animate().fadeIn(delay: 750.ms),
      ],
    );
  }
}

class _PendingState extends StatelessWidget {
  const _PendingState({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
              padding: EdgeInsets.all(28.w),
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 56.sp,
                color: AppColors.primary,
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(
              duration: 2000.ms,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
        SizedBox(height: 28.h),
        Text(
          l10n.emailVerifyHeading,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 12.h),
        Text(
          l10n.emailVerifySentTo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            email,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.emailVerifyWaiting,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}

class _VerifiedState extends StatelessWidget {
  const _VerifiedState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                size: 56.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),
        SizedBox(height: 28.h),
        Text(
          l10n.emailVerified,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 12.h),
        Text(
          l10n.emailVerifiedRedirecting,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
