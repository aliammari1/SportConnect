import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_search_widgets.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Ride Search Screen with filters - Enhanced UI
class RideSearchScreen extends ConsumerStatefulWidget {
  const RideSearchScreen({super.key, this.initialDestination});

  /// Optional pre-filled destination, for example from event detail.
  /// Keys: `destinationAddress`, `destinationLat`, `destinationLng`.
  final Map<String, dynamic>? initialDestination;

  @override
  ConsumerState<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends ConsumerState<RideSearchScreen> {
  RideSearchState get _searchState => ref.read(rideSearchViewModelProvider);

  RideSearchResultsData get _resultsState =>
      ref.read(rideSearchResultsProvider);

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    final dest = widget.initialDestination;

    if (dest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setInitialDestination(dest);
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 240) {
      ref.read(rideSearchViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(rideSearchViewModelProvider)
      ..watch(rideSearchResultsProvider);

    ref.listen(rideSearchViewModelProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).searchFailedPleaseTryAgain,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: responsiveValue<double>(
          context,
          compact: kMaxWidthWide,
          medium: 1120,
          expanded: 1320,
          large: 1440,
          extraLarge: 1520,
        ),
        child: RefreshIndicator.adaptive(
          onRefresh: _handlePullToRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(),

              MultiSliver(
                children: [
                  SliverToBoxAdapter(child: _buildSearchCard()),
                  SliverToBoxAdapter(child: _buildQuickDateSelection()),
                  if (_hasActiveFilters)
                    SliverToBoxAdapter(child: _buildActiveFilters()),
                ],
              ),

              if (!_resultsState.hasSearched &&
                  !_resultsState.isLoading &&
                  _resultsState.visibleResults.isEmpty)
                ..._buildDiscoverySection()
              else
                MultiSliver(
                  children: [
                    SliverToBoxAdapter(child: _buildResultsHeader()),
                    _buildResultsList(),
                  ],
                ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingFilterButton(),
    );
  }

  Future<void> _handlePullToRefresh() async {
    if (_resultsState.hasSearched) {
      await ref
          .read(rideSearchViewModelProvider.notifier)
          .searchRides(forceRefresh: true);

      return;
    }

    ref.invalidate(activeRidesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  bool get _hasActiveFilters => _searchState.hasActiveFilters;

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 56.h,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.home.path),
        icon: Icon(
          Icons.adaptive.arrow_back_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).findARide,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).filters,
          onPressed: _showAdvancedFilters,
          icon: Badge(
            isLabelVisible: _hasActiveFilters,
            backgroundColor: AppColors.warning,
            smallSize: 8.w,
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildSearchCard() {
    final screenPadding = adaptiveScreenPadding(context);
    final l10n = AppLocalizations.of(context);

    Widget buildRouteSection() {
      return IntrinsicHeight(
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBg, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2.w,
                  height: 28.h,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.error],
                    ),
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
                Icon(
                  Icons.location_on,
                  color: AppColors.error,
                  size: 16.sp,
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCompactInputField(
                    hint: l10n.pickupLocation,
                    icon: Icons.my_location_rounded,
                    isFrom: true,
                  ),
                  Divider(
                    height: 16.h,
                    thickness: 1,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  _buildCompactInputField(
                    hint: l10n.whereTo,
                    icon: Icons.search_rounded,
                    isFrom: false,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _swapLocations,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildControlsSection({
      required bool fullWidthButton,
      required bool stacked,
    }) {
      if (stacked) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCompactDateSelector()),
                SizedBox(width: 8.w),
                _buildCompactSeatSelector(),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: _buildSearchButton(expanded: true),
            ),
          ],
        );
      }

      if (fullWidthButton) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _buildCompactDateSelector()),
                SizedBox(width: 8.w),
                _buildCompactSeatSelector(),
              ],
            ),
            SizedBox(height: 12.h),
            _buildSearchButton(expanded: true),
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: _buildCompactDateSelector()),
          SizedBox(width: 8.w),
          _buildCompactSeatSelector(),
          SizedBox(width: 8.w),
          _buildSearchButton(),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.fromLTRB(
        screenPadding.left,
        12.h,
        screenPadding.right,
        8.h,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 340.w;
          final isWideLayout = constraints.maxWidth >= Breakpoints.medium;

          if (isWideLayout) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: buildRouteSection()),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 5,
                  child: buildControlsSection(
                    fullWidthButton: true,
                    stacked: false,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              buildRouteSection(),
              SizedBox(height: 12.h),
              buildControlsSection(
                fullWidthButton: false,
                stacked: compact,
              ),
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  void _swapLocations() {
    unawaited(HapticFeedback.lightImpact());
    ref.read(rideSearchViewModelProvider.notifier).swapLocations();
  }

  Widget _buildCompactInputField({
    required String hint,
    required IconData icon,
    required bool isFrom,
  }) {
    final location = isFrom
        ? _searchState.draftOrigin
        : _searchState.draftDestination;

    final address = location?.address ?? '';

    return GestureDetector(
      onTap: () => _openLocationPicker(isFrom: isFrom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                address.isEmpty ? hint : address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: address.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: address.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            if (address.isNotEmpty) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isFrom) {
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftOrigin(null);
                  } else {
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftDestination(null);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    // iOS gets the native wheel in a bottom sheet; Android keeps the
    // Material calendar themed from the active theme instead of a forced
    // light scheme.
    if (PlatformInfo.isIOS) {
      DateTime selection = _searchState.draftDate;
      final picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (sheetContext) => Container(
          color: AppColors.surface,
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        AppLocalizations.of(sheetContext).actionCancel,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(
                        sheetContext,
                      ).pop(selection),
                      child: Text(
                        AppLocalizations.of(sheetContext).done,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 220.h,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _searchState.draftDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime.now().add(
                      const Duration(days: 90),
                    ),
                    onDateTimeChanged: (value) => selection = value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (!mounted || picked == null) return;
      ref.read(rideSearchViewModelProvider.notifier).setDraftDate(picked);
      ref.read(rideSearchViewModelProvider.notifier).setSelectedDateChip(2);
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _searchState.draftDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (date != null) {
      ref.read(rideSearchViewModelProvider.notifier).setDraftDate(date);
      // Index 2 = "Custom" chip (the third entry in `_buildQuickDateSelection`).
      // Previously this highlighted the "This Weekend" chip, which was
      // misleading when the user picked any other date.
      ref.read(rideSearchViewModelProvider.notifier).setSelectedDateChip(2);
    }
  }

  Widget _buildCompactDateSelector() {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        constraints: BoxConstraints(minHeight: 42.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                _formatDate(_searchState.draftDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSeatSelector() {
    return Container(
      constraints: BoxConstraints(minHeight: 42.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _searchState.draftSeats > 1
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftSeats(_searchState.draftSeats - 1);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.remove_rounded,
                color: _searchState.draftSeats > 1
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 2.w),
                Text(
                  AppLocalizations.of(context).value2(_searchState.draftSeats),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _searchState.draftSeats < 4
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    ref
                        .read(rideSearchViewModelProvider.notifier)
                        .setDraftSeats(_searchState.draftSeats + 1);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.add_rounded,
                color: _searchState.draftSeats < 4
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton({bool expanded = false}) {
    return GestureDetector(
      onTap: _performSearch,
      child: Container(
        width: expanded ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 16.w : 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _searchState.isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    if (expanded) ...[
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).findARide,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_searchState.isLoading) return;

    unawaited(HapticFeedback.mediumImpact());

    final error = await ref
        .read(rideSearchViewModelProvider.notifier)
        .searchRides();

    if (error == null || !mounted) return;

    final l10n = AppLocalizations.of(context);
    final message = switch (error) {
      RideSearchInputError.missingLocations => l10n.searchErrorMissingLocations,
      RideSearchInputError.sameLocation => l10n.searchErrorSameLocation,
      RideSearchInputError.pastDate => l10n.searchErrorPastDate,
      RideSearchInputError.invalidSeats => l10n.searchErrorInvalidSeats,
    };
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
    );
  }

  Widget _buildQuickDateSelection() {
    final now = DateTime.now();
    final dates = [
      (AppLocalizations.of(context).today, now),
      (
        AppLocalizations.of(context).tomorrow,
        now.add(const Duration(days: 1)),
      ),
      // Third chip is a passive indicator for "custom date picked via picker".
      // It intentionally does NOT auto-set a date when tapped — the date
      // picker is the canonical way to pick a custom date. Index 2 mirrors
      // RideSearchState.selectedDateChip semantics (`// 0=Today, 1=Tomorrow,
      // 2=Custom`).
      (AppLocalizations.of(context).custom_label, _searchState.draftDate),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(dates.length, (index) {
                final isSelected = _searchState.selectedDateChip == index;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: index == 2
                        // Custom chip is a passive marker — opening the
                        // picker is the canonical action and keeps the
                        // current draft date intact.
                        ? () => _showDatePicker(context)
                        : () {
                            unawaited(HapticFeedback.selectionClick());
                            ref
                                .read(rideSearchViewModelProvider.notifier)
                                .setSelectedDateChip(index);
                            ref
                                .read(rideSearchViewModelProvider.notifier)
                                .setDraftDate(dates[index].$2);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: BoxConstraints(maxWidth: 150.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected ? AppSpacing.shadowSm : null,
                      ),
                      child: Text(
                        dates[index].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildActiveFilters() {
    final filters = <Widget>[];

    if (_searchState.draftMaxPrice < 100) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(
            context,
          ).maxValue(_searchState.draftMaxPrice),
          onRemove: () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftMaxPrice(100);
          },
        ),
      );
    }

    if (_searchState.draftFemaleOnly) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(context).femaleOnly,
          onRemove: () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftFemaleOnly(false);
          },
        ),
      );
    }

    if (_searchState.draftPetFriendly) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(context).petFriendly,
          onRemove: () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftPetFriendly(false);
          },
        ),
      );
    }

    if (_searchState.draftNoSmoking) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(context).noSmoking,
          onRemove: () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftNoSmoking(false);
          },
        ),
      );
    }

    if (_searchState.draftLuggageRequired) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(context).allowLuggageToggle,
          onRemove: () {
            ref
                .read(rideSearchViewModelProvider.notifier)
                .setDraftLuggageRequired(false);
          },
        ),
      );
    }

    if (_searchState.draftMinRating > 0) {
      filters.add(
        SearchFilterTag(
          label: AppLocalizations.of(
            context,
          ).valueRating(_searchState.draftMinRating.toStringAsFixed(1)),
          onRemove: () {
            ref.read(rideSearchViewModelProvider.notifier).setDraftMinRating(0);
          },
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).activeFilters,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  ref.read(rideSearchViewModelProvider.notifier).resetFilters();
                },
                child: Text(
                  AppLocalizations.of(context).clearAll2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: filters),
        ],
      ),
    ).animate().fadeIn();
  }

  List<Widget> _buildDiscoverySection() {
    final l10n = AppLocalizations.of(context);

    return [
      SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.directions_car_rounded,
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.whereTo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.findARide,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.howItWorks,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              _buildStepTile(
                icon: Icons.location_on_rounded,
                color: AppColors.primary,
                title: l10n.pickupAndDropoff,
                subtitle: l10n.enterPickupAndDestination,
                step: '1',
              ),
              SizedBox(height: 8.h),
              _buildStepTile(
                icon: Icons.calendar_today_rounded,
                color: AppColors.info,
                title: l10n.selectDate,
                subtitle: l10n.chooseWhenYouWantToTravel,
                step: '2',
              ),
              SizedBox(height: 8.h),
              _buildStepTile(
                icon: Icons.search_rounded,
                color: AppColors.success,
                title: l10n.findAndBook,
                subtitle: l10n.browseAvailableRidesAndBook,
                step: '3',
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ),
    ];
  }

  Widget _buildStepTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String step,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(icon, color: color, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    final screenPadding = adaptiveScreenPadding(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenPadding.left,
        16.h,
        screenPadding.right,
        8.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).valueRidesAvailable(_resultsState.totalCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(_searchState.draftDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              constraints: BoxConstraints(maxWidth: 150.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      _getSortLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  String _getSortLabel() {
    switch (_searchState.draftSortBy) {
      case 'price_low':
        return AppLocalizations.of(context).lowestPrice2;
      case 'price_high':
        return AppLocalizations.of(context).highestPrice;
      case 'rating':
        return AppLocalizations.of(context).highestRated2;
      case 'duration':
        return AppLocalizations.of(context).shortestDuration;
      case 'departure':
        return AppLocalizations.of(context).earliestDeparture2;
      default:
        return AppLocalizations.of(context).recommended;
    }
  }

  Widget _buildFloatingFilterButton() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _searchState.isFilterPanelOpen ? const Offset(0, 2) : Offset.zero,
      child: FloatingActionButton.extended(
        heroTag: 'ride_search_filter_fab',
        onPressed: _showAdvancedFilters,
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.filter_list_rounded, size: 20.sp),
        label: Text(
          AppLocalizations.of(context).filtersValue(
            _hasActiveFilters ? ' (${_getActiveFilterCount()})' : '',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    return _searchState.activeFilterCount;
  }

  void _showAdvancedFilters() {
    if (_searchState.isFilterPanelOpen) return;

    unawaited(HapticFeedback.mediumImpact());
    ref.read(rideSearchViewModelProvider.notifier).setFilterPanelOpen(true);

    unawaited(
      AppModalSheet.show<void>(
        context: context,
        forceMaxHeight: true,
        maxHeightFactor: 0.8,
        showCloseButton: false,
        child: Consumer(
          builder: (context, ref, child) {
            final searchState = ref.watch(rideSearchViewModelProvider);

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.75,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).filters,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(rideSearchViewModelProvider.notifier)
                                    .resetFilters();
                              },
                              child: Text(
                                AppLocalizations.of(context).reset,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchFilterSectionTitle(
                            title: AppLocalizations.of(context).priceRange,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).text52,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                constraints: BoxConstraints(maxWidth: 140.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).maxValue(searchState.draftMaxPrice),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppLocalizations.of(context).text100,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
                              trackHeight: 4.h,
                            ),
                            child: AdaptiveSlider(
                              value: searchState.draftMaxPrice.toDouble(),
                              min: 5,
                              max: 100,
                              divisions: 20,
                              onChanged: (value) {
                                ref
                                    .read(rideSearchViewModelProvider.notifier)
                                    .setDraftMaxPrice(value.toInt());
                              },
                            ),
                          ),

                          SizedBox(height: 20.h),

                          SearchFilterSectionTitle(
                            title: AppLocalizations.of(context).minimumRating,
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [0.0, 3.0, 4.0, 4.5, 4.8].map((rating) {
                              final isSelected =
                                  searchState.draftMinRating == rating;

                              return GestureDetector(
                                onTap: () {
                                  unawaited(HapticFeedback.selectionClick());
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftMinRating(rating);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (rating > 0) ...[
                                        Icon(
                                          Icons.star_rounded,
                                          size: 14.sp,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.xpGold,
                                        ),
                                        SizedBox(width: 2.w),
                                      ],
                                      Text(
                                        rating == 0
                                            ? AppLocalizations.of(context).any
                                            : AppLocalizations.of(
                                                context,
                                              ).value13(rating),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 24.h),

                          SearchFilterSectionTitle(
                            title: AppLocalizations.of(context).preferences,
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: [
                              SearchToggleChip(
                                label: AppLocalizations.of(context).femaleOnly,
                                icon: Icons.female_rounded,
                                isSelected: searchState.draftFemaleOnly,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftFemaleOnly(
                                        !searchState.draftFemaleOnly,
                                      );
                                },
                              ),
                              SearchToggleChip(
                                label: AppLocalizations.of(context).petFriendly,
                                icon: Icons.pets_rounded,
                                isSelected: searchState.draftPetFriendly,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftPetFriendly(
                                        !searchState.draftPetFriendly,
                                      );
                                },
                              ),
                              SearchToggleChip(
                                label: AppLocalizations.of(context).noSmoking,
                                icon: Icons.smoke_free_rounded,
                                isSelected: searchState.draftNoSmoking,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftNoSmoking(
                                        !searchState.draftNoSmoking,
                                      );
                                },
                              ),
                              SearchToggleChip(
                                label: AppLocalizations.of(
                                  context,
                                ).allowLuggageToggle,
                                icon: Icons.luggage_rounded,
                                isSelected: searchState.draftLuggageRequired,
                                onTap: () {
                                  ref
                                      .read(
                                        rideSearchViewModelProvider.notifier,
                                      )
                                      .setDraftLuggageRequired(
                                        !searchState.draftLuggageRequired,
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border(
                        top: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: SafeArea(
                      child: PremiumButton(
                        text: AppLocalizations.of(context).applyFilters,
                        onPressed: () {
                          context.pop();
                          unawaited(HapticFeedback.mediumImpact());
                        },
                        style: PremiumButtonStyle.gradient,
                        icon: Icons.check_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ).whenComplete(() {
        if (!mounted) return;

        ref
            .read(rideSearchViewModelProvider.notifier)
            .setFilterPanelOpen(false);
      }),
    );
  }

  Future<void> _openLocationPicker({required bool isFrom}) async {
    LatLng? initialLocation;

    if (isFrom && _searchState.draftOrigin != null) {
      initialLocation = LatLng(
        _searchState.draftOrigin!.latitude,
        _searchState.draftOrigin!.longitude,
      );
    } else if (!isFrom && _searchState.draftDestination != null) {
      initialLocation = LatLng(
        _searchState.draftDestination!.latitude,
        _searchState.draftDestination!.longitude,
      );
    }

    final result = await MapLocationPicker.show(
      context,
      title: isFrom
          ? AppLocalizations.of(context).selectPickupLocation
          : AppLocalizations.of(context).selectDestinationTitle,
      initialLocation: initialLocation,
    );

    if (result != null) {
      final locationPoint = LocationPoint(
        address: result.address,
        latitude: result.location.latitude,
        longitude: result.location.longitude,
      );

      if (isFrom) {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setDraftOrigin(locationPoint);
      } else {
        ref
            .read(rideSearchViewModelProvider.notifier)
            .setDraftDestination(locationPoint);
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (normalizedDate == today) {
      return AppLocalizations.of(context).today;
    }

    if (normalizedDate == today.add(const Duration(days: 1))) {
      return AppLocalizations.of(context).tomorrow;
    }
    return DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  Widget _buildResultsList() {
    if (_resultsState.isLoading) {
      return const SliverFillRemaining(
        child: SkeletonLoader(),
      );
    }

    if (_resultsState.error != null) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.error_outline,
          title: _resultsState.hasSearched
              ? AppLocalizations.of(context).searchFailed
              : AppLocalizations.of(context).somethingWentWrong,
          subtitle: _resultsState.hasSearched
              ? _resultsState.error!
              : AppLocalizations.of(context).unableToLoadRidesTryAgain,
          actionText: AppLocalizations.of(context).retry,
          onActionPressed: () {
            if (_resultsState.hasSearched) {
              unawaited(_performSearch());
              return;
            }

            ref.invalidate(activeRidesProvider);
            ref.read(rideSearchViewModelProvider.notifier).resetPagination();
          },
        ),
      );
    }

    if (_resultsState.visibleResults.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: AppLocalizations.of(context).noRidesFound,
          subtitle: AppLocalizations.of(
            context,
          ).tryAdjustingFiltersOrDifferentDate,
          actionText: AppLocalizations.of(context).clearFilters,
          onActionPressed: () {
            ref.read(rideSearchViewModelProvider.notifier).resetFilters();
          },
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: adaptiveScreenPadding(context).left,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Stagger is capped so late rows don't wait seconds to appear
            // and paginated batches don't re-animate slowly.
            final stagger = 50 + (index.clamp(0, 8)) * 60;
            return RepaintBoundary(
              child: _buildRideModelCard(_resultsState.visibleResults[index])
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: stagger),
                  )
                  .slideX(begin: 0.1, curve: Curves.easeOutCubic),
            );
          },
          childCount: _resultsState.visibleResults.length,
        ),
      ),
    );
  }

  Widget _buildRideModelCard(RideModel ride) {
    final departureTimeFormatted = DateFormat(
      'jm',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(ride.departureTime);

    final estimatedArrival = ride.departureTime.add(
      Duration(minutes: ride.durationMinutes ?? 60),
    );

    final arrivalTimeFormatted = DateFormat(
      'jm',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(estimatedArrival);
    final durationFormatted = _formatDuration(ride.durationMinutes ?? 60);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
        border: Border.all(
          color: ride.status == RideStatus.full
              ? AppColors.textSecondary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: AdaptiveTapSurface(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => context.pushNamed(
          AppRoutes.rideDetail.name,
          pathParameters: {'id': ride.id},
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DriverAvatarWidget(driverId: ride.driverId, radius: 22),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DriverNameWidget(
                              driverId: ride.driverId,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.w,
                              runSpacing: 2.h,
                              children: [
                                DriverRatingWidget(
                                  driverId: ride.driverId,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  durationFormatted,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        constraints: BoxConstraints(maxWidth: 92.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          AppLocalizations.of(context).value5(
                            (ride.pricePerSeatInCents / 100).toStringAsFixed(
                              2,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            departureTimeFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            width: 2.w,
                            height: 24.h,
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.primary, AppColors.error],
                              ),
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          ),
                          Text(
                            arrivalTimeFormatted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    ride.origin.address,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    ride.destination.address,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildRideCardBottomBar(ride),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCardBottomBar(RideModel ride) {
    final chips = <Widget>[
      if (ride.status == RideStatus.full)
        RideInfoChip(
          icon: Icons.do_not_disturb_rounded,
          label: AppLocalizations.of(context).fullyBooked.toUpperCase(),
          color: AppColors.textSecondary,
        )
      else
        RideInfoChip(
          icon: Icons.event_seat_rounded,
          label: AppLocalizations.of(context).valueSeats(ride.remainingSeats),
          color: AppColors.primary,
        ),
      if (ride.isEco)
        RideInfoChip(
          icon: Icons.eco_rounded,
          label: AppLocalizations.of(context).eco,
          color: AppColors.success,
        ),
      if (ride.isPremium)
        RideInfoChip(
          icon: Icons.star_rounded,
          label: AppLocalizations.of(context).premium,
          color: AppColors.warning,
        ),
      if (ride.xpReward > 0)
        RideInfoChip(
          icon: Icons.bolt_rounded,
          label: AppLocalizations.of(context).valueXp(ride.xpReward),
          color: AppColors.primary,
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: chips,
            ),
          ),
          SizedBox(width: 8.w),
          _buildBookBadge(ride),
        ],
      ),
    );
  }

  Widget _buildBookBadge(RideModel ride) {
    final isFull = ride.status == RideStatus.full;

    return Opacity(
      opacity: isFull ? 0.45 : 1.0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: responsiveValue<double>(
            context,
            compact: 96,
            medium: 126,
            expanded: 136,
          ).w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isFull ? AppColors.textSecondary : AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          isFull
              ? AppLocalizations.of(context).fullyBooked
              : AppLocalizations.of(context).book,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) return '${hours}h';

    return '${hours}h ${mins}min';
  }

  void _showSortOptions() {
    unawaited(
      AppModalSheet.show<void>(
        context: context,
        maxHeightFactor: 0.55,
        showCloseButton: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).sortBy2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildSortOption(
                        icon: Icons.recommend_rounded,
                        title: AppLocalizations.of(context).recommended,
                        subtitle: AppLocalizations.of(
                          context,
                        ).bestMatchForYourSearch,
                        value: 'recommended',
                      ),
                      _buildSortOption(
                        icon: Icons.arrow_downward_rounded,
                        title: AppLocalizations.of(context).lowestPrice2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showCheapestRidesFirst,
                        value: 'price_low',
                      ),
                      _buildSortOption(
                        icon: Icons.access_time_rounded,
                        title: AppLocalizations.of(context).earliestDeparture2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showRidesLeavingSoonest,
                        value: 'departure',
                      ),
                      _buildSortOption(
                        icon: Icons.star_rounded,
                        title: AppLocalizations.of(context).highestRated2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showBestRatedDriversFirst,
                        value: 'rating',
                      ),
                      _buildSortOption(
                        icon: Icons.timer_rounded,
                        title: AppLocalizations.of(context).shortestDuration,
                        subtitle: AppLocalizations.of(
                          context,
                        ).showFastestRoutesFirst,
                        value: 'duration',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _searchState.draftSortBy == value;

    return AdaptiveListTile(
      onTap: () {
        context.pop();
        unawaited(HapticFeedback.selectionClick());
        ref.read(rideSearchViewModelProvider.notifier).setDraftSortBy(value);
      },
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22.sp,
            )
          : null,
    );
  }
}


