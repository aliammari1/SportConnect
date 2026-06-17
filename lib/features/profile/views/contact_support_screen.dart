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
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// In-app contact support screen with message submission.
///
/// Features:
/// - Subject category selection
/// - Message composition
/// - Ticket submission to Firebase
/// - Previous tickets view
class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final _imagePicker = ImagePicker();
  late final FormGroup _form;

  static const _categories = [
    'General',
    'Account Issue',
    'Payment Problem',
    'Ride Issue',
    'Safety Concern',
    'Bug Report',
    'Feature Request',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'subject': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(3)],
      ),
      'message': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(10)],
      ),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context);
    final source = await AppModalSheet.show<ImageSource>(
      context: context,
      title: l10n.attach_image,
      maxHeightFactor: 0.45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdaptiveListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: Text(AppLocalizations.of(context).chooseFromGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          AdaptiveListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: Text(AppLocalizations.of(context).takePhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: double.infinity,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (picked == null) return;
    if (!mounted) return;

    await ref
        .read(contactSupportViewModelProvider.notifier)
        .addAttachment(File(picked.path));
  }

  Future<void> _submitTicket() async {
    _form.markAllAsTouched();
    if (_form.invalid) return;
    final user = ref.read(currentUserProvider).value;
    await ref
        .read(contactSupportViewModelProvider.notifier)
        .submitTicket(
          userId: user?.uid ?? 'anonymous',
          userEmail: user?.email ?? '',
          userName: user?.username ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final supportState = ref.watch(contactSupportViewModelProvider);

    ref.listen(contactSupportViewModelProvider, (previous, next) {
      if (next.isSubmitted && previous?.isSubmitted != true) {
        unawaited(HapticFeedback.mediumImpact());
      }

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
        title: l10n.contactSupport,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: adaptiveScreenPadding(context),
            child: supportState.isSubmitted
                ? _buildSuccessState()
                : _buildFormState(l10n, supportState),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(
    AppLocalizations l10n,
    ContactSupportState supportState,
  ) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),

          // Info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.howCanWeHelp,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.responseTimeMessage,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: 24.h),

          // Category selector
          Text(
            l10n.categoryLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: supportState.selectedCategory,
                isExpanded: true,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_localizedCategoryLabel(l10n, cat)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  ref
                      .read(contactSupportViewModelProvider.notifier)
                      .setCategory(value);
                },
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),

          SizedBox(height: 20.h),

          // Subject
          AdaptiveReactiveTextField(
            formControlName: 'subject',
            textCapitalization: TextCapitalization.sentences,
            onChanged: (control) => ref
                .read(contactSupportViewModelProvider.notifier)
                .setSubject(control.value ?? ''),
            validationMessages: {
              ValidationMessage.required: (_) => l10n.supportSubjectRequired,
              ValidationMessage.minLength: (_) => l10n.supportSubjectMinLength,
            },
            labelText: l10n.subjectLabel,
            hintText: l10n.subjectHint,
            prefixIcon: const Icon(Icons.subject_rounded),
          ).animate().fadeIn(delay: 200.ms),

          SizedBox(height: 20.h),

          // Message
          Text(
            l10n.messageFieldLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          AdaptiveReactiveTextField(
            formControlName: 'message',
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (control) => ref
                .read(contactSupportViewModelProvider.notifier)
                .setMessage(control.value ?? ''),
            validationMessages: {
              ValidationMessage.required: (_) => l10n.supportMessageRequired,
              ValidationMessage.minLength: (_) => l10n.supportMessageMinLength,
            },
            hintText: l10n.messageFieldHint,
          ).animate().fadeIn(delay: 300.ms),

          SizedBox(height: 20.h),

          // Attachment
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border,
                ),
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
                      supportState.attachedFiles.isEmpty
                          ? l10n.attachFilesHint
                          : l10n.filesAttachedCount(
                              supportState.attachedFiles.length,
                              ContactSupportViewModel.maxAttachments,
                            ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: supportState.attachedFiles.isEmpty
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
          ).animate().fadeIn(delay: 350.ms),

          if (supportState.attachedFiles.isNotEmpty) ...[
            SizedBox(height: 10.h),
            SizedBox(
              height: 80.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: supportState.attachedFiles.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          supportState.attachedFiles[index],
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
                              .read(contactSupportViewModelProvider.notifier)
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
              text: l10n.submitTicketButton,
              onPressed: supportState.isSubmitting ? null : _submitTicket,
              isLoading: supportState.isSubmitting,
              icon: Icons.send_rounded,
            ),
          ).animate().fadeIn(delay: 400.ms),

          SizedBox(height: 24.h),

          // Response time expectations
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18.sp,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.averageResponseTime,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        l10n.responseTimeInfo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 450.ms),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
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
          AppLocalizations.of(context).ticketSubmittedTitle,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          AppLocalizations.of(context).ticketSubmittedMessage,
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
            text: AppLocalizations.of(context).backToSettings,
            onPressed: () => context.pop(),
            icon: Icons.adaptive.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

String _localizedCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'General':
      return l10n.supportCategoryGeneral;
    case 'Account Issue':
      return l10n.supportCategoryAccountIssue;
    case 'Payment Problem':
      return l10n.supportCategoryPaymentProblem;
    case 'Ride Issue':
      return l10n.supportCategoryRideIssue;
    case 'Safety Concern':
      return l10n.supportCategorySafetyReport;
    case 'Bug Report':
      return l10n.supportCategoryTechnicalBug;
    case 'Feature Request':
      return l10n.supportCategoryFeatureRequest;
    case 'Other':
      return l10n.supportCategoryOther;
    default:
      return category;
  }
}
