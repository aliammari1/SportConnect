import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'home_repository.g.dart';

@Riverpod(keepAlive: true)
HomeRepository homeRepository(Ref ref) {
  return HomeRepository(ref.watch(firebaseServiceProvider).firestore);
}

/// Repository for home screen data
class HomeRepository {
  HomeRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// Server-side document cap fetched before client-side distance filtering.
  /// Must be large relative to the requested `limit` so the radius filter does
  /// not silently truncate nearby results, but kept as low as practical because
  /// Firestore bills per-document read on every snapshot emission — a moving
  /// rider re-subscribes per anchor and most fetched docs are discarded by the
  /// radius filter. 80 keeps a 4× headroom over the default `limit` of 20.
  static const int _serverFetchCap = 80;

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (model, _) => model.toJson(),
      );

  /// Stream nearby active rides

  Stream<List<RideModel>> streamNearbyRides({
    required LatLng center,
    double radiusKm = 50,
    int limit = 20,
  }) {
    // Note: For production, use geohashing or Firebase GeoFire for efficient geo-queries.
    // A geo-bound and a time inequality cannot be combined in one Firestore query,
    // so we fetch a larger server-side window and filter by distance client-side.
    // The server cap must be much larger than `limit` because the radius filter can
    // discard most fetched docs; applying `limit` before the distance filter would
    // silently truncate nearby results.
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where(
          'schedule.departureTime',
          isGreaterThan: Timestamp.fromDate(DateTime.now()),
        )
        .orderBy('schedule.departureTime')
        .limit(_serverFetchCap)
        .snapshots()
        .map((snapshot) {
          const distance = Distance();
          final maxDistanceMeters = radiusKm * 1000;

          final rides = snapshot.docs
              .map((doc) => doc.data())
              .where((ride) {
                final rideOrigin = ride.origin.toLatLng();
                final distanceMeters = distance.as(
                  LengthUnit.Meter,
                  center,
                  rideOrigin,
                );
                return distanceMeters <= maxDistanceMeters;
              })
              // Apply the requested count only AFTER the distance filter, so the
              // radius predicate cannot starve the result set.
              .take(limit)
              .toList();

          return rides;
        });
  }
}
