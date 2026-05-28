import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/misc_feature_widgets.dart';
import 'package:sport_connect/core/widgets/ride_feature_widgets.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/active_ride_widgets.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Active Ride Screen  - shows real-time ride status from Firestore
class PassengerActiveRideScreen extends ConsumerStatefulWidget {
  const PassengerActiveRideScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<PassengerActiveRideScreen> createState() =>
      _PassengerActiveRideScreenState();
}

class _PassengerActiveRideScreenState
    extends ConsumerState<PassengerActiveRideScreen> {
  bool _hasNavigatedOnCancel = false;

  // MapController for live tracking map — allows auto-panning to driver
  final MapController _liveMapController = MapController();

  // Controls the bottom sheet programmatically for auto-expansion
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // H1: Passenger's own GPS location for map pin
  LatLng? _passengerLocation;

  // Whether the map has been initially centered on the driver's position
  bool _hasInitiallyPannedToDriver = false;

  // AR-7: Whether to show the OTP inline during enRoute phase
  bool _showOtp = false;

  // AR-6: Set when location permission is permanently denied so we can show a prompt
  bool _locationPermissionDeniedForever = false;

  @override
  void initState() {
    super.initState();

    // H1: Fetch passenger's current location for map display
    _fetchPassengerLocation();
  }

  Future<void> _fetchPassengerLocation() async {
    final svc = ref.read(locationServiceProvider);

    if (await svc.isPermissionPermanentlyDenied()) {
      if (mounted) setState(() => _locationPermissionDeniedForever = true);
      return;
    }

    final granted = await svc.requestPermission();
    if (!granted) {
      final deniedForever = await svc.isPermissionPermanentlyDenied();
      if (mounted) {
        setState(() => _locationPermissionDeniedForever = deniedForever);
      }
      return;
    }

    try {
      final position = await svc.getCurrentLocation();
      if (mounted && position != null) {
        setState(
          () => _passengerLocation = LatLng(
            position.latitude,
            position.longitude,
          ),
        );
      }
    } on Exception {
      // Location not available — pin simply won't show
    }
  }

  @override
  void dispose() {
    _liveMapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  /// Shares live trip details with contacts.
  Future<void> _shareTrip(RideModel ride) async {
    unawaited(HapticFeedback.mediumImpact());
    final currentUser = ref.read(currentUserProvider).value;
    final l10n = AppLocalizations.of(context);

    final userName = currentUser?.username ?? 'A passenger';
    final origin = ride.origin.address;
    final destination = ride.destination.address;
    final status = ride.status == RideStatus.inProgress
        ? l10n.tripStatusInProgress
        : l10n.tripStatusScheduled;
    final rideId = ride.id.substring(0, 8).toUpperCase();
    final departure = _formatDateTime(ride.departureTime);

    final msg = l10n.tripShareMessage(
      userName,
      status,
      origin,
      destination,
      rideId,
      departure,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: msg,
        sharePositionOrigin: shareSheetOrigin(context),
      ),
    );
  }

  // ==================== SECTION 7 PASSENGER HELPERS ====================

  /// Quick message chips for passenger (e.g. "I'm at pickup", "Running late").
  Widget _buildPassengerQuickMessages(
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final messages = [
      "I'm at the pickup",
      'Running late',
      'Wrong location',
      'On my way',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest quick message received
          if (rideState.latestQuickMessage != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.message, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      rideState.latestQuickMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: messages.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(
                    messages[index],
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  onPressed: () {
                    final notifier = ref.read(
                      activeRideViewModelProvider(widget.rideId).notifier,
                    );
                    final user = ref.read(currentUserProvider).value;
                    if (user == null) return;
                    notifier.sendQuickMessage(
                      chatId: ride.id,
                      message: messages[index],
                      senderId: user.uid,
                      senderName: user.username,
                    );
                    unawaited(HapticFeedback.lightImpact());
                    AdaptiveSnackBar.show(
                      context,
                      message: AppLocalizations.of(
                        context,
                      ).sentMessage(messages[index]),
                      type: AdaptiveSnackBarType.success,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime as "Jan 5, 3:45 PM".
  String _formatPaidAt(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${months[dt.month - 1]} ${dt.day}, $displayHour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  /// Formats a future arrival time as "h:mm AM/PM" given minutes from now.
  String _formatArrivalTime(int minutes) {
    final arrival = DateTime.now().add(Duration(minutes: minutes));
    final hour = arrival.hour;
    final min = arrival.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${min.toString().padLeft(2, '0')} $period';
  }

  /// Returns true if it's currently nighttime (between 8 PM and 6 AM).
  bool get _isNightTime {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }

  @override
  Widget build(BuildContext context) {
    // PERF: Only watch the ride AsyncValue — GPS/driver location changes
    // won't trigger a full rebuild. Individual sections use Consumer widgets.
    final rideAsync = ref.watch(
      activeRideViewModelProvider(widget.rideId).select((s) => s.ride),
    );

    // Auto-expand bottom sheet on key phase transitions
    ref.listen<ActiveRidePhase>(
      activeRideViewModelProvider(widget.rideId).select((s) => s.phase),
      (prev, next) {
        if (prev == next) return;
        if (next == ActiveRidePhase.pickingUp ||
            next == ActiveRidePhase.arriving) {
          if (_sheetController.isAttached) {
            _sheetController.animateTo(
              0.55,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
    );

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: kMaxWidthWide,
        child: rideAsync.when(
          data: (ride) => ride == null
              ? _buildRideNotFound()
              : _buildActiveRideContent(context, ride),
          loading: () => const SkeletonLoader(itemCount: 5),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).failedToLoadRide,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  e.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideNotFound() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.rideNotFound,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.thisRideMayHaveBeen,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          PremiumButton(
            text: l10n.goHome,
            onPressed: () => context.go(AppRoutes.splash.path),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideContent(BuildContext context, RideModel ride) {
    // Non-reactive read for redirect logic
    final currentState = ref.read(activeRideViewModelProvider(widget.rideId));

    // Auto-navigate to completion screen when driver marks ride as done.
    if (ride.status == RideStatus.completed &&
        !currentState.hasAutoNavigatedToCompletion) {
      // Set flag BEFORE scheduling the push to prevent double-navigation
      // if the widget rebuilds between the status check and the callback.
      ref
          .read(activeRideViewModelProvider(widget.rideId).notifier)
          .markCompletionNavigationHandled();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement(
            AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
          );
        }
      });
    }

    // Auto-navigate away when the ride is cancelled mid-trip.
    if (ride.status == RideStatus.cancelled && !_hasNavigatedOnCancel) {
      _hasNavigatedOnCancel = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AdaptiveSnackBar.show(
            context,
            message: AppLocalizations.of(context).rideHasBeenCancelled,
            type: AdaptiveSnackBarType.error,
          );
          context.goNamed(AppRoutes.riderMyRides.name);
        }
      });
    }

    // For in-progress rides, use a full-screen map-first layout
    // PERF: Wrapped in Consumer so driver profile + ride state are
    // isolated from the parent build() which only watches ride status.
    if (ride.status == RideStatus.inProgress) {
      // Phase auto-expand is handled by ref.listen in build()
      return Consumer(
        builder: (context, ref, _) {
          final rideState = ref.watch(
            activeRideViewModelProvider(widget.rideId),
          );
          final driverAsync = ref.watch(
            currentUserProfileProvider(ride.driverId),
          );
          return _buildMapFirstLayout(context, ride, rideState, driverAsync);
        },
      );
    }

    // Non-inProgress rides: show details in a scroll view
    return Consumer(
      builder: (context, ref, _) {
        final rideState = ref.watch(activeRideViewModelProvider(widget.rideId));
        final driverAsync = ref.watch(
          currentUserProfileProvider(ride.driverId),
        );

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ride)),
            // Static route map — shown for scheduled/active/completed rides
            SliverToBoxAdapter(
              child: _buildStaticRouteMap(context, ride, rideState)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 50.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            SliverToBoxAdapter(
              child: _buildStatusSection(context, ride, rideState)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            SliverToBoxAdapter(
              child: driverAsync
                  .when(
                    data: (driver) => _buildDriverInfo(context, driver, ride),
                    loading: () => const SkeletonLoader(
                      type: SkeletonType.profileCard,
                      itemCount: 1,
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            // Vehicle photo match for easy identification
            if (ride.vehicleId != null || ride.vehicleInfo != null)
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 4.h,
                          ),
                          child: Builder(
                            builder: (context) {
                              if (ride.vehicleId != null) {
                                final vehiclesAsync = ref.watch(
                                  userVehiclesStreamProvider(ride.driverId),
                                );
                                return vehiclesAsync.when(
                                  data: (vehicles) {
                                    final vehicle = vehicles
                                        .where((v) => v.id == ride.vehicleId)
                                        .firstOrNull;
                                    if (vehicle == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return VehiclePhotoMatchCard(
                                      vehicleMake: vehicle.make,
                                      vehicleModel: vehicle.model,
                                      vehicleColor: vehicle.color,
                                      licensePlate: vehicle.licensePlate,
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                );
                              }
                              // Fallback: parse from vehicleInfo string
                              final parts = ride.vehicleInfo!.split(' ');
                              return VehiclePhotoMatchCard(
                                vehicleMake: parts.firstOrNull ?? '',
                                vehicleModel: parts.skip(1).join(' '),
                                vehicleColor: '',
                                licensePlate: '',
                              );
                            },
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 250.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
            SliverToBoxAdapter(
              child: _buildRouteDetails(context, ride)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            SliverToBoxAdapter(
              child: _buildPassengersList(context, ride)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            // Post-ride review prompt — shown when ride is completed AND the
            // passenger was actually picked up (FIX RC-2: do not show after a
            // mid-trip cancellation or a ride the passenger never boarded).
            if (ride.status == RideStatus.completed &&
                !rideState.hasSkippedReview &&
                rideState.pickedUpPassengerIds.contains(
                  ref.read(currentAuthUidProvider).value ?? '',
                ))
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          child: PostRideReviewPrompt(
                            driverName: driverAsync.value?.username ?? 'Driver',
                            onRate: (rating) =>
                                _showRatingDialog(context, ride),
                            onSkip: () => ref
                                .read(
                                  activeRideViewModelProvider(
                                    widget.rideId,
                                  ).notifier,
                                )
                                .skipReviewPrompt(),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 450.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
            SliverToBoxAdapter(
              child: _buildActionButtons(context, ride)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MAP-FIRST LAYOUT (in-progress rides)
  // ═══════════════════════════════════════════════════════════════════

  /// Full-screen map experience for in-progress rides.
  /// Uses a Stack with map background + overlay controls + bottom info panel.
  Widget _buildMapFirstLayout(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
    AsyncValue<UserModel?> driverAsync,
  ) {
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );
    final driverLoc = rideState.driverLiveLocation;
    final driverLatLng = driverLoc != null
        ? LatLng(driverLoc.latitude, driverLoc.longitude)
        : originLatLng;
    final etaMinutes =
        rideState.remainingEtaMinutes ?? ride.durationMinutes ?? 30;
    final distToDest = rideState.remainingDistanceKm ?? ride.distanceKm ?? 0;

    // Center on driver only once when the map is first shown,
    // then let the passenger pan freely. Use the recenter button to re-focus.
    if (!_hasInitiallyPannedToDriver && driverLoc != null) {
      _hasInitiallyPannedToDriver = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _liveMapController.move(driverLatLng, 15);
      });
    }

    final routePoints =
        rideState.remainingRoutePoints ??
        rideState.osrmRoutePoints ??
        [
          originLatLng,
          ...ride.route.waypoints.map(
            (wp) => LatLng(wp.location.latitude, wp.location.longitude),
          ),
          destLatLng,
        ];

    return Stack(
      children: [
        // ── Full-screen live map ──
        RepaintBoundary(
          child: FlutterMap(
            mapController: _liveMapController,
            options: MapOptions(initialCenter: driverLatLng, initialZoom: 15),
            children: [
              const AppMapTileLayer(),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.white,
                    strokeWidth: 6,
                  ),
                  Polyline(
                    points: routePoints,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Driver's live position (pulsing)
                  if (driverLoc != null)
                    Marker(
                      point: driverLatLng,
                      width: 44.w,
                      height: 44.w,
                      child: PulsingLocationMarker(
                        heading: 0,
                        outerSize: 44.w,
                        innerSize: 28.w,
                        iconSize: 16.w,
                        icon: Icons.directions_car,
                        reverse: true,
                        color: AppColors.primary,
                      ),
                    ),
                  // Origin marker
                  Marker(
                    point: originLatLng,
                    width: 36.w,
                    height: 36.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
                  // Destination marker
                  Marker(
                    point: destLatLng,
                    width: 36.w,
                    height: 36.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.flag, color: Colors.white, size: 18.w),
                    ),
                  ),
                  // Waypoint markers with ETA
                  ...ride.route.waypoints.map((wp) {
                    final isPassed = rideState.passedWaypointIndices.contains(
                      wp.order,
                    );
                    final etaMin = rideState.waypointEtaMinutes[wp.order];
                    return Marker(
                      point: LatLng(
                        wp.location.latitude,
                        wp.location.longitude,
                      ),
                      width: 56.w,
                      height: etaMin != null && !isPassed ? 48.h : 28.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (etaMin != null && !isPassed)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              margin: EdgeInsets.only(bottom: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '${etaMin}m',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? AppColors.textTertiary
                                  : AppColors.warning,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${wp.order + 1}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // H1: Passenger's own location pin
                  if (_passengerLocation != null)
                    Marker(
                      point: _passengerLocation!,
                      width: 32.w,
                      height: 32.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // ── Route loading indicator ──
        if (rideState.osrmRoutePoints == null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 64.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Loading route...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Top controls ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    MapCircleButton(
                      icon: Icons.adaptive.arrow_back,
                      onTap: () => context.pop(),
                    ),
                    SizedBox(width: 12.w),
                    ActivePhaseBadge(
                      phase: rideState.phase,
                      rideStatus: ride.status,
                    ),
                    const Spacer(),
                    MapCircleButton(
                      icon: Icons.share_location,
                      onTap: () => _shareTrip(ride),
                    ),
                    SizedBox(width: 8.w),
                    MapCircleButton(
                      icon: Icons.my_location,
                      onTap: () {
                        if (driverLoc != null) {
                          _liveMapController.move(driverLatLng, 15);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Live indicator ──
        Positioned(
          top: MediaQuery.paddingOf(context).top + 56.h,
          right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: driverLoc != null
                  ? AppColors.success
                  : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  driverLoc != null ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // AR-5: "Waiting for driver location" overlay when driver GPS is absent
        if (driverLoc == null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56.h,
            left: 12.w,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator.adaptive(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white70),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Waiting for driver's location…",
                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

        // AR-6: Location permission denied — inform and link to settings.
        if (_locationPermissionDeniedForever)
          Positioned(
            bottom: 220.h,
            left: 16.w,
            right: 16.w,
            child: GestureDetector(
              onTap: () => ref.read(locationServiceProvider).openAppSettings(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_off, size: 18.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Location access is off. Open Settings to change access for live trip updates.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Night safety banner ──
        if (_isNightTime)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56.h,
            left: 12.w,
            right: 80.w,
            child: const NightSafetyBanner().animate().fadeIn(duration: 300.ms),
          ),

        // ── Route deviation alert ──
        if (rideState.isOffRoute)
          Positioned(
            top:
                MediaQuery.paddingOf(context).top +
                (_isNightTime ? 120.h : 56.h),
            left: 20.w,
            right: 20.w,
            child: RouteDeviationAlert(rideState: rideState)
                .animate()
                .fadeIn(duration: 300.ms)
                .shake(hz: 2, offset: const Offset(2, 0)),
          ),

        // ── E4: Driver location unavailable banner ──
        if (rideState.lastDriverLocationUpdate != null &&
            DateTime.now()
                    .difference(rideState.lastDriverLocationUpdate!)
                    .inMinutes >=
                5)
          Positioned(
            top:
                MediaQuery.paddingOf(context).top +
                (_isNightTime ? 160.h : 100.h),
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, size: 18.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Driver location unavailable for 5+ min',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

        // ── Bottom draggable info sheet ──
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.38,
          minChildSize: 0.15,
          maxChildSize: 0.80,
          snap: true,
          snapSizes: const [0.15, 0.38, 0.80],
          builder: (context, scrollController) {
            // Consumer isolates bottom sheet from driver GPS updates (driverLiveLocation/routePoints)
            return Consumer(
              builder: (context, ref, _) {
                ref.watch(
                  activeRideViewModelProvider(widget.rideId).select(
                    (s) => (
                      s.phase,
                      s.remainingEtaMinutes,
                      s.remainingDistanceKm,
                      s.isConnected,
                      s.isOffRoute,
                      s.latestQuickMessage,
                      s.rideDelayMinutes,
                      s.rideTimeoutMinutes,
                      s.hasShownTimeoutWarning,
                      s.bookings,
                      s.pickedUpPassengerIds,
                      s.pickupOrder,
                      s.waypointEtaMinutes,
                      s.passedWaypointIndices,
                      s.currentSpeedKmh.toStringAsFixed(0),
                    ),
                  ),
                );
                final latestState = ref.read(
                  activeRideViewModelProvider(widget.rideId),
                );
                final etaMins =
                    latestState.remainingEtaMinutes ??
                    ride.durationMinutes ??
                    30;
                final dist =
                    latestState.remainingDistanceKm ?? ride.distanceKm ?? 0;
                return _buildRideInfoSheet(
                  context,
                  ride,
                  latestState,
                  driverAsync,
                  etaMins,
                  dist,
                  scrollController,
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Draggable bottom sheet for the map-first layout — shows ETA, driver info,
  /// route itinerary, and action buttons in a scrollable sheet.
  Widget _buildRideInfoSheet(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
    AsyncValue<UserModel?> driverAsync,
    int etaMinutes,
    double distToDest,
    ScrollController scrollController,
  ) {
    final driver = driverAsync.value;
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      clipBehavior: Clip.antiAlias,
      child: Builder(
        builder: (context) {
          final sheetItems = <Widget>[
            // Drag handle
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),

            // Connectivity indicator
            if (!rideState.isConnected)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ).copyWith(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 16.sp,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Poor connection — updates may be delayed',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Delay banner
            if (rideState.rideDelayMinutes >= 5)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ).copyWith(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16.sp, color: AppColors.error),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Departure delayed by ${rideState.rideDelayMinutes} min',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Progress bar
            TripProgressBar(ride: ride, rideState: rideState),
            SizedBox(height: 20.h),

            // ETA, distance and speed tiles
            RepaintBoundary(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    RideInfoTile(
                      icon: Icons.access_time_rounded,
                      label: l10n.eta,
                      value: etaMinutes < 1
                          ? 'Arriving'
                          : '${etaMinutes}m · ${_formatArrivalTime(etaMinutes)}',
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12.w),
                    RideInfoTile(
                      icon: Icons.straighten_rounded,
                      label: l10n.distance,
                      value: distToDest < 1
                          ? '${(distToDest * 1000).toInt()} m'
                          : '${distToDest.toStringAsFixed(1)} km',
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 12.w),
                    RideInfoTile(
                      icon: Icons.speed_rounded,
                      label: l10n.speed,
                      value:
                          '${rideState.currentSpeedKmh.toStringAsFixed(0)} km/h',
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
            // Pickup queue position badge (7A)
            if (rideState.phase == ActiveRidePhase.pickingUp &&
                rideState.pickupOrder.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Builder(
                builder: (context) {
                  final user = ref.read(currentUserProvider).value;
                  final pos = user != null
                      ? rideState.pickupOrder.indexOf(user.uid) + 1
                      : 0;
                  if (pos <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt,
                            color: AppColors.info,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'You are #$pos in the pickup queue',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // OTP card — full display during pickingUp; collapsible during enRoute
            if (rideState.phase == ActiveRidePhase.pickingUp ||
                rideState.phase == ActiveRidePhase.enRoute) ...[
              SizedBox(height: 12.h),
              Builder(
                builder: (context) {
                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null) return const SizedBox.shrink();
                  final myBooking = rideState.bookings
                      .where((b) => b.passengerId == currentUser.uid)
                      .firstOrNull;
                  final otp = myBooking?.pickupOtp;
                  if (otp == null) return const SizedBox.shrink();

                  final isPickingUp =
                      rideState.phase == ActiveRidePhase.pickingUp;

                  if (isPickingUp) {
                    // Full OTP card during pickingUp
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pin_rounded,
                                  color: Colors.white70,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Your Pickup Code',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              otp,
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 16,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Show this to your driver',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // AR-7: Collapsible "show again" row during enRoute phase
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _showOtp = !_showOtp),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pin_rounded,
                                  color: AppColors.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Show my pickup code',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _showOtp
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showOtp) ...[
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  otp,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 16,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Your pickup confirmation code',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],

            SizedBox(height: 16.h),

            // AR-3: Overtime warning banner
            if (rideState.rideTimeoutMinutes != null &&
                !rideState.hasShownTimeoutWarning) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_off,
                        size: 18.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Trip is taking longer than expected — is everything okay?',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => ref
                            .read(
                              activeRideViewModelProvider(
                                widget.rideId,
                              ).notifier,
                            )
                            .dismissTimeoutWarning(),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Driver info row
            if (driver != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: driver.photoUrl != null
                          ? CachedNetworkImageProvider(driver.photoUrl!)
                          : null,
                      child: driver.photoUrl == null
                          ? Text(
                              driver.username[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  driver.username,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (driver.isEmailVerified) ...[
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.verified,
                                  size: 16.sp,
                                  color: Colors.blue,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                driver.asDriver?.rating.average.toStringAsFixed(
                                      1,
                                    ) ??
                                    '0.0',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if ((driver.asDriver?.rating.total ?? 0) > 0) ...[
                                Text(
                                  ' (${driver.asDriver?.rating.total ?? 0})',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                              if ((driver.asDriver?.gamification.totalRides ??
                                      0) >
                                  0) ...[
                                Text(
                                  ' · ${driver.asDriver?.gamification.totalRides ?? 0} trips',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Call button
                    MapCircleButton(
                      icon: Icons.phone,
                      onTap: () => _callDriver(driver.asDriver?.phoneNumber),
                    ),
                    SizedBox(width: 10.w),
                    // Message button
                    MapCircleButton(
                      icon: Icons.message,
                      onTap: () => _sendMessage(ride.driverId),
                    ),
                  ],
                ),
              ),

            // Payment confirmation badge — derived from the passenger's own booking
            Builder(
              builder: (context) {
                final currentUser = ref.read(currentUserProvider).value;
                if (currentUser == null) return const SizedBox.shrink();
                final myBooking = rideState.bookings
                    .where((b) => b.passengerId == currentUser.uid)
                    .firstOrNull;
                if (myBooking == null) return const SizedBox.shrink();

                final isPaid = myBooking.paidAt != null;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ).copyWith(top: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isPaid
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          size: 18.sp,
                          color: isPaid ? AppColors.success : AppColors.warning,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPaid
                                    ? 'Payment Confirmed'
                                    : 'Payment Pending',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isPaid
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              if (isPaid && myBooking.paidAt != null)
                                Text(
                                  'Paid on ${_formatPaidAt(myBooking.paidAt!)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              else
                                Text(
                                  'Complete payment to confirm your seat',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isPaid)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'PAID',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),

            // Vehicle info for easy identification
            if (ride.vehicleId != null || ride.vehicleInfo != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                ).copyWith(bottom: 8.h),
                child: Builder(
                  builder: (context) {
                    if (ride.vehicleId != null) {
                      final vehiclesAsync = ref.watch(
                        userVehiclesStreamProvider(ride.driverId),
                      );
                      return vehiclesAsync.when(
                        data: (vehicles) {
                          final vehicle = vehicles
                              .where((v) => v.id == ride.vehicleId)
                              .firstOrNull;
                          if (vehicle == null) return const SizedBox.shrink();
                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    '${vehicle.color} ${vehicle.make} ${vehicle.model}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (vehicle.licensePlate.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      vehicle.licensePlate,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    }
                    // Fallback: parse from vehicleInfo string
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              ride.vehicleInfo!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Quick message chips (7D)
            if (ride.status == RideStatus.inProgress)
              _buildPassengerQuickMessages(ride, rideState),

            // Route itinerary (Compact)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    MiniRouteRow(
                      icon: Icons.trip_origin_rounded,
                      color: AppColors.success,
                      text: ride.origin.address,
                    ),
                    // Show intermediate waypoints
                    for (final wp in ride.route.waypoints)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: MiniRouteRow(
                          icon: Icons.circle,
                          color: AppColors.warning,
                          text: wp.location.address,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    MiniRouteRow(
                      icon: Icons.location_on_rounded,
                      color: AppColors.error,
                      text: ride.destination.address,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Share live trip + SOS row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  // Share button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareTrip(ride),
                      icon: Icon(Icons.share_location, size: 18.sp),
                      label: Text(l10n.shareRide),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h + bottomPadding),
          ];
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: sheetItems.length,
            itemBuilder: (context, index) => sheetItems[index],
          );
        },
      ),
    );
  }

  /// Static route map preview for non-inProgress states (scheduled, active, completed).
  Widget _buildStaticRouteMap(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final l10n = AppLocalizations.of(context);
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );
    final center = LatLng(
      (originLatLng.latitude + destLatLng.latitude) / 2,
      (originLatLng.longitude + destLatLng.longitude) / 2,
    );
    final routePoints = rideState.osrmRoutePoints ?? [originLatLng, destLatLng];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                const AppMapTileLayer(),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.white,
                      strokeWidth: 6,
                    ),
                    Polyline(
                      points: routePoints,
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: originLatLng,
                      width: 36.w,
                      height: 36.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 18.w,
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
                        width: 30.w,
                        height: 30.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 14.w,
                          ),
                        ),
                      ),
                    ),
                    Marker(
                      point: destLatLng,
                      width: 36.w,
                      height: 36.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 18.w,
                        ),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
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
            // Status badge
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ride.status == RideStatus.completed
                      ? AppColors.success
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  ride.status == RideStatus.completed
                      ? l10n.rideCompleted
                      : l10n.routeDetails,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RideModel ride) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.goBackTooltip,
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.adaptive.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  RideStatusBadge(status: ride.status),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.activeRide,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _formatDateTime(ride.departureTime),
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final l10n = AppLocalizations.of(context);
    final phase = rideState.phase;
    final isInProgress = ride.status == RideStatus.inProgress;
    final isEnRouteOrLater =
        isInProgress &&
        (phase == ActiveRidePhase.enRoute ||
            phase == ActiveRidePhase.arriving ||
            phase == ActiveRidePhase.completed);
    final isArrivingOrLater =
        isInProgress &&
        (phase == ActiveRidePhase.arriving ||
            phase == ActiveRidePhase.completed);
    final isCompleted = ride.status == RideStatus.completed;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          RideStatusStep(
            label: l10n.rideConfirmed,
            isCompleted: ride.status.index >= RideStatus.active.index,
            icon: Icons.check_circle,
          ),
          RideStatusDivider(isActive: isEnRouteOrLater || isCompleted),
          RideStatusStep(
            label: l10n.driverOnTheWay,
            isCompleted: isEnRouteOrLater || isCompleted,
            icon: Icons.directions_car,
          ),
          RideStatusDivider(isActive: isArrivingOrLater || isCompleted),
          RideStatusStep(
            label: 'Arriving Soon',
            isCompleted: isArrivingOrLater || isCompleted,
            icon: Icons.near_me,
          ),
          RideStatusDivider(isActive: isCompleted),
          RideStatusStep(
            label: l10n.rideCompleted,
            isCompleted: isCompleted,
            icon: Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(
    BuildContext context,
    UserModel? driver,
    RideModel ride,
  ) {
    final l10n = AppLocalizations.of(context);
    if (driver == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: driver.photoUrl != null
                ? CachedNetworkImageProvider(driver.photoUrl!)
                : null,
            child: driver.photoUrl == null
                ? Text(
                    driver.username[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.username,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (driver.isEmailVerified)
                      Icon(Icons.verified, size: 16.sp, color: Colors.blue),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      driver.asDriver?.rating.average.toStringAsFixed(1) ??
                          '0.0',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).valueRides2(driver.asDriver?.rating.total ?? 0),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: l10n.messageDriver,
                onPressed: () => _sendMessage(driver.uid),
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.callDriver,
                onPressed: driver.asDriver?.phoneNumber != null
                    ? () => _callDriver(driver.asDriver!.phoneNumber)
                    : null,
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color:
                        (driver.asDriver?.phoneNumber != null
                                ? Colors.green
                                : Colors.grey)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: driver.asDriver?.phoneNumber != null
                        ? Colors.green
                        : Colors.grey,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(BuildContext context, RideModel ride) {
    final l10n = AppLocalizations.of(context);
    final passedWaypoints = ref
        .watch(activeRideViewModelProvider(widget.rideId))
        .passedWaypointIndices;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.routeDetails,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.my_location,
                  size: 18.sp,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pickup,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.origin.address,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Dotted line
          Container(
            padding: EdgeInsets.only(left: 16.w),
            height: 24.h,
            width: 2,
            margin: EdgeInsets.symmetric(vertical: 4.h),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.border,
                  width: 2,
                ),
              ),
            ),
          ),
          // Waypoints
          if (ride.route.waypoints.isNotEmpty)
            ...ride.route.waypoints.asMap().entries.map((entry) {
              final index = entry.key;
              final wp = entry.value;
              final isPassed = passedWaypoints.contains(wp.order);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? AppColors.success.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          isPassed
                              ? Icons.check_circle_rounded
                              : Icons.flag_circle,
                          size: 18.sp,
                          color: isPassed ? AppColors.success : Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Waypoint ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                if (isPassed) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Passed',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              wp.location.address,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isPassed
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                decoration: isPassed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
                    height: 24.h,
                    width: 2,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: isPassed
                              ? AppColors.success
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.destination,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.destination.address,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Event badge
          if (ride.eventId != null) ...[
            SizedBox(height: 12.h),
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
          SizedBox(height: 16.h),
          const Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          // Ride info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoItem(
                icon: Icons.euro_symbol,
                value: AppLocalizations.of(
                  context,
                ).value5((ride.pricePerSeatInCents / 100).toStringAsFixed(2)),
                label: l10n.perSeat2,
              ),
              InfoItem(
                icon: Icons.event_seat,
                value: AppLocalizations.of(
                  context,
                ).valueValue(ride.remainingSeats, ride.availableSeats),
                label: l10n.seatsLeft,
              ),
              InfoItem(
                icon: Icons.access_time,
                value: _formatTime(ride.departureTime),
                label: l10n.departure,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersList(BuildContext context, RideModel ride) {
    final l10n = AppLocalizations.of(context);
    final passengers = ride.acceptedBookings;

    if (passengers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 40.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.noPassengersYet,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passengersValue(passengers.length),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...passengers.map(
            (booking) => _buildPassengerItem(booking.passengerId),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(String passengerId) {
    final passengerAsync = ref.watch(currentUserProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        if (passenger == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: passenger.photoUrl != null
                    ? CachedNetworkImageProvider(passenger.photoUrl!)
                    : null,
                child: passenger.photoUrl == null
                    ? Text(passenger.username[0].toUpperCase())
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.username,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          passenger.asRider?.rating.average.toStringAsFixed(
                                1,
                              ) ??
                              '0.0',
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
              IconButton(
                tooltip: AppLocalizations.of(context).messagePassenger,
                onPressed: () => _sendMessage(passenger.uid),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildActionButtons(BuildContext context, RideModel ride) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          if (ride.status == RideStatus.draft ||
              ride.status == RideStatus.active)
            PremiumButton(
              text: l10n.cancelRide2,
              icon: Icons.cancel_outlined,
              onPressed: () => _showCancelDialog(context, ride),
              style: PremiumButtonStyle.outline,
            ),
          if (ride.status == RideStatus.completed)
            PremiumButton(
              text: l10n.rateAndReview,
              icon: Icons.star_outline,
              onPressed: () => _showRatingDialog(context, ride),
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String recipientId) async {
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch recipient's actual profile for correct display name and avatar
      final recipientProfile = await ref.read(
        userProfileProvider(recipientId).future,
      );
      if (!mounted) return;
      final recipientName = recipientProfile?.username ?? 'User';
      final recipientPhotoUrl = recipientProfile?.photoUrl;

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: recipientId,
          userName1: currentUser.username,
          userName2: recipientName,
        ).future,
      );

      if (!mounted) return;

      // Pass the actual UserModel so the chat screen can show the correct info
      final receiverUser =
          recipientProfile ??
          UserModel.rider(
            uid: recipientId,
            email: '',
            username: recipientName,
            photoUrl: recipientPhotoUrl,
          );

      await context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: receiverUser,
      );
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: l10n.failedToOpenChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _callDriver(String? phoneNumber) async {
    final l10n = AppLocalizations.of(context);
    if (phoneNumber == null) {
      AdaptiveSnackBar.show(
        context,
        message: l10n.phoneNumberNotAvailable,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          AdaptiveSnackBar.show(
            context,
            message: l10n.cannotMakePhoneCalls,
          );
        }
      }
    } on Exception {
      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.failedToLaunchDialer,
          type: AdaptiveSnackBarType.error,
        );
      }
    }
  }

  Future<void> _showCancelDialog(BuildContext context, RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierLabel: l10n.cancelRide,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.cancelRide2),
        content: Text(l10n.areYouSureYouWant9),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(l10n.keepRide),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              await _cancelRide(ride);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.cancelRide2),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRide(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      // Find the passenger's booking for this ride to cancel only their booking
      final allBookings = await ref.read(
        bookingsByPassengerProvider(currentUser.uid).future,
      );
      final myBooking = allBookings
          .where((b) => b.rideId == ride.id)
          .firstOrNull;

      if (!mounted) return;
      if (myBooking == null) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.bookingNotFoundTryAgain,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }

      await ref
          .read(rideActionsViewModelProvider.notifier)
          .cancelBooking(rideId: ride.id, bookingId: myBooking.id);

      // Refunds are handled by the booking cancellation Cloud Function.
      // Calling the refund endpoint here races that trigger and can issue a
      // duplicate Stripe refund.

      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.rideCancelledSuccessfully,
          type: AdaptiveSnackBarType.success,
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.failedToCancelRideValue(e),
          type: AdaptiveSnackBarType.error,
        );
      }
    }
  }

  Future<void> _showRatingDialog(BuildContext context, RideModel ride) async {
    // Fetch driver profile to get name for review screen
    final driverProfile = await ref.read(
      userProfileProvider(ride.driverId).future,
    );

    if (!context.mounted) return;

    // Navigate to the submit review screen for the driver
    await context.push(
      '${AppRoutes.submitReview.path}'
      '?rideId=${ride.id}'
      '&revieweeId=${ride.driverId}'
      '&revieweeName=${Uri.encodeComponent(driverProfile?.username ?? 'Driver')}'
      '&reviewType=driverReview',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final daysDiff = dateDay.difference(today).inDays;

    if (daysDiff == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (daysDiff == 1) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (daysDiff == -1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
