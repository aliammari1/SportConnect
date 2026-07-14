import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
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
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/app_segmented_tab_view.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/ride_feature_widgets.dart';
import 'package:sport_connect/core/widgets/safety_widgets.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/repositories/support_repository.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_ride_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/driver/driver_view_ride_widgets.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Driver's dedicated screen for managing their ride and viewing booking requests
/// Features: ride stats, booking management, passenger list, ride controls
class DriverViewRideScreen extends ConsumerStatefulWidget {
  const DriverViewRideScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<DriverViewRideScreen> createState() =>
      _DriverViewRideScreenState();
}

class _DriverViewRideScreenState extends ConsumerState<DriverViewRideScreen> {
  RideStatus? _lastHandledRideStatus;

  void _showInfoSnackBar({
    required String message,
    Color backgroundColor = AppColors.success,
  }) {
    if (!context.mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: backgroundColor == AppColors.success
          ? AdaptiveSnackBarType.success
          : AdaptiveSnackBarType.error,
    );
  }

  void _showErrorMessage(String message) {
    _showInfoSnackBar(message: message, backgroundColor: AppColors.error);
  }

  @override
  Widget build(BuildContext context) {
    // Watch only the ViewModel — it already aggregates ride + bookings.
    final vmState = ref.watch(rideDetailViewModelProvider(widget.rideId));
    final uiState = ref.watch(
      driverRideScreenUiViewModelProvider(widget.rideId),
    );

    return vmState.ride.when(
      data: (ride) => ride != null
          ? _buildContent(ride, vmState.bookings, vmState, uiState)
          : _buildErrorState(AppLocalizations.of(context).rideNotFound),
      loading: _buildLoadingState,
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildLoadingState() {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).yourRide,
      ),
      body: const SkeletonLoader(itemCount: 5),
    );
  }

  Widget _buildErrorState(String error) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).yourRide,
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
    RideModel ride,
    List<RideBooking> bookings,
    RideDetailState vmState,
    DriverRideScreenUiState uiState,
  ) {
    final notifier = ref.read(
      driverRideScreenUiViewModelProvider(widget.rideId).notifier,
    );

    // Trigger OSRM route loading
    if (uiState.osrmRouteRideId != ride.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(driverRideScreenUiViewModelProvider(widget.rideId).notifier)
            .ensureRouteLoaded(ride);
      });
    }

    // ── Auto-navigate when ride transitions to inProgress ────────────────
    // Only navigate on a *transition* (not re-entry) to avoid bouncing the
    // driver back to the active screen while they intentionally came here.
    if (_lastHandledRideStatus != ride.status) {
      _lastHandledRideStatus = ride.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final shouldNavigate = notifier.registerRideStatus(ride.status);
        if (!shouldNavigate || !context.mounted) return;

        context.pushReplacement(
          '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
        );
      });
    }

    final pendingBookings = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();
    final confirmedBookings = bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthWide,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(ride, confirmedBookings, uiState),
              SliverToBoxAdapter(
                child: _buildStatsBar(
                  ride,
                  pendingBookings.length,
                  confirmedBookings,
                ),
              ),
            ];
          },
          body: AppSegmentedTabView(
            tabs: [
              AppLocalizations.of(context).details,
              if (pendingBookings.isNotEmpty)
                '${AppLocalizations.of(context).requests} (${pendingBookings.length})'
              else
                AppLocalizations.of(context).requests,
              if (confirmedBookings.isNotEmpty)
                '${AppLocalizations.of(context).passengers} (${confirmedBookings.length})'
              else
                AppLocalizations.of(context).passengers,
            ],
            selectedColor: Colors.white,
            backgroundColor: AppColors.primary,
            children: [
              _buildDetailsTab(ride),
              _buildRequestsTab(ride, pendingBookings),
              _buildPassengersTab(ride, confirmedBookings),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(ride, vmState.isActing),
    );
  }

  Widget _buildSliverAppBar(
    RideModel ride,
    List<RideBooking> confirmedBookings,
    DriverRideScreenUiState uiState,
  ) {
    return SliverAppBar(
      expandedHeight: 200.h,
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
          tooltip: AppLocalizations.of(context).rideOptions,
          onPressed: () => _showRideOptions(ride),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.adaptive.more_rounded,
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
            // Mini map
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
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points:
                          uiState.osrmRoutePoints ??
                          [
                            LatLng(ride.origin.latitude, ride.origin.longitude),
                            LatLng(
                              ride.destination.latitude,
                              ride.destination.longitude,
                            ),
                          ],
                      strokeWidth: 6,
                      color: Colors.white,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                    Polyline(
                      points:
                          uiState.osrmRoutePoints ??
                          [
                            LatLng(ride.origin.latitude, ride.origin.longitude),
                            LatLng(
                              ride.destination.latitude,
                              ride.destination.longitude,
                            ),
                          ],
                      strokeWidth: 4,
                      color: AppColors.primary,
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
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            // Info overlay
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(ride),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, MMM d',
                              ).format(ride.departureTime),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).earnings,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '€${_calculateEarnings(ride, confirmedBookings).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RideModel ride) {
    Color bgColor;
    String text;
    IconData icon;

    switch (ride.status) {
      case RideStatus.active:
        bgColor = AppColors.success;
        text = 'Active';
        icon = Icons.check_circle_rounded;
      case RideStatus.inProgress:
        bgColor = AppColors.info;
        text = 'In Progress';
        icon = Icons.directions_car_rounded;
      case RideStatus.completed:
        bgColor = AppColors.textSecondary;
        text = 'Completed';
        icon = Icons.done_all_rounded;
      case RideStatus.cancelled:
        bgColor = AppColors.error;
        text = 'Cancelled';
        icon = Icons.cancel_rounded;
      case RideStatus.draft:
        bgColor = AppColors.warning;
        text = 'Draft';
        icon = Icons.edit_note_rounded;
      case RideStatus.full:
        bgColor = AppColors.info;
        text = 'Full';
        icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(
    RideModel ride,
    int pendingCount,
    List<RideBooking> confirmedBookings,
  ) {
    final confirmedSeats = confirmedBookings
        .where((b) => b.status == BookingStatus.accepted)
        .fold(0, (sum, b) => sum + b.seatsBooked);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: RideStatItem(
              icon: Icons.event_seat_rounded,
              value: '$confirmedSeats/${ride.availableSeats}',
              label: AppLocalizations.of(context).seatsFilled,
            ),
          ),
          Container(width: 1.w, height: 40.h, color: Colors.white30),
          Expanded(
            child: RideStatItem(
              icon: Icons.pending_actions_rounded,
              value: '$pendingCount',
              label: AppLocalizations.of(context).pending,
              highlight: pendingCount > 0,
            ),
          ),
          Container(width: 1.w, height: 40.h, color: Colors.white30),
          Expanded(
            child: RideStatItem(
              icon: Icons.euro_rounded,
              value: CurrencyFormatter.fromCents(ride.pricePerSeatInCents),
              label: AppLocalizations.of(context).perSeat,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailsTab(RideModel ride) {
    final details = <Widget>[
      _buildRouteCard(ride),
      SizedBox(height: 12.h),
      _buildVehicleCard(ride),
      SizedBox(height: 12.h),
      _buildPreferencesCard(ride),
      if (ride.notes != null && ride.notes!.isNotEmpty) ...[
        SizedBox(height: 12.h),
        _buildNotesCard(ride),
      ],
      SizedBox(height: 80.h),
    ];
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: details.length,
      itemBuilder: (context, index) => details[index],
    );
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).route,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (ride.distanceKm != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${ride.distanceKm!.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
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
                        AppLocalizations.of(context).value10(
                          DateFormat('HH:mm').format(ride.arrivalTime!),
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
        ],
      ),
    );
  }

  Widget _buildVehicleCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              size: 28.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.vehicleInfo ?? 'Vehicle',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(
                    context,
                  ).valueTotalSeats(ride.availableSeats),
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

  Widget _buildPreferencesCard(RideModel ride) {
    final prefs = <MapEntry<IconData, String>>[];
    if (ride.allowLuggage) {
      prefs.add(const MapEntry(Icons.luggage_rounded, 'Luggage OK'));
    }
    if (ride.allowPets) {
      prefs.add(const MapEntry(Icons.pets_rounded, 'Pets OK'));
    }
    if (!ride.allowSmoking) {
      prefs.add(const MapEntry(Icons.smoke_free_rounded, 'No smoking'));
    }
    if (ride.isWomenOnly) {
      prefs.add(const MapEntry(Icons.female_rounded, 'Women only'));
    }
    if (prefs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18.sp, color: AppColors.primary),
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
            children: prefs
                .map(
                  (p) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.key, size: 14.sp, color: AppColors.success),
                        SizedBox(width: 6.w),
                        Text(
                          p.value,
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
    );
  }

  Widget _buildNotesCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).notes,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            ride.notes!,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(RideModel ride, List<RideBooking> pending) {
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noPendingRequests,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).newBookingRequestsWillAppear,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        return _buildBookingRequestCard(ride, pending[index])
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildBookingRequestCard(RideModel ride, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PassengerAvatarWidget(
                passengerId: booking.passengerId,
                radius: 25,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PassengerNameWidget(
                      passengerId: booking.passengerId,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat_rounded,
                          size: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${booking.seatsBooked} ${booking.seatsBooked == 1 ? AppLocalizations.of(context).seat : AppLocalizations.of(context).seats}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _timeAgo(booking.createdAt),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  CurrencyFormatter.fromCents(
                    ride.pricePerSeatInCents * booking.seatsBooked,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          if (booking.note != null && booking.note!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.message_rounded,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      booking.note!,
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

          SizedBox(height: 12.h),

          // Chat button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => _openPassengerChat(booking),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 20.sp),
              tooltip: AppLocalizations.of(context).chatWithPassenger,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.all(8.w),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      ref
                          .watch(rideDetailViewModelProvider(widget.rideId))
                          .isActing
                      ? null
                      : () => _rejectBooking(ride, booking),
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                  label: Text(AppLocalizations.of(context).decline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed:
                      ref
                          .watch(rideDetailViewModelProvider(widget.rideId))
                          .isActing
                      ? null
                      : () => _acceptBooking(ride, booking),
                  icon: Icon(
                    Icons.check_rounded,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(AppLocalizations.of(context).accept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersTab(RideModel ride, List<RideBooking> confirmed) {
    if (confirmed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noPassengersYet,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).acceptBookingRequestsToAdd,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: confirmed.length,
      itemBuilder: (context, index) {
        return _buildPassengerCard(ride, confirmed[index])
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildPassengerCard(RideModel ride, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          PassengerAvatarWidget(passengerId: booking.passengerId, radius: 25),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: PassengerNameWidget(
                        passengerId: booking.passengerId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.verified_rounded,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${booking.seatsBooked} ${booking.seatsBooked == 1 ? AppLocalizations.of(context).seat : AppLocalizations.of(context).seats}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      CurrencyFormatter.fromCents(
                        ride.pricePerSeatInCents * booking.seatsBooked,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context).messagePassenger,
                onPressed: () => _openPassengerChat(booking),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                tooltip: AppLocalizations.of(context).passengerOptions,
                onPressed: () => _showPassengerOptions(ride, booking),
                icon: Icon(
                  Icons.adaptive.more_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (ride.status == RideStatus.inProgress)
                IconButton(
                  tooltip: AppLocalizations.of(context).markNoShow,
                  onPressed: () async {
                    final confirmed = await NoShowDialog.show(
                      context,
                      passengerName: 'Passenger',
                    );
                    if (confirmed == true) {
                      await _markPassengerNoShow(ride, booking);
                    }
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  ),
                  icon: Icon(
                    Icons.person_off_rounded,
                    size: 18.sp,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  AdaptiveBottomNavigationBar _buildBottomActions(
    RideModel ride,
    bool isActing,
  ) {
    // Mirrors the ride-options overflow sheet's cancel-availability: cancel
    // is reachable for any non-terminal ride, including inProgress, so a
    // genuine mid-ride emergency cancellation is reachable without digging
    // into the "•••" menu (cancellation_reason_screen.dart already supports
    // driver reasons — driverSafetyConcern/driverEmergency — that only make
    // sense mid-ride).
    final canCancel =
        ride.status == RideStatus.active ||
        ride.status == RideStatus.full ||
        ride.status == RideStatus.inProgress;

    return AdaptiveBottomNavigationBar(
      bottomNavigationBar: Container(
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
          child: Row(
            children: [
              if (canCancel) ...[
                IconButton(
                  tooltip: AppLocalizations.of(context).cancelRide2,
                  onPressed: isActing ? null : () => _cancelRide(ride),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    foregroundColor: AppColors.error,
                    padding: EdgeInsets.all(14.w),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: ride.status == RideStatus.inProgress
                    ? PremiumButton(
                        text: AppLocalizations.of(context).activeRide,
                        onPressed: isActing
                            ? null
                            : () => context.push(
                                '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
                              ),
                        style: PremiumButtonStyle.success,
                        icon: Icons.navigation_rounded,
                      )
                    : PremiumButton(
                        text: AppLocalizations.of(context).editRide,
                        onPressed: isActing ? null : () => _editRide(ride),
                        isDisabled: isActing,
                        style: PremiumButtonStyle.secondary,
                        icon: Icons.edit_rounded,
                      ),
              ),
              SizedBox(width: 12.w),
              if (ride.status == RideStatus.active ||
                  ride.status == RideStatus.full)
                Expanded(
                  flex: 2,
                  child: PremiumButton(
                    text: AppLocalizations.of(context).startRide,
                    onPressed: isActing ? null : () => _startRide(ride),
                    isLoading: isActing,
                    icon: Icons.play_arrow_rounded,
                  ),
                )
              else if (ride.status == RideStatus.inProgress)
                Expanded(
                  flex: 2,
                  child: PremiumButton(
                    text: AppLocalizations.of(context).completeRide,
                    onPressed: isActing ? null : () => _completeRide(ride),
                    isLoading: isActing,
                    style: PremiumButtonStyle.success,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // === Actions ===

  double _calculateEarnings(RideModel ride, List<RideBooking> bookings) {
    return bookings
            .where((b) => b.status == BookingStatus.accepted)
            .fold(
              0,
              (sum, b) => sum + (ride.pricePerSeatInCents * b.seatsBooked),
            ) /
        100;
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Unknown';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showRideOptions(RideModel ride) {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).rideOptions,
      maxHeightFactor: 0.55,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveListTile(
              leading: Icon(
                Icons.adaptive.share_rounded,
                color: AppColors.primary,
              ),
              title: Text(AppLocalizations.of(context).shareRide),
              onTap: () {
                Navigator.pop(context);
                _shareRide(ride);
              },
            ),
            AdaptiveListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.info),
              title: Text(AppLocalizations.of(context).duplicateRide),
              onTap: () {
                Navigator.pop(context);
                _duplicateRide(ride);
              },
            ),
            if (ride.status == RideStatus.inProgress)
              AdaptiveListTile(
                leading: const Icon(
                  Icons.report_problem_rounded,
                  color: AppColors.warning,
                ),
                title: Text(AppLocalizations.of(context).reportIncident),
                onTap: () {
                  Navigator.pop(context);
                  IncidentReportSheet.show(
                    context,
                    rideId: ride.id,
                    onSubmit: _submitIncidentReport,
                  );
                },
              ),
            if (ride.status == RideStatus.active ||
                ride.status == RideStatus.full ||
                ride.status == RideStatus.inProgress)
              AdaptiveListTile(
                leading: const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  AppLocalizations.of(context).cancelRide2,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _cancelRide(ride);
                },
              ),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          ],
        ),
      ),
    );
  }

  void _showPassengerOptions(RideModel ride, RideBooking booking) {
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).passengerOptions,
      maxHeightFactor: 0.5,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdaptiveListTile(
              leading: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              title: Text(AppLocalizations.of(context).viewProfile),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.userProfile.path.replaceFirst(
                    ':id',
                    booking.passengerId,
                  ),
                );
              },
            ),
            AdaptiveListTile(
              leading: const Icon(Icons.call_rounded, color: AppColors.success),
              title: Text(AppLocalizations.of(context).callPassenger),
              onTap: () {
                Navigator.pop(context);
                _callPassenger(booking);
              },
            ),
            AdaptiveListTile(
              leading: const Icon(Icons.cancel_rounded, color: AppColors.error),
              title: Text(
                AppLocalizations.of(context).removePassenger,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _removePassenger(ride, booking);
              },
            ),
            SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptBooking(RideModel ride, RideBooking booking) async {
    unawaited(HapticFeedback.mediumImpact());

    try {
      // Fetch passenger profile for confirmation message
      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (!mounted) return;

      // Use fallback if profile is null
      final passengerName = passengerProfile?.username ?? 'Passenger';

      final success = await ref
          .read(rideDetailViewModelProvider(ride.id).notifier)
          .acceptBooking(booking.id);

      if (!success) {
        _showErrorMessage('Could not confirm booking. Please try again.');
        return;
      }

      if (!mounted) return;
      _showInfoSnackBar(
        message: AppLocalizations.of(
          context,
        ).bookingConfirmedForValue(passengerName),
      );
    } on Exception {
      _showErrorMessage('Could not confirm booking. Please try again.');
    }
  }

  Future<void> _rejectBooking(RideModel ride, RideBooking booking) async {
    if (ref.read(rideDetailViewModelProvider(ride.id)).isActing) return;

    // Fetch passenger profile for dialog message
    final passengerProfile = await ref.read(
      userProfileProvider(booking.passengerId).future,
    );

    if (!mounted) return;

    // Use fallback if profile is null
    final passengerName = passengerProfile?.username ?? 'Passenger';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).declineBooking),
        content: Text(
          AppLocalizations.of(
            context,
          ).declineBookingRequestFromValue(passengerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).decline,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    try {
      final success = await ref
          .read(rideDetailViewModelProvider(ride.id).notifier)
          .rejectBooking(booking.id);
      if (!success) {
        _showErrorMessage('Could not decline booking. Please try again.');
      }
    } on Exception {
      _showErrorMessage('Could not decline booking. Please try again.');
    }
  }

  /// Calls a passenger using the device phone dialer.
  Future<void> _callPassenger(RideBooking booking) async {
    try {
      final passenger = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );
      if (!mounted) return;

      final phoneNumber = passenger?.asRider?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showInfoSnackBar(
          message: AppLocalizations.of(context).phoneNumberNotAvailable,
        );
        return;
      }

      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      final canLaunch = await canLaunchUrl(phoneUri);
      if (!mounted) return;

      if (canLaunch) {
        await launchUrl(phoneUri);
      } else {
        _showInfoSnackBar(
          message: AppLocalizations.of(context).cannotMakePhoneCalls,
          backgroundColor: AppColors.textPrimary,
        );
      }
    } on Exception {
      if (!mounted) return;
      _showInfoSnackBar(
        message: AppLocalizations.of(context).failedToLaunchDialer,
        backgroundColor: AppColors.textPrimary,
      );
    }
  }

  Future<void> _removePassenger(RideModel ride, RideBooking booking) async {
    // Fetch passenger profile for dialog message
    final passengerProfile = await ref.read(
      userProfileProvider(booking.passengerId).future,
    );

    if (!mounted) return;

    // Use fallback if profile is null
    final passengerName = passengerProfile?.username ?? 'Passenger';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).removePassenger),
        content: Text(
          AppLocalizations.of(context).removeValueFromThisRide(passengerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).remove,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(rideActionsViewModelProvider.notifier)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: booking.id,
            newStatus: BookingStatus.cancelled,
          );
    } on Exception {
      _showErrorMessage('Could not remove passenger. Please try again.');
    }
  }

  Future<void> _openPassengerChat(RideBooking booking) async {
    unawaited(HapticFeedback.lightImpact());

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch passenger profile for chat
      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (!mounted) return;

      // If profile doesn't exist, show error and return
      if (passengerProfile == null) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).passengerProfileNotFound,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: booking.passengerId,
          userName1: currentUser.username,
          userName2: passengerProfile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      final passengerUser = UserModel.rider(
        uid: booking.passengerId,
        email: '',
        username: passengerProfile.username,
        photoUrl: passengerProfile.photoUrl,
      );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: passengerUser,
      );
    } on Exception {
      _showErrorMessage('Failed to open chat. Please try again.');
    }
  }

  void _editRide(RideModel ride) {
    unawaited(HapticFeedback.lightImpact());
    context.push(AppRoutes.driverEditRide.path.replaceFirst(':id', ride.id));
  }

  Future<void> _shareRide(RideModel ride) async {
    unawaited(HapticFeedback.lightImpact());
    final l10n = AppLocalizations.of(context);

    try {
      // Generate shareable HTTPS link via app_links
      final dynamicLink = await ref
          .read(driverRideScreenUiViewModelProvider(widget.rideId).notifier)
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
            'https://${AppConstants.hostingDomain}/ride/${ride.id}',
          ),
          subject: l10n.rideShareSubject,
          sharePositionOrigin: shareSheetOrigin(context),
        ),
      );
    }
  }

  void _duplicateRide(RideModel ride) {
    unawaited(HapticFeedback.lightImpact());
    context.push(AppRoutes.driverOfferRide.path, extra: ride);
  }

  Future<void> _startRide(RideModel ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).startRide),
        content: Text(AppLocalizations.of(context).markThisRideAsStarted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).start),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final success = await ref
          .read(rideDetailViewModelProvider(ride.id).notifier)
          .startRide();
      if (!success) {
        _showErrorMessage('Could not start ride. Please try again.');
        return;
      }
      // Navigate directly to the active ride management screen
      if (mounted) {
        context.push('${AppRoutes.driverActiveRide.path}?rideId=${ride.id}');
      }
    } on Exception {
      _showErrorMessage('Could not start ride. Please try again.');
    }
  }

  Future<void> _completeRide(RideModel ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).completeRide),
        content: Text(AppLocalizations.of(context).markThisRideAsCompleted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).complete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await ref
          .read(rideDetailViewModelProvider(ride.id).notifier)
          .completeRide();
      if (!success) {
        _showErrorMessage('Could not complete ride. Please try again.');
        return;
      }
      if (!mounted) return;
      _showInfoSnackBar(
        message: AppLocalizations.of(context).rideCompleted,
        backgroundColor: AppColors.textPrimary,
      );
      // Route the driver to the completion screen so the post-completion flow
      // (rate passenger, instant payout) is reachable in-app, mirroring the
      // passenger active-ride auto-navigation on RideStatus.completed.
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
      );
    } on Exception {
      _showErrorMessage('Could not complete ride. Please try again.');
    }
  }

  Future<void> _cancelRide(RideModel ride) async {
    final cancelled = await context.push<bool>(
      '${AppRoutes.cancellationReason.path.replaceFirst(':id', ride.id)}?isDriver=true',
    );
    if (cancelled == true && mounted) context.pop();
  }

  /// Persists a driver-filed ride incident report via [SupportRepository]
  /// (shares the same collection/rules as the profile "report" flow — see
  /// support_repository.dart). Only resolves on success; [IncidentReportSheet]
  /// shows its "submitted" state / dismisses itself only after this succeeds,
  /// and surfaces an inline error without dismissing if it throws.
  Future<void> _submitIncidentReport(IncidentReport report) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('Please sign in to submit a report.');
    }
    await ref
        .read(supportRepositoryProvider)
        .submitReport(
          reporterId: currentUser.uid,
          reporterEmail: currentUser.email,
          type: report.type.name,
          severity: report.severity.name,
          description: report.description,
          rideId: report.rideId,
        );
    if (!mounted) return;
    _showInfoSnackBar(
      message: AppLocalizations.of(context).incidentReportSubmitted,
    );
  }

  /// Records a passenger no-show as a real, queryable booking-status change
  /// (via [RideActionsViewModel.markPassengerNoShow] → the same repository
  /// path used by the passenger-side OTP no-show flow), instead of just
  /// showing a toast with nothing persisted.
  Future<void> _markPassengerNoShow(RideModel ride, RideBooking booking) async {
    try {
      await ref
          .read(rideActionsViewModelProvider.notifier)
          .markPassengerNoShow(
            rideId: ride.id,
            bookingId: booking.id,
            passengerId: booking.passengerId,
          );
      if (!mounted) return;
      _showInfoSnackBar(message: AppLocalizations.of(context).noShowReported);
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Failed to report no-show. Please try again.');
    }
  }
}
