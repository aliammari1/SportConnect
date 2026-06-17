import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/misc_feature_widgets.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/ride_feature_widgets.dart';
import 'package:sport_connect/core/widgets/ride_progress_timeline.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_detail_widgets.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_view_ride_screen.dart'
    show RiderViewRideScreen;
import 'package:sport_connect/features/rides/views/widgets/ride_shared_widgets.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full ride detail screen with map, route visualization, and booking flow.
///
/// Navigated to from search results, notifications, and deep links.
/// For a rider's personal booking view, see [RiderViewRideScreen].

class RideDetailScreen extends ConsumerStatefulWidget {
  const RideDetailScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  final MapController _mapController = MapController();
  // Guard: prevent addPostFrameCallback from re-triggering route load on every rebuild
  String? _loadedRouteRideId;

  RideDetailUiState get _uiState =>
      ref.watch(rideDetailUiViewModelProvider(widget.rideId));

  RideDetailUiViewModel get _uiNotifier =>
      ref.read(rideDetailUiViewModelProvider(widget.rideId).notifier);

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!context.mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: backgroundColor == AppColors.error
          ? AdaptiveSnackBarType.error
          : backgroundColor == AppColors.success
          ? AdaptiveSnackBarType.success
          : AdaptiveSnackBarType.info,
    );
  }

  Future<void> _loadRoute(RideModel ride) async {
    final route = await _uiNotifier.ensureRouteLoaded(ride);
    if (route != null && mounted && route.coordinates.length >= 2) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (context.mounted) {
        final bounds = LatLngBounds.fromPoints(route.coordinates);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(30.w)),
        );
      }
    }
  }

  void _openBookingReview(RideModel ride) {
    unawaited(HapticFeedback.lightImpact());

    context.pushNamed(
      AppRoutes.rideBookingReview.name,
      pathParameters: {'rideId': ride.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(rideDetailViewModelProvider(widget.rideId));
    final bookings = vmState.bookings;

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthWide,
        child: vmState.ride.when(
          loading: _buildLoadingSkeleton,
          error: (error, _) => _buildErrorState(error.toString()),
          data: (ride) {
            if (ride == null) {
              return _buildErrorState(
                AppLocalizations.of(context).rideNotFound,
              );
            }

            // Load route once per ride — guard prevents re-firing on every rebuild
            if (_loadedRouteRideId != ride.id) {
              _loadedRouteRideId = ride.id;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadRoute(ride);
              });
            }

            return _buildContent(ride, bookings);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220.h,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: const SkeletonLoader(
                itemCount: 1,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: List.generate(
                4,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).errorLoadingRide,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RideModel ride, List<RideBooking> bookings) {
    final uiState = _uiState;
    // Check if current user is the driver
    final currentUser = ref.watch(currentUserProvider.select((a) => a.value));
    final currentUserId = ref.watch(currentAuthUidProvider).value;
    final isDriver = currentUserId == ride.driverId;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          slivers: [
            // App bar with map
            _buildSliverAppBar(ride),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Route card with proper spacing
                  _buildRouteCard(ride)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Event badge — shown when this ride is linked to an event
                  if (ride.eventId != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 14.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  ride.eventName ??
                                      AppLocalizations.of(context).eventLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
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
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 70.ms),

                  // Driver info - only show for passengers
                  if (!isDriver)
                    _buildDriverCard(ride)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideX(begin: 0.1, curve: Curves.easeOutCubic),

                  // Trip details
                  _buildTripDetails(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms)
                      .slideX(begin: -0.1, curve: Curves.easeOutCubic),

                  // Ride progress timeline
                  Padding(
                        padding: adaptiveScreenPadding(context),
                        child: RideProgressTimeline(
                          rideStatus: ride.status,
                          bookingStatus:
                              bookings
                                  .where(
                                    (b) => b.passengerId == currentUser?.uid,
                                  )
                                  .firstOrNull
                                  ?.status ??
                              BookingStatus.pending,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 170.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                  // Walking distance to pickup
                  if (uiState.routeInfo != null &&
                      currentUser!.asRider?.latitude != null &&
                      currentUser.asRider?.longitude != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: WalkingDistanceCard.fromDistance(
                        distanceMeters: const Distance().as(
                          LengthUnit.Meter,
                          LatLng(
                            currentUser.asRider!.latitude!,
                            currentUser.asRider!.longitude!,
                          ),
                          LatLng(ride.origin.latitude, ride.origin.longitude),
                        ),
                        onGetDirections: () {
                          final url = Uri.parse(
                            'https://www.google.com/maps/dir/?api=1'
                            '&origin=${currentUser.asRider!.latitude},${currentUser.asRider!.longitude}'
                            '&destination=${ride.origin.latitude},${ride.origin.longitude}'
                            '&travelmode=walking',
                          );
                          launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 180.ms),

                  // Smart departure reminder
                  if (ride.departureTime.isAfter(DateTime.now()))
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: SmartReminderCard(
                        departureTime: ride.departureTime,
                        minutesBefore: () {
                          final hoursUntil = ride.departureTime
                              .difference(DateTime.now())
                              .inHours;
                          if (hoursUntil <= 1) return 15;
                          if (hoursUntil <= 3) return 30;
                          return 60;
                        }(),
                        isEnabled: uiState.isReminderEnabled,
                        onToggle: _uiNotifier.setReminderEnabled,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 197.ms),

                  // Car info
                  _buildCarInfo(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: 0.1, curve: Curves.easeOutCubic),

                  // Amenities
                  _buildAmenities(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms)
                      .slideX(begin: -0.1, curve: Curves.easeOutCubic),

                  // Ride preferences summary (for passengers)
                  if (!isDriver)
                    _buildPreferencesMatch(ride)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 270.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                  // Passengers section - show for both but with different context
                  if (bookings.isNotEmpty)
                    _buildPassengers(
                          ride,
                          bookings: bookings,
                          isDriver: isDriver,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Pending requests - only show for drivers
                  if (isDriver &&
                      bookings.any((b) => b.status == BookingStatus.pending))
                    _buildPendingRequests(ride, bookings)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 350.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Bottom padding for booking sheet - increased to prevent content hiding
                  SizedBox(height: 200.h),
                ],
              ),
            ),
          ],
        ),

        // Fixed bottom sheet - different for driver vs passenger
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: isDriver
              ? _buildDriverActionSheet(ride, bookings)
              : _buildPassengerBottomBar(ride, bookings, currentUser?.uid),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(RideModel ride) {
    final uiState = _uiState;
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
            color: Colors.white,
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
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context).shareRide,
          onPressed: () async {
            final subject = AppLocalizations.of(context).rideShareSubject;
            try {
              // Generate shareable HTTPS link via app_links
              final dynamicLink = await ref
                  .read(
                    rideDetailUiViewModelProvider(widget.rideId).notifier,
                  )
                  .generateRideShareLink(ride);

              if (!mounted) return;

              final shareText = _buildRideShareText(ride, dynamicLink);

              await SharePlus.instance.share(
                ShareParams(
                  text: shareText,
                  subject: subject,
                  sharePositionOrigin: shareSheetOrigin(context),
                ),
              );
            } on Exception {
              if (!mounted) return;
              // Fallback
              await SharePlus.instance.share(
                ShareParams(
                  text: _buildRideShareText(
                    ride,
                    'https://${AppConstants.hostingDomain}/ride/${widget.rideId}',
                  ),
                  subject: subject,
                  sharePositionOrigin: shareSheetOrigin(context),
                ),
              );
            }
          },
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: AppSpacing.shadowSm,
            ),
            child: Icon(
              Icons.adaptive.share_outlined,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Real Map with route
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  ride.origin.latitude,
                  ride.origin.longitude,
                ),
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                const AppMapTileLayer(),
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
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                    // Waypoint markers
                    ...ride.route.waypoints.map(
                      (wp) => Marker(
                        point: LatLng(
                          wp.location.latitude,
                          wp.location.longitude,
                        ),
                        width: 26,
                        height: 26,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                          child: const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    Marker(
                      point: LatLng(
                        ride.destination.latitude,
                        ride.destination.longitude,
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Route badge — shows distance/duration once loaded, small spinner while loading.
            // Does NOT cover the map so tiles remain visible during route fetch.
            if (uiState.routeInfo != null || uiState.isLoadingRoute)
              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: AppSpacing.shadowSm,
                    ),
                    child: uiState.isLoadingRoute
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppLocalizations.of(context).loadingRoute,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.route_rounded,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                AppLocalizations.of(context).valueValue6(
                                  uiState.routeInfo!.formattedDistance,
                                  uiState.routeInfo!.formattedDuration,
                                ),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 16.h, top: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppSpacing.shadowLg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 50.h,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.success, AppColors.error],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.origin.city ??
                              AppLocalizations.of(context).origin,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ride.origin.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.destination.city ??
                              AppLocalizations.of(context).destination,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ride.destination.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: RideInfoChip(
                  icon: Icons.access_time_rounded,
                  value: AppLocalizations.of(
                    context,
                  ).valueMin(ride.durationMinutes ?? 0),
                  label: AppLocalizations.of(context).duration,
                ),
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              Expanded(
                child: RideInfoChip(
                  icon: Icons.straighten_rounded,
                  value: ride.distanceKm != null
                      ? '${ride.distanceKm!.toStringAsFixed(1)} km'
                      : '${0.toStringAsFixed(1)} km',
                  label: AppLocalizations.of(context).distance,
                ),
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              Expanded(
                child: RideInfoChip(
                  icon: Icons.event_seat_rounded,
                  value: '${ride.remainingSeats}',
                  label: AppLocalizations.of(context).seatsLeft2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(RideModel ride) {
    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.lightImpact());
          context.pushNamed(
            AppRoutes.driverProfile.name,
            pathParameters: {'id': ride.driverId},
          );
        },
        child: PremiumCard(
          child: DriverInfoWidget(
            driverId: ride.driverId,
            builder: (context, displayName, photoUrl, rating) {
              return Row(
                children: [
                  LevelAvatar(
                    name: displayName,
                    imageUrl: photoUrl,
                    level: 5,
                    size: 60,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.xpGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: DriverRatingWidget(
                                driverId: ride.driverId,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.xpGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            RideDriverBadge(
                              icon: Icons.verified_user_rounded,
                              label: AppLocalizations.of(context).verified,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context).chatWithDriver,
                    onPressed: () => _openDriverChat(ride.driverId),
                    icon: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetails(RideModel ride) {
    // Calculate projected arrival time
    final durationMin = ride.route.durationMinutes;
    final arrivalTime = durationMin != null
        ? ride.departureTime.add(Duration(minutes: durationMin))
        : null;

    return Container(
      margin: EdgeInsets.all(20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).tripDetails,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            RideDetailInfoRow(
              icon: Icons.calendar_today_rounded,
              label: AppLocalizations.of(context).departure2,
              value: AppLocaleFormatters.formatShortWeekdayDateTime(
                context,
                ride.departureTime,
              ),
            ),
            if (arrivalTime != null) ...[
              SizedBox(height: 12.h),
              RideDetailInfoRow(
                icon: Icons.flag_rounded,
                label: AppLocalizations.of(context).estimatedArrival,
                value: AppLocaleFormatters.formatTime(context, arrivalTime),
              ),
            ],
            if (ride.route.distanceKm != null) ...[
              SizedBox(height: 12.h),
              RideDetailInfoRow(
                icon: Icons.straighten_rounded,
                label: AppLocalizations.of(context).distance,
                value: ride.route.formattedDistance,
              ),
            ],
            if (ride.route.durationMinutes != null) ...[
              SizedBox(height: 12.h),
              RideDetailInfoRow(
                icon: Icons.timer_outlined,
                label: AppLocalizations.of(context).duration,
                value: ride.route.formattedDuration,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfo(RideModel ride) {
    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.vehicleInfo ?? AppLocalizations.of(context).vehicle,
                    style: TextStyle(
                      fontSize: 16.sp,
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
      ),
    );
  }

  Widget _buildAmenities(RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).amenities,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                RideAmenityChip(
                  icon: Icons.pets_rounded,
                  label: AppLocalizations.of(context).pets,
                  isAllowed: ride.allowPets,
                ),
                RideAmenityChip(
                  icon: Icons.smoking_rooms_rounded,
                  label: AppLocalizations.of(context).smoking,
                  isAllowed: ride.allowSmoking,
                ),
                RideAmenityChip(
                  icon: Icons.luggage_rounded,
                  label: AppLocalizations.of(context).luggage,
                  isAllowed: ride.allowLuggage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Computes a simple preference match score and displays it.
  Widget _buildPreferencesMatch(RideModel ride) {
    final prefs = ride.preferences;
    var score = 0;
    const total = 3;

    // Positive signals for passenger convenience
    if (prefs.allowLuggage) score++;
    if (!prefs.allowSmoking) score++; // most passengers prefer non-smoking
    if (ride.remainingSeats > 1) score++; // spacious ride

    final pct = (score / total * 100).round();
    final Color barColor;
    final String label;
    if (pct >= 80) {
      barColor = AppColors.success;
      label = AppLocalizations.of(context).greatMatch;
    } else if (pct >= 50) {
      barColor = AppColors.warning;
      label = AppLocalizations.of(context).goodMatch;
    } else {
      barColor = AppColors.error;
      label = AppLocalizations.of(context).fairMatch;
    }

    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 18.sp, color: barColor),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).rideCompatibility,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: barColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: score / total,
                minHeight: 6.h,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                RideMatchChip(
                  icon: Icons.luggage_rounded,
                  label: AppLocalizations.of(context).luggage,
                  positive: prefs.allowLuggage,
                ),
                RideMatchChip(
                  icon: Icons.smoke_free_rounded,
                  label: AppLocalizations.of(context).nonSmoking,
                  positive: !prefs.allowSmoking,
                ),
                RideMatchChip(
                  icon: Icons.event_seat_rounded,
                  label: AppLocalizations.of(context).spacious,
                  positive: ride.remainingSeats > 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengers(
    RideModel ride, {
    required List<RideBooking> bookings,
    bool isDriver = false,
  }) {
    final acceptedBookings = bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();

    return Container(
      margin: adaptiveScreenPadding(context),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDriver
                      ? AppLocalizations.of(
                          context,
                        ).yourPassengersValue(acceptedBookings.length)
                      : AppLocalizations.of(
                          context,
                        ).passengersValue(acceptedBookings.length),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isDriver)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).valueValueSeats(ride.bookedSeats, ride.availableSeats),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            if (acceptedBookings.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    isDriver
                        ? AppLocalizations.of(context).noPassengersAcceptedYet
                        : AppLocalizations.of(context).noPassengersBookedYet,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else if (isDriver)
              // Show detailed passenger list for drivers
              ...acceptedBookings.map(_buildPassengerItem)
            else
              // Show compact view for other passengers
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 40.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      acceptedBookings.length == 1
                          ? AppLocalizations.of(context).valueHasBookedThisRide(
                              AppLocalizations.of(context).aPassenger,
                            )
                          : AppLocalizations.of(
                              context,
                            ).valuePassengersHaveBooked(
                              acceptedBookings.length,
                            ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
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

  Widget _buildPassengerItem(RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          PassengerAvatarWidget(passengerId: booking.passengerId, radius: 22),
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
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context).valueSeatValueBooked2(
                    booking.seatsBooked,
                    booking.seatsBooked > 1 ? 's' : '',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Chat button
          IconButton(
            tooltip: AppLocalizations.of(context).chatWithPassenger,
            onPressed: () => _openPassengerChat(booking.passengerId),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build pending requests section for drivers
  Widget _buildPendingRequests(RideModel ride, List<RideBooking> bookings) {
    final pendingBookings = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

    return Container(
      margin: adaptiveScreenPadding(context),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.pending_actions_rounded,
                    size: 20.sp,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(
                    context,
                  ).pendingRequestsValue(pendingBookings.length),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...pendingBookings.map(
              (booking) => _buildPendingRequestItem(ride.id, booking),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestItem(String rideId, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PassengerAvatarWidget(
                passengerId: booking.passengerId,
                radius: 22,
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
                    SizedBox(height: 2.h),
                    Text(
                      AppLocalizations.of(context).valueSeatValueRequested(
                        booking.seatsBooked,
                        booking.seatsBooked > 1 ? 's' : '',
                      ),
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
          if (booking.note != null && booking.note!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openPassengerChat(booking.passengerId),
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18.sp,
                  ),
                  label: Text(
                    'Message passenger',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: AppLocalizations.of(context).decline,
                      onPressed: () =>
                          _handleDeclineRequest(rideId, booking.id),
                      style: PremiumButtonStyle.secondary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: PremiumButton(
                      text: AppLocalizations.of(context).accept,
                      onPressed: () => _handleAcceptRequest(rideId, booking.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAcceptRequest(String rideId, String bookingId) async {
    unawaited(HapticFeedback.mediumImpact());
    try {
      await ref
          .read(rideDetailViewModelProvider(rideId).notifier)
          .acceptBooking(bookingId);

      if (!mounted) return;
      _showSnackBar(
        AppLocalizations.of(context).requestAccepted,
        backgroundColor: Colors.green,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar(
        AppLocalizations.of(context).errorValue(e),
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handleDeclineRequest(String rideId, String bookingId) async {
    unawaited(HapticFeedback.mediumImpact());
    try {
      await ref
          .read(rideDetailViewModelProvider(rideId).notifier)
          .rejectBooking(bookingId);

      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context).requestDeclined);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar(
        AppLocalizations.of(context).errorValue(e),
        backgroundColor: Colors.red,
      );
    }
  }

  /// Build driver action sheet (instead of booking sheet)
  Widget _buildDriverActionSheet(RideModel ride, List<RideBooking> bookings) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final pendingCount = bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    final acceptedCount = bookings
        .where((b) => b.status == BookingStatus.accepted)
        .length;
    final earningsPreview = (ride.pricePerSeatInCents * acceptedCount) / 100.0;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Ride stats row
          Row(
            children: [
              // Seats info
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_seat_rounded,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).valueValue(ride.bookedSeats, ride.availableSeats),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppLocalizations.of(context).seatsBooked,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Pending requests
              if (pendingCount > 0)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pending_actions_rounded,
                              size: 18.sp,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              AppLocalizations.of(context).value2(pendingCount),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context).pending,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              // Earnings preview
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).value5(
                          earningsPreview.toStringAsFixed(2),
                        ),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppLocalizations.of(context).earnings,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Action buttons
          Row(
            children: [
              // Edit ride button (only if no accepted bookings)
              if (acceptedCount == 0 && ride.status == RideStatus.draft) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        AppRoutes.driverOfferRide.name,
                        extra: ride,
                      );
                    },
                    icon: Icon(Icons.edit_rounded, size: 20.sp),
                    label: Text(AppLocalizations.of(context).editRide),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              // Start / view-active button
              Expanded(
                child: PremiumButton(
                  text: ride.status == RideStatus.inProgress
                      ? AppLocalizations.of(context).viewActiveRide
                      : AppLocalizations.of(context).startRide,
                  onPressed:
                      ride.status == RideStatus.inProgress || acceptedCount > 0
                      ? () => context.pushNamed(
                          AppRoutes.driverActiveRide.name,
                          queryParameters: {'rideId': ride.id},
                        )
                      : null,
                  icon: ride.status == RideStatus.inProgress
                      ? Icons.navigation_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Routes to booking status bar or new-booking sheet based on existing booking.
  Widget _buildPassengerBottomBar(
    RideModel ride,
    List<RideBooking> bookings,
    String? currentUserId,
  ) {
    final existingBooking = currentUserId != null
        ? bookings.where((b) => b.passengerId == currentUserId).firstOrNull
        : null;

    // No booking, or booking was rejected/cancelled → show booking sheet
    if (existingBooking == null ||
        existingBooking.status == BookingStatus.rejected ||
        existingBooking.status == BookingStatus.cancelled) {
      return _buildBookingSheet(ride);
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final (
      String label,
      IconData icon,
      Color bgColor,
      VoidCallback? onTap,
    ) = switch (existingBooking.status) {
      BookingStatus.pending => (
        AppLocalizations.of(context).waitingForDriverApproval,
        Icons.hourglass_top_rounded,
        AppColors.warning,
        () => context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
        ),
      ),
      BookingStatus.accepted when existingBooking.paidAt != null => (
        AppLocalizations.of(context).bookingConfirmed,
        Icons.check_circle_rounded,
        AppColors.success,
        null,
      ),
      BookingStatus.accepted => (
        AppLocalizations.of(context).completePayment,
        Icons.payment_rounded,
        AppColors.primary,
        () => context.push(
          AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
        ),
      ),
      BookingStatus.completed => (
        AppLocalizations.of(context).bookingConfirmed,
        Icons.check_circle_rounded,
        AppColors.success,
        null,
      ),
      // rejected/cancelled are handled above — this is a defensive fallback
      _ => (
        AppLocalizations.of(context).bookingDeclined,
        Icons.cancel_rounded,
        AppColors.error,
        null,
      ),
    };

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: adaptiveScreenPadding(
              context,
            ).copyWith(bottom: 14.h, top: 14.h),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: bgColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: bgColor, size: 22.sp),
                SizedBox(width: 10.w),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: bgColor,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.adaptive.arrow_forward_rounded,
                    color: bgColor,
                    size: 16.sp,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSheet(RideModel ride) {
    final uiState = _uiState;
    final totalPriceInCents = ride.pricePerSeatInCents * uiState.selectedSeats;
    final totalPrice = totalPriceInCents / 100.0;
    final pricePerSeat = ride.pricePerSeatInCents / 100.0;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final currencySymbol = _getCurrencySymbol();
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48.w,
            height: 5.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),

          // Trip summary row
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                // Route icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                // Route info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).value2(
                          ride.origin.city ??
                              ride.origin.address.split(',').first,
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.adaptive.arrow_forward,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).value2(
                                ride.destination.city ??
                                    ride.destination.address.split(',').first,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
                // Time badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocaleFormatters.formatTime(
                          context,
                          ride.departureTime,
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppLocaleFormatters.formatMonthDay(
                          context,
                          ride.departureTime,
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Seat selector with modern design
          Row(
            children: [
              Text(
                AppLocalizations.of(context).seats2,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).valueAvailable(ride.remainingSeats),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
              const Spacer(),
              // Modern seat counter
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SeatCounterButton(
                      icon: Icons.remove_rounded,
                      onPressed: uiState.selectedSeats > 1
                          ? () {
                              unawaited(HapticFeedback.selectionClick());
                              _uiNotifier.setSelectedSeats(
                                uiState.selectedSeats - 1,
                              );
                            }
                          : null,
                      isEnabled: uiState.selectedSeats > 1,
                    ),
                    Container(
                      width: 48.w,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).value2(uiState.selectedSeats),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SeatCounterButton(
                      icon: Icons.add_rounded,
                      onPressed: uiState.selectedSeats < ride.remainingSeats
                          ? () {
                              unawaited(HapticFeedback.selectionClick());
                              _uiNotifier.setSelectedSeats(
                                uiState.selectedSeats + 1,
                              );
                            }
                          : null,
                      isEnabled: uiState.selectedSeats < ride.remainingSeats,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Pickup location (optional) ──
          PickupPinDropCard(
            currentAddress: uiState.pickupLocation?.address,
            onDropPin: () async {
              final result = await MapLocationPicker.show(
                context,
                title: AppLocalizations.of(context).dropPinForPickup,
                initialLocation: uiState.pickupLocation != null
                    ? LatLng(
                        uiState.pickupLocation!.latitude,
                        uiState.pickupLocation!.longitude,
                      )
                    : null,
              );
              if (result != null && context.mounted) {
                _uiNotifier.setPickupLocation(
                  LocationPoint(
                    latitude: result.location.latitude,
                    longitude: result.location.longitude,
                    address: result.address,
                  ),
                );
              }
            },
            onClearPin: uiState.pickupLocation != null
                ? _uiNotifier.clearPickupLocation
                : null,
          ),

          SizedBox(height: 16.h),

          // Price breakdown
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                BookingPriceRow(
                  label: AppLocalizations.of(context).pricePerSeat2,
                  value: AppLocalizations.of(context).valueValue5(
                    currencySymbol,
                    pricePerSeat.toStringAsFixed(2),
                  ),
                ),
                if (uiState.selectedSeats > 1) ...[
                  SizedBox(height: 8.h),
                  BookingPriceRow(
                    label: AppLocalizations.of(context).numberOfSeats,
                    value: AppLocalizations.of(
                      context,
                    ).value12(uiState.selectedSeats),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(
                    color: AppColors.border.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).total,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).valueValue5(
                        currencySymbol,
                        totalPrice.toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Book button - full width, prominent
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: ride.remainingSeats > 0 && !uiState.isBooking
                  ? () => _openBookingReview(ride)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: uiState.isBooking
                  ? SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: const CircularProgressIndicator.adaptive(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context).bookNow,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 12.h),

          // Secure payment badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                AppLocalizations.of(context).securePaymentWithStripe,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Gets the currency symbol for display
  String _getCurrencySymbol() => '€';

  String _buildRideShareText(RideModel ride, String link) {
    return AppLocalizations.of(context).rideShareText(
      ride.origin.city ?? ride.origin.address,
      ride.destination.city ?? ride.destination.address,
      AppLocaleFormatters.formatMonthDayTime(context, ride.departureTime),
      (ride.pricePerSeatInCents / 100.0).toStringAsFixed(2),
      ride.remainingSeats,
      link,
    );
  }

  Future<void> _openDriverChat(String driverId) async {
    unawaited(HapticFeedback.lightImpact());

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    if (currentUser.uid == driverId) return;

    try {
      final driverProfile = await ref.read(
        userProfileProvider(driverId).future,
      );

      if (!mounted) return;

      if (driverProfile == null) {
        _showSnackBar(AppLocalizations.of(context).passengerProfileNotFound);
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: driverProfile.uid,
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
        queryParameters: {
          'receiverId': driverProfile.uid,
          'receiverName': driverProfile.username,
          if (driverProfile.photoUrl != null)
            'receiverPhotoUrl': driverProfile.photoUrl,
        },
        extra: driverProfile,
      );
    } on Object catch (e, st) {
      TalkerService.warning('Failed to open driver chat: $e');
      TalkerService.error('Open driver chat error', e, st);
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context).failedToOpenChatTryAgain);
    }
  }

  Future<void> _openPassengerChat(String passengerId) async {
    unawaited(HapticFeedback.lightImpact());

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    if (currentUser.uid == passengerId) return;

    try {
      final passengerProfile = await ref.read(
        userProfileProvider(passengerId).future,
      );

      if (!mounted) return;

      if (passengerProfile == null) {
        _showSnackBar(AppLocalizations.of(context).passengerProfileNotFound);
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: passengerProfile.uid,
          userName1: currentUser.username,
          userName2: passengerProfile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        queryParameters: {
          'receiverId': passengerProfile.uid,
          'receiverName': passengerProfile.username,
          if (passengerProfile.photoUrl != null)
            'receiverPhotoUrl': passengerProfile.photoUrl,
        },
        extra: passengerProfile,
      );
    } on Object catch (e, st) {
      TalkerService.warning('Failed to open passenger chat: $e');
      TalkerService.error('Open passenger chat error', e, st);
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context).failedToOpenChatTryAgain);
    }
  }

}
