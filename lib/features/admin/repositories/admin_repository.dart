import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  return AdminRepository(firebase.firestore, firebase.functions);
});

final adminRefundRequestsProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchRefundRequests();
});

final adminDisputesProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchDisputes();
});

final adminSupportTicketsProvider = StreamProvider<List<AdminIssue>>((ref) {
  return ref.watch(adminRepositoryProvider).watchSupportTickets();
});

class AdminIssue {
  const AdminIssue({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdAt,
    required this.data,
  });

  final String id;
  final String title;
  final String subtitle;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  int get amountInCents =>
      _readInt(data['remainingAmountInCents']) ??
      _readInt(data['amountInCents']) ??
      0;

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return null;
  }
}

class AdminRepository {
  const AdminRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<List<AdminIssue>> watchRefundRequests() {
    return _firestore
        .collection('refund_requests')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title:
                      'Refund ${_money(doc.data()['remainingAmountInCents'] ?? doc.data()['amountInCents'])}',
                  fallbackSubtitle: doc.data()['reason'] as String?,
                ),
              )
              .toList(),
        );
  }

  Stream<List<AdminIssue>> watchDisputes() {
    return _firestore
        .collection(AppConstants.disputesCollection)
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title: 'Dispute ${doc.data()['disputeType'] ?? ''}'.trim(),
                  fallbackSubtitle: doc.data()['description'] as String?,
                ),
              )
              .toList(),
        );
  }

  Stream<List<AdminIssue>> watchSupportTickets() {
    return _firestore
        .collection(AppConstants.supportTicketsCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => _issueFromDoc(
                  doc,
                  title: doc.data()['subject'] as String? ?? 'Support ticket',
                  fallbackSubtitle: doc.data()['message'] as String?,
                ),
              )
              .toList(),
        );
  }

  Future<void> approveRefundRequest({
    required String refundRequestId,
    int? amountInCents,
    String? note,
  }) {
    return _call('approveRefundRequest', {
      'refundRequestId': refundRequestId,
      'amountInCents': ?amountInCents,
      'note': ?note,
    });
  }

  Future<void> rejectRefundRequest({
    required String refundRequestId,
    String? note,
  }) {
    return _call('rejectRefundRequest', {
      'refundRequestId': refundRequestId,
      'note': ?note,
    });
  }

  Future<void> approveDisputeRefund({
    required String disputeId,
    int? amountInCents,
    String? note,
  }) {
    return _call('approveDisputeRefund', {
      'disputeId': disputeId,
      'amountInCents': ?amountInCents,
      'note': ?note,
    });
  }

  Future<void> rejectDispute({
    required String disputeId,
    String? note,
  }) {
    return _call('rejectDispute', {
      'disputeId': disputeId,
      'note': ?note,
    });
  }

  Future<void> resolveSupportTicket({
    required String ticketId,
    String? note,
  }) {
    return _call('resolveSupportTicket', {
      'ticketId': ticketId,
      'note': ?note,
    });
  }

  Future<void> _call(String name, Map<String, dynamic> data) async {
    await _functions.httpsCallable(name).call<void>(data);
  }

  // ── Ops actions (server-authoritative, audit-logged server-side) ─────────

  HttpsCallable callable(String name) => _functions.httpsCallable(name);

  Future<void> setUserSuspended({
    required String userId,
    required bool suspended,
    String? reason,
  }) =>
      _call('setUserSuspended', {
        'userId': userId,
        'suspended': suspended,
        if (reason != null) 'reason': reason,
      });

  Future<void> setPremiumOverride({
    required String userId,
    required bool premium,
  }) =>
      _call('setPremiumOverride', {'userId': userId, 'premium': premium});

  Future<void> adminCancelRide({
    required String rideId,
    String reason = 'cancelled_by_platform',
  }) =>
      _call('adminCancelRide', {'rideId': rideId, 'reason': reason});

  Future<void> resolveReport({required String reportId, String? note}) =>
      _call('resolveReport', {'reportId': reportId, 'note': ?note});

  Future<void> sendAdminPush({
    required String userId,
    required String title,
    required String body,
    String? route,
  }) =>
      _call('sendAdminPush', {
        'userId': userId,
        'title': title,
        'body': body,
        if (route != null) 'route': route,
      });

  Future<void> setPlatformConfig({
    int? commissionPercent,
    int? refundWindowDays,
    bool? maintenanceMode,
  }) =>
      _call('setPlatformConfig', {
        if (commissionPercent != null) 'commissionPercent': commissionPercent,
        if (refundWindowDays != null) 'refundWindowDays': refundWindowDays,
        if (maintenanceMode != null) 'maintenanceMode': maintenanceMode,
      });

  static AdminIssue _issueFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required String title,
    String? fallbackSubtitle,
  }) {
    final data = doc.data();
    return AdminIssue(
      id: doc.id,
      title: title.isEmpty ? 'Issue' : title,
      subtitle: fallbackSubtitle?.trim().isNotEmpty == true
          ? fallbackSubtitle!.trim()
          : 'No details provided',
      status: data['status'] as String? ?? 'open',
      createdAt: _date(data['updatedAt']) ?? _date(data['createdAt']),
      data: data,
    );
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String _money(Object? cents) {
    final amount = AdminIssue._readInt(cents) ?? 0;
    return 'EUR ${(amount / 100).toStringAsFixed(2)}';
  }
}

// ── Ops overview KPIs (single server-side aggregation) ───────────────────────

final opsOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await _callRepo(repo, 'getOpsOverview', {});
  return result;
});

Future<Map<String, dynamic>> _callRepo(
  AdminRepository repo,
  String name,
  Map<String, dynamic> data,
) async {
  final callable = repo.callable(name);
  final response = await callable.call<Map<String, dynamic>>(data);
  return response.data;
}

final adminFindUsersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await _callRepo(repo, 'adminFindUsers', {'query': query});
  return ((result['users'] ?? const []) as List)
      .whereType<Map<String, dynamic>>()
      .toList();
});
enum AdminRideSegment { live, upcoming, completed, cancelled }

final adminRidesSegmentProvider = StreamProvider.family<List<RideModel>,
    AdminRideSegment>((ref, segment) {
  final db = ref.watch(firebaseServiceProvider).firestore;
  final rides = db.collection('rides').withConverter(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (model, _) => model.toJson(),
      );

  switch (segment) {
    case AdminRideSegment.live:
      return rides
          .where('status', isEqualTo: 'inProgress')
          .orderBy('schedule.departureTime')
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    case AdminRideSegment.upcoming:
      return rides
          .where('status', isEqualTo: 'active')
          .where('schedule.departureTime',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('schedule.departureTime')
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    case AdminRideSegment.completed:
      return rides
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    case AdminRideSegment.cancelled:
      return rides
          .where('status', isEqualTo: 'cancelled')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
  }
});

// ── P2/P3 streams & wrappers ─────────────────────────────────────────────────

final adminPaymentsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firebaseServiceProvider).firestore;
  return db
      .collection('payments')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());
});

final adminReportsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firebaseServiceProvider).firestore;
  return db
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());
});

final adminAuditProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.watch(firebaseServiceProvider).firestore;
  return db
      .collection('admin_audit')
      .orderBy('at', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());
});

final platformConfigProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final db = ref.watch(firebaseServiceProvider).firestore;
  return db.collection('config').doc('platform').snapshots().map(
        (d) => d.data() ?? <String, dynamic>{},
      );
});


