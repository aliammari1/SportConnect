import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_segmented_tab_view.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Displays the user's own events split into "Created" and "Joined" tabs.
class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentAuthUidProvider).value ?? '';
    final role = ref.watch(
      currentUserProvider.select(
        (value) => value.whenData((user) => user?.role),
      ),
    );

    final isDriver = role.value == UserRole.driver;
    final l10n = AppLocalizations.of(context);
    final actionButton = AdaptiveFloatingActionButton(
      onPressed: () => context.push(AppRoutes.createEvent.path),
      backgroundColor: AppColors.primary,
      child: Icon(Icons.add_rounded, size: 24.sp),
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 22.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: l10n.myEventsTitle,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthContent,
        child: AppSegmentedTabView(
          tabs: [l10n.myEventsCreatedTab, l10n.myEventsJoinedTab],
          selectedColor: Colors.white,
          backgroundColor: AppColors.primary,
          children: [
            _CreatedTab(userId: userId, isDriver: isDriver),
            _JoinedTab(userId: userId, isDriver: isDriver),
          ],
        ),
      ),
      floatingActionButton: actionButton.animate().scale(
        delay: 300.ms,
        duration: 400.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }
}

// =============================================================================
// Created Tab
// =============================================================================
class _CreatedTab extends ConsumerWidget {
  const _CreatedTab({required this.userId, required this.isDriver});
  final String userId;
  final bool isDriver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (userId.isEmpty) {
      return _EmptyTab(message: l10n.signInFirstMessage, isDriver: isDriver);
    }
    final stream = ref.watch(eventsByCreatorStreamProvider(userId));

    return stream.when(
      loading: () =>
          const SkeletonLoader(type: SkeletonType.eventCard, itemCount: 3),
      error: (_, _) =>
          _EmptyTab(message: l10n.unableToLoadEvents, isDriver: isDriver),
      data: (events) {
        if (events.isEmpty) {
          return _EmptyTab(message: l10n.noCreatedEvents, isDriver: isDriver);
        }
        return _EventListView(events: events);
      },
    );
  }
}

// =============================================================================
// Joined Tab
// =============================================================================
class _JoinedTab extends ConsumerWidget {
  const _JoinedTab({required this.userId, required this.isDriver});
  final String userId;
  final bool isDriver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (userId.isEmpty) {
      return _EmptyTab(message: l10n.signInFirstMessage, isDriver: isDriver);
    }
    final stream = ref.watch(joinedEventsStreamProvider(userId));

    return stream.when(
      loading: () =>
          const SkeletonLoader(type: SkeletonType.eventCard, itemCount: 3),
      error: (_, _) =>
          _EmptyTab(message: l10n.unableToLoadEvents, isDriver: isDriver),
      data: (events) {
        if (events.isEmpty) {
          return _EmptyTab(message: l10n.noJoinedEvents, isDriver: isDriver);
        }
        return _EventListView(events: events);
      },
    );
  }
}

// =============================================================================
// Shared list view
// =============================================================================
class _EventListView extends StatelessWidget {
  const _EventListView({required this.events});
  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        16.h,
        AppSpacing.screenPadding,
        100.h,
      ),
      itemCount: events.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final event = events[index];
        return _MyEventCard(
              event: event,
              dateLabel: AppLocaleFormatters.formatMediumDateTime(
                context,
                event.startsAt.toLocal(),
              ),
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 40 * index.clamp(0, 12)),
              duration: 300.ms,
            )
            .slideY(begin: 0.04, end: 0);
      },
    );
  }
}

// =============================================================================
// Event card
// =============================================================================
class _MyEventCard extends StatelessWidget {
  const _MyEventCard({required this.event, required this.dateLabel});
  final EventModel event;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: () => context.pushNamed(
        AppRoutes.eventDetail.name,
        pathParameters: {'id': event.id},
      ),
      child: Row(
        children: [
          // ── Sport icon ──
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: event.type.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(event.type.icon, size: 26.sp, color: event.type.color),
          ),
          SizedBox(width: 14.w),

          // ── Info ──
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
                SizedBox(height: 4.h),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        event.location.city ?? event.location.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _badge(event),
                    const Spacer(),
                    if (!event.isUpcoming)
                      _statusChip(
                        AppLocalizations.of(context).eventPastStatus,
                        AppColors.textTertiary,
                      ),
                    if (event.isUpcoming && event.isFull)
                      _statusChip(
                        AppLocalizations.of(context).eventFullStatus,
                        AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),
          Icon(
            Icons.chevron_right_rounded,
            size: 22.sp,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _badge(EventModel e) {
    final color = e.isFull ? AppColors.warning : AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.group_rounded, size: 14.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          e.participantLabel,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// Empty tab placeholder
// =============================================================================
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.message,
    required this.isDriver,
  });

  final String message;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 52.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            PremiumButton(
              text: AppLocalizations.of(context).browseEventsButton,
              icon: Icons.explore_rounded,
              size: PremiumButtonSize.small,
              style: PremiumButtonStyle.ghost,
              onPressed: () {
                if (isDriver) {
                  unawaited(context.push(AppRoutes.eventsBrowse.path));
                } else {
                  context.goNamed(
                    AppRoutes.events.name,
                    extra: {'resetBranch': true},
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
