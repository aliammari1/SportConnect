import 'dart:async';
import 'dart:math' as math;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/payment_error_handler.dart';
import 'package:sport_connect/core/widgets/analytics_payment_widgets.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/key_value_row.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

/// Payment History Screen - View all payment transactions for a rider
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  static const _filterKeys = [
    'all',
    'completed',
    'pending',
    'refunded',
    'failed',
  ];

  String _filterLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'all':
        return l10n.filterAll;
      case 'completed':
        return l10n.filterCompleted;
      case 'pending':
        return l10n.filterPending;
      case 'refunded':
        return l10n.filterRefunded;
      case 'failed':
        return l10n.filterFailed;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(currentAuthUidProvider);
    final selectedFilter = ref
        .watch(paymentHistoryFilterViewModelProvider)
        .selectedFilter;

    return userIdAsync.when(
      data: (userId) {
        if (userId == null) {
          return AdaptiveScaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).pleaseSignInToView2),
            ),
          );
        }

        final paymentsAsync = ref.watch(
          riderPaymentHistoryStreamProvider(userId),
        );

        return AdaptiveScaffold(
          body: RefreshIndicator.adaptive(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(riderPaymentHistoryStreamProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120.h,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(context),
                  ),
                  title: Text(
                    AppLocalizations.of(context).paymentHistory,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                MultiSliver(
                  children: [
                    // Filter Chips
                    SliverToBoxAdapter(
                      child: _buildFilterChips(context, ref, selectedFilter),
                    ),

                    // Payment List
                    paymentsAsync.when(
                      data: (payments) {
                        final filteredPayments = ref.watch(
                          filteredRiderPaymentsProvider(payments),
                        );

                        if (filteredPayments.isEmpty) {
                          return SliverFillRemaining(
                            child: _buildEmptyState(context),
                          );
                        }

                        // Constrain + center the overview and transaction
                        // cards so they don't stretch edge-to-edge as a single
                        // wide column on iPad / large screens.
                        return SliverCrossAxisConstrained(
                          maxCrossAxisExtent: kMaxWidthContent.w,
                          child: MultiSliver(
                            children: [
                              SliverToBoxAdapter(
                                child: _buildOverviewSection(
                                  context,
                                  payments,
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildPaymentCard(
                                    context,
                                    ref,
                                    filteredPayments[index],
                                    index,
                                  ),
                                  childCount: filteredPayments.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: _buildLoadingSliver,
                      error: (error, stack) => SliverFillRemaining(
                        child: _buildErrorState(context, ref, userId, error),
                      ),
                    ),

                    // Bottom Padding
                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingScaffold(context, selectedFilter),
      error: (error, stack) => AdaptiveScaffold(
        body: Center(
          child: Text(PaymentErrorHandler.humanize(error)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).yourTransactions,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context, String selectedFilter) {
    return AdaptiveScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.h,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(context)),
            title: Text(
              AppLocalizations.of(context).paymentHistory,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: _buildFilterChips(context, null, selectedFilter),
              ),
              _buildLoadingSliver(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverToBoxAdapter(
      child: SkeletonLoader(itemCount: 5),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef? ref,
    String selectedFilter,
  ) {
    final padding = adaptiveScreenPadding(context);
    final chips = _filterKeys.map((key) {
      final isSelected = selectedFilter == key;
      return FilterChip(
        label: Text(
          _filterLabel(context, key),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
        selected: isSelected,
        onSelected: ref == null
            ? null
            : (_) => ref
                  .read(paymentHistoryFilterViewModelProvider.notifier)
                  .setFilter(key),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: AppColors.primary,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(padding.left, 16.h, padding.right, 4.h),
      child: context.isExpandedOrLarger
          ? Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: chips,
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.w),
                    chips[i],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    List<PaymentTransaction> payments,
  ) {
    final summary = _buildSpendingSummary(context, payments);
    if (!context.isExpandedOrLarger) {
      return summary;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: summary),
          SizedBox(width: 16.w),
          Expanded(
            flex: 5,
            child: _buildStatusOverviewCard(context, payments),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSummary(
    BuildContext context,
    List<PaymentTransaction> payments,
  ) {
    final completedPayments = payments
        .where((p) => p.status == PaymentStatus.succeeded)
        .toList();
    if (completedPayments.isEmpty) return const SizedBox.shrink();

    final totalInCents = completedPayments.fold<int>(
      0,
      (sum, p) => sum + p.amountInCents,
    );

    return Container(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 16.h, top: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  AppLocalizations.of(context).totalSpent,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocaleFormatters.formatCurrencyFromCents(
                    context,
                    totalInCents,
                  ),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 44.h,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context).rides,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${completedPayments.length}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildStatusOverviewCard(
    BuildContext context,
    List<PaymentTransaction> payments,
  ) {
    final pendingCount = payments
        .where(
          (payment) =>
              payment.status == PaymentStatus.pending ||
              payment.status == PaymentStatus.processing ||
              payment.status == PaymentStatus.refunding,
        )
        .length;
    final refundedCount = payments
        .where(
          (payment) =>
              payment.status == PaymentStatus.refunded ||
              payment.status == PaymentStatus.partiallyRefunded,
        )
        .length;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).paymentHistory,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            AppLocalizations.of(context).yourTransactions,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetric(
                  context,
                  label: AppLocalizations.of(context).filterAll,
                  value: payments.length.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewMetric(
                  context,
                  label: AppLocalizations.of(context).statusPending,
                  value: pendingCount.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewMetric(
                  context,
                  label: AppLocalizations.of(context).statusRefunded,
                  value: refundedCount.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.05);
  }

  Widget _buildOverviewMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).noPaymentsFound,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).yourPaymentHistoryWillAppear,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              PaymentErrorHandler.humanize(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: () =>
                  ref.invalidate(riderPaymentHistoryStreamProvider(userId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).tryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    PaymentTransaction payment,
    int index,
  ) {
    final card = Dismissible(
      key: ValueKey('payment_${payment.id}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        unawaited(HapticFeedback.mediumImpact());
        _showPaymentDetails(context, ref, payment);
        return false;
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).details,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showPaymentDetails(context, ref, payment),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Status Icon
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      payment.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getStatusIcon(payment.status),
                    color: _getStatusColor(payment.status),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Payment Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).ridePayment,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        payment.createdAt != null
                            ? AppLocaleFormatters.formatMediumDateTime(
                                context,
                                payment.createdAt!,
                              )
                            : AppLocalizations.of(context).unknownDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            payment.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _getStatusText(context, payment.status),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(payment.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocaleFormatters.formatCurrencyFromCents(
                        context,
                        payment.amountInCents,
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (payment.seatsBooked != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).seatsCount(payment.seatsBooked!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return card
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 50))
        .slideX(begin: 0.1);
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.succeeded:
        return AppColors.success;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
      case PaymentStatus.refunding:
        return AppColors.warning;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
      case PaymentStatus.refundFailed:
        return AppColors.error;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.succeeded:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
      case PaymentStatus.refunding:
        return Icons.schedule_rounded;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
      case PaymentStatus.refundFailed:
        return Icons.cancel_rounded;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return Icons.refresh_rounded;
    }
  }

  String _getStatusText(BuildContext context, PaymentStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case PaymentStatus.succeeded:
        return l10n.statusCompleted;
      case PaymentStatus.pending:
        return l10n.statusPending;
      case PaymentStatus.processing:
        return l10n.statusProcessing;
      case PaymentStatus.refunding:
        return l10n.statusProcessing;
      case PaymentStatus.failed:
        return l10n.statusFailed;
      case PaymentStatus.cancelled:
        return l10n.statusCancelled;
      case PaymentStatus.refunded:
        return l10n.statusRefunded;
      case PaymentStatus.partiallyRefunded:
        return l10n.statusPartiallyRefunded;
      case PaymentStatus.refundFailed:
        return l10n.statusFailed;
    }
  }

  void _showPaymentDetails(
    BuildContext context,
    WidgetRef ref,
    PaymentTransaction payment,
  ) {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).paymentDetails,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Amount hero ──────────────────────────────────────────
            _buildAmountHero(context, payment),
            SizedBox(height: 24.h),

            // ── Payment breakdown ────────────────────────────────────
            _buildSectionLabel(AppLocalizations.of(context).paymentBreakdown),
            SizedBox(height: 10.h),
            _buildGroupCard([
              _buildDetailRow(
                AppLocalizations.of(context).baseFare,
                AppLocaleFormatters.formatCurrencyFromCents(
                  context,
                  payment.amountInCents -
                      payment.platformFeeInCents -
                      payment.stripeFeeInCents,
                ),
              ),
              _buildDetailRow(
                AppLocalizations.of(context).platformFee,
                AppLocaleFormatters.formatCurrencyFromCents(
                  context,
                  payment.platformFeeInCents,
                ),
              ),
              if (payment.stripeFeeInCents > 0)
                _buildDetailRow(
                  AppLocalizations.of(context).processingFee,
                  AppLocaleFormatters.formatCurrencyFromCents(
                    context,
                    payment.stripeFeeInCents,
                  ),
                ),
              _buildDivider(),
              _buildDetailRow(
                AppLocalizations.of(context).totalPaid,
                AppLocaleFormatters.formatCurrencyFromCents(
                  context,
                  payment.amountInCents,
                ),
                bold: true,
              ),
            ]),
            SizedBox(height: 20.h),

            // ── Trip details ─────────────────────────────────────────
            _buildSectionLabel(AppLocalizations.of(context).tripDetails),
            SizedBox(height: 10.h),
            _buildGroupCard([
              _buildDetailRow(
                AppLocalizations.of(context).driver,
                payment.driverName,
              ),
              if (payment.seatsBooked != null)
                _buildDetailRow(
                  AppLocalizations.of(context).seats2,
                  AppLocalizations.of(context).value2(payment.seatsBooked!),
                ),
              if (payment.createdAt != null)
                _buildDetailRow(
                  AppLocalizations.of(context).date,
                  AppLocaleFormatters.formatMediumDateTime(
                    context,
                    payment.createdAt!,
                  ),
                ),
              if (payment.paymentMethodLast4 != null)
                _buildDetailRow(
                  AppLocalizations.of(context).card,
                  AppLocalizations.of(
                    context,
                  ).value7(payment.paymentMethodLast4!),
                ),
              if (payment.stripePaymentIntentId != null)
                _buildDetailRow(
                  AppLocalizations.of(context).transactionId,
                  '${payment.stripePaymentIntentId!.substring(0, math.min(20, payment.stripePaymentIntentId!.length))}…',
                ),
              if (payment.failureReason != null &&
                  payment.failureReason!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context).failureReason,
                  payment.failureReason!,
                  valueColor: AppColors.error,
                ),
              if (payment.refundReason != null &&
                  payment.refundReason!.isNotEmpty)
                _buildDetailRow(
                  AppLocalizations.of(context).refundReason,
                  payment.refundReason!,
                  valueColor: AppColors.info,
                ),
            ]),
            SizedBox(height: 28.h),

            // ── Actions ──────────────────────────────────────────────
            if (payment.status == PaymentStatus.succeeded) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => PaymentReceiptGenerator.showReceipt(
                    context,
                    receiptId: payment.id,
                    riderName: payment.riderName.isNotEmpty
                        ? payment.riderName
                        : AppLocalizations.of(context).rider,
                    driverName: payment.driverName,
                    // PaymentTransaction has no human-facing trip
                    // origin/destination (rideId is an opaque doc id), so leave
                    // both blank rather than printing the raw id as the origin.
                    origin: '',
                    destination: '',
                    rideDate: payment.createdAt ?? DateTime.now(),
                    baseFare:
                        payment.amountInCents -
                        payment.platformFeeInCents -
                        payment.stripeFeeInCents,
                    serviceFeeInCents: payment.platformFeeInCents,
                    totalInCents: payment.amountInCents,
                  ),
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: Text(AppLocalizations.of(context).downloadReceipt),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
            if (payment.canRequestRefund)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => RefundRequestSheet.show(
                    context,
                    rideId: payment.rideId,
                    paidAmount: payment.amountInCents,
                    onSubmit: (request) async {
                      await ref
                          .read(paymentViewModelProvider.notifier)
                          .requestBookingRefund(
                            paymentId: payment.id,
                            reason: request.reason.name,
                            details: request.details,
                          );
                      if (!context.mounted) return;
                      Navigator.of(context).pop(); // close refund sheet
                      if (!context.mounted) return;
                      context.pop(); // close detail sheet
                      AdaptiveSnackBar.show(
                        context,
                        message: AppLocalizations.of(
                          context,
                        ).refundRequestSubmitted,
                        type: AdaptiveSnackBarType.success,
                      );
                    },
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(AppLocalizations.of(context).requestRefund),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHero(BuildContext context, PaymentTransaction payment) {
    final statusColor = _getStatusColor(payment.status);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocaleFormatters.formatCurrencyFromCents(
                    context,
                    payment.amountInCents,
                  ),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(payment.status),
                        size: 13.sp,
                        color: statusColor,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        _getStatusText(context, payment.status),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (payment.createdAt != null)
            Text(
              AppLocaleFormatters.formatMediumDate(
                context,
                payment.createdAt!,
              ).replaceFirst(', ', '\n'),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return KeyValueRow(
      label: label,
      value: value,
      bold: bold,
      valueColor: valueColor,
      horizontalPadding: 16.w,
      verticalPadding: 12.h,
    );
  }
}
