import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

part 'payment_repository.g.dart';

@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.read(stripeServiceProvider),
  );
}

/// Payment Repository for Firestore operations
class PaymentRepository {
  PaymentRepository(this._firestore, this._stripeService);
  final FirebaseFirestore _firestore;
  final StripeService _stripeService;

  CollectionReference<PaymentTransaction> get _paymentsCollection => _firestore
      .collection(AppConstants.paymentsCollection)
      .withConverter<PaymentTransaction>(
        fromFirestore: (snap, _) => PaymentTransaction.fromJson({
          ..._normalizePaymentData(snap.data()!),
          'id': snap.id,
        }),
        toFirestore: (payment, _) => payment.toJson(),
      );

  CollectionReference<DriverPayout> get _payoutsCollection => _firestore
      .collection(AppConstants.payoutsCollection)
      .withConverter<DriverPayout>(
        fromFirestore: (snap, _) => DriverPayout.fromJson({
          ..._normalizePayoutData(snap.data()!),
          'id': snap.id,
        }),
        toFirestore: (payout, _) => payout.toJson(),
      );

  CollectionReference<DriverConnectedAccount>
  get _connectedAccountsCollection => _firestore
      .collection(AppConstants.connectedAccountsCollection)
      .withConverter<DriverConnectedAccount>(
        fromFirestore: (snap, _) => DriverConnectedAccount.fromJson(
          _normalizeConnectedAccountData(
            snap.data()!,
            snap.id,
          ),
        ),
        toFirestore: (account, _) => account.toJson(),
      );

  static Map<String, dynamic> _normalizePaymentData(
    Map<String, dynamic> data,
  ) {
    final normalized = Map<String, dynamic>.from(data);

    normalized['stripePaymentIntentId'] ??= normalized['paymentIntentId'];
    normalized['amountInCents'] ??= _legacyAmountToCents(normalized['amount']);
    normalized['platformFeeInCents'] ??= _majorUnitsToCents(
      normalized['platformFee'],
    );
    normalized['driverEarningsInCents'] ??= _majorUnitsToCents(
      normalized['driverEarnings'],
    );
    normalized['stripeFeeInCents'] ??=
        _majorUnitsToCents(normalized['stripeFee']) ?? 0;
    normalized['riderName'] ??= '';
    normalized['driverName'] ??= '';

    return normalized;
  }

  static Map<String, dynamic> _normalizePayoutData(
    Map<String, dynamic> data,
  ) {
    final normalized = Map<String, dynamic>.from(data);

    normalized['driverId'] ??= '';
    normalized['driverName'] ??= '';
    normalized['connectedAccountId'] ??= normalized['stripeAccountId'] ?? '';
    normalized['amountInCents'] ??= _legacyAmountToCents(normalized['amount']);
    normalized['amountInCents'] ??= 0;
    normalized['currency'] ??= 'EUR';
    normalized['status'] ??= 'pending';
    if (normalized['status'] == 'canceled') {
      normalized['status'] = 'cancelled';
    }
    normalized['method'] ??= normalized['isInstantPayout'] == true
        ? 'instant'
        : 'standard';
    if (normalized['type'] == null) {
      normalized['type'] = 'bankAccount';
    } else if (normalized['type'] == 'bank_account') {
      normalized['type'] = 'bankAccount';
    }
    normalized['stripeBalanceTransactionId'] ??=
        normalized['balanceTransactionId'];
    if (normalized['transactionIds'] is! List) {
      normalized['transactionIds'] = const <String>[];
    }
    if (normalized['metadata'] is! Map) {
      normalized['metadata'] = const <String, dynamic>{};
    }

    return normalized;
  }

  static String? _normalizeStripeDisabledReason(Object? value) {
    switch (value) {
      case 'action_required.requested_capabilities':
        return 'actionRequiredRequestedCapabilities';
      case 'listed':
        return 'listed';
      case 'other':
        return 'other';
      case 'platform_paused':
        return 'platformPaused';
      case 'rejected.fraud':
        return 'rejectedFraud';
      case 'rejected.incomplete_verification':
        return 'rejectedIncompleteVerification';
      case 'rejected.listed':
        return 'rejectedListed';
      case 'rejected.other':
        return 'rejectedOther';
      case 'rejected.platform_fraud':
        return 'rejectedPlatformFraud';
      case 'rejected.platform_other':
        return 'rejectedPlatformOther';
      case 'rejected.platform_terms_of_service':
        return 'rejectedPlatformTermsOfService';
      case 'rejected.terms_of_service':
        return 'rejectedTermsOfService';
      case 'requirements.past_due':
        return 'requirementsPastDue';
      case 'requirements.pending_verification':
        return 'requirementsPendingVerification';
      case 'under_review':
        return 'underReview';
      default:
        return value is String ? value : null;
    }
  }

  static Map<String, dynamic> _normalizeRequirements(Object? raw) {
    final data = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    if (data['currentlyDue'] is! List) data['currentlyDue'] = const <String>[];
    if (data['eventuallyDue'] is! List) {
      data['eventuallyDue'] = const <String>[];
    }
    if (data['pastDue'] is! List) data['pastDue'] = const <String>[];
    if (data['pendingVerification'] is! List) {
      data['pendingVerification'] = const <String>[];
    }

    data['disabledReason'] = _normalizeStripeDisabledReason(
      data['disabledReason'],
    );

    return data;
  }

  static Map<String, dynamic> _normalizeConnectedAccountData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final normalized = Map<String, dynamic>.from(data);

    normalized['driverId'] ??= documentId;
    normalized['id'] ??= normalized['stripeAccountId'] ?? documentId;
    normalized['stripeAccountId'] ??= '';
    normalized['email'] ??= '';
    normalized['country'] ??= 'FR';
    normalized['defaultCurrency'] ??= 'EUR';
    normalized['chargesEnabled'] ??= false;
    normalized['payoutsEnabled'] ??= false;
    normalized['detailsSubmitted'] ??= false;
    normalized['availableBalanceInCents'] ??=
        _majorUnitsToCents(normalized['availableBalance']) ?? 0;
    normalized['pendingBalanceInCents'] ??=
        _majorUnitsToCents(normalized['pendingBalance']) ?? 0;
    normalized['totalEarningsInCents'] ??=
        _majorUnitsToCents(normalized['totalEarnings']) ?? 0;

    normalized['capabilities'] ??= const {
      'transfers': 'inactive',
      'cardPayments': 'inactive',
    };

    normalized['requirements'] = _normalizeRequirements(
      normalized['requirements'],
    );
    normalized['futureRequirements'] = _normalizeRequirements(
      normalized['futureRequirements'],
    );

    if (normalized['metadata'] is! Map) {
      normalized['metadata'] = const <String, dynamic>{};
    }

    return normalized;
  }

  static int? _legacyAmountToCents(Object? value) {
    if (value is int) return value;
    if (value is num) return (value * 100).round();
    return null;
  }

  static int? _majorUnitsToCents(Object? value) {
    if (value is num) return (value * 100).round();
    return null;
  }

  static int _statsAmountToCents(
    Map<String, dynamic> data,
    String centsKey,
    String legacyMajorUnitsKey,
  ) {
    final cents = data[centsKey];
    final majorUnits = data[legacyMajorUnitsKey];
    if (cents is num) {
      if (cents != 0 || majorUnits is! num || majorUnits == 0) {
        return cents.toInt();
      }
    }

    if (majorUnits is num) return (majorUnits * 100).round();

    return 0;
  }

  Future<DriverConnectedAccount?> refreshConnectedAccountFromServer({
    required String driverId,
    required String accountId,
  }) async {
    try {
      await _stripeService.getAccountStatus(accountId: accountId);

      final doc = await _connectedAccountsCollection.doc(driverId).get();
      if (!doc.exists) return null;

      return doc.data();
    } on Exception catch (e) {
      TalkerService.error('Error refreshing connected account: $e');
      rethrow;
    }
  }

  /// Create payment transaction record

  Future<String> createPaymentTransaction(PaymentTransaction payment) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.paymentsCollection)
          .doc();
      final paymentWithId = payment.copyWith(id: docRef.id);

      // Write the model fields then override timestamps with server values so
      // that createdAt/updatedAt are set by Firestore's clock, not the client.
      final data = paymentWithId.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
      TalkerService.info('Payment transaction created: ${docRef.id}');
      return docRef.id;
    } on Exception catch (e) {
      TalkerService.error('Error creating payment transaction: $e');
      rethrow;
    }
  }

  // FIX P-1: Valid payment state transitions.
  static const _validTransitions = <String, Set<String>>{
    'pending': {'processing', 'failed'},
    'processing': {'succeeded', 'failed'},
    'succeeded': {'refunding', 'refunded', 'partiallyRefunded'},
    'failed': {},
    'refunded': {},
    'partiallyRefunded': {'refunding', 'refunded'},
    'refunding': {'refunded', 'partiallyRefunded', 'refundFailed'},
    'refundFailed': {'refunding'},
  };

  /// Update payment transaction status — enforces valid state machine.
  ///
  /// The read-then-write is wrapped in a Firestore transaction so that
  /// the state-machine guard and the write are atomic; concurrent updates
  /// cannot slip an invalid transition past the check.

  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? failureReason,
    DateTime? completedAt,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data();
          final currentStatus = data?['status'] as String?;
          if (currentStatus != null) {
            final allowed = _validTransitions[currentStatus] ?? {};
            if (!allowed.contains(status.name)) {
              throw StateError(
                'Invalid payment transition: $currentStatus → ${status.name}',
              );
            }
          }
        }

        final updateData = <String, Object?>{
          'status': status.name,
          'updatedAt': FieldValue.serverTimestamp(),
          if (failureReason != null) 'failureReason': failureReason,
          if (completedAt != null)
            'completedAt': Timestamp.fromDate(completedAt),
        };

        transaction.update(docRef, updateData);
      });

      TalkerService.info(
        'Payment status updated: $paymentId -> ${status.name}',
      );
    } on Exception catch (e) {
      TalkerService.error('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Get payment transaction by Firestore document ID or Stripe paymentIntentId.
  ///
  /// The Cloud Function creates payment docs with `.add()` (auto-generated Firestore
  /// ID), so [paymentId] may be either the Firestore doc ID or the Stripe
  /// paymentIntentId (pi_xxx). We try the doc lookup first (fast path), then
  /// fall back to a field query.

  Future<PaymentTransaction?> getPaymentById(String paymentId) async {
    try {
      // Fast path: try direct document lookup (works if caller has Firestore ID)
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (doc.exists) return doc.data();

      // Fallback: query by Stripe paymentIntentId field (pi_xxx)
      final snapshot = await _paymentsCollection
          .where('paymentIntentId', isEqualTo: paymentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        final stripeSnapshot = await _paymentsCollection
            .where('stripePaymentIntentId', isEqualTo: paymentId)
            .limit(1)
            .get();
        if (stripeSnapshot.docs.isEmpty) return null;
        return stripeSnapshot.docs.first.data();
      }
      return snapshot.docs.first.data();
    } on Exception catch (e) {
      TalkerService.error('Error getting payment: $e');
      rethrow;
    }
  }

  /// Get payments by ride

  Future<List<PaymentTransaction>> getPaymentsByRide(String rideId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('rideId', isEqualTo: rideId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on Exception catch (e) {
      TalkerService.error('Error getting payments by ride: $e');
      rethrow;
    }
  }

  /// Get rider's payment history

  Future<List<PaymentTransaction>> getRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _paymentsCollection
          .where('riderId', isEqualTo: riderId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on Exception catch (e) {
      TalkerService.error('Error getting rider payment history: $e');
      rethrow;
    }
  }

  /// Stream rider's payment history

  Stream<List<PaymentTransaction>> streamRiderPaymentHistory({
    required String riderId,
    int limit = 20,
  }) {
    return _paymentsCollection
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get driver's earnings transactions

  Future<List<PaymentTransaction>> getDriverEarnings({
    required String driverId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _paymentsCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: PaymentStatus.succeeded.name);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return _filterCompletedRidePayments(
        snapshot.docs.map((doc) => doc.data()).toList(),
      );
    } on Exception catch (e) {
      TalkerService.error('Error getting driver earnings: $e');
      rethrow;
    }
  }

  Future<List<PaymentTransaction>> _filterCompletedRidePayments(
    List<PaymentTransaction> payments,
  ) async {
    if (payments.isEmpty) return payments;

    final rideIds = payments.map((payment) => payment.rideId).toSet().toList();
    final completedRideIds = <String>{};

    for (var i = 0; i < rideIds.length; i += 30) {
      final batch = rideIds.sublist(
        i,
        i + 30 > rideIds.length ? rideIds.length : i + 30,
      );
      final ridesSnapshot = await _firestore
          .collection(AppConstants.ridesCollection)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      for (final doc in ridesSnapshot.docs) {
        if (doc.data()['status'] == 'completed') {
          completedRideIds.add(doc.id);
        }
      }
    }

    return payments
        .where((payment) => completedRideIds.contains(payment.rideId))
        .toList();
  }

  /// Calculate earnings summary for driver.
  ///
  /// P-2: Uses the pre-computed `driver_stats` document as a fast path.
  /// Cloud Functions `recomputeDriverStats` keeps it up to date after every
  /// payment success and every refund.  Falls back to a full payments scan
  /// only when the doc doesn't exist yet (first-time / cold-start scenario).

  Future<EarningsSummary> calculateEarningsSummary(String driverId) async {
    try {
      // Fast path: read the pre-aggregated driver_stats document.
      final statsDoc = await _firestore
          .collection(AppConstants.driverStatsCollection)
          .doc(driverId)
          .get();

      // Always fetch payout info — it's a single bounded query.
      final payoutsSnapshot = await _payoutsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      DateTime? lastPayoutDate;
      if (payoutsSnapshot.docs.isNotEmpty) {
        lastPayoutDate = payoutsSnapshot.docs.first.data().arrivedAt;
      }

      if (statsDoc.exists) {
        final data = statsDoc.data()!;
        TalkerService.info(
          'calculateEarningsSummary: using driver_stats fast path for $driverId',
        );
        return EarningsSummary(
          driverId: driverId,
          totalEarningsInCents: _statsAmountToCents(
            data,
            'totalEarningsInCents',
            'totalEarnings',
          ),
          totalPlatformFeesInCents: _statsAmountToCents(
            data,
            'totalPlatformFeesInCents',
            'totalPlatformFees',
          ),
          totalStripeFeesInCents: _statsAmountToCents(
            data,
            'totalStripeFeesInCents',
            'totalStripeFees',
          ),
          earningsTodayInCents: _statsAmountToCents(
            data,
            'earningsTodayInCents',
            'earningsToday',
          ),
          earningsThisWeekInCents: _statsAmountToCents(
            data,
            'earningsThisWeekInCents',
            'earningsThisWeek',
          ),
          earningsThisMonthInCents: _statsAmountToCents(
            data,
            'earningsThisMonthInCents',
            'earningsThisMonth',
          ),
          earningsThisYearInCents: _statsAmountToCents(
            data,
            'earningsThisYearInCents',
            'earningsThisYear',
          ),
          totalRidesCompleted: (data['totalRides'] as num?)?.toInt() ?? 0,
          ridesCompletedToday: (data['ridesToday'] as num?)?.toInt() ?? 0,
          ridesCompletedThisWeek: (data['ridesThisWeek'] as num?)?.toInt() ?? 0,
          ridesCompletedThisMonth:
              (data['ridesThisMonth'] as num?)?.toInt() ?? 0,
          lastUpdated:
              (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastPayoutDate: lastPayoutDate,
        );
      }

      // Fallback: full payments scan — only runs before the first Cloud
      // Function execution or if driver_stats was manually deleted.
      TalkerService.info(
        'calculateEarningsSummary: driver_stats missing for $driverId — '
        'falling back to full payments scan',
      );

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(
        Duration(days: todayStart.weekday - DateTime.monday),
      );
      final monthStart = DateTime(now.year, now.month);
      final yearStart = DateTime(now.year);

      final allPayments = await _paymentsCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: PaymentStatus.succeeded.name)
          .limit(500)
          .get();

      if (allPayments.docs.length == 500) {
        TalkerService.warning(
          'calculateEarningsSummary: fallback scan returned exactly 500 '
          'documents for driver $driverId — earnings total may be understated '
          'if this driver has more than 500 completed rides. '
          'Ensure the Cloud Function initialises driver_stats correctly.',
        );
      }

      final payments = await _filterCompletedRidePayments(
        allPayments.docs.map((doc) => doc.data()).toList(),
      );

      var totalEarningsInCents = 0;
      var totalPlatformFeesInCents = 0;
      var totalStripeFeesInCents = 0;
      final totalRides = payments.length;

      var earningsTodayInCents = 0;
      var earningsThisWeekInCents = 0;
      var earningsThisMonthInCents = 0;
      var earningsThisYearInCents = 0;

      var ridesToday = 0;
      var ridesThisWeek = 0;
      var ridesThisMonth = 0;

      for (final payment in payments) {
        totalEarningsInCents += payment.driverEarningsInCents;
        totalPlatformFeesInCents += payment.platformFeeInCents;
        totalStripeFeesInCents += payment.stripeFeeInCents;

        if (payment.completedAt != null) {
          if (payment.completedAt!.isAfter(todayStart)) {
            earningsTodayInCents += payment.driverEarningsInCents;
            ridesToday++;
          }
          if (payment.completedAt!.isAfter(weekStart)) {
            earningsThisWeekInCents += payment.driverEarningsInCents;
            ridesThisWeek++;
          }
          if (payment.completedAt!.isAfter(monthStart)) {
            earningsThisMonthInCents += payment.driverEarningsInCents;
            ridesThisMonth++;
          }
          if (payment.completedAt!.isAfter(yearStart)) {
            earningsThisYearInCents += payment.driverEarningsInCents;
          }
        }
      }

      return EarningsSummary(
        driverId: driverId,
        totalEarningsInCents: totalEarningsInCents,
        totalPlatformFeesInCents: totalPlatformFeesInCents,
        totalStripeFeesInCents: totalStripeFeesInCents,
        earningsTodayInCents: earningsTodayInCents,
        earningsThisWeekInCents: earningsThisWeekInCents,
        earningsThisMonthInCents: earningsThisMonthInCents,
        earningsThisYearInCents: earningsThisYearInCents,
        totalRidesCompleted: totalRides,
        ridesCompletedToday: ridesToday,
        ridesCompletedThisWeek: ridesThisWeek,
        ridesCompletedThisMonth: ridesThisMonth,
        lastUpdated: DateTime.now(),
        lastPayoutDate: lastPayoutDate,
      );
    } on Exception catch (e) {
      TalkerService.error('Error calculating earnings summary: $e');
      rethrow;
    }
  }

  /// Create payout record

  Future<String> createPayout(DriverPayout payout) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.payoutsCollection)
          .doc();
      final payoutWithId = payout.copyWith(id: docRef.id);

      // Override createdAt with a server-side timestamp so payout ordering
      // is not skewed by client clock drift.
      final data = payoutWithId.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
      TalkerService.info('Payout created: ${docRef.id}');
      return docRef.id;
    } on Exception catch (e) {
      TalkerService.error('Error creating payout: $e');
      rethrow;
    }
  }

  /// Update payout status

  Future<void> updatePayoutStatus({
    required String payoutId,
    required PayoutStatus status,
    String? failureReason,
    DateTime? arrivedAt,
  }) async {
    try {
      await _payoutsCollection.doc(payoutId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'failureReason': ?failureReason,
        if (arrivedAt != null) 'arrivedAt': Timestamp.fromDate(arrivedAt),
      });

      TalkerService.info('Payout status updated: $payoutId -> ${status.name}');
    } on Exception catch (e) {
      TalkerService.error('Error updating payout status: $e');
      rethrow;
    }
  }

  /// Get driver payouts

  Future<List<DriverPayout>> getDriverPayouts({
    required String driverId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _payoutsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on Exception catch (e) {
      TalkerService.error('Error getting driver payouts: $e');
      rethrow;
    }
  }

  /// Save driver connected account

  Future<void> saveConnectedAccount(DriverConnectedAccount account) async {
    try {
      await refreshConnectedAccountFromServer(
        driverId: account.driverId,
        accountId: account.stripeAccountId,
      );
      TalkerService.info(
        'Connected account refresh requested: ${account.driverId}',
      );
    } on Exception catch (e) {
      TalkerService.error('Error refreshing connected account: $e');
      rethrow;
    }
  }

  /// Get driver connected account

  Future<DriverConnectedAccount?> getConnectedAccount(String driverId) async {
    try {
      final doc = await _connectedAccountsCollection.doc(driverId).get();
      if (!doc.exists) return null;

      return doc.data();
    } on Exception catch (e) {
      TalkerService.error('Error getting connected account: $e');
      rethrow;
    }
  }

  /// Update connected account status

  Future<void> updateConnectedAccountStatus({
    required String driverId,
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool detailsSubmitted,
    int? availableBalanceInCents,
    int? pendingBalanceInCents,
  }) async {
    try {
      final current = await getConnectedAccount(driverId);
      if (current == null || current.stripeAccountId.isEmpty) {
        throw StateError('Connected account not found for driver $driverId');
      }

      await refreshConnectedAccountFromServer(
        driverId: driverId,
        accountId: current.stripeAccountId,
      );

      TalkerService.info(
        'Connected account server refresh requested: $driverId',
      );
    } on Exception catch (e) {
      TalkerService.error('Error refreshing connected account status: $e');
      rethrow;
    }
  }

  /// Request a server-policy refund.

  Future<void> requestRefundReview({
    required String paymentId,
    required String reason,
    String? details,
  }) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) throw Exception('Payment not found');
      if (!payment.canRequestRefund) {
        throw Exception('This payment is not eligible for automatic refund');
      }

      await _stripeService.requestRefund(
        paymentId: payment.id,
        reason: reason,
        details: details,
      );

      TalkerService.info('Automatic refund requested: $paymentId');
    } on Exception catch (e) {
      TalkerService.error('Error requesting automatic refund: $e');
      rethrow;
    }
  }

  /// Get payout by ID

  Future<DriverPayout?> getPayoutById(String payoutId) async {
    try {
      final doc = await _payoutsCollection.doc(payoutId).get();
      if (!doc.exists) return null;
      return doc.data();
    } on Exception catch (e) {
      TalkerService.error('Error getting payout: $e');
      rethrow;
    }
  }

  /// Create driver connected account via Stripe and persist it to Firestore.

  Future<ConnectedAccountCreationResult?> createConnectedAccount({
    required String userId,
    required String email,
  }) async {
    try {
      final result = await _stripeService.createDriverConnectedAccount(
        userId: userId,
        email: email,
      );

      final accountId = result['accountId'] as String?;
      if (accountId == null || accountId.isEmpty) return null;

      final account = DriverConnectedAccount(
        id: accountId,
        driverId: userId,
        stripeAccountId: accountId,
        email: email,
        country: 'FR',
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        onboardingCompleted: false,
        defaultCurrency: 'EUR',
      );

      // Do NOT write driver_connected_accounts from the client.
      // The server webhook / sync callable owns that document.
      TalkerService.info('Connected account created via CF: $userId');

      return ConnectedAccountCreationResult(
        account: account,
        onboardingUrl: result['onboardingUrl'] as String?,
      );
    } on Exception catch (e) {
      TalkerService.error('Error creating connected account: $e');
      rethrow;
    }
  }

  Stream<DriverConnectedAccount?> streamConnectedAccount(String driverId) {
    return _connectedAccountsCollection.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }
}
