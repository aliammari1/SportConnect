import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';

part 'ride_repository.g.dart';

@Riverpod(keepAlive: true)
RideRepository rideRepository(Ref ref) {
  return RideRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).database,
  );
}

/// Ride Repository for Firestore operations
class RideRepository {
  RideRepository(this._firestore, this._database);
  final FirebaseDatabase _database;
  final FirebaseFirestore _firestore;

  Map<String, dynamic> _bookingCreateMap(RideBooking booking) {
    return <String, dynamic>{
      'rideId': booking.rideId,
      'passengerId': booking.passengerId,
      'driverId': booking.driverId,
      'status': BookingStatus.pending.name,
      'seatsBooked': booking.seatsBooked,
      'createdAt': booking.createdAt ?? DateTime.now(),
      'updatedAt': DateTime.now(),
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

  // Tracks ride IDs for which onDisconnect().remove() has been registered,
  // so we only pay the round-trip cost once per ride session.
  final _disconnectRegistered = <String>{};

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter<RideModel>(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (ride, _) => ride.toJson(),
      );

  CollectionReference<RideBooking> get _rideBookingsCollection => _firestore
      .collection(AppConstants.bookingsCollection)
      .withConverter<RideBooking>(
        fromFirestore: (snap, _) =>
            RideBooking.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (booking, _) => booking.toJson(),
      );

  /// Create a new ride

  Future<String> createRide(RideModel ride) async {
    if (!ride.hasRequiredEvent) {
      throw ArgumentError('Ride must be linked to an event');
    }
    final docRef = _ridesCollection.doc();
    final rideWithId = ride.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(rideWithId);
    return docRef.id;
  }

  /// Get ride by ID

  Future<RideModel?> getRideById(String rideId) async {
    final doc = await _ridesCollection.doc(rideId).get();
    return doc.data();
  }

  /// Stream ride by ID (real-time updates)

  Stream<RideModel?> streamRideById(String rideId) {
    return _ridesCollection.doc(rideId).snapshots().map((doc) => doc.data());
  }

  /// Update ride

  Future<void> updateRide(RideModel ride) async {
    if (!ride.hasRequiredEvent) {
      throw ArgumentError('Ride must be linked to an event');
    }
    final json = ride.toJson()
      ..remove('id')
      ..remove('createdAt');
    json['updatedAt'] = DateTime.now();
    await _ridesCollection.doc(ride.id).update(json);
  }

  /// Update ride with map (helper method)

  Future<void> updateRideFields(
    String rideId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = DateTime.now();
    await _ridesCollection.doc(rideId).update(updates);
  }

  /// Delete ride

  Future<void> deleteRide(String rideId) async {
    await _ridesCollection.doc(rideId).delete();
  }

  // ==================== INTERFACE IMPLEMENTATIONS ====================

  Stream<List<RideModel>> getActiveRides(String userId) {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('driverId', isEqualTo: userId)
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<RideModel>> getRideHistory(String userId) {
    return _ridesCollection
        .where('driverId', isEqualTo: userId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String> createRideRequest(String rideId, RideBooking booking) async {
    // Unified flow: creating a "request" simply creates a pending booking.
    final bookingId = booking.id.isNotEmpty
        ? booking.id
        : _rideBookingsCollection.doc().id;
    final bookingWithId = booking.copyWith(
      id: bookingId,
      createdAt: booking.createdAt ?? DateTime.now(),
    );
    await bookRide(rideId: rideId, booking: bookingWithId);
    return bookingId;
  }

  Future<List<RideModel>> searchRides({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    DateTime? date,
    int? minSeats,
    int? maxPriceInCents,
  }) async {
    // R-2: A negative maxPrice silently hides all rides.
    if (maxPriceInCents != null && maxPriceInCents < 0) {
      throw ArgumentError(
        'maxPriceInCents must be >= 0 (got $maxPriceInCents).',
      );
    }

    const radiusKm = 10.0;
    const latRange = radiusKm / 111.0;

    final query = _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('route.origin.latitude', isGreaterThan: originLat - latRange)
        .where('route.origin.latitude', isLessThan: originLat + latRange)
        .limit(100);

    final results = await query.get();

    final rides = results.docs.map((doc) => doc.data()).where((ride) {
      if (date != null && !_isSameDay(ride.schedule.departureTime, date)) {
        return false;
      }
      if (minSeats != null && ride.capacity.remaining < minSeats) {
        return false;
      }
      if (maxPriceInCents != null &&
          ride.pricing.pricePerSeatInCents > maxPriceInCents) {
        return false;
      }

      final destDistance = _calculateDistance(
        ride.route.destination.latitude,
        ride.route.destination.longitude,
        destLat,
        destLng,
      );
      if (destDistance > radiusKm) return false;

      return true;
    }).toList();

    rides.sort(
      (a, b) => a.schedule.departureTime.compareTo(b.schedule.departureTime),
    );
    return rides;
  }

  Future<void> cancelRide(String rideId, String reason) async {
    try {
      await _ridesCollection.doc(rideId).update({
        'status': RideStatus.cancelled.name,
        'cancellationReason': reason,
        'updatedAt': DateTime.now(),
      });
    } finally {
      await clearLiveLocation(rideId);
    }
  }

  // ==================== EXISTING METHODS ====================

  /// Get rides by driver

  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    final query = await _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Check if a vehicle is associated with any non-terminal ride.

  Future<bool> hasActiveRidesForVehicle(String vehicleId) async {
    final snapshot = await _ridesCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .where('status', whereIn: ['draft', 'active', 'full', 'inProgress'])
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Stream rides by driver (real-time)

  Stream<List<RideModel>> streamRidesByDriver(String driverId) {
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream rides where user is a passenger.
  ///
  /// Queries the bookings collection via [BookingRepository] to find
  /// rides the user is booked on, then fetches the ride documents.

  Stream<List<RideModel>> streamRidesAsPassenger(String userId) {
    return _rideBookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where(
          'status',
          whereIn: ['pending', 'accepted', 'completed', 'cancelled'],
        )
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .asyncMap((bookingSnapshot) async {
          final rideIds = bookingSnapshot.docs
              .map((doc) => doc.data().rideId)
              .whereType<String>()
              .toSet()
              .toList();

          if (rideIds.isEmpty) return <RideModel>[];

          // Firestore whereIn supports max 30 items
          final rides = <RideModel>[];
          for (var i = 0; i < rideIds.length; i += 30) {
            final batch = rideIds.sublist(
              i,
              i + 30 > rideIds.length ? rideIds.length : i + 30,
            );
            final query = await _ridesCollection
                .where(FieldPath.documentId, whereIn: batch)
                .get();
            rides.addAll(query.docs.map((doc) => doc.data()));
          }

          // Sort by departure time descending
          rides.sort((a, b) => b.departureTime.compareTo(a.departureTime));
          return rides;
        });
  }

  /// Gets upcoming rides for user (as passenger).
  ///
  /// Queries the bookings collection to find active bookings,
  /// then filters to upcoming rides only.
  Future<List<RideModel>> getUpcomingRidesAsPassenger(String userId) async {
    final bookingSnapshot = await _rideBookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(100)
        .get();

    final rideIds = bookingSnapshot.docs
        .map((doc) => doc.data().rideId)
        .whereType<String>()
        .toSet()
        .toList();

    if (rideIds.isEmpty) return [];

    final rides = <RideModel>[];
    for (var i = 0; i < rideIds.length; i += 30) {
      final batch = rideIds.sublist(
        i,
        i + 30 > rideIds.length ? rideIds.length : i + 30,
      );
      final query = await _ridesCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      rides.addAll(query.docs.map((doc) => doc.data()));
    }

    // Filter to only future rides and sort ascending
    final now = DateTime.now();
    final upcoming =
        rides.where((ride) => ride.departureTime.isAfter(now)).toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return upcoming;
  }

  /// Stream rides near location (real-time).
  ///
  /// Firestore only allows a range/inequality filter on a **single** field per
  /// query. We apply the departure-time inequality in Firestore (the most
  /// selective filter) and then post-filter by latitude/longitude in memory
  /// using the Haversine formula so we don't need a composite index.

  Stream<List<RideModel>> streamNearbyRides({
    required double latitude,
    required double longitude,
    double radiusKm = 20.0,
  }) {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .limit(100) // Fetch a larger set so post-filtering still returns enough
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data())
              .where((ride) {
                final dist = _calculateDistance(
                  ride.route.origin.latitude,
                  ride.route.origin.longitude,
                  latitude,
                  longitude,
                );
                return dist <= radiusKm;
              })
              .take(50)
              .toList();
        });
  }

  /// Stream all active rides (for search screen)

  Stream<List<RideModel>> streamActiveRides() {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Books a ride by creating a booking document in the bookings
  /// collection and recording the booking ID on the ride.
  ///
  /// **Capacity is NOT incremented here.** Seats are only reserved when
  /// the driver accepts the booking (via [updateBookingStatus] with
  /// [BookingStatus.accepted]). This prevents over-restricting seat
  /// availability for rides that use manual acceptance.

  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) async {
    final rideDoc = await _ridesCollection.doc(rideId).get();
    final ride = rideDoc.data();
    if (ride == null) {
      throw StateError('Ride $rideId not found.');
    }
    if (!ride.isBookable) {
      throw StateError('Ride $rideId is no longer available for booking.');
    }
    if (booking.seatsBooked <= 0) {
      throw ArgumentError('seatsBooked must be greater than zero.');
    }
    if (ride.capacity.remaining < booking.seatsBooked) {
      throw StateError(
        'Not enough seats: ${ride.capacity.remaining} available, '
        '${booking.seatsBooked} requested.',
      );
    }

    final existing = await _rideBookingsCollection
        .where('passengerId', isEqualTo: booking.passengerId)
        .where('rideId', isEqualTo: rideId)
        .where(
          'status',
          whereIn: [BookingStatus.pending.name, BookingStatus.accepted.name],
        )
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('You already have an active booking for this ride.');
    }

    final bookingWithTimestamps = booking.copyWith(
      createdAt: booking.createdAt ?? DateTime.now(),
    );

    // Store only client-allowed fields.
    // Do NOT send paymentIntentId / paidAt on create.
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(booking.id)
        .set(_bookingCreateMap(bookingWithTimestamps));

    // Track the booking ID on the ride document (but don't touch capacity yet)
    await _ridesCollection.doc(rideId).update({
      'bookingIds': FieldValue.arrayUnion([booking.id]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Updates booking status in the bookings collection and adjusts
  /// ride capacity when a booking is cancelled or rejected.
  ///
  /// Reads `seatsBooked` AND `previousStatus` BEFORE updating to avoid a
  /// TOCTOU race condition. Capacity is only freed when the booking was
  /// previously `accepted` (seats were actually reserved). Rejecting or
  /// cancelling a still-pending booking must NOT decrement capacity.

  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    if (newStatus == BookingStatus.accepted) {
      // Generate a 4-digit OTP when accepting — shown to passenger, entered by driver.
      // Use Random.secure() to prevent OTP prediction from a time-seeded RNG.
      final pickupOtp = (1000 + math.Random.secure().nextInt(9000)).toString();

      // Reserve seats and mark the booking accepted in the same transaction.
      // This prevents an accepted booking from being left behind if capacity
      // checks fail under concurrent driver actions.
      await _firestore.runTransaction((txn) async {
        final bookingRef = _firestore
            .collection(AppConstants.bookingsCollection)
            .doc(bookingId);
        final rideRef = _firestore
            .collection(AppConstants.ridesCollection)
            .doc(rideId);

        final bookingSnap = await txn.get(bookingRef);
        if (!bookingSnap.exists) {
          throw StateError('Booking $bookingId not found.');
        }
        final bookingData = bookingSnap.data()!;
        final currentStatus = bookingData['status'] as String?;
        if (currentStatus == BookingStatus.accepted.name) {
          return;
        }
        if (currentStatus != BookingStatus.pending.name) {
          throw StateError(
            'Only pending bookings can be accepted '
            '(current status: $currentStatus).',
          );
        }

        final rideSnap = await txn.get(rideRef);
        if (!rideSnap.exists) throw StateError('Ride $rideId not found.');

        final data = rideSnap.data()!;
        final total =
            (data['capacity']?['available'] as int?) ??
            (data['capacity']?['total'] as int?) ??
            0;
        final booked = (data['capacity']?['booked'] as int?) ?? 0;
        final available = total - booked;
        final seatsBooked = (bookingData['seatsBooked'] as int?) ?? 1;

        if (available < seatsBooked) {
          throw StateError(
            'Not enough seats: $available available, $seatsBooked requested.',
          );
        }

        final updates = <String, dynamic>{
          'capacity.booked': FieldValue.increment(seatsBooked),
          'updatedAt': DateTime.now(),
        };

        // R-7: Derive waypoint order inside the transaction using the
        // snapshot's current count — eliminates the duplicate-order race.
        final pickupLocationMap = bookingData['pickupLocation'];
        if (pickupLocationMap is Map<String, dynamic>) {
          final waypointsList = (data['route']?['waypoints'] as List?) ?? [];
          final nextOrder = waypointsList.length;
          updates['route.waypoints'] = FieldValue.arrayUnion([
            {'location': pickupLocationMap, 'order': nextOrder},
          ]);
        }

        txn.update(bookingRef, {
          'status': newStatus.name,
          'respondedAt': DateTime.now(),
          'pickupOtp': pickupOtp,
        });
        txn.update(rideRef, updates);
      });
      return;
    }

    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected) {
      await _firestore.runTransaction((txn) async {
        final bookingRef = _firestore
            .collection(AppConstants.bookingsCollection)
            .doc(bookingId);
        final rideRef = _firestore
            .collection(AppConstants.ridesCollection)
            .doc(rideId);
        final bookingSnap = await txn.get(bookingRef);
        if (!bookingSnap.exists) {
          throw StateError('Booking $bookingId not found.');
        }

        final bookingData = bookingSnap.data()!;
        final previousStatus = bookingData['status'] as String?;
        final seatsBooked = (bookingData['seatsBooked'] as int?) ?? 1;

        txn.update(bookingRef, {
          'status': newStatus.name,
          'respondedAt': DateTime.now(),
        });

        final rideUpdates = <String, dynamic>{
          'bookingIds': FieldValue.arrayRemove([bookingId]),
          'updatedAt': DateTime.now(),
        };
        if (previousStatus == BookingStatus.accepted.name) {
          rideUpdates['capacity.booked'] = FieldValue.increment(-seatsBooked);
        }
        txn.update(rideRef, rideUpdates);
      });
      return;
    }

    await _rideBookingsCollection.doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': DateTime.now(),
    });
  }

  /// Cancels a booking by delegating to [updateBookingStatus].

  Future<void> cancelBooking({
    required String rideId,
    required String bookingId,
  }) async {
    await updateBookingStatus(
      rideId: rideId,
      bookingId: bookingId,
      newStatus: BookingStatus.cancelled,
    );
  }

  /// Adds a review for a ride.
  ///
  /// Stores the review in the reviews collection and updates the
  /// ride's aggregated review count and recalculates the average rating
  /// atomically inside a Firestore transaction.
  Future<void> addReview({
    required String rideId,
    required Map<String, dynamic> reviewData,
  }) async {
    final reviewId = reviewData['id'] as String? ?? '';
    final newRating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;

    await _firestore.runTransaction((transaction) async {
      // Store the review document
      final reviewRef = _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);
      transaction.set(reviewRef, reviewData);

      // Read current ride stats
      final rideRef = _ridesCollection.doc(rideId);
      final rideSnap = await transaction.get(rideRef);
      if (!rideSnap.exists) return;

      final currentCount = rideSnap.data()!.reviewCount;
      final currentAvg = rideSnap.data()!.averageRating;

      // Incremental average: newAvg = (oldAvg * count + newRating) / (count + 1)
      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + newRating) / newCount;

      transaction.update(rideRef, {
        'reviewCount': newCount,
        'averageRating': double.parse(newAvg.toStringAsFixed(2)),
        'updatedAt': DateTime.now(),
      });
    });
  }

  /// Start ride
  ///
  /// Uses a transaction to atomically validate that at least one accepted
  /// booking exists, set the ride status to inProgress, record the actual
  /// departure time, and set the initial ride phase.

  Future<void> startRide(String rideId) async {
    await _firestore.runTransaction((transaction) async {
      final rideRef = _ridesCollection.doc(rideId);
      final rideSnap = await transaction.get(rideRef);
      if (!rideSnap.exists) throw ArgumentError('Ride not found');

      final driverId = rideSnap.data()!.driverId;

      // Validate: at least one accepted booking
      // Include driverId filter to satisfy Firestore security rules.
      final bookingsSnap = await _rideBookingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: BookingStatus.accepted.name)
          .limit(1)
          .get();
      if (bookingsSnap.docs.isEmpty) {
        throw StateError('Cannot start ride without accepted bookings');
      }

      transaction.update(rideRef, {
        'status': RideStatus.inProgress.name,
        'ridePhase': 'pickingUp',
        'schedule.actualDepartureTime': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    });
  }

  /// Complete ride
  ///
  /// Writes `arrivalTime` inside the `schedule` sub-object to match the
  /// `RideSchedule` model structure (not at the document root level).

  Future<void> completeRide(String rideId) async {
    // R-4: Warn if any accepted passenger was never picked up (OTP not confirmed).
    final rideDoc = await _firestore
        .collection(AppConstants.ridesCollection)
        .doc(rideId)
        .get();
    if (rideDoc.exists) {
      final pickedUp = List<String>.from(
        rideDoc.data()?['pickedUpPassengers'] as List? ?? [],
      );
      final acceptedBookings = await _rideBookingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('status', isEqualTo: BookingStatus.accepted.name)
          .get();
      final notPickedUp = acceptedBookings.docs
          .map((d) => d.data().passengerId)
          .where((pid) => !pickedUp.contains(pid))
          .toList();
      if (notPickedUp.isNotEmpty) {
        throw StateError(
          'Cannot complete ride: ${notPickedUp.length} accepted passenger(s) '
          'have not been picked up (OTP not confirmed).',
        );
      }
    }

    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.completed.name,
      'ridePhase': 'completed',
      'schedule.arrivalTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
    await clearLiveLocation(rideId);
  }

  /// Updates the driver's ride phase (pickingUp, enRoute, arriving, completed).
  /// This is persisted so passengers can see granular progress.

  Future<void> updateRidePhase(String rideId, String phase) async {
    await _ridesCollection.doc(rideId).update({
      'ridePhase': phase,
      'updatedAt': DateTime.now(),
    });
  }

  /// Streams the driver's current ride phase from the ride document.

  Stream<String?> streamRidePhase(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((
      snapshot,
    ) {
      return snapshot.data()?['ridePhase'] as String?;
    });
  }

  /// Writes the driver's current GPS coordinates to Firebase Realtime Database.
  ///
  /// RTDB is used instead of Firestore for live location because:
  /// - ~10x cheaper (charged per GB transferred, not per write operation)
  /// - ~50-150ms latency vs Firestore's ~300-1000ms for real-time
  /// - Designed for high-frequency data; no per-write billing pressure

  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude, {
    double heading = 0,
  }) async {
    final rtdbRef = _database.ref('liveLocations/$rideId');
    // Register server-side auto-remove once per ride session.
    // If the device disconnects ungracefully the RTDB node is cleaned up automatically.
    if (!_disconnectRegistered.contains(rideId)) {
      try {
        await rtdbRef.onDisconnect().remove();
        _disconnectRegistered.add(rideId);
      } on Exception catch (e, st) {
        // Do not block the live location write if disconnect cleanup cannot be
        // registered yet. The next update will try again.
        TalkerService.warning(
          'Failed to register RTDB onDisconnect cleanup for ride $rideId: $e',
        );
        TalkerService.error(
          'RTDB onDisconnect registration error',
          e,
          st,
        );
      }
    }
    await rtdbRef.update({
      'lat': latitude,
      'lng': longitude,
      'heading': heading,
      'ts': ServerValue.timestamp, // server clock — avoids device clock skew
    });
  }

  Future<void> clearLiveLocation(String rideId) async {
    _disconnectRegistered.remove(rideId);
    await _database.ref('liveLocations/$rideId').remove();
  }

  /// Streams the driver's live GPS location from Firebase Realtime Database.

  Stream<({double latitude, double longitude})?> streamLiveLocation(
    String rideId,
  ) {
    return _database.ref('liveLocations/$rideId').onValue.map((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return (latitude: lat, longitude: lng);
    });
  }

  // ==================== REAL-TIME EXTRA FIELDS ====================

  /// Streams the list of passenger IDs the driver has confirmed as picked up.

  Stream<List<String>> streamPickedUpPassengers(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map(
          (snap) => List<String>.from(
            snap.data()?['pickedUpPassengers'] as List? ?? [],
          ),
        );
  }

  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula
    const earthRadius = 6371.0; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Stream rides linked to a specific event by eventId.

  Stream<List<RideModel>> streamRidesByEventId(String eventId) {
    return _ridesCollection
        .where('eventId', isEqualTo: eventId)
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== 7A: PICKUP ORDER ====================

  Future<void> updatePickupOrder(
    String rideId,
    List<String> passengerIds,
  ) async {
    await _ridesCollection.doc(rideId).update({
      'pickupOrder': passengerIds,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> markPassengerPickedUp(String rideId, String passengerId) async {
    await _ridesCollection.doc(rideId).update({
      'pickedUpPassengers': FieldValue.arrayUnion([passengerId]),
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7B: NO-SHOW ====================

  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final bookingRef = _rideBookingsCollection.doc(bookingId);
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) return;

      final seatsBooked = bookingSnap.data()?.seatsBooked ?? 1;

      // Cancel the booking
      transaction.update(bookingRef, {
        'status': BookingStatus.cancelled.name,
        'note': 'No-show',
        'respondedAt': DateTime.now(),
      });

      // Record no-show on the ride and free up seats
      final rideRef = _ridesCollection.doc(rideId);
      transaction.update(rideRef, {
        'noShowPassengers': FieldValue.arrayUnion([passengerId]),
        'capacity.booked': FieldValue.increment(-seatsBooked),
        'updatedAt': DateTime.now(),
      });
    });
  }

  // ==================== 7E: MID-RIDE STOPS ====================

  Future<void> addMidRideStop(
    String rideId,
    Map<String, dynamic> waypoint,
  ) async {
    final ride = await getRideById(rideId);
    if (ride == null) return;

    final waypoints = List<Map<String, dynamic>>.from(
      ride.route.waypoints.map((w) => w.toJson()),
    );
    waypoints.add(waypoint);

    for (var i = 0; i < waypoints.length; i++) {
      waypoints[i]['order'] = i;
    }

    await _ridesCollection.doc(rideId).update({
      'route.waypoints': waypoints,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> removeMidRideStop(String rideId, int waypointIndex) async {
    final ride = await getRideById(rideId);
    if (ride == null) return;
    final waypoints = List<Map<String, dynamic>>.from(
      ride.route.waypoints.map((w) => w.toJson()),
    );
    if (waypointIndex < 0 || waypointIndex >= waypoints.length) return;
    waypoints.removeAt(waypointIndex);

    for (var i = 0; i < waypoints.length; i++) {
      waypoints[i]['order'] = i;
    }

    await _ridesCollection.doc(rideId).update({
      'route.waypoints': waypoints,
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7F: FARE ADJUSTMENT ====================

  Future<void> recordActualDistance(String rideId, double distanceKm) async {
    await _ridesCollection.doc(rideId).update({
      'actualDistanceKm': distanceKm,
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7H: RETURN RIDE ====================

  Future<String> createReturnRide(String originalRideId) async {
    final original = await getRideById(originalRideId);
    if (original == null) throw ArgumentError('Original ride not found');

    // Swap origin and destination
    final returnRoute = original.route.copyWith(
      origin: original.route.destination,
      destination: original.route.origin,
      waypoints: const [], // Fresh route, no leftover waypoints
    );

    final returnSchedule = original.schedule.copyWith(
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      arrivalTime: null,
      actualDepartureTime: null,
    );

    final returnRide = original.copyWith(
      id: '', // Will be auto-generated
      route: returnRoute,
      schedule: returnSchedule,
      status: RideStatus.active,
      bookingIds: const [],
      bookings: const [],
      reviewCount: 0,
      averageRating: 0,
      notes: 'Return trip from "${original.destination.address}"',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return createRide(returnRide);
  }
}
