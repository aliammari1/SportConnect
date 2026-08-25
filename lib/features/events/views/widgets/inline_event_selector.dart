import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class InlineEventSelector extends ConsumerStatefulWidget {
  const InlineEventSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final EventModel? selected;
  final ValueChanged<EventModel?> onChanged;

  @override
  ConsumerState<InlineEventSelector> createState() =>
      _InlineEventSelectorState();
}

class _InlineEventSelectorState extends ConsumerState<InlineEventSelector> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _expanded = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String _query = '';
  EventType? _filterType;
  EventPageCursor? _cursor;
  List<EventModel> _events = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: 300.ms,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTrigger(), if (_expanded) _buildExpandedContent()],
      ),
    );
  }

  Widget _buildTrigger() {
    final l10n = AppLocalizations.of(context);
    final hasEvent = widget.selected != null;
    return AnimatedContainer(
      duration: 200.ms,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: hasEvent
            ? widget.selected!.type.color.withValues(alpha: 0.07)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasEvent
              ? widget.selected!.type.color
              : _expanded
              ? AppColors.primary
              : AppColors.border,
          width: hasEvent || _expanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: _toggleExpanded,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: 200.ms,
                      child: Icon(
                        hasEvent
                            ? widget.selected!.type.icon
                            : _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.event_rounded,
                        key: ValueKey(
                          hasEvent ? widget.selected!.id : _expanded,
                        ),
                        size: 20.sp,
                        color: hasEvent
                            ? widget.selected!.type.color
                            : _expanded
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: hasEvent
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selected!.title,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  AppLocaleFormatters.formatShortWeekdayDateTime(
                                    context,
                                    widget.selected!.startsAt,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _expanded
                                  ? l10n.eventLabel
                                  : l10n.searchEventsHint,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _expanded
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasEvent)
            IconButton(
              tooltip: l10n.clear,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                widget.onChanged(null);
                setState(() => _expanded = false);
              },
              icon: Icon(
                Icons.close_rounded,
                size: 20.sp,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Container(
            constraints: BoxConstraints(maxHeight: 420.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),
                      SizedBox(height: 10.h),
                      _buildTypeFilterRow(),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Expanded(child: _buildEventList()),
                Divider(height: 1, color: AppColors.divider),
                _buildFooter(),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.04, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildSearchField() {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.searchEventsHint,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20.sp,
          color: AppColors.textTertiary,
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: l10n.clearSearchTooltip,
                icon: Icon(Icons.close_rounded, size: 18.sp),
                onPressed: _searchController.clear,
              ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTypeFilterRow() {
    final l10n = AppLocalizations.of(context);
    final filters = <EventType?>[null, ...EventType.values];
    return SizedBox(
      height: 34.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final type = filters[index];
          return _filterChip(
            type,
            type?.label ?? l10n.all,
            type?.icon ?? Icons.auto_awesome_rounded,
            type?.color ?? AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _filterChip(
    EventType? type,
    String label,
    IconData icon,
    Color color,
  ) {
    final active = _filterType == type;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(
        selected: active,
        onSelected: (_) {
          unawaited(HapticFeedback.selectionClick());
          _setFilterType(type);
        },
        avatar: Icon(
          icon,
          size: 14.sp,
          color: active ? color : AppColors.textSecondary,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? color : AppColors.textSecondary,
        ),
        selectedColor: color.withValues(alpha: 0.12),
        backgroundColor: AppColors.background,
        shape: StadiumBorder(
          side: BorderSide(
            color: active ? color : AppColors.border,
            width: active ? 1.5 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return _loadingList();

    if (_error != null && _events.isEmpty) {
      return _MessageState(
        icon: Icons.error_outline_rounded,
        title: l10n.errorLoadingData,
        message: _error!,
        actionLabel: l10n.tryAgain,
        onAction: () => unawaited(_loadFirstPage()),
      );
    }

    final visibleEvents = _visibleEvents;

    if (visibleEvents.isEmpty) {
      return _MessageState(
        icon: Icons.search_off_rounded,
        title: l10n.noResultsFound,
        message: _hasMore ? l10n.searchFailedPleaseTryAgain : l10n.tryAgain,
        actionLabel: _hasMore ? l10n.actionContinue : null,
        onAction: _hasMore ? () => unawaited(_loadNextPage()) : null,
      );
    }

    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: visibleEvents.length + 1,
        itemBuilder: (context, index) {
          if (index == visibleEvents.length) return _buildLoadMoreRow();
          return _eventTile(visibleEvents[index]);
        },
      ),
    );
  }

  Widget _eventTile(EventModel event) {
    final isSelected = widget.selected?.id == event.id;
    final diff = event.startsAt.difference(DateTime.now());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: AdaptiveTapSurface(
        color: isSelected
            ? event.type.color.withValues(alpha: 0.08)
            : AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          if (isSelected) {
            widget.onChanged(null);
          } else {
            widget.onChanged(event);
            setState(() => _expanded = false);
          }
        },
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? event.type.color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: event.type.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  event.type.icon,
                  size: 18.sp,
                  color: event.type.color,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      AppLocaleFormatters.formatShortWeekdayDateTime(
                        context,
                        event.startsAt,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      event.location.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: isSelected
                        ? event.type.color
                        : AppColors.textTertiary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _countdown(diff),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: diff.inHours < 24
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: 5,
      itemBuilder: (_, _) =>
          Container(
                height: 72.h,
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                color: Colors.white38,
              ),
    );
  }

  Widget _buildLoadMoreRow() {
    if (_isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
        child: OutlinedButton.icon(
          onPressed: () => unawaited(_loadNextPage()),
          icon: Icon(Icons.refresh_rounded, size: 18.sp),
          label: Text(AppLocalizations.of(context).tryAgain),
        ),
      );
    }

    if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Text(
            AppLocalizations.of(context).completed,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      child: OutlinedButton.icon(
        onPressed: () => unawaited(_loadNextPage()),
        icon: Icon(Icons.expand_more_rounded, size: 18.sp),
        label: Text(AppLocalizations.of(context).actionContinue),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_visibleEvents.length} / ${_events.length} ${AppLocalizations.of(context).events.toLowerCase()}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final created = await context.push<EventModel>(
                AppRoutes.createEvent.path,
              );
              if (created != null && mounted) {
                widget.onChanged(created);
                setState(() => _expanded = false);
              }
            },
            icon: Icon(Icons.add_rounded, size: 18.sp),
            label: Text(
              AppLocalizations.of(context).createEventTitle,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<EventModel> get _visibleEvents {
    final query = _query;
    if (query.isEmpty) return _events;
    return _events.where((event) {
      return event.title.toLowerCase().contains(query) ||
          event.location.address.toLowerCase().contains(query) ||
          (event.organizerName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _toggleExpanded() {
    unawaited(HapticFeedback.selectionClick());
    final shouldExpand = !_expanded;
    setState(() => _expanded = shouldExpand);
    if (shouldExpand && _events.isEmpty && !_isLoading) {
      unawaited(_loadFirstPage());
    }
  }

  void _setFilterType(EventType? type) {
    if (_filterType == type && _events.isNotEmpty) return;
    setState(() {
      _filterType = type;
      _query = '';
      _searchController.clear();
    });
    unawaited(_loadFirstPage());
  }

  void _handleSearchChanged() {
    final next = _searchController.text.trim().toLowerCase();
    if (next == _query) return;
    setState(() => _query = next);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter < 220 &&
        _hasMore &&
        !_isLoading &&
        !_isLoadingMore) {
      unawaited(_loadNextPage());
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _cursor = null;
      _events = const [];
      _error = null;
    });

    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .fetchUpcomingEventsPage(
            type: _filterType,
          );
      if (!mounted) return;
      setState(() {
        _events = page.events;
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _error = null;
    });

    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .fetchUpcomingEventsPage(
            type: _filterType,
            startAfter: _cursor,
          );
      if (!mounted) return;
      final seenIds = _events.map((event) => event.id).toSet();
      final newEvents = page.events
          .where((event) => seenIds.add(event.id))
          .toList(growable: false);

      setState(() {
        _events = [..._events, ...newEvents];
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoadingMore = false;
      });
    }
  }

  String _countdown(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return AppLocalizations.of(context).timeNow;
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34.sp, color: AppColors.textTertiary),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
