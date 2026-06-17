import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';
import 'package:sport_connect/core/utils/payment_error_handler.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/icon_label_chip.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class PayoutDetailScreen extends ConsumerStatefulWidget {
  const PayoutDetailScreen({required this.payoutId, super.key});

  final String payoutId;

  @override
  ConsumerState<PayoutDetailScreen> createState() => _PayoutDetailScreenState();
}

class _PayoutDetailScreenState extends ConsumerState<PayoutDetailScreen> {
  bool _cancelling = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final payoutAsync = ref.watch(payoutDetailProvider(widget.payoutId));

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.payoutDetails,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: payoutAsync.when(
        loading: () => const Padding(
          padding: const EdgeInsets.all(20),
          child: SkeletonLoader(),
        ),
        error: (e, _) => _ErrorView(
          message: PaymentErrorHandler.humanize(e),
          onRetry: () => ref.invalidate(payoutDetailProvider(widget.payoutId)),
        ),
        data: (payout) => payout == null
            ? _NotFoundView(l10n: l10n)
            : _PayoutContent(
                payout: payout,
                payoutId: widget.payoutId,
                cancelling: _cancelling,
                onCancel: () => _confirmCancel(context, l10n, payout),
              ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppLocalizations l10n,
    DriverPayout payout,
  ) async {
    if (payout.stripePayoutId == null) {
      AdaptiveSnackBar.show(
        context,
        message: l10n.this_payout_cannot_be_cancelled_no_stripe_reference_found,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.cancelPayout),
        content: Text(l10n.cancelPayoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    setState(() => _cancelling = true);

    try {
      final success = await ref
          .read(driverPayoutViewModelProvider.notifier)
          .cancelPayout(
            payout.id,
            stripePayoutId: payout.stripePayoutId!,
          );

      if (!context.mounted) return;

      if (success) {
        ref.invalidate(payoutDetailProvider(widget.payoutId));
        AdaptiveSnackBar.show(
          context,
          message: l10n.payoutCancelled,
          type: AdaptiveSnackBarType.success,
        );
      } else {
        final error = ref.read(driverPayoutViewModelProvider).error;
        AdaptiveSnackBar.show(
          context,
          message: error != null
              ? PaymentErrorHandler.humanize(error)
              : l10n.payoutCancelFailed,
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
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }
}

// ─── Content ─────────────────────────────────────────────────────────────────

class _PayoutContent extends StatelessWidget {
  const _PayoutContent({
    required this.payout,
    required this.payoutId,
    required this.cancelling,
    required this.onCancel,
  });

  final DriverPayout payout;
  final String payoutId;
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTabletLayout = context.screenWidth >= Breakpoints.medium;

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AmountCard(
          payout: payout,
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
        SizedBox(height: 20.h),
        _PayoutTimeline(
          status: payout.status,
          payout: payout,
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.05),
      ],
    );

    final detailContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (payout.failureReason != null) ...[
          _FailureBanner(
            reason: payout.failureReason!,
          ).animate().fadeIn(delay: 150.ms).shakeX(hz: 2, amount: 3),
          SizedBox(height: 20.h),
        ],
        _DetailsCard(
          payout: payout,
        ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.05),
        if (payout.isPending) ...[
          SizedBox(height: 24.h),
          Text(
            l10n.instant_payouts_can_be_cancelled_while_still_pending_once_in_transit_your_bank_is_already_processing_the_transfer,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          _CancelButton(
            cancelling: cancelling,
            onCancel: onCancel,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ],
    );

    return RefreshIndicator.adaptive(
      onRefresh: () async => ProviderScope.containerOf(context).invalidate(
        payoutDetailProvider(payoutId),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
        child: isTabletLayout
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: mainContent),
                      SizedBox(width: 24.w),
                      Expanded(flex: 5, child: detailContent),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mainContent,
                  SizedBox(height: 20.h),
                  detailContent,
                ],
              ),
      ),
    );
  }
}

// ─── Amount Card ──────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.payout});
  final DriverPayout payout;

  Color get _gradientStart => switch (payout.status) {
    PayoutStatus.paid => AppColors.success,
    PayoutStatus.failed => AppColors.error,
    PayoutStatus.cancelled => AppColors.textSecondary,
    PayoutStatus.inTransit || PayoutStatus.pending => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _gradientStart,
            _gradientStart.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.payoutAmount,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            CurrencyFormatter.fromCents(payout.amountInCents),
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (payout.isInstantPayout)
                IconLabelChip(
                  icon: Icons.bolt_rounded,
                  label: l10n.instantPayout,
                  background: Colors.white.withValues(alpha: 0.2),
                  foreground: Colors.white,
                  borderRadius: 20,
                  bordered: false,
                  iconSize: 13,
                  gap: 5,
                  fontWeight: FontWeight.w600,
                  horizontalPadding: 12,
                  verticalPadding: 5,
                ),
              if (payout.isInstantPayout) SizedBox(width: 8.w),
              IconLabelChip(
                icon: _statusIcon(payout.status),
                label: _statusLabel(l10n, payout.status),
                background: Colors.white.withValues(alpha: 0.2),
                foreground: Colors.white,
                borderRadius: 20,
                bordered: false,
                iconSize: 13,
                gap: 5,
                fontWeight: FontWeight.w600,
                horizontalPadding: 12,
                verticalPadding: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(PayoutStatus s) => switch (s) {
    PayoutStatus.paid => Icons.check_circle_rounded,
    PayoutStatus.failed => Icons.error_rounded,
    PayoutStatus.cancelled => Icons.cancel_rounded,
    PayoutStatus.inTransit => Icons.local_shipping_rounded,
    PayoutStatus.pending => Icons.schedule_rounded,
  };

  String _statusLabel(AppLocalizations l, PayoutStatus s) => switch (s) {
    PayoutStatus.paid => l.payoutPaid,
    PayoutStatus.failed => l.statusFailed,
    PayoutStatus.cancelled => l.statusCancelled,
    PayoutStatus.inTransit => l.payoutInTransit,
    PayoutStatus.pending => l.statusPending,
  };
}

// ─── Timeline ─────────────────────────────────────────────────────────────────

class _PayoutTimeline extends StatelessWidget {
  const _PayoutTimeline({required this.status, required this.payout});
  final PayoutStatus status;
  final DriverPayout payout;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: switch (status) {
                    PayoutStatus.paid => AppColors.success,
                    PayoutStatus.failed => AppColors.error,
                    PayoutStatus.cancelled => AppColors.textSecondary,
                    PayoutStatus.inTransit ||
                    PayoutStatus.pending => AppColors.primary,
                  },
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                l10n.payout_progress,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return _TimelineStep(
              step: step,
              isLast: isLast,
              animDelay: 100 * i,
            );
          }),
        ],
      ),
    );
  }

  List<_StepData> _buildSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_jm();

    final isFailed = status == PayoutStatus.failed;
    final isCancelled = status == PayoutStatus.cancelled;
    final isInTransit =
        status == PayoutStatus.inTransit || status == PayoutStatus.paid;
    final isPaid = status == PayoutStatus.paid;

    return [
      _StepData(
        title: l10n.payout_requested,
        subtitle: payout.createdAt != null
            ? fmt.format(payout.createdAt!)
            : l10n.payoutStepInitiated,
        state: _StepState.done,
        icon: Icons.send_rounded,
      ),
      _StepData(
        title: l10n.processing,
        subtitle: isFailed
            ? l10n.payoutStepCouldNotComplete
            : isCancelled
            ? l10n.statusCancelled
            : l10n.payoutStepPreparingTransfer,
        state: isFailed || isCancelled ? _StepState.failed : _StepState.done,
        icon: isFailed || isCancelled
            ? Icons.close_rounded
            : Icons.autorenew_rounded,
      ),
      _StepData(
        title: l10n.in_transit_to_bank,
        subtitle: isInTransit
            ? (payout.expectedArrivalDate != null
                  ? l10n.payoutStepExpected(
                      fmt.format(payout.expectedArrivalDate!),
                    )
                  : l10n.payoutStepOnItsWayToYourBank)
            : isFailed || isCancelled
            ? '—'
            : l10n.payoutStepWaitingForProcessing,
        state: isPaid
            ? _StepState.done
            : isInTransit
            ? _StepState.active
            : isFailed || isCancelled
            ? _StepState.skipped
            : _StepState.waiting,
        icon: Icons.account_balance_rounded,
      ),
      _StepData(
        title: l10n.funds_arrived,
        subtitle: isPaid && payout.arrivedAt != null
            ? fmt.format(payout.arrivedAt!)
            : isPaid
            ? l10n.payoutStepDepositedToYourAccount
            : '—',
        state: isPaid ? _StepState.done : _StepState.waiting,
        icon: Icons.check_circle_rounded,
      ),
    ];
  }
}

enum _StepState { done, active, waiting, failed, skipped }

class _StepData {
  const _StepData({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final _StepState state;
  final IconData icon;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.animDelay,
  });
  final _StepData step;
  final bool isLast;
  final int animDelay;

  Color get _color => switch (step.state) {
    _StepState.done => AppColors.success,
    _StepState.active => AppColors.primary,
    _StepState.failed => AppColors.error,
    _StepState.waiting => AppColors.border,
    _StepState.skipped => AppColors.border,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + connector line
            Column(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color:
                        step.state == _StepState.waiting ||
                            step.state == _StepState.skipped
                        ? AppColors.border.withValues(alpha: 0.4)
                        : _color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color, width: 2),
                  ),
                  child: step.state == _StepState.active
                      ? Padding(
                          padding: EdgeInsets.all(8.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(_color),
                          ),
                        )
                      : Icon(
                          step.icon,
                          size: 16.sp,
                          color:
                              step.state == _StepState.waiting ||
                                  step.state == _StepState.skipped
                              ? AppColors.textTertiary
                              : _color,
                        ),
                ),
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 32.h,
                    color: _color.withValues(alpha: 0.3),
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 6.h, bottom: isLast ? 0 : 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            step.state == _StepState.waiting ||
                                step.state == _StepState.skipped
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay))
        .slideX(begin: 0.05);
  }
}

// ─── Failure Banner ───────────────────────────────────────────────────────────

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).why_did_this_fail,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  PaymentErrorHandler.humanize(reason),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.error.withValues(alpha: 0.85),
                    height: 1.4,
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

// ─── Details Card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.payout});
  final DriverPayout payout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();

    final rows = <({String label, String value})>[
      if (payout.createdAt != null)
        (label: l10n.date, value: fmt.format(payout.createdAt!)),
      if (payout.expectedArrivalDate != null)
        (
          label: l10n.expectedArrival,
          value: fmt.format(payout.expectedArrivalDate!),
        ),
      if (payout.arrivedAt != null)
        (label: l10n.arrivedAt, value: fmt.format(payout.arrivedAt!)),
      (
        label: l10n.method,
        value: payout.method == PayoutMethod.instant
            ? l10n.payoutMethodInstantDescription
            : l10n.payoutMethodStandardDescription,
      ),
      if (payout.destination != null)
        (
          label: l10n.payoutDestinationLabel,
          value:
              '••••  ${payout.destination!.length > 4 ? payout.destination!.substring(payout.destination!.length - 4) : payout.destination!}',
        ),
      if (payout.stripePayoutId != null)
        (
          label: l10n.transactionId,
          value: payout.stripePayoutId!.length > 24
              ? '${payout.stripePayoutId!.substring(0, 24)}…'
              : payout.stripePayoutId!,
        ),
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payoutDetailsSection,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...rows.map(
            (r) => Padding(
              padding: EdgeInsets.symmetric(vertical: 9.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130.w,
                    child: Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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

// ─── Cancel Button ────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.cancelling, required this.onCancel});
  final bool cancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: cancelling ? null : onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          foregroundColor: AppColors.error,
          disabledBackgroundColor: AppColors.error.withValues(alpha: 0.05),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
          ),
        ),
        child: cancelling
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.error),
                ),
              )
            : Text(
                l10n.cancelPayout,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ─── Error / Not Found ────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.payoutNotFound,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
