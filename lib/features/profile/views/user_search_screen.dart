import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/features/profile/view_models/user_search_view_model.dart';
import 'package:sport_connect/features/profile/views/profile_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Premium User Search Screen with autocomplete
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(userSearchUiViewModelProvider);
    final searchResults = ref.watch(searchResultsProvider(uiState.query));

    final searchBody = SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(context, ref, uiState),
          Expanded(
            child: uiState.query.isEmpty
                ? _buildEmptyState(context, ref)
                : searchResults.when(
                    data: (users) => users.isEmpty
                        ? _buildNoResults(context, uiState.query)
                        : _buildResults(context, ref, users, uiState.query),
                    loading: () => _buildLoadingState(context),
                    error: (error, _) =>
                        _buildErrorState(context, error.toString()),
                  ),
          ),
        ],
      ),
    );

    return AdaptiveScaffold(
      body: AdaptiveMasterDetailScaffold(
        master: MaxWidthContainer(
          maxWidth: kMaxWidthContent,
          child: searchBody,
        ),
        detail: _buildTabletDetail(context),
        phone: MaxWidthContainer(
          maxWidth: kMaxWidthContent,
          child: searchBody,
        ),
      ),
    );
  }

  Widget _buildTabletDetail(BuildContext context) {
    if (_selectedUserId == null) {
      final l10n = AppLocalizations.of(context);
      return TabletEmptyDetail(
        icon: Icons.person_search_rounded,
        title: l10n.viewDetails,
        message: l10n.searchByNameHint,
      );
    }
    return ProfileScreen(userId: _selectedUserId);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: adaptiveScreenPadding(context).copyWith(top: 12.h, bottom: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: AppSpacing.shadowSm,
              ),
              child: Icon(
                Icons.adaptive.arrow_back_rounded,
                size: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).findPeople,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).searchByName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    UserSearchUiState uiState,
  ) {
    return Container(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppSpacing.shadowSm,
          border: Border.all(color: AppColors.border),
        ),
        child: TextFormField(
          key: ValueKey(uiState.searchFieldKey),
          initialValue: uiState.query,
          autofocus: true,
          onChanged: (query) => ref
              .read(userSearchUiViewModelProvider.notifier)
              .scheduleQuery(query),
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).searchUsers,
            hintText: AppLocalizations.of(context).searchUsers,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textTertiary,
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12.w),
              child: Icon(
                Icons.search_rounded,
                size: 24.sp,
                color: AppColors.textSecondary,
              ),
            ),
            suffixIcon: uiState.query.isNotEmpty
                ? IconButton(
                    tooltip: AppLocalizations.of(context).clearSearchTooltip,
                    onPressed: () {
                      ref.read(userSearchUiViewModelProvider.notifier).clear();
                      unawaited(HapticFeedback.lightImpact());
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 64.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).findFellowRiders,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).searchForUsersByTheir,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Quick suggestions
          Text(
            AppLocalizations.of(context).popularSearches,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children:
                [
                  AppLocalizations.of(context).driversLabel,
                  AppLocalizations.of(context).ridersLabel,
                  AppLocalizations.of(context).sportsLabel,
                  AppLocalizations.of(context).events,
                ].map((tag) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(userSearchUiViewModelProvider.notifier)
                          .applySuggestion(tag);
                      unawaited(HapticFeedback.selectionClick());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: const CircularProgressIndicator.adaptive(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).searching,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64.sp,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).noResultsFound2,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).noUsersFoundMatchingValue(query),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).tryADifferentSearchTerm,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).somethingWentWrong,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    WidgetRef ref,
    List<UserModel> users,
    String query,
  ) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.invalidate(searchResultsProvider(query));
        await Future<void>.delayed(const Duration(milliseconds: 250));
      },
      child: ListView.builder(
        padding: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          void navigateToProfile() {
            unawaited(HapticFeedback.lightImpact());
            if (context.isTabletOrLarger) {
              setState(() => _selectedUserId = user.uid);
              return;
            }
            if (user.role == UserRole.driver) {
              context.pushNamed(
                AppRoutes.driverProfile.name,
                pathParameters: {'id': user.uid},
              );
            } else {
              context.pushNamed(
                AppRoutes.userProfile.name,
                pathParameters: {'id': user.uid},
              );
            }
          }

          return Dismissible(
            key: ValueKey('user_search_${user.uid}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              unawaited(HapticFeedback.mediumImpact());
              navigateToProfile();
              return false;
            },
            background: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: _UserCard(user: user, onTap: navigateToProfile)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn()
                .slideX(begin: 0.05),
          );
        },
      ),
    );
  }
}

/// User card widget
class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});
  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: AdaptiveTapSurface(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: user.photoUrl == null
                      ? AppColors.primaryGradient
                      : null,
                  image: user.photoUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.photoUrl == null
                    ? Center(
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 14.w),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.username,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isEmailVerified)
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 14.sp,
                              color: AppColors.info,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildRoleBadge(user.role),
                        SizedBox(width: 8.w),
                        if (switch (user) {
                              final RiderModel rider =>
                                rider.asRider?.rating.average ?? 0,
                              final DriverModel driver =>
                                driver.asDriver?.rating.average ?? 0,
                              _ => 0,
                            } >
                            0)
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                switch (user) {
                                  final RiderModel rider =>
                                    rider.asRider?.rating.average
                                            .toStringAsFixed(1) ??
                                        '0.0',
                                  final DriverModel driver =>
                                    driver.asDriver?.rating.average
                                            .toStringAsFixed(1) ??
                                        '0.0',
                                  _ => '0.0',
                                },
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color badgeColor;
    IconData icon;

    switch (role) {
      case UserRole.driver:
        badgeColor = const Color(0xFF11998e);
        icon = Icons.drive_eta_rounded;
      case UserRole.rider:
        badgeColor = const Color(0xFF667eea);
        icon = Icons.person_pin_circle_rounded;
      case UserRole.pending:
        badgeColor = const Color(0xFFe2e2e2);
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: badgeColor),
          SizedBox(width: 4.w),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
