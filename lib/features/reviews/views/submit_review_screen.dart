import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/view_models/review_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Screen for submitting a review after a ride
class SubmitReviewScreen extends ConsumerStatefulWidget {
  const SubmitReviewScreen({
    required this.rideId,
    required this.revieweeId,
    required this.revieweeName,
    required this.reviewType,
    super.key,
    this.revieweePhotoUrl,
  });
  final String rideId;
  final String revieweeId;
  final String revieweeName;
  final String? revieweePhotoUrl;
  final ReviewType reviewType;

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewFormViewModelProvider);
    final viewModel = ref.read(reviewFormViewModelProvider.notifier);
    final availableTags = ReviewTag.getTagsFor(widget.reviewType);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).leaveAReview,
      ),
      body: state.isSubmitting
          ? const Center(child: CircularProgressIndicator.adaptive())
          : MaxWidthContainer(
              maxWidth: kMaxWidthFormNarrow,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    // User being reviewed
                    _buildUserCard()
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    SizedBox(height: 32.h),

                    // Rating selector
                    Text(
                      AppLocalizations.of(context).howWasYourExperience,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildRatingSelector(
                      state,
                      viewModel,
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                    SizedBox(height: 32.h),

                    // Tag selection
                    if (availableTags.isNotEmpty) ...[
                      Text(
                        AppLocalizations.of(context).whatStoodOut,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildTagSelector(
                        availableTags,
                        state,
                        viewModel,
                      ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                      SizedBox(height: 24.h),
                    ],

                    // Comment field
                    Text(
                      AppLocalizations.of(context).additionalCommentsOptional,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildCommentField(
                      viewModel,
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                    SizedBox(height: 24.h),

                    // Error message
                    if (state.error != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Submit button
                    if (!state.isValid && state.rating == 0)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).pleaseSelectRatingToSubmit,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    PremiumButton(
                      text: AppLocalizations.of(context).submitReviewButton,
                      onPressed: state.isValid && !state.isSubmitting
                          ? () => _submitReview(viewModel)
                          : null,
                      isLoading: state.isSubmitting,
                      fullWidth: true,
                    ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

                    SizedBox(height: 16.h),

                    // Skip button
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        AppLocalizations.of(context).skipForNow,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          PremiumAvatar(
            imageUrl: widget.revieweePhotoUrl,
            name: widget.revieweeName,
            size: 80,
          ),
          SizedBox(height: 12.h),
          Text(
            widget.revieweeName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: widget.reviewType == ReviewType.driver
                  ? AppColors.info.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.reviewType == ReviewType.driver
                  ? AppLocalizations.of(context).yourDriver
                  : AppLocalizations.of(context).yourPassenger,
              style: TextStyle(
                color: widget.reviewType == ReviewType.driver
                    ? AppColors.info
                    : AppColors.success,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSelector(
    ReviewFormState state,
    ReviewFormViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= state.rating;
        return GestureDetector(
          onTap: () {
            unawaited(HapticFeedback.lightImpact());
            viewModel.setRating(starNumber);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 48.r,
              color: isSelected ? Colors.amber : AppColors.textTertiary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTagSelector(
    List<ReviewTag> availableTags,
    ReviewFormState state,
    ReviewFormViewModel viewModel,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: availableTags.map((tag) {
        final isSelected = state.selectedTags.contains(tag);
        return GestureDetector(
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            viewModel.toggleTag(tag);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  switch (tag) {
                    ReviewTag.punctual => Icons.timer_rounded,
                    ReviewTag.greatConversation =>
                      Icons.chat_bubble_outline_rounded,
                    ReviewTag.cleanCar => Icons.cleaning_services_rounded,
                    ReviewTag.safeDriver => Icons.shield_outlined,
                    ReviewTag.comfortableRide => Icons.weekend_rounded,
                    ReviewTag.goodMusic => Icons.music_note_rounded,
                    ReviewTag.friendly => Icons.sentiment_satisfied_outlined,
                    ReviewTag.professional => Icons.work_outline_rounded,
                    ReviewTag.flexible => Icons.handshake_outlined,
                    ReviewTag.respectfulRider =>
                      Icons.volunteer_activism_rounded,
                    ReviewTag.onTimeRider => Icons.access_time_rounded,
                    ReviewTag.polite => Icons.sentiment_very_satisfied_outlined,
                    ReviewTag.easyCommunication => Icons.message_outlined,
                  },
                  size: 14.sp,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  tag.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentField(ReviewFormViewModel viewModel) {
    return TextField(
      onChanged: (value) {
        // Sanitize: don't accept whitespace-only comments
        final trimmed = value.trim();
        viewModel.setComment(trimmed);
      },
      maxLines: 4,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).shareYourExperience,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        helperText: AppLocalizations.of(context).specificFeedbackHelps,
        helperStyle: TextStyle(color: AppColors.textTertiary, fontSize: 11.sp),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.all(16.r),
        counterStyle: const TextStyle(color: AppColors.textTertiary),
      ),
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
    );
  }

  Future<void> _submitReview(ReviewFormViewModel viewModel) async {
    final success = await viewModel.submitReview(
      rideId: widget.rideId,
      revieweeId: widget.revieweeId,
      revieweeName: widget.revieweeName,
      revieweePhotoUrl: widget.revieweePhotoUrl,
      type: widget.reviewType,
    );

    if (success && mounted) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).thankYouForYourReview,
        type: AdaptiveSnackBarType.success,
      );
      context.pop();
    }
  }
}
