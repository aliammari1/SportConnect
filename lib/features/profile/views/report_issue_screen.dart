import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Report Issue screen for reporting ride problems, safety concerns, or users.
///
/// Features:
/// - Issue type selection (Safety, Payment, Behavior, Technical, Other)
/// - Severity level indicator
/// - Ride reference (optional)
/// - Evidence attachment placeholder
/// - Firebase submission
class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key, this.rideId, this.reportedUserId});
  final String? rideId;
  final String? reportedUserId;

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  void _showFloatingMessage(String message, {required Color backgroundColor}) {
    if (!context.mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
    );
  }

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context);
    final source = await AppModalSheet.show<ImageSource>(
      context: context,
      title: l10n.attach_evidence,
      maxHeightFactor: 0.45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: Text(l10n.chooseFromGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          AdaptiveListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: Text(l10n.takeAPhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );

    if (source == null) return;
    if (!mounted) return;

    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: l10n.permissionCameraPhotosMessage,
    );
    if (!accepted) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: double.infinity,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (picked == null) return;
    if (!mounted) return;

    await ref
        .read(_reportFormProvider.notifier)
        .addAttachment(File(picked.path));
  }

  Future<void> _submitReport() async {
    final user = ref.read(currentUserProvider).value;
    await ref
        .read(_reportFormProvider.notifier)
        .submit(
          reporterId: user?.uid ?? 'anonymous',
          reporterEmail: user?.email ?? '',
        );
  }

  ReportIssueFormArgs get _reportFormArgs => ReportIssueFormArgs(
    rideId: widget.rideId,
    reportedUserId: widget.reportedUserId,
  );

  ReportIssueFormViewModelProvider get _reportFormProvider =>
      reportIssueFormViewModelProvider(_reportFormArgs);

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(_reportFormProvider);

    ref.listen<ReportIssueFormState>(_reportFormProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showFloatingMessage(
          next.errorMessage!,
          backgroundColor: AppColors.error,
        );
      }

      if (next.isSubmitted && previous?.isSubmitted != true) {
        unawaited(HapticFeedback.mediumImpact());
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).reportIssueTitle,
        leading: IconButton(
          tooltip: AppLocalizations.of(context).goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: adaptiveScreenPadding(context),
            child: formState.isSubmitted
                ? _buildSuccessState()
                : _buildFormState(formState),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(ReportIssueFormState formState) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // Ride reference
        if (widget.rideId != null)
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.rideInfoLabel(widget.rideId!),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        // Issue type
        Text(
          l10n.whatHappenedQuestion,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 100.ms),

        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _ReportType.values.asMap().entries.map((entry) {
            final type = entry.value;
            final isSelected = formState.selectedType == type.label;
            return _buildTypeChip(type, isSelected);
          }).toList(),
        ).animate().fadeIn(delay: 200.ms),

        // Inline type error
        if (formState.typeError != null) ...[
          SizedBox(height: 6.h),
          Text(
            formState.typeError!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        SizedBox(height: 24.h),

        // Severity
        Text(
          l10n.howSevereQuestion,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 12.h),

        Row(
          children: _Severity.values.map((sev) {
            final isSelected = formState.severity == sev.name;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  ref.read(_reportFormProvider.notifier).setSeverity(sev.name);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? sev.color.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected ? sev.color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(sev.icon, size: 20.sp, color: sev.color),
                      SizedBox(height: 4.h),
                      Text(
                        sev.localizedLabel(l10n),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? sev.color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 350.ms),

        SizedBox(height: 24.h),

        // Description
        Text(
          l10n.describeIssueLabel,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 8.h),

        TextField(
          onChanged: ref.read(_reportFormProvider.notifier).updateDescription,
          maxLines: 5,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.describeIssuePlaceholder,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textTertiary,
            ),
            errorText: formState.descriptionError,
            filled: true,
            fillColor: AppColors.surface,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ).animate().fadeIn(delay: 450.ms),

        SizedBox(height: 24.h),

        // Evidence attachment
        Text(
          l10n.evidenceOptionalLabel,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 470.ms),

        SizedBox(height: 8.h),

        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32.sp,
                  color: formState.attachedFiles.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
                SizedBox(height: 8.h),
                Text(
                  formState.attachedFiles.isEmpty
                      ? l10n.attachScreenshotsPlaceholder
                      : l10n.filesAttachedCount(
                          formState.attachedFiles.length,
                          ReportIssueFormViewModel.maxAttachments,
                        ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: formState.attachedFiles.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.supportsImagesHint,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 490.ms),

        if (formState.attachedFiles.isNotEmpty) ...[
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: formState.attachedFiles.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        formState.attachedFiles[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(_reportFormProvider.notifier)
                            .removeAttachmentAt(index),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        SizedBox(height: 32.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.submitReportButton,
            onPressed: formState.isSubmitting ? null : _submitReport,
            isLoading: formState.isSubmitting,
            icon: Icons.flag_rounded,
            style: PremiumButtonStyle.danger,
          ),
        ).animate().fadeIn(delay: 500.ms),

        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildTypeChip(_ReportType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        ref.read(_reportFormProvider.notifier).selectType(type.label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? type.color.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16.sp,
              color: isSelected ? type.color : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              type.localizedLabel(AppLocalizations.of(context)),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? type.color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(height: 80.h),

        Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 24.h),

        Text(
          l10n.reportSubmittedTitle,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.reportSubmittedMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 40.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.doneButton,
            onPressed: () => context.pop(),
            icon: Icons.check_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

enum _ReportType {
  safety('Safety', Color(0xFFF44336)),
  payment('Payment', Color(0xFFFF9800)),
  behavior('Behavior', Color(0xFF9C27B0)),
  technical('Technical', Color(0xFF2196F3)),
  discrimination('Discrimination', Color(0xFFE91E63)),
  other('Other', Color(0xFF607D8B));

  final String label;
  final Color color;

  // Constructor no longer takes the IconData directly
  const _ReportType(this.label, this.color);

  // Getter to handle Icon selection at runtime
  IconData get icon => switch (this) {
    safety => Icons.shield_rounded,
    payment => Icons.payment_rounded,
    behavior => Icons.person_off_rounded,
    technical => Icons.bug_report_rounded,
    discrimination => Icons.do_not_disturb_rounded,
    // This is now safe because the getter is not 'const'
    other => Icons.adaptive.more_rounded,
  };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    safety => l10n.reportSafety,
    payment => l10n.reportPayment,
    behavior => l10n.reportBehavior,
    technical => l10n.reportTechnical,
    discrimination => l10n.reportDiscrimination,
    other => l10n.reportOther,
  };
}

enum _Severity {
  low('Low', Icons.info_outline_rounded, Color(0xFF4CAF50)),
  medium('Medium', Icons.warning_amber_rounded, Color(0xFFFF9800)),
  high('High', Icons.error_outline_rounded, Color(0xFFF44336)),
  critical('Critical', Icons.dangerous_rounded, Color(0xFF9C27B0));

  final String label;
  final IconData icon;
  final Color color;

  const _Severity(this.label, this.icon, this.color);

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    low => l10n.severityLow,
    medium => l10n.severityMedium,
    high => l10n.severityHigh,
    critical => l10n.severityCritical,
  };
}
