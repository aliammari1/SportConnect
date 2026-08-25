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
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_countdown_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class RideCountdownScreen extends ConsumerStatefulWidget {
  const RideCountdownScreen({required this.bookingId, super.key});
  final String bookingId;

  @override
  ConsumerState<RideCountdownScreen> createState() =>
      _RideCountdownScreenState();
}

class _RideCountdownScreenState extends ConsumerState<RideCountdownScreen> {
  final MapController _mapController = MapController();
  DateTime? _lastSyncedDeparture;
  String? _lastRequestedRouteRideId;
  RideStatus? _lastHandledRideStatus;
  bool _hasFittedBounds = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}d  ${d.inHours.remainder(24)}h  '
          '${d.inMinutes.remainder(60)}m';
    }
    if (d.inHours > 0) {
      return '${d.inHours.toString().padLeft(2, '0')}:'
          '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes.toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(
      rideCountdownUiViewModelProvider(widget.bookingId),
    );
    final bookingAsync = ref.watch(bookingStreamProvider(widget.bookingId));
    final booking = bookingAsync.value;
    final vmState = booking != null
        ? ref.watch(rideDetailViewModelProvider(booking.rideId))
        : null;

    if (bookingAsync.isLoading) {
      return _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: const SkeletonLoader(),
      );
    }

    if (bookingAsync.hasError) {
      return _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              AppLocalizations.of(
                context,
              ).failedToLoadBookingValue(bookingAsync.error.toString()),
            ),
          ),
        ),
      );
    }

    if (booking == null) {
      return _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              AppLocalizations.of(context).bookingNotFoundMayBeCancelled,
            ),
          ),
        ),
      );
    }

    if (vmState == null) {
      return _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: const SkeletonLoader(),
      );
    }

    return vmState.ride.when(
      data: (ride) => ride == null
          ? _buildAdaptiveScaffold(
              title: AppLocalizations.of(context).yourRide,
              body: Center(
                child: Text(AppLocalizations.of(context).rideNotFound),
              ),
            )
          : _buildContent(ride, booking, uiState),
      loading: () => _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: const SkeletonLoader(),
      ),
      error: (e, _) => _buildAdaptiveScaffold(
        title: AppLocalizations.of(context).yourRide,
        body: Center(child: Text(AppLocalizations.of(context).errorValue(e))),
      ),
    );
  }

  AdaptiveScaffold _buildAdaptiveScaffold({
    required String title,
    required Widget body,
  }) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: title,
      ),
      body: body,
    );
  }

  Widget _buildContent(
    RideModel ride,
    RideBooking booking,
    RideCountdownUiState uiState,
  ) {
    final notifier = ref.read(
      rideCountdownUiViewModelProvider(widget.bookingId).notifier,
    );

    if (_lastSyncedDeparture != ride.schedule.departureTime) {
      _lastSyncedDeparture = ride.schedule.departureTime;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        notifier.syncDeparture(ride.schedule.departureTime);
      });
    }

    // Trigger OSRM route loading
    if (uiState.osrmRouteRideId != ride.id &&
        _lastRequestedRouteRideId != ride.id) {
      _lastRequestedRouteRideId = ride.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(rideCountdownUiViewModelProvider(widget.bookingId).notifier)
            .ensureRouteLoaded(ride);
      });
    }

    // Auto-navigate ONLY when we observe the ride status TRANSITION into inProgress.
    // If the ride is already inProgress when the screen first opens (re-entry case),
    // skip auto-navigation so we don't immediately bounce the user away again.
    if (_lastHandledRideStatus != ride.status) {
      _lastHandledRideStatus = ride.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final shouldNavigate = notifier.registerRideStatus(ride.status);
        if (!shouldNavigate || !mounted) return;

        if (ride.status == RideStatus.inProgress) {
          context.pushReplacement(
            '${AppRoutes.riderActiveRide.path}?rideId=${booking.rideId}',
          );
          return;
        }

        if (ride.status == RideStatus.cancelled) {
          AdaptiveSnackBar.show(
            context,
            message: AppLocalizations.of(context).rideHasBeenCancelled,
            type: AdaptiveSnackBarType.error,
          );
          context.goNamed(AppRoutes.riderMyRides.name);
          return;
        }

        if (ride.status == RideStatus.completed) {
          context.pushReplacement(
            AppRoutes.rideCompletion.path.replaceFirst(':id', booking.rideId),
          );
        }
      });
    }

    final isInPast = uiState.timeUntilDeparture == Duration.zero;
    final isImminent = !isInPast && uiState.timeUntilDeparture.inMinutes <= 15;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).yourRide,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            children: [
              // Booking confirmed badge
              _buildStatusBadge().animate().fadeIn(delay: 100.ms),
              SizedBox(height: 32.h),

              // Countdown display
              if (!isInPast) ...[
                Text(
                  isImminent
                      ? AppLocalizations.of(context).departingSoonLabel
                      : AppLocalizations.of(context).departureInLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isImminent
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                      _formatDuration(uiState.timeUntilDeparture),
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: isImminent
                            ? AppColors.warning
                            : AppColors.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .tint(
                      color: isImminent ? AppColors.warning : AppColors.primary,
                      duration: 1.seconds,
                    ),
              ] else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColors.success,
                      size: 28.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      AppLocalizations.of(context).rideStartedMessage,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              SizedBox(height: 32.h),

              // Route map preview
              _buildRouteMapPreview(
                ride,
                uiState,
              ).animate().fadeIn(delay: 150.ms),
              SizedBox(height: 16.h),

              // Route card
              _buildRouteCard(ride).animate().slideY(delay: 200.ms),
              SizedBox(height: 16.h),

              // Driver info + contact buttons
              _buildDriverCard(ride).animate().slideY(delay: 250.ms),
              SizedBox(height: 16.h),

              // Booking info card
              _buildBookingInfoCard(
                ride,
                booking,
              ).animate().slideY(delay: 300.ms),
              SizedBox(height: 32.h),

              // Action buttons
              if (ride.status == RideStatus.inProgress || isInPast)
                PremiumButton(
                  text: AppLocalizations.of(context).joinActiveRideButton,
                  style: PremiumButtonStyle.success,
                  onPressed: () => context.push(
                    '${AppRoutes.riderActiveRide.path}?rideId=${booking.rideId}',
                  ),
                )
              else
                PremiumButton(
                  text: AppLocalizations.of(context).viewRideDetailsButton,
                  onPressed: () => context.push(
                    AppRoutes.riderViewRide.path.replaceFirst(
                      ':id',
                      booking.rideId,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _fitMapToBounds(List<LatLng> routePoints) {
    if (_hasFittedBounds || routePoints.length < 2) return;
    _hasFittedBounds = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bounds = LatLngBounds.fromPoints(routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(40.w)),
      );
    });
  }

  Widget _buildRouteMapPreview(RideModel ride, RideCountdownUiState uiState) {
    final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dest = LatLng(ride.destination.latitude, ride.destination.longitude);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    final routePoints = uiState.osrmRoutePoints ?? [origin, dest];
    _fitMapToBounds(routePoints);

    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: center, initialZoom: 10),
            children: [
              const AppMapTileLayer(),
              const CurrentLocationLayer(),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6,
                    color: Colors.white,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: AppColors.primary,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: origin,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.success,
                      size: 22.sp,
                    ),
                  ),
                  Marker(
                    point: dest,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Distance / duration overlay
          if (ride.route.distanceKm != null ||
              ride.route.durationMinutes != null)
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ride.route.distanceKm != null) ...[
                      Icon(
                        Icons.straighten_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDistance,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (ride.route.distanceKm != null &&
                        ride.route.durationMinutes != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    if (ride.route.durationMinutes != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDuration,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Zoom controls
          Positioned(
            right: 8.w,
            bottom: 8.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ZoomButton(
                  icon: Icons.add,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                ),
                SizedBox(height: 4.h),
                _ZoomButton(
                  icon: Icons.remove,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                ),
                SizedBox(height: 4.h),
                _ZoomButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    _hasFittedBounds = false;
                    _fitMapToBounds(uiState.osrmRoutePoints ?? [origin, dest]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 10.h, top: 10.h),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(30),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Booking Confirmed',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(RideModel ride) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Column(
            children: [
              Row(
                children: [
                  DriverAvatarWidget(driverId: ride.driverId, radius: 24),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14.sp,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              rating.average.toStringAsFixed(1),
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
                  Text(
                    AppLocalizations.of(context).yourDriverLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: AppLocalizations.of(context).messageButton,
                      icon: Icons.chat_bubble_outline_rounded,
                      style: PremiumButtonStyle.secondary,
                      onPressed: () =>
                          _openDriverChat(ride, displayName, photoUrl),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: PremiumButton(
                      text: AppLocalizations.of(context).callButton,
                      icon: Icons.phone_outlined,
                      style: PremiumButtonStyle.ghost,
                      onPressed: () => _callDriver(ride.driverId),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openDriverChat(
    RideModel ride,
    String driverName,
    String? driverPhotoUrl,
  ) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: ride.driverId,
          userName1: currentUser.username,
          userName2: driverName,
        ).future,
      );

      if (!mounted) return;

      final driverUser = UserModel.driver(
        uid: ride.driverId,
        email: '',
        username: driverName,
        photoUrl: driverPhotoUrl,
      );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: driverUser,
      );
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedOpenChatError,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _callDriver(String driverId) async {
    try {
      final profile = await ref.read(userProfileProvider(driverId).future);
      final phone = profile?.asDriver?.phoneNumber;
      if (phone == null || phone.isEmpty) {
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).driverPhoneUnavailableError,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotLaunchDialerError,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).routeLabel,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.origin.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.5.w),
            child: SizedBox(
              height: 18.h,
              child: VerticalDivider(
                width: 1.w,
                color: AppColors.divider,
                thickness: 1.5,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.error,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.destination.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Event badge
          if (ride.eventId != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
    );
  }

  Widget _buildBookingInfoCard(RideModel ride, RideBooking booking) {
    final totalPrice = booking.seatsBooked * ride.pricePerSeatInCents;
    final refCode = booking.id.length >= 6
        ? booking.id.substring(0, 6).toUpperCase()
        : booking.id.toUpperCase();

    // Compute estimated arrival time
    final durationMin = ride.route.durationMinutes;
    final arrivalTime = durationMin != null
        ? ride.departureTime.add(Duration(minutes: durationMin))
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Icons.airline_seat_recline_normal_rounded,
                value: '${booking.seatsBooked}',
                label: AppLocalizations.of(context).seatsLabel,
              ),
              Container(width: 1.w, height: 32.h, color: AppColors.divider),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: booking.id));
                  unawaited(HapticFeedback.lightImpact());
                  AdaptiveSnackBar.show(
                    context,
                    message: AppLocalizations.of(
                      context,
                    ).bookingRefCopied(refCode),
                    type: AdaptiveSnackBarType.success,
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.confirmation_number_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          refCode,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    Text(
                      '${AppLocalizations.of(context).refNumberLabel} ${AppLocalizations.of(context).tapToCopyInstruction}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1.w, height: 32.h, color: AppColors.divider),
              _buildInfoItem(
                icon: Icons.payments_outlined,
                value: CurrencyFormatter.fromCents(totalPrice),
                label: AppLocalizations.of(context).totalLabel,
              ),
            ],
          ),
          // Estimated arrival row
          if (arrivalTime != null) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_rounded, size: 16.sp, color: AppColors.success),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context).estimatedArrivalLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${arrivalTime.hour.toString().padLeft(2, '0')}:'
                  '${arrivalTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }
}
