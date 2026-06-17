import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'driver_stats_repository.g.dart';

@Riverpod(keepAlive: true)
DriverStatsRepository driverStatsRepository(Ref ref) {
  return DriverStatsRepository(ref.watch(firebaseServiceProvider).firestore);
}

/// Driver Stats Repository
class DriverStatsRepository {
  DriverStatsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<DriverStats> get _driverStatsCollection => _firestore
      .collection(AppConstants.driverStatsCollection)
      .withConverter<DriverStats>(
        fromFirestore: (snap, _) => DriverStats.fromJson(snap.data()!),
        toFirestore: (stats, _) => stats.toJson(),
      );

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
        toFirestore: (req, _) => req.toJson(),
      );

  /// Get driver stats

  Future<DriverStats> getDriverStats(String driverId) async {
    final doc = await _driverStatsCollection.doc(driverId).get();
    if (!doc.exists) {
      // Create default stats if not exists
      final stats = DriverStats(driverId: driverId);
      await _driverStatsCollection.doc(driverId).set(stats);
      return stats;
    }
    return doc.data()!;
  }

  /// Stream driver stats

  Stream<DriverStats> streamDriverStats(String driverId) {
    return _driverStatsCollection.doc(driverId).snapshots().map((doc) {
      return doc.data() ?? DriverStats(driverId: driverId);
    });
  }

  /// Streams pending bookings for a driver (replaces old rideRequests flow).

  Stream<List<RideBooking>> streamPendingRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: BookingStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Streams accepted bookings for a driver.

  Stream<List<RideBooking>> streamAcceptedRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: BookingStatus.accepted.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Streams rejected/cancelled bookings for a driver.

  Stream<List<RideBooking>> streamRejectedRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where(
          'status',
          whereIn: [BookingStatus.rejected.name, BookingStatus.cancelled.name],
        )
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Get upcoming rides for driver - returns proper RideModel

  Stream<List<RideModel>> streamUpcomingRides(String driverId) {
    final now = DateTime.now();
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .where('schedule.departureTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', whereIn: ['active', 'full'])
        .orderBy('schedule.departureTime')
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Get earnings transactions

  Stream<List<EarningsTransaction>> streamTransactions(String driverId) {
    final controller = StreamController<List<EarningsTransaction>>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? paymentsSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? payoutsSub;
    var paymentTransactions = <EarningsTransaction>[];
    var payoutTransactions = <EarningsTransaction>[];

    void emit() {
      if (controller.isClosed) return;
      final all = <EarningsTransaction>[
        ...paymentTransactions,
        ...payoutTransactions,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(all.take(50).toList());
    }

    controller.onListen = () {
      paymentsSub = _firestore
          .collection(AppConstants.paymentsCollection)
          .where('driverId', isEqualTo: driverId)
          .where(
            'status',
            whereIn: const ['succeeded', 'refunded', 'partiallyRefunded'],
          )
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) async {
            try {
              paymentTransactions = await _completedRidePaymentTransactions(
                snapshot.docs,
              );
              emit();
            } on Object catch (error, stackTrace) {
              controller.addError(error, stackTrace);
            }
          }, onError: controller.addError);

      payoutsSub = _firestore
          .collection(AppConstants.payoutsCollection)
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((snapshot) {
            payoutTransactions = snapshot.docs
                .map(_payoutDocToEarningsTransaction)
                .toList();
            emit();
          }, onError: controller.addError);
    };

    controller.onCancel = () async {
      await paymentsSub?.cancel();
      await payoutsSub?.cancel();
    };

    return controller.stream;
  }

  Future<List<EarningsTransaction>> _completedRidePaymentTransactions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) return const [];

    final rideIds = docs
        .map((doc) => doc.data()['rideId'] as String? ?? '')
        .where((rideId) => rideId.isNotEmpty)
        .toSet()
        .toList();
    final completedRideIds = <String>{};

    for (var i = 0; i < rideIds.length; i += 30) {
      final batch = rideIds.sublist(
        i,
        i + 30 > rideIds.length ? rideIds.length : i + 30,
      );
      final rideSnapshot = await _firestore
          .collection(AppConstants.ridesCollection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in rideSnapshot.docs) {
        if (doc.data()['status'] == RideStatus.completed.name) {
          completedRideIds.add(doc.id);
        }
      }
    }

    return docs
        .where((doc) {
          final data = doc.data();
          if (data['payoutEligible'] == true) return true;
          final rideId = data['rideId'] as String? ?? '';
          return completedRideIds.contains(rideId);
        })
        .map(_paymentDocToEarningsTransaction)
        .toList();
  }

  EarningsTransaction _paymentDocToEarningsTransaction(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final status = data['status'] as String? ?? 'succeeded';
    final isRefund = status == 'refunded' || status == 'partiallyRefunded';
    final amountInCents = _centsValue(
      data,
      centsKey: 'driverEarningsInCents',
      legacyMajorKey: 'driverEarnings',
    );
    final rideId = data['rideId'] as String? ?? '';
    final riderName = data['riderName'] as String? ?? '';
    final description = isRefund
        ? 'Ride refund${riderName.isEmpty ? '' : ' - $riderName'}'
        : 'Ride payment${riderName.isEmpty ? '' : ' - $riderName'}';

    return EarningsTransaction(
      id: doc.id,
      rideId: rideId,
      amountInCents: isRefund ? -amountInCents : amountInCents,
      description: description,
      createdAt:
          _dateValue(data['rideCompletedAt']) ??
          _dateValue(data['completedAt']) ??
          _dateValue(data['createdAt']) ??
          DateTime.now(),
      type: isRefund
          ? EarningsTransactionType.refund
          : EarningsTransactionType.ride,
    );
  }

  EarningsTransaction _payoutDocToEarningsTransaction(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final amountInCents = _centsValue(
      data,
      centsKey: 'amountInCents',
      legacyMajorKey: 'amount',
    );
    final method = data['method'] as String? ?? 'standard';
    final status = data['status'] as String? ?? 'pending';

    return EarningsTransaction(
      id: doc.id,
      rideId: '',
      amountInCents: -amountInCents,
      description:
          '${method == 'instant' ? 'Instant payout' : 'Payout'} - $status',
      createdAt: _dateValue(data['createdAt']) ?? DateTime.now(),
      type: EarningsTransactionType.payout,
    );
  }

  int _centsValue(
    Map<String, dynamic> data, {
    required String centsKey,
    required String legacyMajorKey,
  }) {
    final cents = data[centsKey];
    if (cents is num) return cents.round();
    final major = data[legacyMajorKey];
    if (major is num) return (major * 100).round();
    return 0;
  }

  DateTime? _dateValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  // NOTE: Accept/decline booking transactions and ride-completion stat writes
  // were removed from this repository to eliminate divergent copies of the
  // critical seat/OTP/capacity logic. The single source of truth for accepting
  // and declining bookings is RideRepository.updateBookingStatus (reached via
  // RideRequestService). DriverStatsRepository is now read/stream-only.
  //
  // Previously here:
  //   - acceptRequest / declineRequest: duplicated RideRepository's accept/
  //     reject transaction (OTP gen, capacity.booked increment, waypoint
  //     arrayUnion, conditional capacity release). They had no callers and
  //     could drift from RideRepository (e.g. the active->full transition).
  //   - recordRideCompletion: dead code (zero callers). Driver earnings are
  //     owned by the Stripe webhook aggregation, and its windowed counters
  //     (ridesToday/ThisWeek/ThisMonth) had no server-side rollover, so they
  //     would have grown unbounded had it ever been called.
}

@riverpod
Stream<DriverStats> driverStats(Ref ref) async* {
  final userUID = await ref.watch(currentAuthUidProvider.future);
  if (userUID == null) {
    yield const DriverStats();
    return;
  }
  yield* ref.watch(driverStatsRepositoryProvider).streamDriverStats(userUID);
}

@riverpod
Stream<List<RideBooking>> pendingRideRequests(Ref ref) async* {
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield const <RideBooking>[];
    return;
  }
  yield* ref.watch(driverStatsRepositoryProvider).streamPendingRequests(userId);
}

@riverpod
Stream<List<RideBooking>> acceptedRideRequests(Ref ref) async* {
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield const <RideBooking>[];
    return;
  }
  yield* ref
      .watch(driverStatsRepositoryProvider)
      .streamAcceptedRequests(userId);
}

@riverpod
Stream<List<RideBooking>> rejectedRideRequests(Ref ref) async* {
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield const <RideBooking>[];
    return;
  }
  yield* ref
      .watch(driverStatsRepositoryProvider)
      .streamRejectedRequests(userId);
}

@riverpod
Stream<List<RideModel>> upcomingDriverRides(Ref ref) async* {
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield const <RideModel>[];
    return;
  }
  yield* ref.watch(driverStatsRepositoryProvider).streamUpcomingRides(userId);
}

@riverpod
Stream<List<EarningsTransaction>> earningsTransactions(Ref ref) async* {
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield const <EarningsTransaction>[];
    return;
  }
  yield* ref.watch(driverStatsRepositoryProvider).streamTransactions(userId);
}
