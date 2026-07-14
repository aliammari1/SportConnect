import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_participants_view_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

String _recurrenceLabel(AppLocalizations l10n, RecurrencePattern pattern) {
  return switch (pattern) {
    RecurrencePattern.daily => l10n.every_day,
    RecurrencePattern.weekly => l10n.every_week,
    RecurrencePattern.biweekly => l10n.every_2_weeks,
    RecurrencePattern.monthly => l10n.every_month,
    RecurrencePattern.yearly => l10n.every_year,
  };
}

/// Full-screen event detail with hero banner, info sections and join/leave CTA.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final _dateFormatter = DateFormat('EEE, MMM d · h:mm a');

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  bool _isParticipant(EventModel event, String userId) =>
      event.participantIds.contains(userId);

  bool _isCreator(EventModel event, String userId) => event.creatorId == userId;

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));
    // Select only action states — event content rebuilds handled by eventByIdProvider
    ref.watch(
      eventDetailViewModelProvider(widget.eventId).select(
        (s) => (
          s.isJoining,
          s.isLeaving,
          s.isDeleting,
        ),
      ),
    );
    final detailVm = ref.read(eventDetailViewModelProvider(widget.eventId));
    final currentUser = ref.watch(
      currentUserProvider.select((value) {
        final user = value.value;
        if (user == null) {
          return (uid: '', isPremium: false, isDriver: false);
        }
        final isPremium = switch (user) {
          RiderModel(:final isPremium) => isPremium,
          DriverModel(:final isPremium) => isPremium,
          _ => false,
        };
        return (
          uid: user.uid,
          isPremium: isPremium,
          isDriver: user.role == UserRole.driver,
        );
      }),
    );
    final userId = currentUser.uid;
    final isPremiumSubscriber = currentUser.isPremium;
    final isDriver = currentUser.isDriver;
    // Listen for success / error messages from the view-model.
    ref.listen<EventDetailState>(eventDetailViewModelProvider(widget.eventId), (
      prev,
      next,
    ) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        AdaptiveSnackBar.show(
          context,
          message: next.successMessage!,
          type: AdaptiveSnackBarType.success,
        );
        ref
            .read(eventDetailViewModelProvider(widget.eventId).notifier)
            .clearMessages();
      }
      if (next.error != null && next.error != prev?.error) {
        AdaptiveSnackBar.show(
          context,
          message: next.error!,
          type: AdaptiveSnackBarType.error,
        );
        ref
            .read(eventDetailViewModelProvider(widget.eventId).notifier)
            .clearMessages();
      }
    });

    return AdaptiveScaffold(
      body: eventAsync.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) => _ErrorBody(message: e.toString()),
        data: (event) {
          if (event == null) {
            return _ErrorBody(
              message: AppLocalizations.of(context).eventNotFound,
            );
          }
          return _buildBody(
            event,
            userId,
            detailVm,
            isPremiumSubscriber,
            isDriver,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    EventModel event,
    String userId,
    EventDetailState detailState,
    bool isPremiumSubscriber,
    bool isDriver,
  ) {
    final isOwner = _isCreator(event, userId);
    final isJoined = _isParticipant(event, userId);

    // Two-pane only when there's genuine room (landscape iPad ≥ 1100). In
    // portrait the right pane gets too narrow and its content (e.g. the
    // participants avatar row) overflows — so use the single-column body.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return _buildSingleColumnBody(
            event,
            userId,
            detailState,
            isPremiumSubscriber,
            isDriver,
            isOwner,
            isJoined,
          );
        }
        return _buildTabletBody(
          event,
          userId,
          detailState,
          isPremiumSubscriber,
          isDriver,
          isOwner,
          isJoined,
        );
      },
    );
  }

  Widget _buildSingleColumnBody(
    EventModel event,
    String userId,
    EventDetailState detailState,
    bool isPremiumSubscriber,
    bool isDriver,
    bool isOwner,
    bool isJoined,
  ) {
    return MaxWidthContainer(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero app bar ──
          _buildSliverAppBar(event, isOwner),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // ── Title & type badge ──
                  _TitleSection(event: event)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.05, end: 0),

                  SizedBox(height: 20.h),

                  // ── Date & venue info cards ──
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: _dateFormatter.format(event.startsAt),
                    sublabel: event.endsAt != null
                        ? AppLocalizations.of(
                            context,
                          ).eventUntilDate(_dateFormatter.format(event.endsAt!))
                        : null,
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                  SizedBox(height: 12.h),

                  _OrganizerRow(
                    creatorId: event.creatorId,
                  ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  SizedBox(height: 12.h),

                  // ── Participants chip ──
                  _ParticipantChip(
                    event: event,
                  ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

                  SizedBox(height: 16.h),

                  // ── Status badge ──
                  _StatusBadge(
                    isOwner: isOwner,
                    isJoined: isJoined,
                    event: event,
                  ).animate().fadeIn(delay: 275.ms, duration: 350.ms),

                  SizedBox(height: 24.h),

                  // ── Description ──
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context).eventAbout,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
                    SizedBox(height: 24.h),
                  ],

                  // ── Participant list preview ──
                  if (event.participantIds.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(
                        context,
                      ).eventParticipantsCount(event.participantIds.length),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        AppRoutes.eventAttendees.name,
                        pathParameters: {'id': event.id},
                      ),
                      child: _ParticipantAvatars(
                        participantIds: event.participantIds,
                      ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        AppRoutes.eventAttendees.name,
                        pathParameters: {'id': event.id},
                      ),
                      child: Text(
                        AppLocalizations.of(context).view_all_attendees,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],

                  // ── Action button ──
                  if (!isOwner && event.isUpcoming)
                    _buildJoinLeaveButton(
                      event,
                      userId,
                      isJoined,
                      detailState,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  SizedBox(height: 24.h),

                  if (isOwner && event.isUpcoming)
                    _buildOwnerActions(
                      event,
                      detailState,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  // ── #27: Event Attendee Ride Counter ──
                  if (event.participantIds.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _RideStatusCounter(
                      event: event,
                    ).animate().fadeIn(delay: 410.ms, duration: 350.ms),
                  ],

                  // ── #24: RSVP with Ride Status ──
                  if (!isOwner && isJoined && event.isUpcoming) ...[
                    SizedBox(height: 16.h),
                    _RideStatusSelector(
                      event: event,
                      userId: userId,
                      onStatusSelected: (status) async {
                        unawaited(HapticFeedback.selectionClick());
                        await ref
                            .read(
                              eventDetailViewModelProvider(
                                widget.eventId,
                              ).notifier,
                            )
                            .setRideStatus(userId, status);
                      },
                    ).animate().fadeIn(delay: 420.ms, duration: 350.ms),
                  ],

                  // ── #22: Rides to This Event ──
                  if (event.isUpcoming || event.isOngoing) ...[
                    SizedBox(height: 24.h),
                    _EventRidesSection(
                      eventId: widget.eventId,
                      event: event,
                    ).animate().fadeIn(delay: 430.ms, duration: 350.ms),
                  ],

                  // ── #28: Recurring Event Info ──
                  if (event.isRecurring) ...[
                    SizedBox(height: 16.h),
                    _RecurringEventBadge(
                      event: event,
                    ).animate().fadeIn(delay: 445.ms, duration: 350.ms),
                  ],

                  // ── #32: Cost Split Badge ──
                  if (event.costSplitEnabled) ...[
                    SizedBox(height: 12.h),
                    const _CostSplitBadge().animate().fadeIn(
                      delay: 448.ms,
                      duration: 350.ms,
                    ),
                  ],

                  // ── #30: Post-Event Meetup Pin ──
                  if ((event.isOngoing || event.hasEnded) && isJoined) ...[
                    SizedBox(height: 16.h),
                    _MeetupPinSection(
                      event: event,
                      isOwner: isOwner,
                      onSetPin: () => _setMeetupPin(event),
                    ).animate().fadeIn(delay: 450.ms, duration: 350.ms),
                  ],

                  // ── #29: Event Chat Group ──
                  if (isJoined && event.participantIds.length >= 2) ...[
                    SizedBox(height: 16.h),
                    (isPremiumSubscriber
                            ? _EventChatButton(
                                event: event,
                                onOpenChat: () => _openEventChat(event, userId),
                              )
                            : _EventChatPremiumLockedCard(
                                onUpgradeTap: () =>
                                    context.push(AppRoutes.settings.path),
                              ))
                        .animate()
                        .fadeIn(delay: 455.ms, duration: 350.ms),
                  ],

                  // ── #23: Need Ride Home button ──
                  if ((event.isOngoing || event.hasEnded) && isJoined) ...[
                    SizedBox(height: 16.h),
                    PremiumButton(
                      text: AppLocalizations.of(context).eventNeedRideHome,
                      icon: Icons.home_rounded,
                      style: PremiumButtonStyle.secondary,
                      fullWidth: true,
                      onPressed: () async {
                        unawaited(HapticFeedback.lightImpact());
                        await context.push(
                          AppRoutes.searchRides.path,
                          extra: {
                            'originAddress': event.location.address,
                            'originLat': event.location.latitude,
                            'originLng': event.location.longitude,
                          },
                        );
                      },
                    ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
                  ],

                  // ── Find Rides CTA (#26: Auto-Suggest Carpool) ──
                  if (event.isUpcoming) ...[
                    SizedBox(height: 16.h),
                    PremiumButton(
                      text: AppLocalizations.of(context).eventFindRides,
                      icon: Icons.directions_car_rounded,
                      style: PremiumButtonStyle.secondary,
                      fullWidth: true,
                      onPressed: () => context.push(
                        AppRoutes.searchRides.path,
                        extra: {
                          'destinationAddress': event.location.address,
                          'destinationLat': event.location.latitude,
                          'destinationLng': event.location.longitude,
                        },
                      ),
                    ).animate().fadeIn(delay: 470.ms, duration: 350.ms),
                    SizedBox(height: 8.h),
                    // #21: Offer a ride to this event (Event-Linked Carpool)
                    if (isDriver)
                      PremiumButton(
                        text: AppLocalizations.of(context).eventOfferRide,
                        icon: Icons.add_road_rounded,
                        style: PremiumButtonStyle.ghost,
                        fullWidth: true,
                        onPressed: () async {
                          unawaited(HapticFeedback.lightImpact());
                          await context.push(
                            AppRoutes.driverOfferRide.path,
                            extra: DriverRidePrefill(
                              eventId: event.id,
                              eventName: event.title,
                              destination: LocationPoint(
                                latitude: event.location.latitude,
                                longitude: event.location.longitude,
                                address: event.location.address,
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 480.ms, duration: 350.ms),
                  ],

                  // Bottom safe-area padding
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Tablet body — two-column: event info left, map/attendees right
  // ------------------------------------------------------------------
  Widget _buildTabletBody(
    EventModel event,
    String userId,
    EventDetailState detailState,
    bool isPremiumSubscriber,
    bool isDriver,
    bool isOwner,
    bool isJoined,
  ) {
    final screenPad = adaptiveScreenPadding(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — event info (60%)
        Expanded(
          flex: 3,
          child: _buildSingleColumnBody(
            event,
            userId,
            detailState,
            isPremiumSubscriber,
            isDriver,
            isOwner,
            isJoined,
          ),
        ),
        // Right column — location & attendees (40%)
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 16.h,
              right: screenPad.right,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                // Location section
                if (event.location.address.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).eventLocationTitle,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            event.location.address,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // Attendees section
                if (event.participantIds.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        AppLocalizations.of(context).eventParticipantsCount(
                          event.participantIds.length,
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => context.pushNamed(
                      AppRoutes.eventAttendees.name,
                      pathParameters: {'id': event.id},
                    ),
                    child: _ParticipantAvatars(
                      participantIds: event.participantIds,
                    ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  ),
                ],
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Sliver app bar
  // ------------------------------------------------------------------
  SliverAppBar _buildSliverAppBar(EventModel event, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      stretch: true,
      backgroundColor: event.type.color,
      leading: _CircleBackButton(onTap: () => context.pop()),
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
          onPressed: () => _addToCalendar(event),
        ),
        IconButton(
          icon: Icon(
            Icons.adaptive.share_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
          onPressed: () async {
            final l10n = AppLocalizations.of(context);
            final dateStr = DateFormat(
              'EEE, MMM d · h:mm a',
            ).format(event.startsAt);
            await SharePlus.instance.share(
              ShareParams(
                text: l10n.eventShareText(
                  event.title,
                  AppLocalizations.of(context).running,
                  dateStr,
                  event.location.address,
                  'https://${AppConstants.hostingDomain}/events/detail/${event.id}',
                ),
                sharePositionOrigin: shareSheetOrigin(context),
              ),
            );
          },
        ),
        if (isOwner)
          IconButton(
            icon: Icon(Icons.edit_rounded, color: Colors.white, size: 22.sp),
            onPressed: () => context.pushNamed(
              AppRoutes.editEvent.name,
              pathParameters: {'id': event.id},
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeroBanner(event: event),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Join / Leave button
  // ------------------------------------------------------------------
  Widget _buildJoinLeaveButton(
    EventModel event,
    String userId,
    bool isJoined,
    EventDetailState detailState,
  ) {
    if (isJoined) {
      return PremiumButton(
        text: AppLocalizations.of(context).eventLeave,
        style: PremiumButtonStyle.ghost,
        icon: Icons.logout_rounded,
        fullWidth: true,
        isLoading: detailState.isLeaving,
        onPressed: () async {
          unawaited(HapticFeedback.mediumImpact());
          await ref
              .read(eventDetailViewModelProvider(widget.eventId).notifier)
              .leaveEvent(userId);
        },
      );
    }

    final isFull = event.isFull;
    return PremiumButton(
      text: isFull
          ? AppLocalizations.of(context).eventFull
          : AppLocalizations.of(context).eventJoin,
      icon: isFull ? Icons.block_rounded : Icons.group_add_rounded,
      fullWidth: true,
      isLoading: detailState.isJoining,
      isDisabled: isFull,
      onPressed: isFull
          ? null
          : () async {
              unawaited(HapticFeedback.mediumImpact());
              await ref
                  .read(eventDetailViewModelProvider(widget.eventId).notifier)
                  .joinEvent(userId);
            },
    );
  }

  // ------------------------------------------------------------------
  // Owner action buttons (Edit + Cancel)
  // ------------------------------------------------------------------
  //
  // "Cancel" is the single participant-facing removal action: it always
  // notifies every joined participant (or, when nobody besides the
  // organizer has joined, hard-deletes the event internally since there is
  // no one to notify). A separate hard-"Delete" action used to exist here
  // but was removed because, from a participant's perspective, it had the
  // exact same effect as Cancel while skipping the notification entirely —
  // see [EventDetailViewModel.cancelEvent].
  Widget _buildOwnerActions(EventModel event, EventDetailState detailState) {
    return Column(
      children: [
        PremiumButton(
          text: AppLocalizations.of(context).eventEdit,
          icon: Icons.edit_rounded,
          style: PremiumButtonStyle.secondary,
          fullWidth: true,
          onPressed: () => context.pushNamed(
            AppRoutes.editEvent.name,
            pathParameters: {'id': event.id},
          ),
        ),
        SizedBox(height: 12.h),
        PremiumButton(
          text: AppLocalizations.of(context).actionCancel,
          icon: Icons.event_busy_rounded,
          style: PremiumButtonStyle.danger,
          fullWidth: true,
          isLoading: detailState.isDeleting,
          onPressed: () => _showCancelSheet(event),
        ),
      ],
    );
  }

  Future<void> _showCancelSheet(EventModel event) async {
    final reasonController = TextEditingController();
    final otherParticipantCount = event.participantIds
        .where((id) => id != event.creatorId)
        .length;
    try {
      final confirmed = await AppModalSheet.show<bool>(
      context: context,
      title: AppLocalizations.of(context).actionCancel,
      maxHeightFactor: 0.7,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.viewInsetsOf(context).bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).actionCancel,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              otherParticipantCount > 0
                  ? AppLocalizations.of(
                      context,
                    ).eventCancelParticipantsNotice(otherParticipantCount)
                  : AppLocalizations.of(
                      context,
                    ).eventCancelNoParticipantsNotice,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).eventOptional,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context).actionCancel),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context).actionCancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

      if (confirmed != true || !mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      final reason = reasonController.text.trim();
      final cancelled = await ref
          .read(eventDetailViewModelProvider(widget.eventId).notifier)
          .cancelEvent(reason: reason.isNotEmpty ? reason : null);
      if (cancelled && mounted) context.pop();
    } finally {
      reasonController.dispose();
    }
  }

  /// Opens map to set post-event meetup pin (#30).
  Future<void> _setMeetupPin(EventModel event) async {
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(context).eventSetMeetupPoint,
      initialLocation: event.location.toLatLng(),
    );
    if (result != null && mounted) {
      final pin = LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      );
      await ref
          .read(eventDetailViewModelProvider(widget.eventId).notifier)
          .setMeetupPin(pin);
    }
  }

  Future<void> _openEventChat(EventModel event, String userId) async {
    if (userId.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).value;
    final isPremiumSubscriber = switch (currentUser) {
      final RiderModel rider => rider.isPremium,
      final DriverModel driver => driver.isPremium,
      _ => false,
    };
    if (!isPremiumSubscriber) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: 'Event group chat is available to Premium subscribers only.',
        type: AdaptiveSnackBarType.warning,
      );
      return;
    }

    unawaited(HapticFeedback.lightImpact());

    final chatId = await ref
        .read(eventDetailViewModelProvider(widget.eventId).notifier)
        .ensureEventGroupChat(event, userId);

    if (!mounted || chatId == null) return;

    final receiver = UserModel.rider(
      uid: chatId,
      email: '',
      username: event.title,
      photoUrl: event.imageUrl,
    );

    unawaited(
      context.pushNamed(
        AppRoutes.chatGroup.name,
        pathParameters: {'id': chatId},
        extra: receiver,
      ),
    );
  }

  Future<void> _addToCalendar(EventModel event) async {
    try {
      final start = event.startsAt
          .toUtc()
          .toIso8601String()
          .replaceAll(RegExp(r'\.\d+Z$'), 'Z')
          .replaceAll(RegExp('[-:]'), '');
      final end = (event.endsAt ?? event.startsAt.add(const Duration(hours: 2)))
          .toUtc()
          .toIso8601String()
          .replaceAll(RegExp(r'\.\d+Z$'), 'Z')
          .replaceAll(RegExp('[-:]'), '');
      final title = Uri.encodeComponent(event.title);
      final location = Uri.encodeComponent(event.location.address);
      final details = Uri.encodeComponent(
        event.description ??
            '${AppLocalizations.of(context).running} on SportConnect',
      );

      // Build base URL parameters
      var urlString =
          'https://calendar.google.com/calendar/render'
          '?action=TEMPLATE'
          '&text=$title'
          '&dates=$start/$end'
          '&location=$location'
          '&details=$details';

      // Build recurrence rule (RRULE) if event is recurring
      // RFC-5545 format: RRULE:FREQ=WEEKLY
      if (event.isRecurring) {
        // Build RRULE according to RFC-5545 spec using recurrence pattern
        if (event.recurringPattern != null) {
          final freqPart = event.recurringPattern!.rruleFreq;

          if (event.recurringEndDate != null) {
            // Format end date as iCal timestamp: YYYYMMDDTHHMMSSZ (no milliseconds)
            final untilDate = event.recurringEndDate!
                .toUtc()
                .toIso8601String()
                .replaceAll(
                  RegExp(r'\.\d+Z$'),
                  'Z',
                ) // Remove milliseconds (.000Z)
                .replaceAll(RegExp('[-:]'), ''); // Remove dashes and colons

            // RRULE:FREQ=DAILY;UNTIL=20260630T235959Z
            // RRULE:FREQ=WEEKLY;UNTIL=20260630T235959Z
            // RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=20260630T235959Z
            // RRULE:FREQ=MONTHLY;UNTIL=20260630T235959Z
            final rrule = 'RRULE:FREQ=$freqPart;UNTIL=$untilDate';
            urlString += '&recur=${Uri.encodeComponent(rrule)}';
          } else {
            // No end date
            final rrule = 'RRULE:FREQ=$freqPart';
            urlString += '&recur=${Uri.encodeComponent(rrule)}';
          }
        }
      }

      final url = Uri.parse(urlString);

      // Check if URL can be launched before attempting
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) {
          final message = event.isRecurring
              ? AppLocalizations.of(context).opening_google_calendar_recurring(
                  event.recurringPattern != null
                      ? _recurrenceLabel(
                          AppLocalizations.of(context),
                          event.recurringPattern!,
                        )
                      : AppLocalizations.of(context).custom_label,
                )
              : AppLocalizations.of(context).opening_google_calendar;
          AdaptiveSnackBar.show(
            context,
            message: message,
            type: AdaptiveSnackBarType.success,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        if (mounted) {
          AdaptiveSnackBar.show(
            context,
            message: AppLocalizations.of(
              context,
            ).could_not_open_calendar_please_ensure_google_calendar_is_available,
            type: AdaptiveSnackBarType.error,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } on Exception {
      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(
            context,
          ).could_not_open_calendar_please_ensure_google_calendar_is_available,
          type: AdaptiveSnackBarType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

}

// =============================================================================
// PRIVATE WIDGETS
// =============================================================================

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          radius: 18.r,
          child: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: event.imageUrl!,
            fit: BoxFit.cover,
            memCacheWidth: 800,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  event.type.color.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          _SportOverlay(event: event),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [event.type.color, event.type.color.withValues(alpha: 0.7)],
        ),
      ),
      child: _SportOverlay(event: event),
    );
  }
}

class _SportOverlay extends StatelessWidget {
  const _SportOverlay({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(event.type.icon, size: 52.sp, color: Colors.white70),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).running,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sport type is already shown on the hero overlay above; avoid
        // duplicating it here and lead directly with the event title.
        Text(
          event.title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.sublabel});

  final IconData icon;
  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (sublabel != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    sublabel!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerRow extends ConsumerWidget {
  const _OrganizerRow({required this.creatorId});
  final String creatorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizer = ref.watch(
      userProfileProvider(creatorId).select((a) => a.value),
    );
    final name = organizer?.username ?? 'Organizer';

    return PremiumCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: organizer?.photoUrl != null
                ? CachedNetworkImageProvider(organizer!.photoUrl!)
                : null,
            child: organizer?.photoUrl == null
                ? Icon(
                    Icons.person_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context).eventOrganizer,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final color = event.isFull ? AppColors.warning : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_rounded, size: 18.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            event.participantLabel,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (event.seatsLeft > 0) ...[
            SizedBox(width: 4.w),
            Text(
              '· ${AppLocalizations.of(context).eventSeatsLeftCount(event.seatsLeft)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends ConsumerWidget {
  const _ParticipantAvatars({required this.participantIds});
  final List<String> participantIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCount = participantIds.length.clamp(0, 8);
    final overflow = participantIds.length - displayCount;

    // Resolve only the first N visible avatars through a single batched
    // provider instead of one Firestore document listener per avatar.
    final displayIds = participantIds.take(displayCount);
    final profiles = ref
            .watch(
              eventParticipantProfilesProvider(
                eventParticipantProfilesKey(displayIds),
              ),
            )
            .value ??
        const <String, UserModel>{};

    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      children: [
        ...List.generate(displayCount, (i) {
          return _ParticipantAvatar(
            photoUrl: profiles[participantIds[i]]?.photoUrl,
          );
        }),
        if (overflow > 0)
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary,
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.photoUrl});
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: AppColors.primarySurface,
      backgroundImage: url != null
          ? CachedNetworkImageProvider(url)
          : null,
      child: url == null
          ? Icon(
              Icons.person_rounded,
              size: 18.sp,
              color: AppColors.primary,
            )
          : null,
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: AppLocalizations.of(context).goBack,
              style: PremiumButtonStyle.ghost,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge — shows the user's relationship to the event ──
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isOwner,
    required this.isJoined,
    required this.event,
  });

  final bool isOwner;
  final bool isJoined;
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (IconData icon, String label, Color color) = switch ((
      isOwner,
      isJoined,
      event.isUpcoming,
    )) {
      (true, _, true) => (
        Icons.stars_rounded,
        l10n.eventYouAreOrganizer,
        AppColors.primary,
      ),
      (true, _, false) => (
        Icons.stars_rounded,
        l10n.eventOrganizedThis,
        AppColors.textTertiary,
      ),
      (false, true, true) => (
        Icons.check_circle_rounded,
        l10n.eventYoureGoing,
        AppColors.success,
      ),
      (false, true, false) => (
        Icons.check_circle_rounded,
        l10n.eventYouAttended,
        AppColors.textTertiary,
      ),
      (false, false, true) => (
        Icons.info_outline_rounded,
        l10n.eventNotJoinedYet,
        AppColors.warning,
      ),
      _ => (
        Icons.event_busy_rounded,
        l10n.eventHasEnded,
        AppColors.textTertiary,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (event.isUpcoming) ...[
            _CountdownText(startsAt: event.startsAt, color: color),
          ],
        ],
      ),
    );
  }
}

// ── Relative countdown text (e.g. "In 2h 15m") ──
class _CountdownText extends StatelessWidget {
  const _CountdownText({required this.startsAt, required this.color});

  final DateTime startsAt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final diff = startsAt.difference(DateTime.now());
    if (diff.isNegative) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final String text;
    if (diff.inDays > 0) {
      text = l10n.eventCountdownDaysHours(
        diff.inDays,
        diff.inHours.remainder(24),
      );
    } else if (diff.inHours > 0) {
      text = l10n.eventCountdownHoursMinutes(
        diff.inHours,
        diff.inMinutes.remainder(60),
      );
    } else {
      text = l10n.eventCountdownMinutes(diff.inMinutes);
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

// ── #27: Ride Status Counter ──
class _RideStatusCounter extends StatelessWidget {
  const _RideStatusCounter({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final driving = event.driversCount;
    final needRide = event.needRideCount;
    final selfArranged = event.selfArrangedCount;

    if (driving == 0 && needRide == 0 && selfArranged == 0) {
      return const SizedBox.shrink();
    }

    return PremiumCard(
      child: Row(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 18.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              event.rideStatusSummary,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── #24: Ride Status Selector (I'm driving / Need ride / Self-arranged) ──
class _RideStatusSelector extends StatelessWidget {
  const _RideStatusSelector({
    required this.event,
    required this.userId,
    required this.onStatusSelected,
  });

  final EventModel event;
  final String userId;
  final ValueChanged<String> onStatusSelected;

  static List<(String, IconData, String)> _options(AppLocalizations l10n) => [
    ('driving', Icons.directions_car_rounded, l10n.eventImDriving),
    ('need_ride', Icons.hail_rounded, l10n.eventNeedRide),
    (
      'self_arranged',
      Icons.check_circle_outline_rounded,
      l10n.eventSelfArranged,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = event.rideStatusFor(userId);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventHowGettingThere,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _options(l10n).map((opt) {
            final (value, icon, label) = opt;
            final selected = current == value;
            return ChoiceChip(
              avatar: Icon(
                icon,
                size: 18.sp,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              label: Text(label),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
              onSelected: (_) => onStatusSelected(value),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.textTertiary.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── #22: Event Rides Section (rides linked to this event) ──
class _EventRidesSection extends ConsumerWidget {
  const _EventRidesSection({required this.eventId, required this.event});

  final String eventId;
  final EventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(eventLinkedRidesProvider(eventId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_car_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context).eventRidesToEvent,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ridesAsync.when(
          data: (rides) {
            if (rides.isEmpty) {
              return PremiumCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.no_transfer_rounded,
                          size: 32.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context).eventNoRidesOffered,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final ride in rides.take(5))
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _EventRideTile(ride: ride),
                  ),
              ],
            );
          },
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, _) => PremiumCard(
            child: Center(
              child: Text(
                AppLocalizations.of(context).eventCouldNotLoadRides,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Single ride tile for event rides list ──
class _EventRideTile extends StatelessWidget {
  const _EventRideTile({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    return PremiumCard(
      onTap: () =>
          context.push(AppRoutes.rideDetail.path.replaceFirst(':id', ride.id)),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ride.origin.address} → ${ride.destination.address}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${timeFormat.format(ride.departureTime)} · ${AppLocalizations.of(context).valueSeatsLeft(ride.remainingSeats)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

// ── #28: Recurring Event Badge ──
class _RecurringEventBadge extends StatelessWidget {
  const _RecurringEventBadge({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patternText = event.recurringPattern != null
        ? _recurrenceLabel(l10n, event.recurringPattern!)
        : l10n.recurringSummaryLabel;

    final endStr = event.recurringEndDate != null
        ? ' ${l10n.eventUntilDate(DateFormat('MMM d').format(event.recurringEndDate!))}'
        : '';

    return PremiumCard(
      child: Row(
        children: [
          Icon(Icons.repeat_rounded, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventRecurringTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$patternText$endStr',
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
    );
  }
}

// ── #32: Cost Split Badge ──
class _CostSplitBadge extends StatelessWidget {
  const _CostSplitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            AppLocalizations.of(context).eventCostSplitEnabled,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── #30: Meetup Pin Section ──
class _MeetupPinSection extends StatelessWidget {
  const _MeetupPinSection({
    required this.event,
    required this.isOwner,
    required this.onSetPin,
  });

  final EventModel event;
  final bool isOwner;
  final VoidCallback onSetPin;

  @override
  Widget build(BuildContext context) {
    final pin = event.meetupPinLocation;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pin_drop_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).eventMeetupPoint,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (pin != null)
            Text(
              pin.address,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            )
          else if (isOwner)
            PremiumButton(
              text: AppLocalizations.of(context).eventSetMeetupPoint,
              icon: Icons.add_location_alt_rounded,
              style: PremiumButtonStyle.ghost,
              size: PremiumButtonSize.small,
              onPressed: onSetPin,
            )
          else
            Text(
              AppLocalizations.of(context).eventNoMeetupPoint,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }
}

// ── #29: Event Chat Button ──
class _EventChatButton extends StatelessWidget {
  const _EventChatButton({required this.event, required this.onOpenChat});

  final EventModel event;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      text: AppLocalizations.of(context).eventGroupChat,
      icon: Icons.chat_bubble_outline_rounded,
      style: PremiumButtonStyle.secondary,
      fullWidth: true,
      onPressed: onOpenChat,
    );
  }
}

class _EventChatPremiumLockedCard extends StatelessWidget {
  const _EventChatPremiumLockedCard({required this.onUpgradeTap});

  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.warning, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).premium_event_chat,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(
              context,
            ).subscribe_to_premium_to_join_attendee_group_chats_for_events,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          PremiumButton(
            text: AppLocalizations.of(context).upgrade_to_premium,
            icon: Icons.workspace_premium_rounded,
            style: PremiumButtonStyle.ghost,
            size: PremiumButtonSize.small,
            onPressed: onUpgradeTap,
          ),
        ],
      ),
    );
  }
}
