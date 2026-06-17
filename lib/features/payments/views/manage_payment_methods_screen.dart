import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/features/payments/view_models/customer_sheet_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class ManagePaymentMethodsScreen extends ConsumerWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(customerSheetViewModelProvider);
    final viewModel = ref.read(customerSheetViewModelProvider.notifier);

    ref.listen(customerSheetViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        AdaptiveSnackBar.show(
          context,
          message: next.errorMessage!,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 22.sp,
          ),
        ),
        title: l10n.settingsPaymentMethods,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.managePaymentMethodsDesc,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Selected payment method display
              if (state.selectedPaymentOption != null) ...[
                Text(
                  l10n.selectedPaymentMethod,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                _SelectedMethodCard(result: state.selectedPaymentOption),
                SizedBox(height: 24.h),
              ],

              // Manage button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : viewModel.presentCustomerSheet,
                  icon: state.isLoading
                      ? SizedBox(
                          width: 18.sp,
                          height: 18.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.credit_card, size: 20.sp),
                  label: Text(
                    state.selectedPaymentOption != null
                        ? l10n.changePaymentMethod
                        : l10n.addPaymentMethod,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
      ),
    );
  }
}

class _SelectedMethodCard extends StatelessWidget {
  const _SelectedMethodCard({required this.result});

  final CustomerSheetResult? result;

  @override
  Widget build(BuildContext context) {
    // Show the actual selected payment option's label (e.g. "Visa ····4242")
    // instead of a generic message, so the user can see which card is selected.
    final label = result?.paymentOption?.label;
    final displayLabel = (label != null && label.isNotEmpty)
        ? label
        : AppLocalizations.of(context).selectedPaymentMethod;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              displayLabel,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
