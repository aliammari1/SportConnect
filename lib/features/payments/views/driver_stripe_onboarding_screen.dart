import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/payment_error_handler.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

const _ink = Color(0xFF062015);
const _muted = Color(0xFF607466);
const _border = Color(0xFFDCEADF);
const _primaryGreen = Color(0xFF13A35B);
const _deepGreen = Color(0xFF087A3D);
const _mintGreen = Color(0xFF5CCF88);
const _successGreen = Color(0xFF22C55E);
const _stripeGreen = Color(0xFF16834C);

enum _PayoutSetupPage { intro, prep, success }

/// Driver Stripe onboarding redesigned as a 3-screen payout setup flow:
/// 1. Premium payout intro
/// 2. Before-you-continue checklist
/// 3. Payouts-ready confirmation
///
/// The Stripe Connect hosted onboarding URL is presented in an
/// `SFSafariViewController` on iOS (and a Chrome Custom Tab on Android) via
/// [ChromeSafariBrowser]. Apple rejects apps that load financial/identity
/// onboarding flows inside an embedded `WKWebView` (App Store Review
/// Guideline 4.0 / 5.1.1), and Stripe's own guidance is to use the native
/// secure browser. When the browser closes we re-verify the connected
/// account server-side (the only source of truth) rather than trusting any
/// redirect URL.
class DriverStripeOnboardingScreen extends ConsumerStatefulWidget {
  const DriverStripeOnboardingScreen({super.key});

  @override
  ConsumerState<DriverStripeOnboardingScreen> createState() => _DriverStripeOnboardingScreenState();
}

class _DriverStripeOnboardingScreenState extends ConsumerState<DriverStripeOnboardingScreen>
    with WidgetsBindingObserver {
  bool _didNavigateAway = false;
  _PayoutSetupPage _page = _PayoutSetupPage.intro;
  bool _safariLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(driverStripeOnboardingFlowViewModelProvider.notifier)
          .checkExistingAccount(ref.read(currentUserProvider).value);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Proxy for "the secure browser closed" — flutter_custom_tabs has no
    // onClosed callback, so returning to the foreground while a Custom
    // Tab/SFSafariViewController session is active is our signal to
    // re-verify the account server-side.
    if (state == AppLifecycleState.resumed && _safariLaunched) {
      _onSafariClosed();
    }
  }

  void _safeGoNamed(
    String routeName, {
    Map<String, String> queryParameters = const {},
  }) {
    if (_didNavigateAway || !mounted) return;

    _didNavigateAway = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.goNamed(
        routeName,
        queryParameters: queryParameters,
        extra: {'resetBranch': true},
      );
    });
  }

  void _goToDashboard() {
    final returnTo = GoRouterState.of(context).uri.queryParameters['returnTo'];
    _safeGoNamed(returnTo ?? AppRoutes.driverHome.name);
  }

  /// A driver who can't (or won't) finish Stripe onboarding — unsupported
  /// country, missing documents, a stuck "additional information needed"
  /// account — must still be able to get help or leave the app. The route
  /// guard now carves out an exception for settings/support routes, but this
  /// button is the discoverable, on-screen way out: it's shown on both the
  /// intro and prep pages, before the driver ever reaches Stripe.
  Widget _buildHelpMenuButton() {
    final l10n = AppLocalizations.of(context);
    return AdaptivePopupMenuButton.widget<String>(
      items: [
        AdaptivePopupMenuItem<String>(
          label: l10n.contactSupport,
          icon: Icons.support_agent_outlined,
          value: 'support',
        ),
        AdaptivePopupMenuItem<String>(
          label: l10n.signOut,
          icon: Icons.logout_rounded,
          value: 'signOut',
        ),
      ],
      onSelected: (_, entry) {
        switch (entry.value) {
          case 'support':
            context.push(AppRoutes.contactSupport.path);
          case 'signOut':
            _confirmSignOut();
        }
      },
      child: const _RoundIconButton(icon: Icons.help_outline_rounded),
    );
  }

  void _confirmSignOut() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierLabel: l10n.settingsLogout,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.settingsLogout),
        content: Text(l10n.areYouSureYouWant5),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              await ref.read(authActionsViewModelProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );
  }

  /// Maps the server-reported pending-requirement category to a specific
  /// message so drivers know exactly what's missing, falling back to the
  /// generic message when the category isn't recognized.
  String _additionalInfoMessage(
    StripeRequirementCategory? category,
    String fallback,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (category) {
      StripeRequirementCategory.identity => l10n.stripeAdditionalInfoIdentity,
      StripeRequirementCategory.banking => l10n.stripeAdditionalInfoBanking,
      StripeRequirementCategory.tax => l10n.stripeAdditionalInfoTax,
      _ => fallback,
    };
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(
      driverStripeOnboardingFlowViewModelProvider,
    );

    ref
      ..listen(currentUserProvider, (previous, next) {
        final previousUser = previous?.value;
        final user = next.value;
        if (user != null && previousUser?.uid != user.uid) {
          ref.read(driverStripeOnboardingFlowViewModelProvider.notifier).checkExistingAccount(user);
        }
      })
      ..listen(driverStripeOnboardingFlowViewModelProvider, (previous, next) {
        if (next.successMessage != null &&
            next.successMessage != previous?.successMessage &&
            context.mounted) {
          // Onboarding "complete" doesn't always mean the account is ready:
          // Stripe can come back still missing requirements (e.g. an
          // unsupported document, missing IBAN). That case reuses
          // successMessage for the toast text but must never render as a
          // success-styled snackbar, and should say what's actually missing
          // when we can tell.
          AdaptiveSnackBar.show(
            context,
            message: next.isConnected
                ? next.successMessage!
                : _additionalInfoMessage(
                    next.pendingRequirementCategory,
                    next.successMessage!,
                  ),
            type: next.isConnected ? AdaptiveSnackBarType.success : AdaptiveSnackBarType.warning,
          );
        }

        if (next.isConnected && previous?.isConnected != true && context.mounted) {
          setState(() => _page = _PayoutSetupPage.success);
        }
      });

    if (onboardingState.showWebView) {
      return _buildSafariHandoff();
    }

    if (onboardingState.isConnected || _page == _PayoutSetupPage.success) {
      return _buildSuccessScreen(onboardingState);
    }

    if (_page == _PayoutSetupPage.prep) {
      return _buildPrepScreen(onboardingState);
    }

    return _buildIntroScreen(onboardingState);
  }

  Widget _buildShell({required Widget child}) {
    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: Container(
          // Page chrome tracks the app theme; the Stripe-branded light cards
          // below stay light inside it (see balance card / success header).
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, AppColors.surface],
            ),
          ),
          child: SafeArea(child: child),
        ),
      ),
    );
  }

  Widget _buildIntroScreen(DriverStripeOnboardingFlowState state) {
    final l10n = AppLocalizations.of(context);
    final isBusy = state.isLoading || state.isVerifying;

    return _buildShell(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [const Spacer(), _buildHelpMenuButton()],
                  ),
                  SizedBox(height: 8.h),
                  _buildIntroHero(l10n),
                  SizedBox(height: 28.h),
                  _buildDriverBenefits(),
                  _buildStatusArea(context, state),
                ],
              ),
            ),
          ),
          _StickyFooter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GradientButton(
                  text: l10n.connectStripeAccount,
                  trailingIcon: Icons.lock_outline_rounded,
                  isLoading: isBusy,
                  onPressed: isBusy ? null : () => setState(() => _page = _PayoutSetupPage.prep),
                ),
                SizedBox(height: 13.h),
                _PoweredByStripe(l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroHero(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 17.h, 18.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E1A), Color(0xFF064E3B), Color(0xFF087A3D)],
        ),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.24),
            blurRadius: 30.r,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -70.h,
            end: -65.w,
            child: _SoftCircle(
              size: 190.w,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          PositionedDirectional(
            bottom: 82.h,
            start: -92.w,
            child: _SoftCircle(
              size: 180.w,
              color: const Color(0xFF34D399).withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _MiniLogo(onDark: true),
                  SizedBox(width: 8.w),
                  Text(
                    'SportConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 34.h),
              Text(
                l10n.get_paid_fornevery_ride,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  height: 1.10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.04, end: 0),
              SizedBox(height: 12.h),
              Text(
                l10n.set_up_eur_payouts_in_minutes_andnreceive_earnings_automatically,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 70.ms),
              SizedBox(height: 24.h),
              _buildBalanceCard(),
              SizedBox(height: 13.h),
              Row(
                children: [
                  Expanded(
                    child: _MiniFeatureTile(
                      icon: Icons.bolt_rounded,
                      title: l10n.fast_payouts,
                      subtitle: l10n.business_days_1_to_2,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _MiniFeatureTile(
                      icon: Icons.verified_user_rounded,
                      title: l10n.secure,
                      subtitle: l10n.eugrade_safety,
                      color: _mintGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _MiniFeatureTile(
                      icon: Icons.percent_rounded,
                      title: l10n.lowFees,
                      subtitle: l10n.transparent_pricing,
                      color: const Color(0xFF2FA66A),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.04, end: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF4FBF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 26.r,
            offset: Offset(0, 14.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).stripeEurBalance,
                  style: _labelStyle(_muted),
                ),
                SizedBox(height: 8.h),
                // Illustrative placeholder shown on the pre-onboarding intro
                // hero (the driver has no connected account / balance yet).
                // Masked so it cannot be mistaken for the user's real money.
                Text(
                  '•••• €',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FAF0),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: const Color(0xFF159A50),
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Ready for EUR payout',
                        style: TextStyle(
                          color: const Color(0xFF159A50),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          const _WalletArt(),
        ],
      ),
    ).animate().fadeIn(delay: 120.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildDriverBenefits() {
    final items = [
      'Automatic weekly payouts',
      'No hidden charges',
      'Trusted by thousands of drivers',
      '24/7 support when you need it',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why drivers love payouts on\nSportConnect',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            height: 1.18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 16.h),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildPrepScreen(DriverStripeOnboardingFlowState state) {
    final l10n = AppLocalizations.of(context);
    final isBusy = state.isLoading || state.isVerifying;

    return _buildShell(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrepTopBar(),
                  SizedBox(height: 38.h),
                  Text(
                    l10n.before_you_continue,
                    style: _titleStyle(27),
                  ).animate().fadeIn().slideY(begin: 0.04, end: 0),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.heres_what_youll_need_to_get_set_up,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 60.ms),
                  SizedBox(height: 18.h),
                  _TimeChip(l10n: l10n),
                  SizedBox(height: 24.h),
                  _ChecklistRow(
                    icon: Icons.account_balance_rounded,
                    iconColor: _primaryGreen,
                    iconBg: const Color(0xFFE9F9EF),
                    title: l10n.french_iban,
                    subtitle: l10n.to_receive_eur_payouts,
                  ),
                  SizedBox(height: 12.h),
                  _ChecklistRow(
                    icon: Icons.badge_rounded,
                    iconColor: _mintGreen,
                    iconBg: const Color(0xFFEAF8ED),
                    title: l10n.identity_verification,
                    subtitle: l10n.carte_didentit_or_passport,
                  ),
                  SizedBox(height: 12.h),
                  _ChecklistRow(
                    icon: Icons.description_rounded,
                    iconColor: _successGreen,
                    iconBg: const Color(0xFFE8FAF0),
                    title: l10n.french_tax_details,
                    subtitle: l10n.for_french_tax_records,
                  ),
                  SizedBox(height: 28.h),
                  const _SecurityCard(),
                  SizedBox(height: 12.h),
                  _buildStatusArea(context, state),
                ],
              ),
            ),
          ),
          _StickyFooter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GradientButton(
                  text: l10n.continue_to_stripe,
                  trailingIcon: Icons.open_in_new_rounded,
                  isLoading: isBusy,
                  onPressed: isBusy ? null : _startOnboarding,
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepTopBar() {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => setState(() => _page = _PayoutSetupPage.intro),
        ),
        const Spacer(),
        _buildHelpMenuButton(),
      ],
    );
  }

  Widget _buildSuccessScreen(DriverStripeOnboardingFlowState state) {
    final l10n = AppLocalizations.of(context);
    return _buildShell(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
              child: Column(
                children: [
                  _buildSuccessHeader(),
                  SizedBox(height: 18.h),
                  // _PayoutAccountCard and _EarningsSnapshotCard previously
                  // rendered fabricated placeholder financial data (fake IBAN,
                  // balance, next-payout date) to every driver who completed
                  // onboarding. Removed until they can be bound to the driver's
                  // real connected-account / earnings data.
                  const _GreatJobCard(),
                  SizedBox(height: 14.h),
                  _buildStatusArea(context, state),
                ],
              ),
            ),
          ),
          _StickyFooter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GradientButton(
                  text: l10n.back_to_dashboard,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: _goToDashboard,
                ),
                SizedBox(height: 15.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: l10n.need_help_visit_our),
                      TextSpan(
                        text: l10n.support_center,
                        style: const TextStyle(
                          color: _primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 28.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9F9EF), Color(0xFFF3FBF5), Color(0xFFF9FFFB)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: _ConfettiLayer()),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: _RoundIconButton(
              icon: Icons.close_rounded,
              onPressed: _goToDashboard,
              backgroundColor: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 42.h),
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _successGreen.withValues(alpha: 0.22),
                      blurRadius: 24.r,
                      offset: Offset(0, 12.h),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF62E98F), Color(0xFF12C870)],
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 43.sp,
                    ),
                  ),
                ),
              ).animate().scale(
                duration: 420.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.86, 0.86),
                end: const Offset(1, 1),
              ),
              SizedBox(height: 24.h),
              // Success header is a Stripe-branded light section that stays
              // light in dark mode, so its title pins to the light-UI ink
              // instead of the theme-flipping [_titleStyle].
              Text(
                l10n.payouts_ready,
                style: TextStyle(
                  color: _ink,
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.your_account_is_connected_and_yourenall_set_to_receive_earnings,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 12.sp,
                  height: 1.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea(
    BuildContext context,
    DriverStripeOnboardingFlowState onboardingState,
  ) {
    final widgets = <Widget>[];

    if (onboardingState.errorMessage != null) {
      widgets.add(
        _InlineStatusCard(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.08),
          borderColor: AppColors.error.withValues(alpha: 0.25),
          message: PaymentErrorHandler.humanize(onboardingState.errorMessage!),
        ).animate().fadeIn().slideY(begin: 0.04, end: 0),
      );
      widgets.add(SizedBox(height: 12.h));
    }

    if (onboardingState.isVerifying) {
      widgets.add(
        _InlineStatusCard(
          icon: Icons.sync_rounded,
          iconColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          borderColor: AppColors.primary.withValues(alpha: 0.18),
          message: AppLocalizations.of(context).stripeVerifyingAccount,
          showSpinner: true,
        ).animate().fadeIn().slideY(begin: 0.04, end: 0),
      );
      widgets.add(SizedBox(height: 12.h));
    }

    if (widgets.isEmpty) return const SizedBox.shrink();

    return Column(children: widgets);
  }

  /// Start Stripe Connect onboarding: create/refresh the account link, then
  /// open it in the native secure browser.
  Future<void> _startOnboarding() async {
    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .startOnboarding(ref.read(currentUserProvider).value);

    if (!mounted) return;

    final url = ref.read(driverStripeOnboardingFlowViewModelProvider).onboardingUrl;
    if (url != null && url.isNotEmpty) {
      await _openStripeOnboarding(url);
    }
  }

  /// Present the Stripe onboarding URL in SFSafariViewController (iOS) /
  /// Chrome Custom Tab (Android). Completion is detected when the browser
  /// closes ([_onSafariClosed]), where we re-verify the account server-side.
  Future<void> _openStripeOnboarding(String url) async {
    if (_safariLaunched) return;
    _safariLaunched = true;

    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,
          ),
          urlBarHidingEnabled: true,
          showTitle: true,
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: theme.colorScheme.surface,
          preferredControlTintColor: theme.colorScheme.onSurface,
          barCollapsingEnabled: false,
        ),
      );
    } catch (e) {
      _safariLaunched = false;
      if (!mounted) return;
      ref
          .read(driverStripeOnboardingFlowViewModelProvider.notifier)
          .failWebViewLoad(AppLocalizations.of(context).stripePageLoadFailed);
    }
  }

  /// Called when the Stripe secure browser closes (either because Stripe
  /// redirected to the return URL, or the driver dismissed it). We never trust
  /// the redirect: we re-fetch the connected-account status from the server.
  void _onSafariClosed() {
    _safariLaunched = false;
    if (!mounted) return;

    final state = ref.read(driverStripeOnboardingFlowViewModelProvider);
    if (state.completionHandled) return;

    ref.read(driverStripeOnboardingFlowViewModelProvider.notifier).markCompletionHandled();
    unawaited(_handleOnboardingComplete());
  }

  /// Lightweight placeholder shown behind the secure browser while Stripe
  /// onboarding is in progress.
  Widget _buildSafariHandoff() {
    final l10n = AppLocalizations.of(context);
    return _buildShell(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            SizedBox(height: 18.h),
            Text(
              l10n.stripeLoadingConnect,
              textAlign: TextAlign.center,
              style: _titleStyle(18),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.poweredByStripe,
              textAlign: TextAlign.center,
              style: _captionStyle(),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle successful onboarding completion.
  Future<void> _handleOnboardingComplete() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .handleOnboardingComplete(
          user: ref.read(currentUserProvider).value,
          successMessage: l10n.stripeAccountConnectedSuccessfully,
          additionalInfoMessage: l10n.stripeAdditionalInfoNeeded,
          verifyFailedMessage: l10n.stripeVerifyFailed,
        );

    if (!mounted) return;

    final state = ref.read(driverStripeOnboardingFlowViewModelProvider);

    if (state.isConnected) {
      setState(() => _page = _PayoutSetupPage.success);
    }
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.trailingIcon,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 54.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(colors: [_primaryGreen, _deepGreen]),
            boxShadow: [
              BoxShadow(
                color: _primaryGreen.withValues(alpha: 0.26),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator.adaptive(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, color: Colors.white, size: 20.sp)
                      else
                        SizedBox(width: 20.w),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PoweredByStripe extends StatelessWidget {
  const _PoweredByStripe({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.powered_by, style: _labelStyle(AppColors.textSecondary)),
        SizedBox(width: 5.w),
        Text(
          'stripe',
          style: TextStyle(
            color: _stripeGreen,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MiniLogo extends StatelessWidget {
  const _MiniLogo({required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: onDark
              ? [Colors.white, Colors.white.withValues(alpha: 0.72)]
              : [_primaryGreen, _mintGreen],
        ),
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            color: onDark ? _ink : Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MiniFeatureTile extends StatelessWidget {
  const _MiniFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Column(
        children: [
          Container(
            width: 31.w,
            height: 31.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _ink,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletArt extends StatelessWidget {
  const _WalletArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 105.w,
      height: 96.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: 2.h,
            end: 13.w,
            child: _Coin(size: 28.w),
          ),
          PositionedDirectional(
            top: 21.h,
            start: 8.w,
            child: _Coin(size: 23.w),
          ),
          PositionedDirectional(
            bottom: 9.h,
            start: 0,
            child: _Coin(size: 27.w),
          ),
          PositionedDirectional(
            end: 3.w,
            bottom: 5.h,
            child: Container(
              width: 72.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6F8DFF), Color(0xFF1641E5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withValues(alpha: 0.34),
                    blurRadius: 18.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    top: 10.h,
                    start: 10.w,
                    child: Container(
                      width: 37.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: -1.w,
                    top: 18.h,
                    child: Container(
                      width: 36.w,
                      height: 25.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C74FF),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(12.r),
                          right: Radius.circular(8.r),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.62),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE482), Color(0xFFFFA92E)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFAE2E).withValues(alpha: 0.32),
            blurRadius: 11.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '€',
          style: TextStyle(
            color: const Color(0xFFD78000),
            fontSize: size * 0.42,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 15.sp, color: AppColors.textPrimary),
          SizedBox(width: 7.w),
          Text(
            l10n.takes_about_3_minutes,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 90.ms).slideY(begin: 0.03, end: 0);
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _border),
      ),
      child: Icon(icon, size: 20.sp, color: _ink),
    );

    if (onPressed == null) return child;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 25.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _cardTitleStyle()),
                SizedBox(height: 4.h),
                Text(subtitle, style: _captionStyle()),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 24.sp,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.04, end: 0);
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(23.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9EF),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: _primaryGreen,
                  size: 25.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.your_security_is_our_priority,
                      style: _cardTitleStyle(),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10n.sportconnect_partners_with_stripe_to_securely_collect_and_protect_your_information_your_data_is_encrypted_and_never_shared_with_us,
                      style: _captionStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: _SecurityBadge(
                  icon: Icons.shield_outlined,
                  text: l10n.secure_by_stripe,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _SecurityBadge(
                  icon: Icons.verified_outlined,
                  text: l10n.pci_dss_compliant,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.04, end: 0);
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 14.sp),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreatJobCard extends StatelessWidget {
  const _GreatJobCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _mintGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withValues(alpha: 0.22),
            blurRadius: 22.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: 0,
            top: 4.h,
            bottom: 0,
            child: CustomPaint(
              size: Size(104.w, 58.h),
              painter: _SparklinePainter(),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFFFD34D),
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.youre_doing_great,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.keep_driving_more_rides_more_earnings,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.04, end: 0);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InlineStatusCard extends StatelessWidget {
  const _InlineStatusCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.message,
    this.showSpinner = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (showSpinner)
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            )
          else
            Icon(icon, color: iconColor, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: iconColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiLayer extends StatelessWidget {
  const _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ConfettiPiece(
          top: 30.h,
          left: 34.w,
          color: _successGreen,
          angle: -0.55,
        ),
        _ConfettiPiece(
          top: 82.h,
          left: 12.w,
          color: const Color(0xFFFFD34D),
          angle: 0.45,
        ),
        _ConfettiPiece(
          top: 94.h,
          right: 22.w,
          color: const Color(0xFF22C55E),
          angle: 0.35,
        ),
        _ConfettiPiece(
          top: 22.h,
          right: 52.w,
          color: const Color(0xFFFFD34D),
          angle: -0.35,
        ),
        _ConfettiPiece(
          top: 58.h,
          right: 24.w,
          color: _successGreen,
          angle: 0.52,
        ),
        _ConfettiPiece(
          top: 108.h,
          left: 42.w,
          color: const Color(0xFF22C55E),
          angle: -0.48,
        ),
      ],
    );
  }
}

class _ConfettiPiece extends StatelessWidget {
  const _ConfettiPiece({
    required this.color,
    required this.angle,
    this.top,
    this.left,
    this.right,
  });

  final double? top;
  final double? left;
  final double? right;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: top,
      start: left,
      end: right,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 10.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.62,
        size.width * 0.25,
        size.height * 0.82,
        size.width * 0.43,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.18,
        size.width * 0.68,
        size.height * 0.28,
        size.width * 0.78,
        size.height * 0.16,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.04,
        size.width * 0.94,
        size.height * 0.08,
        size.width,
        0,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}

TextStyle _titleStyle(double fontSize) {
  return TextStyle(
    color: AppColors.textPrimary,
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );
}

TextStyle _cardTitleStyle() {
  return TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14.sp,
    fontWeight: FontWeight.w900,
  );
}

TextStyle _captionStyle() {
  return TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11.sp,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
}

TextStyle _labelStyle(Color color) {
  return TextStyle(
    color: color,
    fontSize: 11.sp,
    fontWeight: FontWeight.w700,
  );
}
