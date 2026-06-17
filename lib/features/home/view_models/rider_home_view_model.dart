import 'dart:async' show StreamSubscription, unawaited;

import 'package:geolocator/geolocator.dart' show Position;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'rider_home_view_model.g.dart';

/// Location permission and service state
enum LocationPermissionState {
  /// Never asked yet / cold start
  unknown,

  /// User tapped allow — OS dialog pending or GPS acquiring
  acquiring,

  /// GPS fix obtained — map ready
  ready,

  /// Soft deny: user tapped "Not now" on rationale screen
  deniedSoft,

  /// Hard deny: user previously denied the OS dialog forever
  deniedHard,

  /// Device-level location services are OFF
  serviceDisabled,
}

/// Complete state for RiderHomeScreen
class RiderHomeState {
  const RiderHomeState({
    this.locationState = LocationPermissionState.unknown,
    this.currentLocation,
    this.userHeading = 0.0,
    this.nearbyQueryAnchor,
    this.lastMapMoveAt,
    this.currentZoom = 14,
    this.showNearbyDrivers = true,
    this.showDistanceRadius = false,
    this.searchRadius = 5.0,
    this.selectedFilter = 'all',
    this.activeRoute,
    this.alternativeRoutes = const [],
    this.isLoadingRoute = false,
    this.showRouteInfo = false,
    this.selectedRouteIndex = 0,
    this.showMapView = false,
  });

  // Location permission and acquisition
  final LocationPermissionState locationState;

  // Current location
  final LatLng? currentLocation;
  final double userHeading;
  final LatLng? nearbyQueryAnchor;
  final DateTime? lastMapMoveAt;

  // Map view settings
  final double currentZoom;
  final bool showNearbyDrivers;
  final bool showDistanceRadius;
  final double searchRadius;

  // Filter state
  final String selectedFilter;

  // Route state
  final RouteInfo? activeRoute;
  final List<RouteInfo> alternativeRoutes;
  final bool isLoadingRoute;
  final bool showRouteInfo;
  final int selectedRouteIndex;

  // View mode: false = feed (default), true = full map
  final bool showMapView;

  RiderHomeState copyWith({
    LocationPermissionState? locationState,
    LatLng? currentLocation,
    double? userHeading,
    LatLng? nearbyQueryAnchor,
    DateTime? lastMapMoveAt,
    double? currentZoom,
    bool? showNearbyDrivers,
    bool? showDistanceRadius,
    double? searchRadius,
    String? selectedFilter,
    RouteInfo? activeRoute,
    List<RouteInfo>? alternativeRoutes,
    bool? isLoadingRoute,
    bool? showRouteInfo,
    int? selectedRouteIndex,
    bool? showMapView,
  }) {
    return RiderHomeState(
      locationState: locationState ?? this.locationState,
      currentLocation: currentLocation ?? this.currentLocation,
      userHeading: userHeading ?? this.userHeading,
      nearbyQueryAnchor: nearbyQueryAnchor ?? this.nearbyQueryAnchor,
      lastMapMoveAt: lastMapMoveAt ?? this.lastMapMoveAt,
      currentZoom: currentZoom ?? this.currentZoom,
      showNearbyDrivers: showNearbyDrivers ?? this.showNearbyDrivers,
      showDistanceRadius: showDistanceRadius ?? this.showDistanceRadius,
      searchRadius: searchRadius ?? this.searchRadius,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      activeRoute: activeRoute ?? this.activeRoute,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      showRouteInfo: showRouteInfo ?? this.showRouteInfo,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      showMapView: showMapView ?? this.showMapView,
    );
  }

  RiderHomeState clearLocation() {
    return RiderHomeState(
      locationState: locationState,
      currentZoom: currentZoom,
      showNearbyDrivers: showNearbyDrivers,
      showDistanceRadius: showDistanceRadius,
      searchRadius: searchRadius,
      selectedFilter: selectedFilter,
      activeRoute: activeRoute,
      alternativeRoutes: alternativeRoutes,
      isLoadingRoute: isLoadingRoute,
      showRouteInfo: showRouteInfo,
      selectedRouteIndex: selectedRouteIndex,
      showMapView: showMapView,
    );
  }

  RiderHomeState clearRoute() {
    return RiderHomeState(
      locationState: locationState,
      currentLocation: currentLocation,
      userHeading: userHeading,
      nearbyQueryAnchor: nearbyQueryAnchor,
      lastMapMoveAt: lastMapMoveAt,
      currentZoom: currentZoom,
      showNearbyDrivers: showNearbyDrivers,
      showDistanceRadius: showDistanceRadius,
      searchRadius: searchRadius,
      selectedFilter: selectedFilter,
      showMapView: showMapView,
    );
  }
}

/// ViewModel for RiderHomeScreen with all business logic
@riverpod
class RiderHomeViewModel extends _$RiderHomeViewModel {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  RiderHomeState build() {
    ref.onDispose(() {
      _positionStreamSubscription?.cancel();
    });

    return const RiderHomeState();
  }

  // ============================================================================
  // Location Permission Flow
  // ============================================================================

  /// Check initial location permission state on cold start
  Future<void> checkInitialLocationState() async {
    final svc = ref.read(locationServiceProvider);
    if (!await svc.isServiceEnabled()) {
      if (!ref.mounted) return;
      state = state.copyWith(
        locationState: LocationPermissionState.serviceDisabled,
      );
      return;
    }
    if (await svc.isPermissionPermanentlyDenied()) {
      if (!ref.mounted) return;
      state = state.copyWith(locationState: LocationPermissionState.deniedHard);
      return;
    }
    if (await svc.checkPermission()) {
      if (!ref.mounted) return;
      await acquireLocationAndShowMap();
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(locationState: LocationPermissionState.unknown);
  }

  /// Full OS permission request flow — called after UI rationale dialog accepted.
  Future<void> handleLocationPermissionRequest() async {
    final svc = ref.read(locationServiceProvider);
    if (!await svc.isServiceEnabled()) {
      if (!ref.mounted) return;
      state = state.copyWith(
        locationState: LocationPermissionState.serviceDisabled,
      );
      return;
    }
    final granted = await svc.requestPermission();
    if (!ref.mounted) return;
    if (granted) {
      await acquireLocationAndShowMap();
      return;
    }
    final hardDenied = await svc.isPermissionPermanentlyDenied();
    if (!ref.mounted) return;
    state = state.copyWith(
      locationState: hardDenied
          ? LocationPermissionState.deniedHard
          : LocationPermissionState.deniedSoft,
    );
  }

  /// Transition to acquiring state (called when user taps "Allow Location")
  void setAcquiringLocation() {
    state = state.copyWith(locationState: LocationPermissionState.acquiring);
  }

  /// Handle permission denial states
  void setLocationDeniedSoft() {
    state = state.copyWith(locationState: LocationPermissionState.deniedSoft);
  }

  void setLocationDeniedHard() {
    state = state.copyWith(locationState: LocationPermissionState.deniedHard);
  }

  void setLocationServiceDisabled() {
    state = state.copyWith(
      locationState: LocationPermissionState.serviceDisabled,
    );
  }

  // ============================================================================
  // Notification Permission
  // ============================================================================

  /// True if we should prompt — false if already granted or dialog was shown before.
  Future<bool> shouldAskNotificationPermission() async {
    if (await ref.read(pushNotificationServiceProvider).hasPermission()) {
      return false;
    }
    if (!ref.mounted) return false;
    final settings = ref.read(settingsViewModelProvider);
    return !settings.notificationDialogShown;
  }

  Future<void> markNotificationDialogShown() async {
    final settings = ref.read(settingsViewModelProvider.notifier);
    await settings.setNotificationDialogShown();
  }

  Future<void> requestNotificationPermission() async {
    await ref.read(pushNotificationServiceProvider).requestPermission();
  }

  Future<void> openLocationAppSettings() =>
      ref.read(locationServiceProvider).openAppSettings();

  Future<void> openLocationSettings() =>
      ref.read(locationServiceProvider).openLocationSettings();

  /// Acquire GPS location and transition to ready state
  Future<void> acquireLocationAndShowMap() async {
    if (state.locationState != LocationPermissionState.acquiring) {
      state = state.copyWith(locationState: LocationPermissionState.acquiring);
    }

    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      if (!ref.mounted) return;

      if (position != null) {
        final loc = LatLng(position.latitude, position.longitude);
        state = state.copyWith(
          currentLocation: loc,
          nearbyQueryAnchor: loc,
          userHeading: position.heading,
          locationState: LocationPermissionState.ready,
        );
      } else {
        state = state.copyWith(locationState: LocationPermissionState.ready);
      }

      _startLocationStream();
    } on Exception catch (e) {
      TalkerService.error('Failed to get initial position: $e');
      if (!ref.mounted) return;
      state = state.copyWith(locationState: LocationPermissionState.ready);
      _startLocationStream();
    }
  }

  /// Refresh current location without full acquisition
  Future<void> refetchCurrentLocation() async {
    if (state.locationState != LocationPermissionState.ready) return;

    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      if (!ref.mounted) return;
      if (position == null) return;
      state = state.copyWith(
        currentLocation: LatLng(position.latitude, position.longitude),
        userHeading: position.heading,
      );
    } on Exception catch (e) {
      TalkerService.error('Failed to refetch location: $e');
    }
  }

  /// Start continuous GPS tracking stream
  void _startLocationStream() {
    unawaited(_positionStreamSubscription?.cancel());
    final locationService = ref.read(locationServiceProvider);

    _positionStreamSubscription = locationService.getLocationStream().listen(
      (position) {
        final next = LatLng(position.latitude, position.longitude);

        final current = state.currentLocation;
        if (current != null) {
          final movedMeters =
              locationService.calculateDistance(
                current.latitude,
                current.longitude,
                next.latitude,
                next.longitude,
              ) *
              1000;
          final headingDelta = (state.userHeading - position.heading).abs();
          if (movedMeters < 12 && headingDelta < 8) return;
        }

        var newState = state.copyWith(
          currentLocation: next,
          userHeading: position.heading,
        );

        // Snap the anchor to a coarse grid so it only changes when the rider
        // crosses into a new cell, instead of producing a fresh anchor (and a
        // brand-new Firestore .snapshots() subscription) every time they move
        // ~1km. Quantizing keeps the family key stable across small movements.
        final anchor = state.nearbyQueryAnchor;
        final snapped = _quantizeAnchor(next);
        if (anchor == null || snapped != anchor) {
          newState = newState.copyWith(nearbyQueryAnchor: snapped);
        }

        state = newState;
      },
      onError: (Object e) {
        TalkerService.error('Location stream error: $e');
      },
    );
  }

  /// Grid cell size (in degrees) used to quantize the nearby-rides query
  /// anchor. ~0.01° ≈ 1.1km of latitude, keeping the query family key stable
  /// while the rider makes small movements.
  static const double _anchorGridDegrees = 0.01;

  /// Snap [point] to the nearest coarse grid cell so the nearby-rides query
  /// family key (and its Firestore subscription) changes far less often.
  LatLng _quantizeAnchor(LatLng point) {
    final lat = (point.latitude / _anchorGridDegrees).roundToDouble() *
        _anchorGridDegrees;
    final lng = (point.longitude / _anchorGridDegrees).roundToDouble() *
        _anchorGridDegrees;
    return LatLng(lat, lng);
  }

  /// Stop location tracking (cleanup)
  void stopLocationTracking() {
    unawaited(_positionStreamSubscription?.cancel());
    _positionStreamSubscription = null;
  }

  // ============================================================================
  // Map State Methods
  // ============================================================================

  /// Update zoom level (called from map onPositionChanged)
  void updateZoom(double zoom) {
    if ((state.currentZoom - zoom).abs() > 0.01) {
      state = state.copyWith(currentZoom: zoom);
    }
  }

  /// Toggle nearby drivers visibility
  void toggleNearbyDrivers() {
    state = state.copyWith(showNearbyDrivers: !state.showNearbyDrivers);
  }

  /// Toggle distance radius circle
  void toggleDistanceRadius() {
    state = state.copyWith(showDistanceRadius: !state.showDistanceRadius);
  }

  /// Update search radius
  void updateSearchRadius(double radius) {
    if (radius >= 1.0 && radius <= 25.0) {
      state = state.copyWith(searchRadius: radius);
    }
  }

  /// Record last map move time (for throttling)
  void updateLastMapMoveTime(DateTime time) {
    state = state.copyWith(lastMapMoveAt: time);
  }

  /// Check if map can move (throttle check)
  bool canMoveMap() {
    final last = state.lastMapMoveAt;
    if (last == null) return true;
    final now = DateTime.now();
    return now.difference(last) >= const Duration(milliseconds: 700);
  }

  // ============================================================================
  // Filter Methods
  // ============================================================================

  /// Set ride filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Apply filter to ride list
  List<RideModel> applyFilter(List<RideModel> rides) {
    switch (state.selectedFilter) {
      case 'available':
        return rides.where((r) => r.availableSeats > 0).toList();
      case 'premium':
        return rides.where((r) => r.isPremium).toList();
      case 'eco':
        return rides.where((r) => r.isEco).toList();
      default:
        return rides;
    }
  }

  // ============================================================================
  // Route Methods
  // ============================================================================

  /// Set active route
  void setActiveRoute(RouteInfo? route) {
    state = state.copyWith(activeRoute: route, showRouteInfo: route != null);
  }

  /// Set alternative routes
  void setAlternativeRoutes(List<RouteInfo> routes) {
    state = state.copyWith(alternativeRoutes: routes);
  }

  /// Select route by index
  void selectRoute(int index) {
    if (index >= 0 && index < state.alternativeRoutes.length) {
      state = state.copyWith(
        selectedRouteIndex: index,
        activeRoute: state.alternativeRoutes[index],
      );
    }
  }

  /// Toggle route info panel
  void toggleRouteInfo() {
    state = state.copyWith(showRouteInfo: !state.showRouteInfo);
  }

  /// Set route loading state
  void setLoadingRoute(bool loading) {
    state = state.copyWith(isLoadingRoute: loading);
  }

  /// Clear all route state
  void clearRoutes() {
    state = state.clearRoute();
  }

  /// Toggle between feed view and full map view
  void toggleMapView() {
    state = state.copyWith(showMapView: !state.showMapView);
  }

  /// Switch to map view
  void showMap() {
    state = state.copyWith(showMapView: true);
  }

  /// Switch to feed view
  void showFeed() {
    state = state.copyWith(showMapView: false);
  }
}
