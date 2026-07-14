import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'ride_countdown_view_model.g.dart';

class RideCountdownUiState {
  const RideCountdownUiState({
    this.timeUntilDeparture = const Duration(hours: 1),
    this.lastDepartureTime,
    this.osrmRoutePoints,
    this.osrmRouteRideId,
    this.isLoadingOsrmRoute = false,
    this.hasNavigated = false,
    this.lastKnownRideStatus,
  });

  final Duration timeUntilDeparture;
  final DateTime? lastDepartureTime;
  final List<LatLng>? osrmRoutePoints;
  final String? osrmRouteRideId;
  final bool isLoadingOsrmRoute;
  final bool hasNavigated;
  final RideStatus? lastKnownRideStatus;

  RideCountdownUiState copyWith({
    Duration? timeUntilDeparture,
    DateTime? lastDepartureTime,
    List<LatLng>? osrmRoutePoints,
    bool clearOsrmRoutePoints = false,
    String? osrmRouteRideId,
    bool clearOsrmRouteRideId = false,
    bool? isLoadingOsrmRoute,
    bool? hasNavigated,
    RideStatus? lastKnownRideStatus,
  }) {
    return RideCountdownUiState(
      timeUntilDeparture: timeUntilDeparture ?? this.timeUntilDeparture,
      lastDepartureTime: lastDepartureTime ?? this.lastDepartureTime,
      osrmRoutePoints: clearOsrmRoutePoints
          ? null
          : (osrmRoutePoints ?? this.osrmRoutePoints),
      osrmRouteRideId: clearOsrmRouteRideId
          ? null
          : (osrmRouteRideId ?? this.osrmRouteRideId),
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
      hasNavigated: hasNavigated ?? this.hasNavigated,
      lastKnownRideStatus: lastKnownRideStatus ?? this.lastKnownRideStatus,
    );
  }
}

@riverpod
class RideCountdownUiViewModel extends _$RideCountdownUiViewModel {
  @override
  RideCountdownUiState build(String bookingId) {
    ref.onDispose(() => _countdownTimer?.cancel());
    return const RideCountdownUiState();
  }

  Timer? _countdownTimer;

  Future<void> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingOsrmRoute || state.osrmRouteRideId == ride.id) return;
    state = state.copyWith(isLoadingOsrmRoute: true);

    try {
      final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
      final dest = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );

      final waypoints = ride.route.waypoints.isNotEmpty
          ? ride.route.waypoints
                .map(
                  (wp) => LatLng(wp.location.latitude, wp.location.longitude),
                )
                .toList()
          : null;

      final routeInfo = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: origin,
            destination: dest,
            waypoints: waypoints,
          );

      if (!ref.mounted) return;

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        osrmRouteRideId: ride.id,
        isLoadingOsrmRoute: false,
      );
    } catch (_) {
      if (!ref.mounted) return;

      state = state.copyWith(isLoadingOsrmRoute: false);
    }
  }

  void syncDeparture(DateTime departure) {
    if (state.lastDepartureTime == departure) return;
    _countdownTimer?.cancel();
    state = state.copyWith(
      lastDepartureTime: departure,
      timeUntilDeparture: _remaining(departure),
    );
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) return;
      state = state.copyWith(timeUntilDeparture: _remaining(departure));
    });
  }

  bool registerRideStatus(RideStatus status) {
    final previousStatus = state.lastKnownRideStatus;
    if (previousStatus == null) {
      state = state.copyWith(lastKnownRideStatus: status);
      return false;
    }

    final shouldNavigateToActive =
        status == RideStatus.inProgress &&
        previousStatus != RideStatus.inProgress &&
        !state.hasNavigated;
    final shouldNavigateTerminal =
        (status == RideStatus.cancelled || status == RideStatus.completed) &&
        !state.hasNavigated;
    final shouldNavigate = shouldNavigateToActive || shouldNavigateTerminal;
    state = state.copyWith(
      lastKnownRideStatus: status,
      hasNavigated: state.hasNavigated || shouldNavigate,
    );
    return shouldNavigate;
  }

  Duration _remaining(DateTime departure) {
    final diff = departure.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
