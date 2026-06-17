import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/events/views/event_detail_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Browse / discover upcoming events, filter by sport type.
class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  String? _selectedEventId;

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(eventListViewModelProvider);
    final selectedEventId =
        vm.filteredEvents.any(
          (event) => event.id == _selectedEventId,
        )
        ? _selectedEventId
        : null;

    return AdaptiveScaffold(
      body: AdaptiveMasterDetailScaffold(
        master: _buildEventListBody(context, ref, vm, isTabletMaster: true),
        detail: _buildTabletDetail(context, selectedEventId),
        phone: _buildEventListBody(context, ref, vm),
      ),
      floatingActionButton: _buildCreateEventFab(context),
    );
  }

  Widget _buildEventListBody(
    BuildContext context,
    WidgetRef ref,
    EventListState vm, {
    bool isTabletMaster = false,
  }) {
    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshEvents(ref),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: _buildEventSlivers(
          context,
          ref,
          vm,
          isTabletMaster: isTabletMaster,
        ),
      ),
    );
  }

  Future<void> _refreshEvents(WidgetRef ref) async {
    ref.invalidate(eventListViewModelProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  List<Widget> _buildEventSlivers(
    BuildContext context,
    WidgetRef ref,
    EventListState vm, {
    required bool isTabletMaster,
  }) {
    return [
      // ── Header ──
      _buildAppBar(context),

      // ── Search bar ──
      SliverToBoxAdapter(child: _buildSearchBar(context, ref, vm)),

      // ── Filter chips ──
      SliverToBoxAdapter(child: _buildFilterChips(context, ref, vm)),

      // ── Event list ──
      if (vm.isLoading)
        const SliverToBoxAdapter(
          child: SkeletonLoader(
            type: SkeletonType.eventCard,
          ),
        )
      else if (vm.error != null)
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 12.h),
                Text(
                  AppLocalizations.of(context).unableToLoadData,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                TextButton.icon(
                  onPressed: () => ref.invalidate(eventListViewModelProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        )
      else if (vm.filteredEvents.isEmpty)
        SliverFillRemaining(
          child: _buildEmptyState(context, vm.filterType),
        )
      else if (isTabletMaster)
        _buildTabletEventList(context, vm.filteredEvents)
      else
        _buildEventList(context, vm.filteredEvents),
    ];
  }

  Widget _buildTabletDetail(BuildContext context, String? selectedEventId) {
    if (selectedEventId == null) {
      final l10n = AppLocalizations.of(context);
      return TabletEmptyDetail(
        icon: Icons.event_note_rounded,
        title: l10n.viewDetails,
        message: l10n.searchEventsHint,
      );
    }

    return EventDetailScreen(
      key: ValueKey(selectedEventId),
      eventId: selectedEventId,
    );
  }

  Widget _buildCreateEventFab(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => context.push(AppRoutes.createEvent.path),
      backgroundColor: AppColors.primary,
      icon: Icon(Icons.add_rounded, size: 22.sp),
      label: Text(
        AppLocalizations.of(context).createLabel,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    ).animate().scale(
      delay: 300.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  void _selectEvent(String eventId) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _selectedEventId = eventId);
  }

  // -------------------------------------------------------------------
  // App bar
  // -------------------------------------------------------------------
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: context.canPop()
          ? IconButton(
              tooltip: AppLocalizations.of(context).goBackTooltip,
              icon: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 22.sp,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(
        AppLocalizations.of(context).discoverEventsTitle,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
    );
  }

  // -------------------------------------------------------------------
  // Search bar
  // -------------------------------------------------------------------
  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    EventListState vm,
  ) {
    final pad = adaptiveScreenPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad.left,
        4.h,
        pad.right,
        8.h,
      ),
      child: TextField(
        key: ValueKey(vm.searchFieldKey),
        textInputAction: TextInputAction.search,
        onChanged: (v) =>
            ref.read(eventListViewModelProvider.notifier).setSearchQuery(v),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).searchEventsHint,
          hintText: AppLocalizations.of(context).searchEventsHint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: AppColors.textTertiary,
          ),
          suffixIcon: vm.searchQuery.isNotEmpty
              ? IconButton(
                  tooltip: AppLocalizations.of(context).clearSearchTooltip,
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                  onPressed: () => ref
                      .read(eventListViewModelProvider.notifier)
                      .clearSearch(),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // -------------------------------------------------------------------
  // Filter chips
  // -------------------------------------------------------------------
  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    EventListState vm,
  ) {
    final pad = adaptiveScreenPadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: pad.left),
            children: [
              _FilterChip(
                label: AppLocalizations.of(context).filterAll,
                isSelected: vm.filterType == null,
                onTap: () => ref
                    .read(eventListViewModelProvider.notifier)
                    .setFilterType(null),
              ),
              ...EventType.values.map((type) {
                return _FilterChip(
                  label: type.label,
                  icon: type.icon,
                  color: type.color,
                  isSelected: vm.filterType == type,
                  onTap: () => ref
                      .read(eventListViewModelProvider.notifier)
                      .setFilterType(vm.filterType == type ? null : type),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad.left),
          child: GestureDetector(
            onTap: () async {
              await _showRadiusPicker(context, ref, vm);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: vm.hasLocationFilter
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: vm.hasLocationFilter
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vm.isLoadingLocation)
                    SizedBox(
                      width: 14.w,
                      height: 14.h,
                      child: const CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  else
                    Icon(
                      Icons.near_me_rounded,
                      size: 14.sp,
                      color: vm.hasLocationFilter
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  SizedBox(width: 6.w),
                  Text(
                    vm.hasLocationFilter
                        ? AppLocalizations.of(context).withinValueKm(
                            vm.radiusKm!.toInt(),
                          )
                        : AppLocalizations.of(context).nearMe,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: vm.hasLocationFilter
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (vm.hasLocationFilter) ...[
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => ref
                          .read(eventListViewModelProvider.notifier)
                          .clearRadiusFilter(),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Future<void> _showRadiusPicker(
    BuildContext context,
    WidgetRef ref,
    EventListState vm,
  ) async {
    final options = [5.0, 10.0, 25.0, 50.0];
    final chosen = await AppModalSheet.show<double?>(
      context: context,
      title: AppLocalizations.of(context).events_near_me,
      maxHeightFactor: 0.6,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              AppLocalizations.of(context).events_near_me,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...options.map(
                      (km) => AdaptiveListTile(
                        leading: Icon(
                          Icons.radio_button_checked_rounded,
                          color: vm.radiusKm == km
                              ? AppColors.primary
                              : AppColors.border,
                          size: 20.sp,
                        ),
                        title: Text(
                          AppLocalizations.of(
                            context,
                          ).withinValueKm(km.toInt()),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(km),
                      ),
                    ),
                    const Divider(),
                    AdaptiveListTile(
                      leading: Icon(
                        Icons.public_rounded,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        AppLocalizations.of(context).everywhere,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(-1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (chosen == null || !context.mounted) return;
    if (chosen < 0) {
      ref.read(eventListViewModelProvider.notifier).clearRadiusFilter();
      return;
    }

    await ref
        .read(eventListViewModelProvider.notifier)
        .applyRadiusFilterWithLocation(chosen);
  }

  // -------------------------------------------------------------------
  // Event list
  // -------------------------------------------------------------------
  SliverPadding _buildEventList(BuildContext context, List<EventModel> events) {
    final crossAxisCount = responsiveValue<int>(
      context,
      phone: 1,
      tablet: 2,
      desktop: 3,
    );
    final screenPadding = adaptiveScreenPadding(context);

    if (crossAxisCount > 1) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          screenPadding.left,
          16.h,
          screenPadding.right,
          100.h,
        ),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final event = events[index];
              return _EventCard(event: event)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 50 * index.clamp(0, 10)),
                    duration: 350.ms,
                  )
                  .slideY(begin: 0.04, end: 0);
            },
            childCount: events.length,
          ),
          // Use a fixed main-axis extent instead of childAspectRatio so the
          // card height tracks its content and does NOT scale with the
          // (much wider) cell width on tablet/desktop grids. A width-derived
          // aspect ratio caused vertical overflow stripes on iPad where the
          // cells are wide but the content (image + scaled text rows) needs a
          // bounded, predictable height.
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            mainAxisExtent: 260.h,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        screenPadding.left,
        16.h,
        screenPadding.right,
        100.h,
      ),
      sliver: SliverList.separated(
        itemCount: events.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final event = events[index];
          return _EventCard(event: event)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 50 * index.clamp(0, 10)),
                duration: 350.ms,
              )
              .slideY(begin: 0.04, end: 0);
        },
      ),
    );
  }

  SliverPadding _buildTabletEventList(
    BuildContext context,
    List<EventModel> events,
  ) {
    final screenPadding = adaptiveScreenPadding(context);

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        screenPadding.left,
        16.h,
        screenPadding.right,
        100.h,
      ),
      sliver: SliverList.separated(
        itemCount: events.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: AppSpacing.listItemSpacing),
        itemBuilder: (context, index) {
          final event = events[index];
          return _TabletEventListItem(
                event: event,
                isSelected: event.id == _selectedEventId,
                onTap: () => _selectEvent(event.id),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 40 * index.clamp(0, 10)),
                duration: 300.ms,
              )
              .slideY(begin: 0.03, end: 0);
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Empty state
  // -------------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context, EventType? filterType) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 56.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noEventsFound,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              filterType != null
                  ? AppLocalizations.of(
                      context,
                    ).noEventsInCategory(filterType.label.toLowerCase())
                  : AppLocalizations.of(context).beFirstToCreate,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: AppLocalizations.of(context).eventCreateButton,
              icon: Icons.add_rounded,
              size: PremiumButtonSize.small,
              onPressed: () => context.push(AppRoutes.createEvent.path),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = isSelected
        ? (color ?? AppColors.primary)
        : AppColors.textTertiary;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap();
        },
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? chipColor : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: chipColor),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? chipColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletEventListItem extends StatelessWidget {
  const _TabletEventListItem({
    required this.event,
    required this.isSelected,
    required this.onTap,
  });

  final EventModel event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = AppLocaleFormatters.formatMediumDateTime(
      context,
      event.startsAt.toLocal(),
    );
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final typeColor = event.type.color;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusXl,
          child: AnimatedContainer(
            duration: 200.ms,
            constraints: BoxConstraints(minHeight: AppSpacing.buttonHeightLg),
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySurface : AppColors.surface,
              borderRadius: AppSpacing.borderRadiusXl,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? AppSpacing.shadowMd : AppSpacing.shadowSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSpacing.buttonHeightMd,
                  height: AppSpacing.buttonHeightMd,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: AppSpacing.borderRadiusLg,
                  ),
                  child: Icon(
                    event.type.icon,
                    size: 22.sp,
                    color: typeColor,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      _TabletEventMetaRow(
                        icon: Icons.calendar_today_rounded,
                        label: dateLabel,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      _TabletEventMetaRow(
                        icon: Icons.location_on_rounded,
                        label: event.location.city ?? event.location.address,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: _TabletEventPill(
                              icon: event.type.icon,
                              label: event.type.label,
                              color: typeColor,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: _TabletEventPill(
                              icon: Icons.group_rounded,
                              label: event.participantLabel,
                              color: event.isFull
                                  ? AppColors.warning
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabletEventMetaRow extends StatelessWidget {
  const _TabletEventMetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _TabletEventPill extends StatelessWidget {
  const _TabletEventPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = AppLocaleFormatters.formatMediumDateTime(
      context,
      event.startsAt.toLocal(),
    );
    return PremiumCard(
      onTap: () => context.pushNamed(
        AppRoutes.eventDetail.name,
        pathParameters: {'id': event.id},
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image banner or colour fallback ──
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: SizedBox(
              height: 90.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient base — always visible
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          event.type.color,
                          event.type.color.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: event.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, err) =>
                          const SizedBox.shrink(),
                    ),
                  // Watermark icon
                  Center(
                    child: Icon(
                      event.type.icon,
                      size: 40.sp,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  // Type badge
                  Positioned(
                    top: 10.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!event.isUpcoming)
                    Positioned(
                      top: 10.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          AppLocalizations.of(context).eventPastStatus,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Details ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                _iconRow(
                  Icons.calendar_today_rounded,
                  dateLabel,
                ),
                SizedBox(height: 4.h),
                _iconRow(
                  Icons.location_on_rounded,
                  event.location.city ?? event.location.address,
                ),
                if (event.organizerName != null &&
                    event.organizerName!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  _iconRow(
                    Icons.person_outline_rounded,
                    AppLocalizations.of(
                      context,
                    ).eventByOrganizer(event.organizerName!),
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _participantBadge(),
                    const Spacer(),
                    if (event.isUpcoming && !event.isFull)
                      Text(
                        AppLocalizations.of(context).eventJoinArrow,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    if (event.isFull)
                      Text(
                        AppLocalizations.of(context).eventFullStatus,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textTertiary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _participantBadge() {
    final color = event.isFull ? AppColors.warning : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_rounded, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            event.participantLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
