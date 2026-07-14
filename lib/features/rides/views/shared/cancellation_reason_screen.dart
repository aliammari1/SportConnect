import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

/// Cancellation reason selection screen.
///
/// Shows selectable reasons for ride cancellation with:
/// - Pre-defined reason chips
/// - Optional comment field
/// - Cancellation policy warning
/// - Confirmation dialog
class CancellationReasonScreen extends ConsumerWidget {
  const CancellationReasonScreen({
    required this.rideId,
    super.key,
    this.isDriver = false,
  });
  final String rideId;
  final bool isDriver;

  List<_CancelReason> get _reasons => isDriver ? _driverReasons : _riderReasons;

  static const _riderReasons = [
    _CancelReason(
      _CancelReasonId.riderChangeOfPlans,
      Icons.event_busy_rounded,
    ),
    _CancelReason(
      _CancelReasonId.riderFoundAnotherRide,
      Icons.swap_horiz_rounded,
    ),
    _CancelReason(
      _CancelReasonId.riderPriceTooHigh,
      Icons.money_off_rounded,
    ),
    _CancelReason(
      _CancelReasonId.riderSafetyConcern,
      Icons.shield_outlined,
    ),
    _CancelReason(
      _CancelReasonId.riderDriverNotResponding,
      Icons.chat_bubble_outline_rounded,
    ),
    _CancelReason(
      _CancelReasonId.riderIncorrectDetails,
      Icons.error_outline_rounded,
    ),
    _CancelReason(
      _CancelReasonId.riderEmergency,
      Icons.emergency_rounded,
    ),
    _CancelReason(_CancelReasonId.other, null),
  ];

  static const _driverReasons = [
    _CancelReason(
      _CancelReasonId.driverVehicleIssue,
      Icons.car_repair_rounded,
    ),
    _CancelReason(
      _CancelReasonId.driverPassengerNotAtPickup,
      Icons.person_off_rounded,
    ),
    _CancelReason(
      _CancelReasonId.driverChangeOfPlans,
      Icons.event_busy_rounded,
    ),
    _CancelReason(
      _CancelReasonId.driverSafetyConcern,
      Icons.shield_outlined,
    ),
    _CancelReason(
      _CancelReasonId.driverPassengerNotResponding,
      Icons.chat_bubble_outline_rounded,
    ),
    _CancelReason(
      _CancelReasonId.driverRouteIssue,
      Icons.wrong_location_rounded,
    ),
    _CancelReason(
      _CancelReasonId.driverEmergency,
      Icons.emergency_rounded,
    ),
    _CancelReason(_CancelReasonId.other, null),
  ];

  Future<void> _submitCancellation(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmationDialog(context);
    if (confirmed != true) {
      return;
    }
    if (!context.mounted) return;
    await ref
        .read(cancellationReasonViewModelProvider(rideId).notifier)
        .submit();
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).cancelRide2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              ).are_you_sure_you_want_to_cancel_this_ride,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                AppLocalizations.of(
                  context,
                ).frequent_cancellations_may_affect_your_account_rating,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.warningDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).actionClose),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).cancelRide2),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formState = ref.watch(cancellationReasonViewModelProvider(rideId));

    ref.listen<CancellationReasonState>(
      cancellationReasonViewModelProvider(rideId),
      (previous, next) {
        if (next.validationMessage != null &&
            next.validationMessage != previous?.validationMessage) {
          AdaptiveSnackBar.show(
            context,
            message: next.validationMessage!,
            type: AdaptiveSnackBarType.warning,
          );
        }

        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage!,
            type: AdaptiveSnackBarType.error,
          );
        }

        if (next.isSubmitted && previous?.isSubmitted != true) {
          unawaited(HapticFeedback.mediumImpact());
          // Tell the user what actually happens to affected passengers' money
          // instead of a generic "cancelled successfully" that says nothing
          // about it. This screen only ever cancels the WHOLE ride
          // (RideActionsViewModel.cancelRide → onRideCancelled in
          // functions/src/index.ts), which — unlike the simpler per-booking
          // onBookingCancelled rule — issues a PARTIAL refund (driver's
          // share, platform fee retained) rather than none at all when the
          // ride had already started, so the copy reflects that distinction.
          AdaptiveSnackBar.show(
            context,
            message: next.wasInProgress
                ? l10n.rideCancelledPartialRefundPending
                : l10n.rideCancelledFullRefundPending,
            type: AdaptiveSnackBarType.success,
          );
          context.pop(true);
        }
      },
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.cancelRide2,
        leading: IconButton(
          tooltip: AppLocalizations.of(context).goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // Warning banner
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).cancellationReasonBannerMessage,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 24.h),

              Text(
                AppLocalizations.of(context).select_a_reason,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 100.ms),

              SizedBox(height: 16.h),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isTabletLayout =
                      constraints.maxWidth >= Breakpoints.compact;
                  final spacing = 12.w;
                  final itemWidth = isTabletLayout
                      ? (constraints.maxWidth - spacing) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 10.h,
                    children: List.generate(_reasons.length, (index) {
                      final reason = _reasons[index];
                      final title = reason.title(l10n);
                      final isSelected = formState.selectedReason == title;
                      return SizedBox(
                        width: itemWidth,
                        child:
                            _buildReasonCard(
                                  context,
                                  reason,
                                  isSelected,
                                  () => ref
                                      .read(
                                        cancellationReasonViewModelProvider(
                                          rideId,
                                        ).notifier,
                                      )
                                      .selectReason(title),
                                )
                                .animate()
                                .fadeIn(
                                  delay: Duration(
                                    milliseconds: 150 + (index * 50),
                                  ),
                                )
                                .slideX(begin: 0.05),
                      );
                    }),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // Additional comments
              Text(
                AppLocalizations.of(context).additional_comments_optional,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 600.ms),

              SizedBox(height: 8.h),

              TextField(
                onChanged: (value) => ref
                    .read(cancellationReasonViewModelProvider(rideId).notifier)
                    .updateComment(value),
                maxLines: 3,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).cancellationReasonHint,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  counterStyle: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms),

              SizedBox(height: 32.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: AppLocalizations.of(context).cancelRide2,
                  onPressed: formState.isSubmitting
                      ? null
                      : () => _submitCancellation(context, ref),
                  isLoading: formState.isSubmitting,
                  icon: Icons.cancel_rounded,
                  style: PremiumButtonStyle.danger,
                ),
              ).animate().fadeIn(delay: 700.ms),

              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: AppLocalizations.of(context).keepRide,
                  onPressed: () => context.pop(false),
                  style: PremiumButtonStyle.ghost,
                  icon: Icons.adaptive.arrow_back_rounded,
                ),
              ).animate().fadeIn(delay: 750.ms),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonCard(
    BuildContext context,
    _CancelReason reason,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                reason.icon,
                size: 20.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.title(l10n),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    reason.description(l10n),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

enum _CancelReasonId {
  riderChangeOfPlans,
  riderFoundAnotherRide,
  riderPriceTooHigh,
  riderSafetyConcern,
  riderDriverNotResponding,
  riderIncorrectDetails,
  riderEmergency,
  driverVehicleIssue,
  driverPassengerNotAtPickup,
  driverChangeOfPlans,
  driverSafetyConcern,
  driverPassengerNotResponding,
  driverRouteIssue,
  driverEmergency,
  other,
}

class _CancelReason {
  const _CancelReason(this.id, this._staticIcon);

  final _CancelReasonId id;
  final IconData? _staticIcon;

  String title(AppLocalizations l10n) => switch (id) {
    _CancelReasonId.riderChangeOfPlans => l10n.cancelReasonChangeOfPlansTitle,
    _CancelReasonId.riderFoundAnotherRide =>
      l10n.cancelReasonFoundAnotherRideTitle,
    _CancelReasonId.riderPriceTooHigh => l10n.cancelReasonPriceTooHighTitle,
    _CancelReasonId.riderSafetyConcern => l10n.cancelReasonSafetyConcernTitle,
    _CancelReasonId.riderDriverNotResponding =>
      l10n.cancelReasonDriverNotRespondingTitle,
    _CancelReasonId.riderIncorrectDetails =>
      l10n.cancelReasonIncorrectDetailsTitle,
    _CancelReasonId.riderEmergency => l10n.cancelReasonEmergencyTitle,
    _CancelReasonId.driverVehicleIssue => l10n.cancelReasonVehicleIssueTitle,
    _CancelReasonId.driverPassengerNotAtPickup =>
      l10n.cancelReasonPassengerNotAtPickupTitle,
    _CancelReasonId.driverChangeOfPlans => l10n.cancelReasonChangeOfPlansTitle,
    _CancelReasonId.driverSafetyConcern => l10n.cancelReasonSafetyConcernTitle,
    _CancelReasonId.driverPassengerNotResponding =>
      l10n.cancelReasonPassengerNotRespondingTitle,
    _CancelReasonId.driverRouteIssue => l10n.cancelReasonRouteIssueTitle,
    _CancelReasonId.driverEmergency => l10n.cancelReasonEmergencyTitle,
    _CancelReasonId.other => l10n.cancelReasonOtherTitle,
  };

  String description(AppLocalizations l10n) => switch (id) {
    _CancelReasonId.riderChangeOfPlans =>
      l10n.cancelReasonChangeOfPlansDescription,
    _CancelReasonId.riderFoundAnotherRide =>
      l10n.cancelReasonFoundAnotherRideDescription,
    _CancelReasonId.riderPriceTooHigh =>
      l10n.cancelReasonPriceTooHighDescription,
    _CancelReasonId.riderSafetyConcern =>
      l10n.cancelReasonSafetyConcernDescription,
    _CancelReasonId.riderDriverNotResponding =>
      l10n.cancelReasonDriverNotRespondingDescription,
    _CancelReasonId.riderIncorrectDetails =>
      l10n.cancelReasonIncorrectDetailsDescription,
    _CancelReasonId.riderEmergency => l10n.cancelReasonEmergencyDescription,
    _CancelReasonId.driverVehicleIssue =>
      l10n.cancelReasonVehicleIssueDescription,
    _CancelReasonId.driverPassengerNotAtPickup =>
      l10n.cancelReasonPassengerNotAtPickupDescription,
    _CancelReasonId.driverChangeOfPlans =>
      l10n.cancelReasonChangeOfPlansDescription,
    _CancelReasonId.driverSafetyConcern =>
      l10n.cancelReasonSafetyConcernDescription,
    _CancelReasonId.driverPassengerNotResponding =>
      l10n.cancelReasonPassengerNotRespondingDescription,
    _CancelReasonId.driverRouteIssue => l10n.cancelReasonRouteIssueDescription,
    _CancelReasonId.driverEmergency => l10n.cancelReasonEmergencyDescription,
    _CancelReasonId.other => l10n.cancelReasonOtherDescription,
  };

  // This handles the runtime platform check
  IconData get icon {
    if (id == _CancelReasonId.other) {
      return Icons.adaptive.more_rounded;
    }
    return _staticIcon ?? Icons.help_outline_rounded;
  }
}
