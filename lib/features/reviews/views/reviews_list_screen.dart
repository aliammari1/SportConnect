import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/rating_and_profile_widgets.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/view_models/review_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Screen to display a user's reviews and rating stats
class ReviewsListScreen extends ConsumerStatefulWidget {
  const ReviewsListScreen({
    required this.userId,
    required this.userName,
    super.key,
    this.userPhotoUrl,
  });
  final String userId;
  final String userName;
  final String? userPhotoUrl;

  @override
  ConsumerState<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends ConsumerState<ReviewsListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(reviewsListViewModelProvider(widget.userId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(reviewsListViewModelProvider(widget.userId));

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).valueSReviews(widget.userName),
        actions: [
          AdaptiveAppBarAction(
            icon: Icons.refresh,
            onPressed: () {
              ref
                  .read(reviewsListViewModelProvider(widget.userId).notifier)
                  .refresh();
            },
          ),
        ],
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthContent,
        child: RefreshIndicator.adaptive(
          color: AppColors.primary,
          onRefresh: () async {
            ref
                .read(reviewsListViewModelProvider(widget.userId).notifier)
                .refresh();
          },
          child: asyncState.when(
            loading: () => const SkeletonLoader(
              type: SkeletonType.compactTile,
              itemCount: 5,
            ),
            error: (error, _) => _buildErrorState(context, error.toString()),
            data: (state) => state.error != null
                ? _buildErrorState(context, state.error!)
                : _buildContent(context, state),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    // Wrap in a scrollable so the parent RefreshIndicator.adaptive can arm and
    // the user can pull-to-retry even when the content does not fill the height.
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  error,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(
                          reviewsListViewModelProvider(widget.userId).notifier,
                        )
                        .refresh();
                  },
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReviewsListState state,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        MultiSliver(
          children: [
            // Stats header
            SliverToBoxAdapter(child: _buildStatsCard(context, state)),
            // Rating breakdown by tag
            if (state.stats != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  child: RatingBreakdownWidget(
                    averageRating: state.averageRating,
                    totalReviews: state.totalReviews,
                    // RatingBreakdownWidget expects raw per-star counts, so read
                    // the explicit *StarCount fields rather than the
                    // `distribution` getter (which returns percentages).
                    distribution: {
                      5: state.stats!.fiveStarCount,
                      4: state.stats!.fourStarCount,
                      3: state.stats!.threeStarCount,
                      2: state.stats!.twoStarCount,
                      1: state.stats!.oneStarCount,
                    },
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              ),
            // Filter chips
            SliverToBoxAdapter(child: _buildFilterChips(context, state)),
          ],
        ),
        // Reviews list
        if (state.filteredReviews.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64.r,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context).noReviewsYet,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final review = state.filteredReviews[index];
              // Reporting is handled by the overflow menu inside _ReviewCard;
              // the redundant swipe-to-report Dismissible was removed.
              return _ReviewCard(review: review)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: index * 50))
                  .slideX(begin: 0.1, end: 0);
            }, childCount: state.filteredReviews.length),
          ),
        SliverPadding(padding: EdgeInsets.only(bottom: 32.h)),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, ReviewsListState state) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      final isFilled = index < state.averageRating.round();
                      return Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24.r,
                      );
                    }),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueReviews(state.totalReviews),
                    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          if (state.stats != null) ...[
            SizedBox(height: 20.h),
            ...List.generate(5, (index) {
              final star = 5 - index;
              // Read raw per-star counts from the explicit *StarCount fields;
              // the `distribution` getter returns percentages, not counts.
              final count = switch (star) {
                5 => state.stats!.fiveStarCount,
                4 => state.stats!.fourStarCount,
                3 => state.stats!.threeStarCount,
                2 => state.stats!.twoStarCount,
                _ => state.stats!.oneStarCount,
              };
              final percentage = state.totalReviews > 0
                  ? count / state.totalReviews
                  : 0.0;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).value2(star),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 14.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.amber,
                          ),
                          minHeight: 8.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 32.w,
                      child: Text(
                        AppLocalizations.of(context).value2(count),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    ReviewsListState state,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _FilterChip(
            label: AppLocalizations.of(context).filterAll,
            isSelected: state.filterType == null,
            onTap: () {
              ref
                  .read(reviewsListViewModelProvider(widget.userId).notifier)
                  .setFilterType(null);
            },
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: AppLocalizations.of(context).as_driver,
            isSelected: state.filterType == ReviewType.driver,
            onTap: () {
              ref
                  .read(reviewsListViewModelProvider(widget.userId).notifier)
                  .setFilterType(ReviewType.driver);
            },
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: AppLocalizations.of(context).as_rider,
            isSelected: state.filterType == ReviewType.rider,
            onTap: () {
              ref
                  .read(reviewsListViewModelProvider(widget.userId).notifier)
                  .setFilterType(ReviewType.rider);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with reviewer info
          Row(
            children: [
              PremiumAvatar(
                imageUrl: review.reviewerPhotoUrl,
                name: review.reviewerName,
                size: 40,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(review.createdAt),
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Review type badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: review.type == ReviewType.driver
                      ? AppColors.info.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  review.type == ReviewType.driver
                      ? AppLocalizations.of(context).driver
                      : AppLocalizations.of(context).rider,
                  style: TextStyle(
                    color: review.type == ReviewType.driver
                        ? AppColors.info
                        : AppColors.success,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Report menu
              AdaptivePopupMenuButton.icon<String>(
                icon: Icons.adaptive.more,
                items: [
                  AdaptivePopupMenuItem<String>(
                    label: AppLocalizations.of(context).report_review,
                    icon: Icons.flag_outlined,
                    value: 'report',
                  ),
                ],
                onSelected: (index, entry) {
                  if (entry.value == 'report') {
                    context.push(
                      AppRoutes.reportIssue.path,
                      extra: {
                        'reportType': 'review',
                        'reviewId': review.id,
                        'reviewerName': review.reviewerName,
                      },
                    );
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Rating stars
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < review.rating;
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Colors.amber : AppColors.textTertiary,
                size: 20.r,
              );
            }),
          ),
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
          ],
          // Tags
          if (review.tags.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: review.tags.map((tagName) {
                // Try to get ReviewTag enum from string name for icon/label
                final reviewTag = ReviewTag.values
                    .where((t) => t.name == tagName)
                    .firstOrNull;
                final tagIcon = switch (reviewTag) {
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
                  ReviewTag.respectfulRider => Icons.volunteer_activism_rounded,
                  ReviewTag.onTimeRider => Icons.access_time_rounded,
                  ReviewTag.polite => Icons.sentiment_very_satisfied_outlined,
                  ReviewTag.easyCommunication => Icons.message_outlined,
                  null => Icons.label_rounded,
                };
                final label = reviewTag?.label ?? tagName.replaceAll('_', ' ');

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tagIcon, size: 12.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          // Response from reviewee
          if (review.response != null && review.response!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16.r,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).response,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    review.response!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
