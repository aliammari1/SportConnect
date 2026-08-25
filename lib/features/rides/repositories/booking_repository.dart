import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

part 'booking_repository.g.dart';

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(firebaseServiceProvider).firestore);
}

/// Repository for managing ride bookings
/// Bookings are now stored separately from rides for better scalability
class BookingRepository {
  BookingRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<RideBooking> get _bookingsCollection => _firestore
      .collection(AppConstants.bookingsCollection)
      .withConverter<RideBooking>(
        fromFirestore: (snap, _) =>
            RideBooking.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (booking, _) => booking.toJson(),
      );
  Map<String, dynamic> _bookingCreateMap(RideBooking booking) {
    return <String, dynamic>{
      'rideId': booking.rideId,
      'passengerId': booking.passengerId,
      'driverId': booking.driverId,
      'status': BookingStatus.pending.name,
      'seatsBooked': booking.seatsBooked,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (booking.note != null && booking.note!.trim().isNotEmpty)
        'note': booking.note!.trim(),
      if (booking.pickupLocation != null)
        'pickupLocation': {
          'latitude': booking.pickupLocation!.latitude,
          'longitude': booking.pickupLocation!.longitude,
          'address': booking.pickupLocation!.address,
        },
    };
  }

  /// Create a new booking

  Future<String> createBooking(RideBooking booking) async {
    // R-11/TOCTOU: Use a deterministic doc id keyed on passenger+ride and do
    // the existence check + duplicate guard + write inside a single
    // transaction, so two concurrent calls for the same passenger+ride cannot
    // both pass the duplicate check and both write.
    final deterministicBookingId = '${booking.rideId}_${booking.passengerId}';
    final bookingWithId = booking.copyWith(id: deterministicBookingId);

    await _firestore.runTransaction((txn) async {
      final rideRef = _firestore
          .collection(AppConstants.ridesCollection)
          .doc(booking.rideId);
      final bookingRef = _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(deterministicBookingId);

      // Reads first (transaction requirement).
      final rideDoc = await txn.get(rideRef);
      if (!rideDoc.exists) {
        throw StateError('Ride ${booking.rideId} not found.');
      }
      // R-10: Validate the ride is still accepting bookings. RideStatus has no
      // 'scheduled' value; 'active' is the only bookable status here.
      final rideStatus = rideDoc.data()?['status'] as String?;
      if (rideStatus != 'active') {
        throw StateError(
          'Cannot book a ride with status "$rideStatus". Only active rides accept bookings.',
        );
      }

      // Atomic duplicate guard: the deterministic id makes a concurrent
      // duplicate resolve to the same doc, so this read detects it.
      final bookingSnap = await txn.get(bookingRef);
      if (bookingSnap.exists) {
        throw StateError(
          'Passenger ${booking.passengerId} already has an active booking for ride ${booking.rideId}.',
        );
      }

      txn.set(bookingRef, _bookingCreateMap(bookingWithId));
    });

    return deterministicBookingId;
  }

  /// Get booking by ID

  Future<RideBooking?> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    return doc.data();
  }

  /// Stream booking by ID (real-time updates)

  Stream<RideBooking?> streamBookingById(String bookingId) {
    return _bookingsCollection
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Get bookings for a specific ride (driver-side).
  ///
  /// Includes [driverId] in the query so that Firestore security rules can
  /// verify `resource.data.driverId == request.auth.uid` and allow the
  /// collection query (a query filtered only by rideId would be denied).

  Future<List<RideBooking>> getBookingsByRideId(
    String rideId,
    String driverId,
  ) async {
    final query = await _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Stream bookings for a specific ride (driver-side, real-time).
  ///
  /// See [getBookingsByRideId] for the security-rule rationale.

  Stream<List<RideBooking>> streamBookingsByRideId(
    String rideId,
    String driverId,
  ) {
    return _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Returns the passenger's own booking for a given ride, or null.
  ///
  /// Queries by [passengerId] so that Firestore security rules can verify
  /// `resource.data.passengerId == request.auth.uid`.

  Future<RideBooking?> getPassengerBookingForRide(
    String rideId,
    String passengerId,
  ) async {
    final query = await _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .where('rideId', isEqualTo: rideId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }

  /// Get bookings for a specific passenger

  Future<List<RideBooking>> getBookingsByPassengerId(String passengerId) async {
    final query = await _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Real-time stream of a passenger's own booking for a specific ride.
  ///
  /// Filters by [rideId] and [passengerId] so Firestore security rules can
  /// verify `resource.data.passengerId == request.auth.uid`.

  Stream<List<RideBooking>> streamPassengerBookingForRide(
    String rideId,
    String passengerId,
  ) {
    return _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .where('passengerId', isEqualTo: passengerId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream bookings for a specific passenger (real-time)

  Stream<List<RideBooking>> streamBookingsByPassengerId(String passengerId) {
    return _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Update booking status

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update booking

  Future<void> updateBooking(RideBooking booking) async {
    await _bookingsCollection
        .doc(booking.id)
        .set(booking, SetOptions(merge: true));
  }

  /// Stamp a booking with the Stripe payment intent ID once payment succeeds.
  /// Uses a targeted partial update to avoid overwriting other fields.

  Future<void> updateBookingPaymentIntent({
    required String bookingId,
    required String paymentIntentId,
  }) async {
    // Server-owned fields.
    // Stripe webhook writes paymentIntentId + paidAt after payment succeeds.
    return;
  }

  /// Delete booking

  Future<void> deleteBooking(String bookingId) async {
    await _bookingsCollection.doc(bookingId).delete();
  }

  /// Get active bookings (pending or accepted)

  Stream<List<RideBooking>> streamActiveBookingsByPassengerId(
    String passengerId,
  ) {
    return _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get pending bookings for a ride

}
