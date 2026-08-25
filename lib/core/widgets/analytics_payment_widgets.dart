import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Monthly ride summary card (#92)
class MonthlyRideSummary extends StatelessWidget {
  const MonthlyRideSummary({
    required this.totalRides,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalDistance,
    required this.month,
    super.key,
  });
  final int totalRides;
  final double totalSpent;
  final double totalEarned;
  final double totalDistance;
  final String month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$totalRides ${l10n.rides}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _summaryTile(
                l10n.totalSpent,
                l10n.value5(totalSpent.toStringAsFixed(2)),
                Icons.arrow_upward_rounded,
              ),
              SizedBox(width: 8.w),
              _summaryTile(
                l10n.earned,
                l10n.value5(totalEarned.toStringAsFixed(2)),
                Icons.arrow_downward_rounded,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_rounded, size: 16.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  l10n.distanceKmValue(totalDistance.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: Colors.white70),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyCost {
  const MonthlyCost(this.label, this.amountInCents);
  final String label;
  final int amountInCents;
}

/// Payment receipt PDF generator (#99)
class PaymentReceiptGenerator {
  static Future<Uint8List> generate({
    required BuildContext context,
    required String receiptId,
    required String riderName,
    required String driverName,
    required String origin,
    required String destination,
    required DateTime rideDate,
    required int baseFare,
    required int serviceFeeInCents,
    required int totalInCents,
  }) async {
    final l10n = AppLocalizations.of(context);
    final pdf = pw.Document();
    final dateStr = AppLocaleFormatters.formatShortWeekdayDateTime(
      context,
      rideDate,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SportConnect',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    l10n.payment_receipt,
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${l10n.receiptNumberLabel} $receiptId',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),
              _pdfRow(l10n.dateLabel, dateStr),
              _pdfRow(l10n.rider, riderName),
              _pdfRow(l10n.driver, driverName),
              pw.SizedBox(height: 12),
              _pdfRow(l10n.fromLabel, origin),
              _pdfRow(l10n.toLabel, destination),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              _pdfRow(
                l10n.receiptBaseFare,
                l10n.value5((baseFare / 100).toStringAsFixed(2)),
              ),
              _pdfRow(
                l10n.receiptServiceFee,
                l10n.value5((serviceFeeInCents / 100).toStringAsFixed(2)),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    l10n.totalPaid,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    l10n.value5((totalInCents / 100).toStringAsFixed(2)),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                l10n.thank_you_for_riding_with_sportconnect,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Flexible(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Show print/share dialog
  static Future<void> showReceipt(
    BuildContext context, {
    required String receiptId,
    required String riderName,
    required String driverName,
    required String origin,
    required String destination,
    required DateTime rideDate,
    required int baseFare,
    required int serviceFeeInCents,
    required int totalInCents,
  }) async {
    final bytes = await generate(
      context: context,
      receiptId: receiptId,
      riderName: riderName,
      driverName: driverName,
      origin: origin,
      destination: destination,
      rideDate: rideDate,
      baseFare: baseFare,
      serviceFeeInCents: serviceFeeInCents,
      totalInCents: totalInCents,
    );

    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}

/// Refund request flow (#100)
class RefundRequestSheet extends StatefulWidget {
  const RefundRequestSheet({
    required this.rideId,
    required this.paidAmount,
    required this.onSubmit,
    super.key,
  });

  final String rideId;
  final int paidAmount;
  final Future<void> Function(RefundRequest request) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String rideId,
    required int paidAmount,
    required Future<void> Function(RefundRequest request) onSubmit,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).requestRefund,
      maxHeightFactor: 0.86,
      child: RefundRequestSheet(
        rideId: rideId,
        paidAmount: paidAmount,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<RefundRequestSheet> createState() => _RefundRequestSheetState();
}

class _RefundRequestSheetState extends State<RefundRequestSheet> {
  RefundReason? _reason;
  final _detailsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String? _errorMessage;

  Future<void> _submitRefundRequest() async {
    final selectedReason = _reason;
    if (selectedReason == null || _isSubmitting) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await widget.onSubmit(
        RefundRequest(
          rideId: widget.rideId,
          reason: selectedReason,
          details: _detailsController.text.trim(),
          amountInCents: widget.paidAmount,
        ),
      );
      // caller handles navigation on success
    } catch (e, st) {
      TalkerService.error('Refund request submission failed', e, st);
      if (!mounted) return;
      // A rejected policy check arrives as StripePaymentException carrying
      // the server's user-facing reason ("not eligible because …"). Show it;
      // a generic "try again" would send the user into a retry loop that can
      // never succeed.
      final message = switch (e) {
        final StripePaymentException stripeError when
            stripeError.code == 'failed-precondition' =>
          stripeError.message,
        _ => AppLocalizations.of(context).could_not_submit_refund_please_try_again,
      };
      setState(() {
        _isSubmitting = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amountText = AppLocaleFormatters.formatCurrencyFromCents(
      context,
      widget.paidAmount,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount + timeline banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.undo_rounded,
                    color: AppColors.warningDark,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.refundReviewLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.refundIfEligibleLineOne,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      l10n.refundIfEligibleLineTwo,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 22.h),

          // Section label
          Text(
            AppLocalizations.of(context).reasonForRefund.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.9,
            ),
          ),
          SizedBox(height: 10.h),

          // Reason tiles with icons
          ...RefundReason.automaticValues.map((reason) {
            final selected = reason == _reason;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _reason = reason),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reason.icon,
                        size: 18.sp,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          reason.localizedLabel(context),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 14.h),

          // Details field
          TextFormField(
            controller: _detailsController,
            enabled: !_isSubmitting,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).additionalDetailsOptional,
              alignLabelWithHint: true,
            ),
          ),

          // Inline error
          if (_errorMessage != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 16.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 20.h),

          // Submit
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_reason == null || _isSubmitting)
                  ? null
                  : _submitRefundRequest,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(
                  alpha: 0.38,
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).submitRefundRequest,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RefundReason {
  driverNoShow,
  rideNotAsDescribed,
  unsafeExperience,
  overcharged,
  cancelledByDriver,
  other,
  ;

  static const List<RefundReason> automaticValues = [
    driverNoShow,
    cancelledByDriver,
  ];
}

extension RefundReasonL10n on RefundReason {
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RefundReason.driverNoShow:
        return l10n.refundReasonDriverNoShow;
      case RefundReason.rideNotAsDescribed:
        return l10n.refundReasonRideNotAsDescribed;
      case RefundReason.unsafeExperience:
        return l10n.refundReasonUnsafeExperience;
      case RefundReason.overcharged:
        return l10n.refundReasonOvercharged;
      case RefundReason.cancelledByDriver:
        return l10n.refundReasonCancelledByDriver;
      case RefundReason.other:
        return l10n.refundReasonOther;
    }
  }

  IconData get icon {
    switch (this) {
      case RefundReason.driverNoShow:
        return Icons.person_off_rounded;
      case RefundReason.rideNotAsDescribed:
        return Icons.info_outline_rounded;
      case RefundReason.unsafeExperience:
        return Icons.shield_outlined;
      case RefundReason.overcharged:
        return Icons.payments_outlined;
      case RefundReason.cancelledByDriver:
        return Icons.cancel_outlined;
      case RefundReason.other:
        return Icons.more_horiz_rounded;
    }
  }
}

class RefundRequest {
  const RefundRequest({
    required this.rideId,
    required this.reason,
    required this.details,
    required this.amountInCents,
  });
  final String rideId;
  final RefundReason reason;
  final String details;
  final int amountInCents;
}
