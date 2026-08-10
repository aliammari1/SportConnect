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
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Dispute filing screen for ride fare or service disagreements.
class DisputeScreen extends ConsumerStatefulWidget {
  const DisputeScreen({required this.rideId, this.rideSummary, super.key});

  final String rideId;
  final String? rideSummary;

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> {
  final _imagePicker = ImagePicker();
  // Owns the description field so it can be programmatically cleared after a
  // successful submission. Without this, the TextField's internal text would
  // persist across submits, and any external reset (e.g. via state mutation)
  // would not be reflected in the UI.
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final initialDescription = ref
        .read(disputeFormViewModelProvider(widget.rideId))
        .description;
    _descriptionController = TextEditingController(text: initialDescription);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Keep the controller in sync when the view model clears the description
  // externally (e.g. after a successful submit resets the form).
  void _syncDescriptionIfNeeded(String vmDescription) {
    if (_descriptionController.text == vmDescription) return;
    _descriptionController.value = TextEditingValue(
      text: vmDescription,
      selection: TextSelection.collapsed(offset: vmDescription.length),
    );
  }

  List<_DisputeType> _getDisputeTypes(AppLocalizations l10n) => [
    _DisputeType(
      id: 'incorrect_fare',
      icon: Icons.euro_rounded,
      title: l10n.incorrectFareType,
      description: l10n.incorrectFareDesc,
    ),
    _DisputeType(
      id: 'incomplete_ride',
      icon: Icons.wrong_location_rounded,
      title: l10n.incompleteRideType,
      description: l10n.incompleteRideDesc,
    ),
    _DisputeType(
      id: 'unauthorized_charge',
      icon: Icons.credit_card_off_rounded,
      title: l10n.unauthorizedChargeType,
      description: l10n.unauthorizedChargeDesc,
    ),
    _DisputeType(
      id: 'poor_service',
      icon: Icons.sentiment_dissatisfied_rounded,
      title: l10n.poorServiceType,
      description: l10n.poorServiceDesc,
    ),
    _DisputeType(
      id: 'safety_concern',
      icon: Icons.health_and_safety_rounded,
      title: l10n.safetyConcernType,
      description: l10n.safetyConcernDesc,
    ),
    _DisputeType(
      id: 'other',
      icon: Icons.adaptive.more_rounded,
      title: l10n.otherDisputeType,
      description: l10n.otherDisputeDesc,
    ),
  ];

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context);
    final source = await AppModalSheet.show<ImageSource>(
      context: context,
      title: l10n.attachEvidence,
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
        .read(disputeFormViewModelProvider(widget.rideId).notifier)
        .addAttachment(File(picked.path));
  }

  Future<void> _submitDispute() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      return;
    }

    await ref
        .read(disputeFormViewModelProvider(widget.rideId).notifier)
        .submit(
          userId: user.uid,
          userEmail: user.email,
          rideSummary: widget.rideSummary,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(disputeFormViewModelProvider(widget.rideId));
    final l10n = AppLocalizations.of(context);

    ref.listen<DisputeFormState>(disputeFormViewModelProvider(widget.rideId), (
      previous,
      next,
    ) {
      _syncDescriptionIfNeeded(next.description);
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
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
        title: l10n.fileDisputeTitle,
        leading: IconButton(
          tooltip: AppLocalizations.of(context).goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: formState.isSubmitted
            ? _buildSuccessView(l10n)
            : _buildFormView(formState, l10n),
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 56.sp,
                color: AppColors.success,
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.disputeSubmittedTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 12.h),
            Text(
              l10n.disputeSubmittedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  l10n.doneButton,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(DisputeFormState formState, AppLocalizations l10n) {
    final items = <Widget>[
      SizedBox(height: 16.h),

      // Ride info card
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.rideIdLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.rideId,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),

      SizedBox(height: 24.h),

      // Dispute type selection
      Text(
        l10n.disputeTypeLabel,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ).animate().fadeIn(delay: 100.ms),
      SizedBox(height: 4.h),
      Text(
        l10n.selectDisputeReason,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ).animate().fadeIn(delay: 150.ms),

      SizedBox(height: 16.h),

      ..._getDisputeTypes(l10n).asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        final isSelected = formState.selectedDisputeType == type.id;

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              ref
                  .read(
                    disputeFormViewModelProvider(
                      widget.rideId,
                    ).notifier,
                  )
                  .selectType(type.id);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      type.icon,
                      size: 20.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          type.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 22.sp,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (200 + index * 50).ms).slideX(begin: 0.03),
        );
      }),

      if (formState.typeError != null) ...[
        SizedBox(height: 4.h),
        Text(
          formState.typeError!,
          style: TextStyle(fontSize: 12.sp, color: AppColors.error),
        ),
      ],

      SizedBox(height: 20.h),

      // Description
      Text(
        l10n.detailsLabel,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 8.h),
      TextField(
        controller: _descriptionController,
        maxLines: 5,
        maxLength: 1000,
        onChanged: (value) => ref
            .read(disputeFormViewModelProvider(widget.rideId).notifier)
            .updateDescription(value),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.describeIssueDetailPlaceholder,
          errorText: formState.descriptionError,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: Colors.white,
          counterStyle: TextStyle(fontSize: 11.sp),
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
          contentPadding: EdgeInsets.all(14.w),
        ),
      ),

      SizedBox(height: 12.h),

      // Note
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18.sp,
              color: AppColors.warning,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                l10n.disputeWarningNote,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 20.h),

      // Evidence attachment
      Text(
        l10n.evidenceOptionalLabel,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 8.h),
      GestureDetector(
        onTap: _pickFiles,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  formState.attachedFiles.isEmpty
                      ? l10n.attachReceiptsPlaceholder
                      : l10n.filesAttachedCount(
                          formState.attachedFiles.length,
                          DisputeFormViewModel.maxAttachments,
                        ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: formState.attachedFiles.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
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
                          .read(
                            disputeFormViewModelProvider(
                              widget.rideId,
                            ).notifier,
                          )
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

      SizedBox(height: 20.h),

      // Resolution expectation
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whatToExpectTitle,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _buildExpectationRow(
              Icons.access_time_rounded,
              l10n.reviewWithinHours,
            ),
            SizedBox(height: 6.h),
            _buildExpectationRow(
              Icons.email_outlined,
              l10n.emailNotificationExpectation,
            ),
            SizedBox(height: 6.h),
            _buildExpectationRow(
              Icons.gavel_rounded,
              l10n.fairResolutionExpectation,
            ),
          ],
        ),
      ),

      SizedBox(height: 28.h),

      // Submit
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: formState.isSubmitting ? null : _submitDispute,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: formState.isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l10n.submitDisputeButton,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),

      SizedBox(height: 32.h),
    ];
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildExpectationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DisputeType {
  const _DisputeType({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
}
