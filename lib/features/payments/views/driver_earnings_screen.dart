import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/payment_error_handler.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/analytics_payment_widgets.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart'
    show DriverConnectedAccount;
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Earnings Screen  - View earnings with real Firestore data
///
/// Uses [driverStatsProvider] from the rides feature (denormalized aggregate
/// in `driver_stats` collection) for performance — single document read
/// instead of aggregating all payment transactions on-the-fly.
/// The payments feature's [driverEarningsSummaryProvider] computes the same
/// data from the `payments` collection and can be used for reconciliation.
class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  static const List<String> _periodKeys = [
    'today',
    'thisWeek',
    'thisMonth',
    'allTime',
  ];

  String _periodLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'today':
        return l10n.periodToday;
      case 'thisWeek':
        return l10n.periodThisWeek;
      case 'thisMonth':
        return l10n.periodThisMonth;
      case 'allTime':
        return l10n.periodAllTime;
      default:
        return key;
    }
  }

  /// Displays all money values in Euro.
  String _currencyCode(WidgetRef _) => 'EUR';

  void _exportEarnings(BuildContext context, WidgetRef ref) {
    final driverStats = ref.read(driverStatsProvider);
    final transactions = ref.read(earningsTransactionsProvider);

    final stats = driverStats.value;
    final txList = transactions.value;

    if (stats == null) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).noData,
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final now = AppLocaleFormatters.formatMediumDate(context, DateTime.now());
    final buffer = StringBuffer()
      ..writeln('SportConnect - ${l10n.exportEarningsReport}')
      ..writeln('${l10n.exportGenerated}: $now')
      ..writeln('================================')
      ..writeln()
      ..writeln(l10n.exportEarningsSummary)
      ..writeln(
        '  ${l10n.periodToday}:      ${AppLocaleFormatters.formatCurrencyFromCents(context, stats.earningsTodayInCents)}',
      )
      ..writeln(
        '  ${l10n.periodThisWeek}:  ${AppLocaleFormatters.formatCurrencyFromCents(context, stats.earningsThisWeekInCents)}',
      )
      ..writeln(
        '  ${l10n.periodThisMonth}: ${AppLocaleFormatters.formatCurrencyFromCents(context, stats.earningsThisMonthInCents)}',
      )
      ..writeln(
        '  ${l10n.periodAllTime}:      ${AppLocaleFormatters.formatCurrencyFromCents(context, stats.totalEarningsInCents)}',
      )
      ..writeln()
      ..writeln(l10n.exportRideStatistics)
      ..writeln('  ${l10n.statRides}: ${stats.totalRides}')
      ..writeln(
        '  ${l10n.distance}: ${l10n.distanceKmValue(stats.totalDistance.toStringAsFixed(1))}',
      )
      ..writeln();

    if (txList != null && txList.isNotEmpty) {
      buffer
        ..writeln(l10n.exportRecentTransactions)
        ..writeln('--------------------------------');
      for (final tx in txList.take(20)) {
        final date = AppLocaleFormatters.formatShortDateTime(
          context,
          tx.createdAt,
        );
        buffer.writeln(
          '  $date | ${AppLocaleFormatters.formatCurrencyFromCents(context, tx.amountInCents)} | ${tx.description}',
        );
      }
    }

    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text: buffer.toString(),
          sharePositionOrigin: shareSheetOrigin(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverStats = ref.watch(driverStatsProvider);
    final transactions = ref.watch(earningsTransactionsProvider);
    final selectedPeriod = ref.watch(
      driverEarningsPeriodViewModelProvider.select((s) => s.selectedPeriod),
    );

    return AdaptiveScaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(driverStripeStatusProvider);
          ref.invalidate(driverPayoutEligibilityProvider);
          await Future.wait<Object?>(
            [
              ref.refresh(driverStatsProvider.future),
              ref.refresh(earningsTransactionsProvider.future),
              ref
                  .refresh(driverPayoutEligibilityProvider.future)
                  .timeout(const Duration(seconds: 8))
                  .catchError((_) => const DriverPayoutEligibility()),
              ref
                  .read(driverStripeStatusProvider.future)
                  .timeout(const Duration(seconds: 8))
                  .catchError((_) => const DriverStripeStatus()),
            ],
          );
          ref.invalidate(currentDriverConnectedAccountProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 160.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildEarningsHeader(
                  context,
                  ref,
                  driverStats,
                  selectedPeriod,
                ),
              ),
              title: Text(
                AppLocalizations.of(context).earnings,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _exportEarnings(context, ref),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                ),
              ],
            ),

            // ── Stats overview group ──────────────────────────
            MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: AppLocalizations.of(context).earningsOverview,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildPeriodSelector(context, ref, selectedPeriod),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsGrid(
                    context,
                    ref,
                    driverStats,
                    selectedPeriod,
                  ),
                ),
                SliverToBoxAdapter(
                  child: driverStats.when(
                    data: (stats) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: MonthlyRideSummary(
                        totalRides: stats.totalRides,
                        totalSpent: stats.totalSpentInCents / 100,
                        totalEarned: stats.totalEarningsInCents / 100,
                        totalDistance: stats.totalDistance,
                        month: AppLocaleFormatters.formatMonthYear(
                          context,
                          DateTime.now(),
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildEarningsChart(
                    context,
                    driverStats,
                    selectedPeriod,
                  ),
                ),
              ],
            ),

            // ── Payout + Transactions group ───────────────────
            MultiSliver(
              children: [
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: AppLocalizations.of(context).setUpPayouts,
                  ),
                ),
                SliverToBoxAdapter(child: _buildPayoutSection(context, ref)),
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: AppLocalizations.of(context).recentTransactions,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRecentTransactions(context, ref, transactions),
                ),
              ],
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
    return statsAsync.when(
      data: (stats) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _periodLabel(context, selectedPeriod),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  AppLocalizations.of(context).value5(
                    (() {
                      switch (selectedPeriod) {
                        case 'today':
                          return stats.earningsTodayInCents / 100;
                        case 'thisWeek':
                          return stats.earningsThisWeekInCents / 100;
                        case 'thisMonth':
                          return stats.earningsThisMonthInCents / 100;
                        default:
                          return stats.totalEarningsInCents / 100;
                      }
                    })().toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                SizedBox(height: 6.h),
                Text(
                  () {
                    final rides = switch (selectedPeriod) {
                      'thisWeek' => stats.ridesThisWeek,
                      'thisMonth' => stats.ridesThisMonth,
                      _ => stats.totalRides,
                    };
                    return '$rides ${AppLocalizations.of(context).totalRides.toLowerCase()}';
                  }(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: const Center(
          child: SkeletonLoader(type: SkeletonType.compactTile, itemCount: 1),
        ),
      ),
      error: (_, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).failedToLoadEarnings,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: () {
                  ref.invalidate(driverStatsProvider);
                  ref.invalidate(earningsTransactionsProvider);
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context).tryAgain,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    String selectedPeriod,
  ) {
    final chips = _periodKeys.map((period) {
      final isSelected = selectedPeriod == period;
      return AdaptiveTapSurface(
        borderRadius: BorderRadius.circular(999.r),
        onTap: () => ref
            .read(driverEarningsPeriodViewModelProvider.notifier)
            .setPeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 8.h,
          ),
          constraints: BoxConstraints(minHeight: 40.h, minWidth: 96.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: isSelected ? AppSpacing.shadowSm : null,
          ),
          child: Center(
            child: Text(
              _periodLabel(context, period),
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: context.isExpandedOrLarger
          ? Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: chips,
            )
          : SizedBox(
              height: 56.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) => chips[index],
              ),
            ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
    return statsAsync.when(
      data: (stats) {
        double displayEarnings;
        int displayRides;

        switch (selectedPeriod) {
          case 'today':
            displayEarnings = stats.earningsTodayInCents / 100;
            displayRides = stats.totalRides;
          case 'thisWeek':
            displayEarnings = stats.earningsThisWeekInCents / 100;
            displayRides = stats.ridesThisWeek;
          case 'thisMonth':
            displayEarnings = stats.earningsThisMonthInCents / 100;
            displayRides = stats.ridesThisMonth;
          default:
            displayEarnings = stats.totalEarningsInCents / 100;
            displayRides = stats.totalRides;
        }

        final avgPerRide = displayRides > 0
            ? AppLocaleFormatters.formatCurrency(
                context,
                displayEarnings / displayRides,
                decimalDigits: 0,
              )
            : '—';

        final cards = [
          _StatCard(
            icon: Icons.directions_car_rounded,
            iconColor: AppColors.primary,
            title: AppLocalizations.of(context).statRides,
            value: displayRides.toString(),
          ),
          _StatCard(
            icon: Icons.euro_rounded,
            iconColor: AppColors.success,
            title: AppLocalizations.of(context).statEarnings,
            value: AppLocaleFormatters.formatCurrency(
              context,
              displayEarnings,
              decimalDigits: 0,
            ),
          ),
          _StatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.starFilled,
            title: AppLocalizations.of(context).statAvgRating,
            value: stats.rating > 0 ? stats.rating.toStringAsFixed(2) : '—',
          ),
          _StatCard(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.secondary,
            title: AppLocalizations.of(context).avgPerRide,
            value: avgPerRide,
          ),
        ];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _buildStatCardsGrid(
            context: context,
            cards: cards,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _buildStatCardsGrid(
          context: context,
          cards: List<Widget>.generate(4, (_) => _buildLoadingStatCard()),
        ),
      ),
      error: (_, _) => _buildErrorPlaceholder(context),
    );
  }

  /// Displays a compact error message when earnings data fails to load.
  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context).unableToLoadData,
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const SkeletonLoader(type: SkeletonType.compactTile, itemCount: 1),
    );
  }

  // This section is rendered inside an outer scroll view, so a non-scrollable
  // wrap layout avoids shrink-wrapped nested GridView overhead.
  Widget _buildStatCardsGrid({
    required BuildContext context,
    required List<Widget> cards,
  }) {
    final crossAxisCount = context.isExpandedOrLarger ? 4 : 2;
    final spacingW = 12.w;
    final spacingH = 12.h;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacingW * (crossAxisCount - 1);
        final itemWidth =
            (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacingW,
          runSpacing: spacingH,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildEarningsChart(
    BuildContext context,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
    return statsAsync.when(
      data: (stats) => Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppSpacing.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).earningsOverview,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            // Total earnings breakdown
            _buildEarningsBreakdownItem(
              context,
              AppLocalizations.of(context).statEarnings,
              switch (selectedPeriod) {
                'today' => stats.earningsTodayInCents,
                'thisWeek' => stats.earningsThisWeekInCents,
                'thisMonth' => stats.earningsThisMonthInCents,
                _ => stats.totalEarningsInCents,
              },
              AppColors.primary,
            ),
            SizedBox(height: 20.h),
            // CO2 Impact
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco, color: AppColors.success, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).totalDistance,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).distanceKmValue(
                            stats.totalDistance.toStringAsFixed(1),
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.success,
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
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
      loading: () => Container(
        margin: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const SkeletonLoader(itemCount: 3),
      ),
      error: (_, _) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildEarningsBreakdownItem(
    BuildContext context,
    String label,
    int amountInCents,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
        Text(
          AppLocalizations.of(
            context,
          ).value5((amountInCents / 100).toStringAsFixed(0)),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStripeBalanceLine(
    BuildContext context,
    String label,
    int amountInCents,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
        Text(
          AppLocaleFormatters.formatCurrencyFromCents(context, amountInCents),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build the payout section with Stripe integration
  Widget _buildPayoutSection(BuildContext context, WidgetRef ref) {
    final connectedAccount = ref.watch(currentDriverConnectedAccountProvider);
    final resolvedLiveStatus = ref.watch(
      driverStripeStatusProvider.select((a) => a.value),
    );
    final cachedStatus = _statusFromConnectedAccount(connectedAccount.value);

    return connectedAccount.when(
      data: (account) {
        final accountStatus = _statusFromConnectedAccount(account);
        return _buildPayoutCard(
          context,
          ref,
          _stableStripeStatus(accountStatus, resolvedLiveStatus),
        );
      },
      loading: () {
        final status = _stableStripeStatus(cachedStatus, resolvedLiveStatus);
        if (status == null) return _buildPayoutStatusLoading();
        return _buildPayoutCard(context, ref, status);
      },
      error: (_, _) {
        final status = _stableStripeStatus(cachedStatus, resolvedLiveStatus);
        if (status == null) return _buildPayoutStatusLoading();
        return _buildPayoutCard(context, ref, status);
      },
    );
  }

  DriverStripeStatus? _stableStripeStatus(
    DriverStripeStatus? cachedStatus,
    DriverStripeStatus? liveStatus,
  ) {
    if (cachedStatus == null) return liveStatus;
    if (liveStatus == null) return cachedStatus;

    final liveHasAccount = liveStatus.stripeAccountId?.isNotEmpty ?? false;
    if (!liveHasAccount) return cachedStatus;

    // Do not let a partial live refresh flip a connected account back to the
    // setup CTA. Firestore is the source of truth for whether onboarding exists;
    // live Stripe only refreshes payout flags and balances.
    return liveStatus.copyWith(
      isConnected: cachedStatus.isConnected || liveStatus.isConnected,
      stripeAccountId:
          liveStatus.stripeAccountId ?? cachedStatus.stripeAccountId,
    );
  }

  Widget _buildPayoutStatusLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: const SkeletonLoader(type: SkeletonType.compactTile, itemCount: 2),
    );
  }

  DriverStripeStatus? _statusFromConnectedAccount(
    DriverConnectedAccount? account,
  ) {
    if (account == null) return null;

    return DriverStripeStatus(
      isConnected: account.isFullySetup,
      payoutsEnabled: account.payoutsEnabled,
      chargesEnabled: account.chargesEnabled,
      detailsSubmitted: account.detailsSubmitted,
      availableBalanceInCents: account.availableBalanceInCents,
      pendingBalanceInCents: account.pendingBalanceInCents,
      currency: account.defaultCurrency,
      stripeAccountId: account.stripeAccountId,
    );
  }

  Widget _buildPayoutCard(
    BuildContext context,
    WidgetRef ref,
    DriverStripeStatus? status,
  ) {
    final isConnected = status?.isConnected ?? false;
    final payoutsEnabled = status?.payoutsEnabled ?? false;
    final rawStripeAvailableBalanceInCents =
        status?.availableBalanceInCents ?? 0;
    final pendingBalanceInCents = status?.pendingBalanceInCents ?? 0;
    final totalStripeBalanceInCents =
        rawStripeAvailableBalanceInCents + pendingBalanceInCents;
    final payoutEligibility = ref.watch(driverPayoutEligibilityProvider);
    final eligibility = payoutEligibility.value;
    final isEligibilityLoading =
        payoutEligibility.isLoading && eligibility == null;
    final withdrawableBalanceInCents =
        eligibility?.withdrawableBalanceInCents ?? 0;
    final completedEarningsInCents =
        eligibility?.completedEarningsInCents ??
        (ref
                .watch(driverStatsProvider.select((a) => a.value))
                ?.totalEarningsInCents ??
            0);
    final activePayoutsInCents = eligibility?.activePayoutsInCents ?? 0;
    final blockedPendingRideEarningsInCents =
        eligibility?.blockedPendingRideEarningsInCents ?? 0;
    final tripEarningsInCents =
        ref
            .watch(driverStatsProvider.select((a) => a.value))
            ?.totalEarningsInCents ??
        0;
    final stripeAccountId = status?.stripeAccountId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: isConnected
            ? LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isConnected
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isConnected ? Icons.account_balance_wallet : Icons.link,
                  color: isConnected ? AppColors.success : AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? AppLocalizations.of(context).stripeConnected
                          : AppLocalizations.of(context).setUpPayouts,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isConnected
                          ? (payoutsEnabled
                                ? AppLocalizations.of(
                                    context,
                                  ).receivePaymentsFromRiders
                                : AppLocalizations.of(
                                    context,
                                  ).completeVerification)
                          : AppLocalizations.of(context).connectYourBankAccount,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).active,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (isConnected && payoutsEnabled) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context).availableBalance,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () async => showDialog<void>(
                                    context: context,
                                    builder: (_) => AlertDialog.adaptive(
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).availableBalance,
                                      ),
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).withdrawableBalanceInfo,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).actionDone,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 14.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).value5(
                                (withdrawableBalanceInCents / 100)
                                    .toStringAsFixed(2),
                              ),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PremiumButton(
                        text: AppLocalizations.of(context).withdraw,
                        onPressed: () => _onWithdrawPressed(
                          context,
                          ref,
                          stripeAccountId: stripeAccountId,
                          availableBalanceInCents: withdrawableBalanceInCents,
                          pendingBalanceInCents: pendingBalanceInCents,
                          blockedPendingRideEarningsInCents:
                              blockedPendingRideEarningsInCents,
                          isFullySetup: payoutsEnabled,
                        ),
                        isLoading: isEligibilityLoading,
                        isDisabled:
                            isEligibilityLoading ||
                            withdrawableBalanceInCents <= 0,
                        style: PremiumButtonStyle.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).withdrawableNowLabel,
                    withdrawableBalanceInCents,
                    AppColors.success,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).completedRideEarningsLabel,
                    completedEarningsInCents,
                    AppColors.primary,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).payoutsAlreadyRequestedLabel,
                    activePayoutsInCents,
                    AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(
                      context,
                    ).paidRidesAwaitingCompletionLabel,
                    blockedPendingRideEarningsInCents,
                    AppColors.warning,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).stripeInstantAvailableLabel,
                    rawStripeAvailableBalanceInCents,
                    AppColors.success,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).statusProcessing,
                    pendingBalanceInCents,
                    AppColors.warning,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).stripeBalanceTotalLabel,
                    totalStripeBalanceInCents,
                    AppColors.textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  _buildStripeBalanceLine(
                    context,
                    AppLocalizations.of(context).tripEarningsRecordedLabel,
                    tripEarningsInCents,
                    AppColors.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppLocalizations.of(context).withdrawableNowFootnote,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isConnected) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: AppLocalizations.of(context).connectStripeAccount,
                onPressed: () =>
                    context.push(AppRoutes.driverStripeOnboarding.path),
              ),
            ),
          ],
          if (isConnected && !payoutsEnabled) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: AppLocalizations.of(context).completeVerification,
                onPressed: () =>
                    context.push(AppRoutes.driverStripeOnboarding.path),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Future<void> _requestPayout(
    BuildContext context,
    WidgetRef ref,
    String stripeAccountId,
    int amountInCents,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).confirmPayout),
        content: Text(
          AppLocalizations.of(
            context,
          ).withdrawValueToYourConnected(
            (amountInCents / 100).toStringAsFixed(2),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(AppLocalizations.of(context).withdraw),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final success = await ref
          .read(driverPayoutViewModelProvider.notifier)
          .requestInstantPayout(
            stripeAccountId: stripeAccountId,
            amountInCents: amountInCents,
            currency: _currencyCode(ref),
          );

      if (success) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message:
              AppLocalizations.of(
                context,
              ).payoutOfValueInitiated(
                (amountInCents / 100).toStringAsFixed(2),
              ),
          type: AdaptiveSnackBarType.success,
        );
        ref
          ..invalidate(driverStripeStatusProvider)
          ..invalidate(driverPayoutEligibilityProvider)
          ..invalidate(driverStatsProvider)
          ..invalidate(earningsTransactionsProvider);
        unawaited(_refreshStripeStatusAfterPayout(context, ref));
      } else {
        if (!context.mounted) return;
        final payoutState = ref.read(driverPayoutViewModelProvider);
        final message = payoutState.hasError
            ? PaymentErrorHandler.humanize(payoutState.error!)
            : AppLocalizations.of(context).payoutFailedPleaseTryAgain;
        AdaptiveSnackBar.show(
          context,
          message: message,
          type: AdaptiveSnackBarType.error,
        );
      }
    } on Object catch (e) {
      if (!context.mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: PaymentErrorHandler.humanize(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _refreshStripeStatusAfterPayout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(driverStripeStatusProvider.future);
      if (!context.mounted) return;
      ref.invalidate(currentDriverConnectedAccountProvider);
    } on Object catch (e, st) {
      // The next manual refresh will retry the server sync.
      TalkerService.warning('Post-payout Stripe status refresh failed: $e');
      TalkerService.error('Post-payout Stripe status refresh error', e, st);
    }
  }

  Future<void> _onWithdrawPressed(
    BuildContext context,
    WidgetRef ref, {
    required String? stripeAccountId,
    required int availableBalanceInCents,
    required int pendingBalanceInCents,
    required int blockedPendingRideEarningsInCents,
    required bool isFullySetup,
  }) async {
    if (!isFullySetup) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).completeVerification,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    if (stripeAccountId == null || stripeAccountId.isEmpty) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(
          context,
        ).your_stripe_account_id_is_missing_please_reconnect_your_payout_account,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    if (availableBalanceInCents <= 0) {
      final pendingText = blockedPendingRideEarningsInCents > 0
          ? AppLocalizations.of(context).rideCompletionPendingAmount(
              (blockedPendingRideEarningsInCents / 100).toStringAsFixed(2),
            )
          : pendingBalanceInCents > 0
          ? AppLocalizations.of(context).processingBalancePendingAmount(
              (pendingBalanceInCents / 100).toStringAsFixed(2),
            )
          : '';
      AdaptiveSnackBar.show(
        context,
        message:
            AppLocalizations.of(context).noCompletedRideBalanceAvailableYet +
            pendingText,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    await _requestPayout(
      context,
      ref,
      stripeAccountId,
      availableBalanceInCents,
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<EarningsTransaction>> transactionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppLocalizations.of(context).noTransactionsYet,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _TransactionItem(
                  description: transaction.description,
                  amountInCents: transaction.amountInCents,
                  type: transaction.type,
                  date: AppLocaleFormatters.formatShortDateTime(
                    context,
                    transaction.createdAt,
                  ),
                  onTap: transaction.type == EarningsTransactionType.payout
                      ? () => context.push(
                          AppRoutes.payoutDetail.path.replaceFirst(
                            ':id',
                            transaction.id,
                          ),
                        )
                      : null,
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            );
          },
          loading: () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const SkeletonLoader(
              type: SkeletonType.compactTile,
            ),
          ),
          error: (_, _) => Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context).failedToLoadTransactions,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.description,
    required this.amountInCents,
    required this.type,
    required this.date,
    this.onTap,
  });
  final String description;
  final int amountInCents;
  final EarningsTransactionType type;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      EarningsTransactionType.ride => (Icons.directions_car, AppColors.primary),
      EarningsTransactionType.bonus => (Icons.star, AppColors.starFilled),
      EarningsTransactionType.refund => (Icons.replay, AppColors.warning),
      EarningsTransactionType.payout => (
        Icons.account_balance,
        AppColors.success,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppSpacing.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${amountInCents >= 0 ? '+' : '-'}${AppLocaleFormatters.formatCurrencyFromCents(context, amountInCents.abs())}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: amountInCents >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
