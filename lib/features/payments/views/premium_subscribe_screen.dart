import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';
import 'package:sport_connect/features/payments/view_models/premium_checkout_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feature data
// ─────────────────────────────────────────────────────────────────────────────

class _Feature {
  const _Feature({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

List<_Feature> _features(AppLocalizations l10n) => [
  _Feature(icon: Icons.directions_car_rounded, label: l10n.smart_ride_matching),
  _Feature(icon: Icons.route_rounded, label: l10n.unlimited_saved_routes),
  _Feature(icon: Icons.shield_rounded, label: l10n.verified_community),
  _Feature(icon: Icons.groups_rounded, label: l10n.crew_coordination),
  _Feature(icon: Icons.emoji_events_rounded, label: l10n.race_day_priority),
  _Feature(icon: Icons.bolt_rounded, label: l10n.priority_support),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PremiumSubscribeScreen extends ConsumerStatefulWidget {
  const PremiumSubscribeScreen({super.key});

  @override
  ConsumerState<PremiumSubscribeScreen> createState() =>
      _PremiumSubscribeScreenState();
}

class _PremiumSubscribeScreenState
    extends ConsumerState<PremiumSubscribeScreen> {
  Map<PremiumPlan, ProductDetails> _products = const {};
  bool _loadingProducts = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _loadFailed = false;
    });
    try {
      final p = await ref
          .read(premiumIapServiceProvider.notifier)
          .fetchAvailablePlans();
      if (!mounted) return;
      setState(() {
        _products = p;
        _loadingProducts = false;
      });
    } on Object catch (e, st) {
      TalkerService.warning('Premium plan load failed: $e');
      TalkerService.error('Premium plan load error', e, st);
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _loadFailed = true;
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  PremiumPlan get _selected =>
      ref.read(premiumCheckoutViewModelProvider).selectedPlan;

  void _select(PremiumPlan plan) {
    unawaited(HapticFeedback.selectionClick());
    ref.read(premiumCheckoutViewModelProvider.notifier).selectPlan(plan);
  }

  /// Price string for the given plan, from StoreKit if available.
  String _price(PremiumPlan plan) {
    final product = _products[plan];
    if (product != null) return product.price;
    return plan == PremiumPlan.monthly
        ? AppLocalizations.of(context).fallbackMonthlyPrice
        : AppLocalizations.of(context).fallbackYearlyPrice;
  }

  /// Per-month equivalent for the yearly plan.
  String _yearlyMonthly() {
    final product = _products[PremiumPlan.yearly];
    if (product != null) {
      final sym = product.currencySymbol;
      final monthly = product.rawPrice / 12;
      return AppLocalizations.of(
        context,
      ).yearlyMonthlyAtPrice('$sym${monthly.toStringAsFixed(2)}');
    }
    return AppLocalizations.of(context).yearlyMonthlyEstimate;
  }

  /// Label shown on the CTA button: price + period.
  String _ctaLabel(AppLocalizations l10n) {
    if (_loadingProducts) return l10n.loading_subscription_plans;
    if (_loadFailed) return l10n.pricingUnavailableCheckYourConnection;
    final plan = _selected;
    final price = _price(plan);
    final period = plan == PremiumPlan.monthly
        ? l10n.billingPeriodMonthShort
        : l10n.billingPeriodYearShort;
    return '${l10n.subscribe_now} · $price $period';
  }

  /// Renewal disclosure shown in the legal footer.
  String _renewalText() {
    final plan = _selected;
    if (_loadingProducts || _loadFailed) {
      return AppLocalizations.of(context).premiumRenewsUntilCancelled;
    }
    final period = plan == PremiumPlan.monthly
        ? AppLocalizations.of(context).month
        : AppLocalizations.of(context).year;
    return AppLocalizations.of(
      context,
    ).premiumRenewsEachPeriodAtPrice(period, _price(plan));
  }

  bool get _canPurchase =>
      !_loadingProducts && !_loadFailed && _products.isNotEmpty;

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _onSubscribe() async {
    if (!_canPurchase) return;
    unawaited(HapticFeedback.mediumImpact());

    final vm = ref.read(premiumCheckoutViewModelProvider.notifier);
    final success = await vm.completeCheckout();
    if (!mounted) return;
    if (!success) return;

    AdaptiveSnackBar.show(
      context,
      message: AppLocalizations.of(context).premium_activated_successfully,
      type: AdaptiveSnackBarType.success,
    );

    if (!mounted) return;
    final user = ref.read(currentUserProvider).value;
    context.go(
      user is DriverModel ? AppRoutes.driverHome.path : AppRoutes.home.path,
    );
  }

  Future<void> _onRestore() async {
    unawaited(HapticFeedback.lightImpact());
    final result = await ref
        .read(premiumIapServiceProvider.notifier)
        .restorePurchases();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    AdaptiveSnackBar.show(
      context,
      message: result.isSuccess
          ? l10n.purchasesRestoredSuccessfully
          : (result.errorMessage ?? l10n.couldNotRestorePurchases),
      type: result.isSuccess
          ? AdaptiveSnackBarType.success
          : AdaptiveSnackBarType.error,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checkoutState = ref.watch(premiumCheckoutViewModelProvider);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final isProcessing = checkoutState.isProcessing;
    final isTabletLayout = context.screenWidth >= Breakpoints.medium;

    // If the user is already Premium, show a simple confirmation instead of
    // the subscribe flow so they cannot accidentally initiate a duplicate purchase.
    final user = ref.watch(currentUserProvider).value;
    final alreadyPremium = switch (user) {
      final RiderModel r => r.isPremium,
      final DriverModel d => d.isPremium,
      _ => false,
    };
    if (alreadyPremium) return _AlreadyPremiumScreen(l10n: l10n);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: AdaptiveScaffold(
        body: ColoredBox(
          color: AppColors.background,
          child: isTabletLayout
              || (context.isLandscape && context.screenHeight < 500)
              ? _buildTabletLayout(l10n, checkoutState, isProcessing)
              : _buildMobileLayout(
                  l10n,
                  checkoutState,
                  isProcessing,
                  bottomPad,
                ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    AppLocalizations l10n,
    PremiumCheckoutState checkoutState,
    bool isProcessing,
    double bottomPad,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildHeader(l10n),
            _buildHeroSection(l10n),
            _buildFeatureList(l10n),
            _buildPlanSelector(l10n),
            SliverToBoxAdapter(
              child: SizedBox(height: 160.h + bottomPad),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildStickyBottom(
            l10n,
            checkoutState,
            isProcessing,
            bottomPad,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    AppLocalizations l10n,
    PremiumCheckoutState checkoutState,
    bool isProcessing,
  ) {
    final sidebarWidth = responsiveValue<double>(
      context,
      compact: 360,
      medium: 380,
      expanded: 420,
      large: 460,
    );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: CustomScrollView(
                      slivers: [
                        _buildHeader(l10n),
                        _buildHeroSection(l10n),
                        _buildFeatureList(l10n),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 24.h),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 24.w),
                SizedBox(
                  width: sidebarWidth,
                  child: _buildTabletPurchaseSidebar(
                    l10n,
                    checkoutState,
                    isProcessing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletPurchaseSidebar(
    AppLocalizations l10n,
    PremiumCheckoutState checkoutState,
    bool isProcessing,
  ) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.premium_checkout,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.premiumSubscribeHeroSubtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTabletPlanSelector(l10n),
                  SizedBox(height: 20.h),
                  _buildTabletValueCard(l10n),
                  SizedBox(height: 20.h),
                  _buildTabletCheckoutPanel(l10n, checkoutState, isProcessing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletPlanSelector(AppLocalizations l10n) {
    return Column(
      children: [
        _PlanCard(
          label: l10n.monthly,
          priceLabel: _loadingProducts
              ? '…'
              : _loadFailed
              ? '—'
              : _price(PremiumPlan.monthly),
          sublabel: l10n.cancelAnytime,
          isSelected: _selected == PremiumPlan.monthly,
          isBestValue: false,
          isLoading: _loadingProducts,
          onTap: () => _select(PremiumPlan.monthly),
        ),
        SizedBox(height: 12.h),
        _PlanCard(
          label: l10n.yearly,
          priceLabel: _loadingProducts
              ? '…'
              : _loadFailed
              ? '—'
              : _price(PremiumPlan.yearly),
          sublabel: _loadingProducts
              ? ''
              : _loadFailed
              ? l10n.yearlyMonthlyEstimate
              : _yearlyMonthly(),
          badgeLabel: l10n.bestValue,
          isSelected: _selected == PremiumPlan.yearly,
          isBestValue: true,
          isLoading: _loadingProducts,
          onTap: () => _select(PremiumPlan.yearly),
        ),
      ],
    );
  }

  Widget _buildTabletValueCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bestValue,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.save_about_16_compared_to_monthly,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.billedMonthly,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletCheckoutPanel(
    AppLocalizations l10n,
    PremiumCheckoutState checkoutState,
    bool isProcessing,
  ) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (checkoutState.errorMessage != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                checkoutState.errorMessage!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_loadFailed) ...[
            GestureDetector(
              onTap: _loadProducts,
              child: Text(
                l10n.retry_loading_plans,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: _SubscribeButton(
              label: _ctaLabel(l10n),
              isEnabled: _canPurchase && !isProcessing,
              isLoading: isProcessing,
              onPressed: _onSubscribe,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _renewalText(),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegalLink(
                label: l10n.termsOfServiceTitle,
                onTap: () => context.push(AppRoutes.terms.path),
              ),
              Text(
                '  ·  ',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              _LegalLink(
                label: l10n.privacyPolicyTitle,
                onTap: () => context.push(AppRoutes.privacy.path),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: l10n.goBackTooltip,
        icon: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: _onRestore,
          child: Text(
            l10n.restore_purchases,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHeroSection(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            // Crown icon
            Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF40916C), Color(0xFF2D6A4F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(),
            SizedBox(height: 16.h),
            Text(
              l10n.sportconnect_premium,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            SizedBox(height: 6.h),
            Text(
              l10n.premiumSubscribeHeroSubtitle,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  // ── Features ──────────────────────────────────────────────────────────────

  Widget _buildFeatureList(AppLocalizations l10n) {
    final items = _features(l10n);
    return SliverToBoxAdapter(
      child: Padding(
        padding: adaptiveScreenPadding(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: adaptiveScreenPadding(
            context,
          ).copyWith(bottom: 16.h, top: 16.h),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _FeatureRow(icon: items[i].icon, label: items[i].label)
                    .animate(delay: (200 + i * 60).ms)
                    .fadeIn()
                    .slideX(begin: -0.08),
                if (i < items.length - 1)
                  Divider(
                    height: 16.h,
                    thickness: 0.5,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Plan selector ─────────────────────────────────────────────────────────

  Widget _buildPlanSelector(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        child: Row(
          children: [
            Expanded(
              child: _PlanCard(
                label: l10n.monthly,
                priceLabel: _loadingProducts
                    ? '…'
                    : _loadFailed
                    ? '—'
                    : _price(PremiumPlan.monthly),
                sublabel: l10n.cancelAnytime,
                isSelected: _selected == PremiumPlan.monthly,
                isBestValue: false,
                isLoading: _loadingProducts,
                onTap: () => _select(PremiumPlan.monthly),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _PlanCard(
                label: l10n.yearly,
                priceLabel: _loadingProducts
                    ? '…'
                    : _loadFailed
                    ? '—'
                    : _price(PremiumPlan.yearly),
                sublabel: _loadingProducts
                    ? ''
                    : _loadFailed
                    ? l10n.yearlyMonthlyEstimate
                    : _yearlyMonthly(),
                badgeLabel: l10n.bestValue,
                isSelected: _selected == PremiumPlan.yearly,
                isBestValue: true,
                isLoading: _loadingProducts,
                onTap: () => _select(PremiumPlan.yearly),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky CTA bar ────────────────────────────────────────────────────────

  Widget _buildStickyBottom(
    AppLocalizations l10n,
    PremiumCheckoutState checkoutState,
    bool isProcessing,
    double bottomPad,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error message
          if (checkoutState.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                checkoutState.errorMessage!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Load-fail retry link
          if (_loadFailed) ...[
            GestureDetector(
              onTap: _loadProducts,
              child: Text(
                l10n.retry_loading_plans,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: _SubscribeButton(
              label: _ctaLabel(l10n),
              isEnabled: _canPurchase && !isProcessing,
              isLoading: isProcessing,
              onPressed: _onSubscribe,
            ),
          ),

          SizedBox(height: 12.h),

          // Legal disclosure
          Text(
            _renewalText(),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          // Terms · Privacy
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegalLink(
                label: l10n.termsOfServiceTitle,
                onTap: () => context.push(AppRoutes.terms.path),
              ),
              Text(
                '  ·  ',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              _LegalLink(
                label: l10n.privacyPolicyTitle,
                onTap: () => context.push(AppRoutes.privacy.path),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.primaryDark),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          size: 18.sp,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.priceLabel,
    required this.sublabel,
    required this.isSelected,
    required this.isBestValue,
    required this.isLoading,
    required this.onTap,
    this.badgeLabel,
  });

  final String label;
  final String priceLabel;
  final String sublabel;
  final String? badgeLabel;
  final bool isSelected;
  final bool isBestValue;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (badgeLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            if (isLoading)
              SizedBox(
                width: 16.sp,
                height: 16.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            if (sublabel.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({
    required this.label,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.sp,
                height: 22.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AlreadyPremiumScreen extends StatelessWidget {
  const _AlreadyPremiumScreen({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF40916C), Color(0xFF2D6A4F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.alreadyPremiumTitle,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  l10n.alreadyPremiumSubtitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      l10n.backToApp,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}
