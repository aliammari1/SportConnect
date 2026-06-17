import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/rating_value.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/services/ride_request_service.dart';
import 'package:sport_connect/features/rides/view_models/driver_requests_view_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/features/rides/views/driver/driver_view_ride_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────────────────

class DriverMyRidesScreen extends ConsumerStatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  ConsumerState<DriverMyRidesScreen> createState() =>
      _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends ConsumerState<DriverMyRidesScreen> {
  String? _selectedRideId;

  // Must match AdaptiveMasterDetailScaffold's threshold, else a tap selects a
  // detail with no pane to render it (stuck on the list on iPad portrait).
  bool get _usesTwoPaneLayout => context.screenWidth >= kTwoPaneMinWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeRide = ref.watch(
      activeDriverRideProvider.select((a) => a.value),
    );
    final pendingRequests = ref.watch(pendingRideRequestsProvider);
    final upcomingRides = ref.watch(upcomingDriverRidesProvider);

    return AdaptiveScaffold(
      body: AdaptiveMasterDetailScaffold(
        master: _buildRideList(
          activeRide: activeRide,
          pendingRequests: pendingRequests,
          upcomingRides: upcomingRides,
        ),
        detail: _buildTabletDetail(l10n),
        phone: _buildRideList(
          activeRide: activeRide,
          pendingRequests: pendingRequests,
          upcomingRides: upcomingRides,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.driverOfferRide.path),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.offerRide),
      ),
    );
  }

  Widget _buildRideList({
    required RideModel? activeRide,
    required AsyncValue<List<RideBooking>> pendingRequests,
    required AsyncValue<List<RideModel>> upcomingRides,
  }) {
    return RefreshIndicator.adaptive(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait<Object?>([
          ref.refresh(activeDriverRideProvider.future),
          ref.refresh(pendingRideRequestsProvider.future),
          ref.refresh(upcomingDriverRidesProvider.future),
          ref.refresh(pastDriverRidesProvider.future),
        ]);
      },
      child: CustomScrollView(
        slivers: [
          _DriverSliverAppBar(
            onOfferRide: () => context.push(AppRoutes.driverOfferRide.path),
          ),
          // ── Active + pending group ────────────────────────
          MultiSliver(
            children: [
              if (activeRide != null)
                SliverToBoxAdapter(
                  child: _ActiveRideBanner(ride: activeRide),
                ),
              SliverToBoxAdapter(
                child: _PendingRequestsSection(
                  requestsAsync: pendingRequests,
                  onRideTap: _selectRideInDetailPane,
                ),
              ),
            ],
          ),
          // ── Rides history group ───────────────────────────
          MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: _UpcomingRidesSection(
                  ridesAsync: upcomingRides,
                  onRideTap: _openRide,
                ),
              ),
              SliverToBoxAdapter(
                child: _HistorySection(
                  ridesAsync: ref.watch(pastDriverRidesProvider),
                  onRideTap: _openRide,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  Widget _buildTabletDetail(AppLocalizations l10n) {
    final selectedRideId = _selectedRideId;
    if (selectedRideId == null) {
      return TabletEmptyDetail(
        icon: Icons.directions_car_outlined,
        title: l10n.rideDetails,
        message: l10n.noRidesYetSubtitle,
      );
    }

    return DriverViewRideScreen(
      key: ValueKey('driver_ride_$selectedRideId'),
      rideId: selectedRideId,
    );
  }

  void _openRide(String rideId) {
    if (_usesTwoPaneLayout) {
      setState(() => _selectedRideId = rideId);
      return;
    }

    context.pushNamed(
      AppRoutes.driverViewRide.name,
      pathParameters: {'id': rideId},
    );
  }

  void _selectRideInDetailPane(String rideId) {
    if (!_usesTwoPaneLayout) return;
    setState(() => _selectedRideId = rideId);
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIVER APP BAR
// ─────────────────────────────────────────────────────────────────

class _DriverSliverAppBar extends StatelessWidget {
  const _DriverSliverAppBar({required this.onOfferRide});
  final VoidCallback onOfferRide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateStr = AppLocaleFormatters.formatWeekdayDayMonth(context, now);

    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () => context.pushNamed(AppRoutes.driverRequests.name),
          icon: const Icon(Icons.inbox_rounded),
          tooltip: AppLocalizations.of(context).viewRequestsTooltip,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        title: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children: [
              TextSpan(
                text: '${l10n.driverMyRidesTitle}\n',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              TextSpan(
                text: dateStr,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE RIDE BANNER
// ─────────────────────────────────────────────────────────────────

class _ActiveRideBanner extends StatelessWidget {
  const _ActiveRideBanner({required this.ride});
  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: GestureDetector(
        onTap: () => context.push(
          '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PulsingDot(),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rideInProgress,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${ride.origin.address} → ${ride.destination.address}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${l10n.valueValuePassengers(ride.bookedSeats, ride.capacity.available)} · '
                      '${l10n.value5((ride.pricePerSeatInCents / 100).toStringAsFixed(2))} ${l10n.perSeat2}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  l10n.view,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .scaleXY(begin: 1, end: 1.5, duration: 800.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(begin: 1.5, end: 1, duration: 800.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────────
// PENDING REQUESTS SECTION
// ─────────────────────────────────────────────────────────────────

class _PendingRequestsSection extends StatelessWidget {
  const _PendingRequestsSection({
    required this.requestsAsync,
    required this.onRideTap,
  });

  final AsyncValue<List<RideBooking>> requestsAsync;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.pendingRequestsTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              requestsAsync.maybeWhen(
                data: (list) => list.isNotEmpty
                    ? _Badge(count: list.length)
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          requestsAsync.when(
            loading: () => const SkeletonLoader(
              type: SkeletonType.compactTile,
              itemCount: 3,
            ),
            error: (e, _) => _InlineError(message: l10n.couldNotLoadRequests),
            data: (requests) {
              if (requests.isEmpty) {
                return const _InlineEmpty(
                  icon: Icons.inbox_rounded,
                  label: 'No pending requests',
                );
              }
              return Column(
                children: [
                  for (final request in requests)
                    _PendingRequestCard(
                      request: request,
                      onTap: () => onRideTap(request.rideId),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PENDING REQUEST CARD
// ─────────────────────────────────────────────────────────────────

class _PendingRequestCard extends ConsumerWidget {
  const _PendingRequestCard({
    required this.request,
    this.onTap,
  });

  final RideBooking request;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(
      userProfileProvider(request.passengerId).select((a) => a.value),
    );
    final ride = ref.watch(
      requestCardRideProvider(request.rideId).select((a) => a.value),
    );

    final passengerName = profile?.username ?? '…';
    final passengerPhoto = profile?.photoUrl;
    final passengerRating = profile?.asRider?.rating.average ?? 0.0;
    final pricePerSeatInCents = ride?.pricePerSeatInCents ?? 0.0;
    final pickupAddress =
        request.pickupLocation?.address ?? ride?.origin.address ?? '…';
    final dropoffAddress =
        request.dropoffLocation?.address ?? ride?.destination.address ?? '…';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger header
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: passengerPhoto != null
                      ? CachedNetworkImageProvider(passengerPhoto)
                      : null,
                  backgroundColor: AppColors.primarySurface,
                  child: passengerPhoto == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 20.sp,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passengerName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      RatingValue(
                        rating: passengerRating,
                        iconSize: 13,
                        starColor: AppColors.accent,
                        gap: 3,
                        valueStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.value5(
                        (pricePerSeatInCents / 100).toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '× ${request.seatsBooked} ${l10n.seatsCount(request.seatsBooked)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Route info
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.radio_button_checked_rounded,
                    color: AppColors.primary,
                    label: l10n.pickupLabel,
                    address: pickupAddress,
                  ),
                  SizedBox(height: 6.h),
                  _RoutePoint(
                    icon: Icons.location_on_rounded,
                    color: AppColors.error,
                    label: l10n.dropoffLabel,
                    address: dropoffAddress,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Accept / Decline
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _confirmDecline(context, ref, passengerName),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      l10n.declineButton,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () =>
                        _confirmAccept(context, ref, passengerName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.acceptButton,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAccept(
    BuildContext context,
    WidgetRef ref,
    String passengerName,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(l10n.acceptRequestTitle),
        content: Text(l10n.acceptRequestMessage(passengerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(ctx);
              final result = await ref
                  .read(rideRequestServiceProvider.notifier)
                  .acceptRequest(request.id);
              if (!context.mounted) return;
              if (result is Success) {
                ref.invalidate(pendingRideRequestsProvider);
                ref.invalidate(upcomingDriverRidesProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.acceptButton),
          ),
        ],
      ),
    );
  }

  void _confirmDecline(
    BuildContext context,
    WidgetRef ref,
    String passengerName,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(l10n.declineRequestTitle),
        content: Text(l10n.declineRequestMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.keepButton),
          ),
          ElevatedButton(
            onPressed: () async {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(ctx);
              final result = await ref
                  .read(rideRequestServiceProvider.notifier)
                  .rejectRequest(request.id, 'Declined by driver');
              if (!context.mounted) return;
              if (result is Success) {
                ref.invalidate(pendingRideRequestsProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.declineButton),
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UPCOMING RIDES SECTION
// ─────────────────────────────────────────────────────────────────

class _UpcomingRidesSection extends StatelessWidget {
  const _UpcomingRidesSection({
    required this.ridesAsync,
    required this.onRideTap,
  });
  final AsyncValue<List<RideModel>> ridesAsync;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.upcoming,
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
            loading: () => const SkeletonLoader(itemCount: 2),
            error: (e, _) => _InlineError(message: l10n.couldNotLoadRides),
            data: (rides) {
              if (rides.isEmpty) {
                return _InlineEmpty(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.noRidesYetTitle,
                );
              }
              return _RidesTimeline(rides: rides, onRideTap: onRideTap);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HISTORY SECTION
// ─────────────────────────────────────────────────────────────────

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.ridesAsync, required this.onRideTap});
  final AsyncValue<List<RideModel>> ridesAsync;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.history,
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
            loading: () => const SkeletonLoader(
              type: SkeletonType.compactTile,
              itemCount: 3,
            ),
            error: (e, _) => _InlineError(message: l10n.couldNotLoadRides),
            data: (rides) {
              if (rides.isEmpty) {
                return _InlineEmpty(
                  icon: Icons.history_rounded,
                  label: l10n.noRidesYetTitle,
                );
              }
              return Column(
                children: rides.asMap().entries.map((e) {
                  return _HistoryRideCard(
                    ride: e.value,
                    index: e.key,
                    onTap: () => onRideTap(e.value.id),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryRideCard extends StatelessWidget {
  const _HistoryRideCard({required this.ride, required this.index, this.onTap});
  final RideModel ride;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCancelled = ride.status == RideStatus.cancelled;
    final date = AppLocaleFormatters.formatMonthDayTime(
      context,
      ride.departureTime,
    );
    final earnings = ride.pricing.pricePerSeatInCents * ride.capacity.booked;

    return GestureDetector(
      onTap:
          onTap ??
          () => context.pushNamed(
            AppRoutes.driverViewRide.name,
            pathParameters: {'id': ride.id},
          ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.successLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCancelled
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline_rounded,
                size: 20.sp,
                color: isCancelled ? AppColors.error : AppColors.success,
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
                  SizedBox(height: 3.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isCancelled
                      ? '—'
                      : l10n.value5((earnings / 100).toStringAsFixed(2)),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isCancelled
                        ? AppColors.textTertiary
                        : AppColors.success,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RIDES TIMELINE
// ─────────────────────────────────────────────────────────────────

class _RidesTimeline extends StatelessWidget {
  const _RidesTimeline({required this.rides, required this.onRideTap});
  final List<RideModel> rides;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rides.asMap().entries.map((e) {
        return _TimelineRideCard(
          ride: e.value,
          isLast: e.key == rides.length - 1,
          index: e.key,
          onTap: () => onRideTap(e.value.id),
        );
      }).toList(),
    );
  }
}

class _TimelineRideCard extends StatelessWidget {
  const _TimelineRideCard({
    required this.ride,
    required this.isLast,
    required this.index,
    this.onTap,
  });

  final RideModel ride;
  final bool isLast;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dt = ride.departureTime;
    final time = AppLocaleFormatters.formatTime(context, dt);
    final date = AppLocaleFormatters.formatShortDateLabel(context, dt);
    final seatsText = '${ride.bookedSeats}/${ride.capacity.available}';

    return GestureDetector(
      onTap:
          onTap ??
          () => context.pushNamed(
            AppRoutes.driverViewRide.name,
            pathParameters: {'id': ride.id},
          ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            // Card content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time + price
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            l10n.value5(
                              (ride.pricePerSeatInCents / 100).toStringAsFixed(
                                2,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Route
                    Text(
                      ride.origin.address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.w),
                      child: Icon(
                        Icons.south_rounded,
                        size: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      ride.destination.address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Seats + status
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$seatsText booked',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        _StatusChip(status: ride.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 80).ms, duration: 350.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STATUS CHIP
// ─────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RideStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case RideStatus.active:
        bg = AppColors.primarySurface;
        fg = AppColors.primary;
        label = 'Open';
      case RideStatus.full:
        bg = AppColors.warningSurface;
        fg = AppColors.warning;
        label = 'Full';
      case RideStatus.inProgress:
        bg = AppColors.successLight.withValues(alpha: 0.2);
        fg = AppColors.success;
        label = 'Live';
      case RideStatus.completed:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
        label = 'Done';
      case RideStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.1);
        fg = AppColors.error;
        label = 'Cancelled';
      case RideStatus.draft:
        bg = AppColors.infoSurface;
        fg = AppColors.info;
        label = 'Draft';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGE
// ─────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INLINE STATES
// ─────────────────────────────────────────────────────────────────

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.sp, color: AppColors.textTertiary),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
