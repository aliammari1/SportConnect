import 'dart:async';

import 'package:geolocator/geolocator.dart' show Position;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/home/repositories/home_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'home_view_model.g.dart';

/// State for the home screen with comprehensive map and location management
class HomeState {
  const HomeState({
    this.selectedTabIndex = 0,
    this.isMapExpanded = true,
    this.currentLocation = const LatLng(37.7749, -122.4194),
    this.isLoadingLocation = true,
    this.locationError,
    this.userHeading = 0.0,
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
    this.user = const AsyncLoading(),
  });
  // Navigation state
  final int selectedTabIndex;
  final bool isMapExpanded;

  // Location state
  final LatLng currentLocation;
  final bool isLoadingLocation;
  final String? locationError;
  final double userHeading;

  // Map state
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

  // Aggregated data (via ref.listen in build())
  /// Current authenticated user.
  final AsyncValue<UserModel?> user;

  HomeState copyWith({
    int? selectedTabIndex,
    bool? isMapExpanded,
    LatLng? currentLocation,
    bool? isLoadingLocation,
    String? locationError,
    double? userHeading,
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
    AsyncValue<UserModel?>? user,
  }) {
    return HomeState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isMapExpanded: isMapExpanded ?? this.isMapExpanded,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: locationError,
      userHeading: userHeading ?? this.userHeading,
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
      user: user ?? this.user,
    );
  }
}

/// ViewModel for the home screen with full business logic extraction
/// Manages navigation, map state, location tracking, and routing
@riverpod
class HomeViewModel extends _$HomeViewModel {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  HomeState build() {
    // Cancel subscription on dispose
    ref
      ..onDispose(() {
        unawaited(_positionStreamSubscription?.cancel());
      })
      ..listen(currentUserProvider, (_, next) {
        state = state.copyWith(user: next);
      });

    return HomeState(
      user: ref.read(currentUserProvider),
    );
  }

  /// Initializes location services and starts tracking.
  ///
  /// Must be called explicitly by the consumer widget (e.g. in a
  /// post-frame callback or button handler) to avoid side effects during
  /// provider initialization.
  Future<void> initializeLocation() async {
    await getCurrentLocation();
    if (!ref.mounted) return;
    startLocationTracking();
  }

  // ============================================================================
  // Navigation Methods
  // ============================================================================

  /// Set the current tab index
  void setTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  /// Toggle map expansion
  void toggleMapExpansion() {
    state = state.copyWith(isMapExpanded: !state.isMapExpanded);
  }

  // ============================================================================
  // Location Methods
  // ============================================================================

  /// Get current device location with permission handling
  Future<void> getCurrentLocation() async {
    final locationService = ref.read(locationServiceProvider);
    try {
      final granted = await locationService.requestPermission();
      if (!ref.mounted) return;
      if (!granted) {
        final permanentlyDenied = await locationService
            .isPermissionPermanentlyDenied();
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: permanentlyDenied
              ? 'Location access is off in device settings.'
              : 'Location permission denied',
        );
        return;
      }

      final position = await locationService.getCurrentLocation();
      if (!ref.mounted) return;
      if (position == null) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: 'Unable to get location',
        );
        return;
      }

      state = state.copyWith(
        currentLocation: LatLng(position.latitude, position.longitude),
        isLoadingLocation: false,
        userHeading: position.heading,
      );
    } on Exception catch (e) {
      TalkerService.error('Error getting location: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'Error getting location: $e',
      );
    }
  }

  /// Start continuous location tracking stream
  void startLocationTracking() {
    _positionStreamSubscription = ref
        .read(locationServiceProvider)
        .getLocationStream()
        .listen(
          (position) {
            final newLocation = LatLng(position.latitude, position.longitude);
            state = state.copyWith(
              currentLocation: newLocation,
              userHeading: position.heading,
            );
          },
          onError: (Object error) {
            TalkerService.error('Location tracking error: $error');
            state = state.copyWith(locationError: 'Location tracking error');
          },
        );
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Manually set location (for testing or manual input)
  void setCurrentLocation(LatLng location) {
    state = state.copyWith(
      currentLocation: location,
      isLoadingLocation: false,
    );
  }

  // ============================================================================
  // Map State Methods
  // ============================================================================

  /// Update map zoom level
  void updateZoom(double zoom) {
    state = state.copyWith(currentZoom: zoom);
  }



  /// Toggle nearby drivers/riders visibility on map
  void toggleNearbyDrivers() {
    state = state.copyWith(showNearbyDrivers: !state.showNearbyDrivers);
  }

  /// Toggle distance radius circle visibility
  void toggleDistanceRadius() {
    state = state.copyWith(showDistanceRadius: !state.showDistanceRadius);
  }

  /// Update search radius in kilometers
  void updateSearchRadius(double radius) {
    if (radius >= 1.0 && radius <= 50.0) {
      state = state.copyWith(searchRadius: radius);
    }
  }

  // ============================================================================
  // Filter Methods
  // ============================================================================

  /// Set ride filter (all, carpool, rideshare, etc.)
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  // ============================================================================
  // Route Methods
  // ============================================================================

  /// Set active route for navigation
  void setActiveRoute(RouteInfo? route) {
    state = state.copyWith(activeRoute: route, showRouteInfo: route != null);
  }

  /// Set alternative routes
  void setAlternativeRoutes(List<RouteInfo> routes) {
    state = state.copyWith(alternativeRoutes: routes);
  }

  /// Select route by index from alternatives
  void selectRoute(int index) {
    if (index >= 0 && index < state.alternativeRoutes.length) {
      state = state.copyWith(
        selectedRouteIndex: index,
        activeRoute: state.alternativeRoutes[index],
      );
    }
  }

  /// Toggle route info panel visibility
  void toggleRouteInfo() {
    state = state.copyWith(showRouteInfo: !state.showRouteInfo);
  }

  /// Set route loading state
  void setLoadingRoute({required bool loading}) {
    state = state.copyWith(isLoadingRoute: loading);
  }

  /// Clear active route and alternatives
  void clearRoutes() {
    state = state.copyWith(
      alternativeRoutes: [],
      selectedRouteIndex: 0,
      showRouteInfo: false,
    );
  }

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Clear location error
  void clearLocationError() {
    state = state.copyWith();
  }
}

/// Available map styles with their tile URLs
const Map<String, String> availableMapStyles = {
  'standard': AppConstants.osmStandardTileUrl,
  'terrain': AppConstants.openTopoTileUrl,
  'dark': AppConstants.stadiaDarkTileUrl,
  'satellite': AppConstants.arcgisSatelliteTileUrl,
};

// Note: nearbyRidesStreamProvider is defined below as a VM-layer provider.

/// VM-layer stream provider for nearby rides (wraps home repository).
@riverpod
Stream<List<RideModel>> nearbyRidesStream(
  Ref ref,
  LatLng location,
  double radiusKm,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamNearbyRides(center: location, radiusKm: radiusKm);
}
