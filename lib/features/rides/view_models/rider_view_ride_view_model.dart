import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'rider_view_ride_view_model.g.dart';

class RiderViewRideUiState {
  const RiderViewRideUiState({
    this.seatsToBook = 1,
    this.note = '',
    this.routeInfo,
    this.routeRideId,
    this.isLoadingRoute = false,
  });

  final int seatsToBook;
  final String note;
  final RouteInfo? routeInfo;
  final String? routeRideId;
  final bool isLoadingRoute;

  RiderViewRideUiState copyWith({
    int? seatsToBook,
    String? note,
    RouteInfo? routeInfo,
    bool clearRouteInfo = false,
    String? routeRideId,
    bool clearRouteRideId = false,
    bool? isLoadingRoute,
  }) {
    return RiderViewRideUiState(
      seatsToBook: seatsToBook ?? this.seatsToBook,
      note: note ?? this.note,
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      routeRideId: clearRouteRideId ? null : (routeRideId ?? this.routeRideId),
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
    );
  }
}

@riverpod
class RiderViewRideUiViewModel extends _$RiderViewRideUiViewModel {
  @override
  RiderViewRideUiState build(String arg) => const RiderViewRideUiState();

  Future<void> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingRoute || state.routeRideId == ride.id) return;
    state = state.copyWith(isLoadingRoute: true, routeRideId: ride.id);
    try {
      final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
      final dest = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );
      final waypoints = ride.route.waypoints
          .map((wp) => LatLng(wp.location.latitude, wp.location.longitude))
          .toList(growable: false);
      final info = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: origin,
            destination: dest,
            waypoints: waypoints.isEmpty ? null : waypoints,
          );
      if (!ref.mounted) return;
      state = state.copyWith(routeInfo: info, isLoadingRoute: false);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingRoute: false);
    }
  }

  void setSeatsToBook(int value) {
    if (value < 1) return;
    state = state.copyWith(seatsToBook: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
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
