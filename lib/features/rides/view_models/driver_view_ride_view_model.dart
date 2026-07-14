import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'driver_view_ride_view_model.g.dart';

class DriverRideScreenUiState {
  const DriverRideScreenUiState({
    this.osrmRoutePoints,
    this.osrmRouteRideId,
    this.isLoadingOsrmRoute = false,
    this.lastKnownRideStatus,
    this.hasAutoNavigated = false,
  });

  final List<LatLng>? osrmRoutePoints;
  final String? osrmRouteRideId;
  final bool isLoadingOsrmRoute;
  final RideStatus? lastKnownRideStatus;
  final bool hasAutoNavigated;

  DriverRideScreenUiState copyWith({
    List<LatLng>? osrmRoutePoints,
    bool clearOsrmRoutePoints = false,
    String? osrmRouteRideId,
    bool clearOsrmRouteRideId = false,
    bool? isLoadingOsrmRoute,
    RideStatus? lastKnownRideStatus,
    bool clearLastKnownRideStatus = false,
    bool? hasAutoNavigated,
  }) {
    return DriverRideScreenUiState(
      osrmRoutePoints: clearOsrmRoutePoints
          ? null
          : (osrmRoutePoints ?? this.osrmRoutePoints),
      osrmRouteRideId: clearOsrmRouteRideId
          ? null
          : (osrmRouteRideId ?? this.osrmRouteRideId),
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
      lastKnownRideStatus: clearLastKnownRideStatus
          ? null
          : (lastKnownRideStatus ?? this.lastKnownRideStatus),
      hasAutoNavigated: hasAutoNavigated ?? this.hasAutoNavigated,
    );
  }
}

@riverpod
class DriverRideScreenUiViewModel extends _$DriverRideScreenUiViewModel {
  @override
  DriverRideScreenUiState build(String rideId) =>
      const DriverRideScreenUiState();

  Future<void> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingOsrmRoute || state.osrmRouteRideId == ride.id) return;
    state = state.copyWith(isLoadingOsrmRoute: true, osrmRouteRideId: ride.id);
    try {
      final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
      final dest = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );
      final waypoints = ride.route.waypoints
          .map((wp) => LatLng(wp.location.latitude, wp.location.longitude))
          .toList();
      final routeInfo = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: origin,
            destination: dest,
            waypoints: waypoints.isNotEmpty ? waypoints : null,
          );
      if (!ref.mounted) return;
      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        isLoadingOsrmRoute: false,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingOsrmRoute: false);
    }
  }

  bool registerRideStatus(RideStatus status) {
    final wasAlreadyInProgress =
        state.lastKnownRideStatus == RideStatus.inProgress;
    final shouldNavigate =
        status == RideStatus.inProgress &&
        !wasAlreadyInProgress &&
        !state.hasAutoNavigated;
    state = state.copyWith(
      lastKnownRideStatus: status,
      hasAutoNavigated: state.hasAutoNavigated || shouldNavigate,
    );
    return shouldNavigate;
  }

  Future<String> generateRideShareLink(RideModel ride) async {
    try {
      return await ref
          .read(deepLinkServiceProvider)
          .generateRideLink(
            rideId: ride.id,
            fromCity: ride.origin.city ?? ride.origin.address,
            toCity: ride.destination.city ?? ride.destination.address,
            priceInCents: ride.pricePerSeatInCents,
            seats: ride.remainingSeats,
            departureTime: ride.departureTime,
          );
    } catch (_) {
      return 'https://${AppConstants.hostingDomain}/ride/${ride.id}';
    }
  }
}
