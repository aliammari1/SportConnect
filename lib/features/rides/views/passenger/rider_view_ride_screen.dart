import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/view_models/review_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/view_models/rider_view_ride_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_detail_screen.dart'
    show RideDetailScreen;
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Rider's personal ride view with booking and review sections.
///
/// Navigated to from the rider's "My Rides" tab to see details about
/// a ride they have booked or are interested in.
/// For the general ride detail screen, see [RideDetailScreen].
class RiderViewRideScreen extends ConsumerStatefulWidget {
  const RiderViewRideScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<RiderViewRideScreen> createState() =>
      _RiderViewRideScreenState();
}

class _RiderViewRideScreenState extends ConsumerState<RiderViewRideScreen> {
  bool _hasNavigatedToActiveRide = false;

  RideBooking? _latestBookingForRide(
    List<RideBooking>? bookings,
    String rideId,
  ) {
    final matches = bookings
        ?.where((booking) => booking.rideId == rideId)
        .toList(growable: false);
    if (matches == null || matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) {
      final aTimestamp = a.createdAt ?? a.respondedAt ?? DateTime(1970);
      final bTimestamp = b.createdAt ?? b.respondedAt ?? DateTime(1970);
      return bTimestamp.compareTo(aTimestamp);
    });

    return matches.first;
  }

  RideDetailState get _rideDetailState =>
      ref.watch(rideDetailViewModelProvider(widget.rideId));

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch only the ViewModel — it already aggregates ride + bookings.
    final vmState = _rideDetailState;
    final uiState = ref.watch(riderViewRideUiViewModelProvider(widget.rideId));

    // Auto-redirect to active ride screen when ride transitions to inProgress
    ref.listen(rideDetailViewModelProvider(widget.rideId), (previous, next) {
      final ride = next.ride.value;
      if (ride == null || _hasNavigatedToActiveRide) return;

      if (ride.status == RideStatus.inProgress) {
        final currentUserId = ref.read(currentAuthUidProvider).value;
        if (currentUserId == null) return;

        // Only redirect if this passenger has an accepted booking
        final hasAcceptedBooking = next.bookings.any(
          (b) =>
              b.passengerId == currentUserId &&
              b.status == BookingStatus.accepted,
        );
        if (hasAcceptedBooking) {
          _hasNavigatedToActiveRide = true;
          context.pushReplacement(
            '${AppRoutes.riderActiveRide.path}?rideId=${ride.id}',
          );
        }
      }
    });

    // Initial check: if the ride is already inProgress on first build,
    // ref.listen won't fire (no state change), so handle it here.
    if (!_hasNavigatedToActiveRide) {
      final ride = vmState.ride.value;
      if (ride != null && ride.status == RideStatus.inProgress) {
        final currentUserId = ref.read(currentAuthUidProvider).value;
        if (currentUserId != null) {
          final hasAcceptedBooking = vmState.bookings.any(
            (b) =>
                b.passengerId == currentUserId &&
                b.status == BookingStatus.accepted,
          );
          if (hasAcceptedBooking) {
            _hasNavigatedToActiveRide = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.pushReplacement(
                  '${AppRoutes.riderActiveRide.path}?rideId=${ride.id}',
                );
              }
            });
          }
        }
      }
    }

    return vmState.ride.when(
      data: (ride) => _buildContent(ride, vmState.bookings, uiState),
      loading: _buildLoadingState,
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildLoadingState() {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).rideDetails,
      ),
      body: const SkeletonLoader(itemCount: 5),
    );
  }

  Widget _buildErrorState(String error) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).rideDetails,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).couldnTLoadRide,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              PremiumButton(
                text: AppLocalizations.of(context).goBack,
                onPressed: () => context.pop(),
                style: PremiumButtonStyle.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    RideModel? ride,
    List<RideBooking> bookings,
    RiderViewRideUiState uiState,
  ) {
    if (ride == null) {
      return _buildErrorState(AppLocalizations.of(context).rideNotFound);
    }

    // Trigger OSRM route fetch for header map preview
    if (uiState.routeRideId != ride.id && !uiState.isLoadingRoute) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref
            .read(riderViewRideUiViewModelProvider(widget.rideId).notifier)
            .ensureRouteLoaded(ride),
      );
    }

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthWide,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(ride, uiState),
                SliverToBoxAdapter(child: _buildDriverCard(ride, bookings)),
                SliverToBoxAdapter(child: _buildRouteCard(ride)),
                SliverToBoxAdapter(child: _buildDetailsCard(ride)),
                SliverToBoxAdapter(child: _buildPreferencesCard(ride)),
                if (ride.reviewCount > 0)
                  SliverToBoxAdapter(child: _buildReviewsSection(ride)),
                // Bottom padding so content isn't hidden behind the booking bar
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBookingBar(ride, uiState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(RideModel ride, RiderViewRideUiState uiState) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).shareRide,
          onPressed: () => _shareRide(ride),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.adaptive.share_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Mini map preview
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (ride.origin.latitude + ride.destination.latitude) / 2,
                  (ride.origin.longitude + ride.destination.longitude) / 2,
                ),
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                const AppMapTileLayer(),
                const CurrentLocationLayer(),
                if (uiState.routeInfo != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: uiState.routeInfo!.coordinates,
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                      Polyline(
                        points: uiState.routeInfo!.coordinates,
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        ride.origin.latitude,
                        ride.origin.longitude,
                      ),
                      width: 32.w,
                      height: 32.w,
                      child: Icon(
                        Icons.trip_origin_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    Marker(
                      point: LatLng(
                        ride.destination.latitude,
                        ride.destination.longitude,
                      ),
                      width: 32.w,
                      height: 32.w,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.error,
                        size: 28.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Date and Price overlay
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          CurrencyFormatter.fromCents(ride.pricePerSeatInCents),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).perSeat2,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(RideModel ride, List<RideBooking> bookings) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              DriverAvatarWidget(driverId: ride.driverId, radius: 28),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: DriverNameWidget(
                            driverId: ride.driverId,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        DriverRatingWidget(
                          driverId: ride.driverId,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).valueRides(bookings.length),
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
              // Message button
              IconButton(
                tooltip: AppLocalizations.of(context).messageDriver,
                onPressed: () => _openChat(ride),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          if (ride.vehicleInfo != null) ...[
            SizedBox(height: 12.h),
            const Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    ride.vehicleInfo!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal_rounded,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).valueLeft(ride.remainingSeats),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).route,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Origin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primary, AppColors.error],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          ride.origin.address,
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

              // Waypoints / intermediate stops
              if (ride.route.waypoints.isNotEmpty) ...[
                ...(ride.route.waypoints.toList()
                      ..sort((a, b) => a.order.compareTo(b.order)))
                    .map((wp) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 2.w,
                                height: 32.h,
                                color: AppColors.warning.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                          SizedBox(width: 13.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stop ${wp.order + 1}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  Text(
                                    wp.location.address,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ],

              // Destination
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.error,
                    size: 16.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ride.arrivalTime != null)
                          Text(
                            DateFormat('HH:mm').format(ride.arrivalTime!),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          )
                        else if (ride.durationMinutes != null)
                          Text(
                            AppLocalizations.of(
                              context,
                            ).valueMin2(ride.durationMinutes!),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        SizedBox(height: 4.h),
                        Text(
                          ride.destination.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Event badge
                        if (ride.eventId != null) ...[
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  size: 12.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    ride.eventName ?? 'Event',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (ride.distanceKm != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ecoGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.route_rounded,
                        size: 16.sp,
                        color: AppColors.ecoGreen,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${(ride.route.distanceKm ?? 0).toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ecoGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailsCard(RideModel ride) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).rideDetails,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Details grid
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (ride.distanceKm != null)
                    _buildDetailChip(
                      Icons.straighten_rounded,
                      '${ride.distanceKm!.toStringAsFixed(1)} km',
                    ),
                  if (ride.durationMinutes != null)
                    _buildDetailChip(
                      Icons.timer_outlined,
                      AppLocalizations.of(
                        context,
                      ).valueMin(ride.durationMinutes!),
                    ),
                  _buildDetailChip(
                    Icons.event_seat_rounded,
                    AppLocalizations.of(
                      context,
                    ).valueSeats(ride.remainingSeats),
                  ),
                ],
              ),

              if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          ride.notes!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailChip(
    IconData icon,
    String label, {
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: highlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: highlight ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(RideModel ride) {
    final preferences = <MapEntry<IconData, String>>[];

    if (ride.allowLuggage) {
      preferences.add(const MapEntry(Icons.luggage_rounded, 'Luggage OK'));
    }
    if (ride.allowPets) {
      preferences.add(const MapEntry(Icons.pets_rounded, 'Pets OK'));
    }
    if (!ride.allowSmoking) {
      preferences.add(const MapEntry(Icons.smoke_free_rounded, 'No smoking'));
    }
    if (ride.isWomenOnly) {
      preferences.add(const MapEntry(Icons.female_rounded, 'Women only'));
    }
    if (preferences.isEmpty) return const SizedBox.shrink();

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).preferences,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: preferences
                    .map(
                      (pref) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pref.key,
                              size: 14.sp,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              pref.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildReviewsSection(RideModel ride) {
    if (ride.reviewCount == 0) return const SizedBox.shrink();

    final reviewsAsync = ref.watch(rideReviewsProvider(ride.id));

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rate_review_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).reviews,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    ride.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '(${ride.reviewCount} reviews)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Fetch and display individual reviews
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Text(
                      AppLocalizations.of(context).noReviewsYet,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                      ),
                    );
                  }
                  return Column(
                    children: reviews.take(3).map(_buildReviewItem).toList(),
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, _) => Text(
                  AppLocalizations.of(context).failedToLoadReviews,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }

  /// Builds a single review item card.
  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 10.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: review.reviewerPhotoUrl != null
                    ? CachedNetworkImageProvider(review.reviewerPhotoUrl!)
                    : null,
                child: review.reviewerPhotoUrl == null
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 14.sp),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14.sp,
                            color: AppColors.warning,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          DateFormat('MMM d, y').format(review.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.comment!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (review.tags.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: review.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingBar(RideModel ride, RiderViewRideUiState uiState) {
    final currentUserId = ref.watch(currentAuthUidProvider).value;
    final isOwnRide = currentUserId == ride.driverId;

    // Use the passenger-scoped provider to find the rider's own booking for
    // this ride. The ride-scoped provider filters by driverId and returns
    // nothing when the current user is a passenger.
    final existingBooking = currentUserId != null
        ? _latestBookingForRide(
            ref.watch(
              bookingsByPassengerProvider(currentUserId).select((a) => a.value),
            ),
            ride.id,
          )
        : null;

    // Rider has an accepted booking on a ride that requires online payment.
    // Show "Complete Payment" only if they haven't paid yet;
    // once paidAt is stamped on the booking, show Confirmed instead.
    if (existingBooking != null &&
        existingBooking.status == BookingStatus.accepted) {
      if (existingBooking.paidAt != null) {
        return _buildExistingBookingBar(
          label: AppLocalizations.of(context).bookingConfirmed,
          icon: Icons.check_circle_rounded,
          onPressed: null,
          style: PremiumButtonStyle.secondary,
        );
      }
      return _buildExistingBookingBar(
        label: AppLocalizations.of(context).completePayment,
        icon: Icons.payment_rounded,
        onPressed: () => context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
        ),
      );
    }

    // Rider has a pending booking → show status instead of a second book button
    if (existingBooking != null &&
        existingBooking.status == BookingStatus.pending) {
      return _buildExistingBookingBar(
        label: AppLocalizations.of(context).waitingForDriverApproval,
        icon: Icons.hourglass_top_rounded,
        onPressed: () => context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
        ),
      );
    }

    // Booking was declined by driver → show status + allow re-booking
    if (existingBooking != null &&
        existingBooking.status == BookingStatus.rejected) {
      return _buildExistingBookingBar(
        label: AppLocalizations.of(context).bookingDeclined,
        icon: Icons.cancel_rounded,
        onPressed: null,
        style: PremiumButtonStyle.secondary,
      );
    }

    final canBook = ride.isBookable && !isOwnRide;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seat selector
            if (canBook && ride.remainingSeats > 1) ...[
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).seats3,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          ride.remainingSeats,
                          (i) => GestureDetector(
                            onTap: () {
                              unawaited(HapticFeedback.selectionClick());
                              ref
                                  .read(
                                    riderViewRideUiViewModelProvider(
                                      widget.rideId,
                                    ).notifier,
                                  )
                                  .setSeatsToBook(i + 1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 8.w),
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: uiState.seatsToBook == i + 1
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).value2(i + 1),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: uiState.seatsToBook == i + 1
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.fromCents(
                      ride.pricePerSeatInCents * uiState.seatsToBook,
                    ),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // Book button
            PremiumButton(
              text: isOwnRide
                  ? 'This is your ride'
                  : canBook
                  ? (_rideDetailState.isActing
                        ? 'Booking...'
                        : 'Book ${uiState.seatsToBook} ${uiState.seatsToBook == 1 ? 'Seat' : 'Seats'}')
                  : ride.isFull
                  ? 'Ride is full'
                  : 'Unavailable',
              onPressed: canBook ? () => _showBookingConfirmation(ride) : null,
              isLoading: _rideDetailState.isActing,
              style: canBook
                  ? PremiumButtonStyle.primary
                  : PremiumButtonStyle.ghost,
              icon: canBook ? Icons.check_circle_outline_rounded : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingBookingBar({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    PremiumButtonStyle style = PremiumButtonStyle.primary,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PremiumButton(
          text: label,
          onPressed: onPressed,
          style: style,
          icon: icon,
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _shareRide(RideModel ride) async {
    unawaited(HapticFeedback.lightImpact());
    final l10n = AppLocalizations.of(context);

    try {
      // Generate shareable HTTPS link via app_links
      final dynamicLink = await ref
          .read(riderViewRideUiViewModelProvider(widget.rideId).notifier)
          .generateRideShareLink(ride);

      if (!mounted) return;

      final shareText = l10n.rideShareText(
        ride.origin.city ?? ride.origin.address,
        ride.destination.city ?? ride.destination.address,
        DateFormat('MMM d, h:mm a').format(ride.departureTime),
        (ride.pricePerSeatInCents / 100).toStringAsFixed(2),
        ride.remainingSeats,
        dynamicLink,
      );

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: l10n.rideShareSubject,
          sharePositionOrigin: shareSheetOrigin(context),
        ),
      );
    } on Exception {
      if (!mounted) return;
      // Fallback to basic share with HTTPS link
      await SharePlus.instance.share(
        ShareParams(
          text: l10n.rideShareText(
            ride.origin.city ?? ride.origin.address,
            ride.destination.city ?? ride.destination.address,
            DateFormat('MMM d, h:mm a').format(ride.departureTime),
            (ride.pricePerSeatInCents / 100).toStringAsFixed(2),
            ride.remainingSeats,
            'https://${AppConstants.hostingDomain}/ride/${widget.rideId}',
          ),
          subject: l10n.rideShareSubject,
          sharePositionOrigin: shareSheetOrigin(context),
        ),
      );
    }
  }

  Future<void> _openChat(RideModel ride) async {
    unawaited(HapticFeedback.lightImpact());

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch driver profile to get name and photo
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );

      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      if (!mounted) return;
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: ride.driverId,
          userName1: currentUser.username,
          userName2: driverProfile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: driverProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: driverProfile,
      );
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToOpenChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  void _showBookingConfirmation(RideModel ride) {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).confirmBooking,
      maxHeightFactor: 0.75,
      child: _BookingConfirmationSheet(
        ride: ride,
        seatsToBook: ref
            .read(riderViewRideUiViewModelProvider(widget.rideId))
            .seatsToBook,
        initialNote: ref
            .read(riderViewRideUiViewModelProvider(widget.rideId))
            .note,
        onConfirm: (note) {
          ref
              .read(riderViewRideUiViewModelProvider(widget.rideId).notifier)
              .setNote(note);
          _bookRide(ride);
        },
      ),
    );
  }

  Future<void> _bookRide(RideModel ride) async {
    unawaited(HapticFeedback.mediumImpact());

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('Please sign in to book a ride');
      }

      final success = await ref
          .read(rideDetailViewModelProvider(ride.id).notifier)
          .bookRide(
            passengerId: currentUser.uid,
            seats: ref
                .read(riderViewRideUiViewModelProvider(widget.rideId))
                .seatsToBook,
            note:
                ref
                    .read(riderViewRideUiViewModelProvider(widget.rideId))
                    .note
                    .isNotEmpty
                ? ref.read(riderViewRideUiViewModelProvider(widget.rideId)).note
                : null,
          );

      if (!success) {
        throw Exception('Booking failed. Please try again.');
      }

      if (mounted) {
        // Navigate to the pending screen so the passenger can track the
        // booking status and cancel if needed (design requirement).
        context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
        );
      }
    } on Exception {
      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).bookingFailedTryAgain,
          type: AdaptiveSnackBarType.error,
        );
      }
    }
  }
}

/// Bottom sheet content for booking confirmation.
///
/// Owned as a [StatefulWidget] so that [TextEditingController] lifecycle is
/// managed by Flutter's element tree — [dispose] fires only after the sheet's
/// dismiss animation fully completes, preventing the
/// "controller used after dispose" crash that occurs when using
/// `.whenComplete()` (which resolves the moment the route is popped, before
/// the animation ends).
class _BookingConfirmationSheet extends StatefulWidget {
  const _BookingConfirmationSheet({
    required this.ride,
    required this.seatsToBook,
    required this.initialNote,
    required this.onConfirm,
  });
  final RideModel ride;
  final int seatsToBook;
  final String initialNote;
  final void Function(String note) onConfirm;

  @override
  State<_BookingConfirmationSheet> createState() =>
      _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState extends State<_BookingConfirmationSheet> {
  late String _noteText;

  @override
  void initState() {
    super.initState();
    _noteText = widget.initialNote;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
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
            SizedBox(height: 20.h),
            Text(
              l10n.confirmBooking,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildRow(l10n.seats2, l10n.value2(widget.seatsToBook)),
                  SizedBox(height: 8.h),
                  _buildRow(
                    l10n.pricePerSeat2,
                    CurrencyFormatter.fromCents(
                      widget.ride.pricePerSeatInCents,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  const Divider(color: AppColors.divider),
                  SizedBox(height: 8.h),
                  _buildRow(
                    l10n.total,
                    CurrencyFormatter.fromCents(
                      widget.ride.pricePerSeatInCents * widget.seatsToBook,
                    ),
                    isBold: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              initialValue: widget.initialNote,
              onChanged: (v) => _noteText = v,
              maxLength: 255,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.addANoteToThe,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                counterStyle: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiary,
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    text: AppLocalizations.of(context).actionCancel,
                    onPressed: () => Navigator.pop(context),
                    style: PremiumButtonStyle.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: PremiumButton(
                    text: AppLocalizations.of(context).confirmBooking,
                    onPressed: () {
                      final note = _noteText;
                      Navigator.pop(context);
                      widget.onConfirm(note);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
