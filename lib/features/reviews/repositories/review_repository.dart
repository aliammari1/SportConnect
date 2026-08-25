import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
part 'review_repository.g.dart';

/// Firestore Collection Structure for Reviews:
///
/// /reviews/{reviewId}
///   - id: string
///   - rideId: string
///   - reviewerId: string
///   - reviewerName: string
///   - reviewerPhotoUrl: string?
///   - revieweeId: string
///   - revieweeName: string
///   - revieweePhotoUrl: string?
///   - type: string (driver/rider)
///   - rating: number
///   - comment: string?
///   - tags: array<string>
///   - isVisible: bool
///   - response: string?
///   - responseAt: timestamp?
///   - createdAt: timestamp
///   - updatedAt: timestamp?
///
/// Indexes needed:
/// - reviews: revieweeId ASC, createdAt DESC
/// - reviews: reviewerId ASC, createdAt DESC
/// - reviews: rideId ASC
/// - reviews: type ASC, revieweeId ASC, createdAt DESC
///
/// This design supports:
/// 1. Many-to-many: A user can review many users, and be reviewed by many users
/// 2. Efficient queries: Get all reviews for a user, or all reviews by a user
/// 3. Ride association: Link reviews to specific rides
/// 4. Response feature: Reviewees can respond to reviews
/// 5. Tag aggregation: Can compute tag statistics

@Riverpod(keepAlive: true)
ReviewRepository reviewRepository(Ref ref) {
  return ReviewRepository(ref.watch(firebaseServiceProvider).firestore);
}

/// Provider to get reviews for a specific user
@riverpod
Future<List<ReviewModel>> userReviews(Ref ref, String userId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  final result = await repo.getReviewsForUser(userId);
  return result.reviews;
}

/// Provider to get reviews left by a specific user
@riverpod
Future<List<ReviewModel>> reviewsByUser(Ref ref, String userId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsByUser(userId);
}

/// Provider to get rating stats for a user
@riverpod
Future<RatingStats> userRatingStats(Ref ref, String userId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getRatingStatsForUser(userId);
}

/// Stream provider for real-time review updates for a user
@riverpod
Stream<List<ReviewModel>> userReviewsStream(Ref ref, String userId) {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.watchReviewsForUser(userId);
}

class ReviewRepository {
  ReviewRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<ReviewModel> get _reviewsCollection => _firestore
      .collection(AppConstants.reviewsCollection)
      .withConverter<ReviewModel>(
        fromFirestore: (snap, _) => ReviewModel.fromJson(snap.data()!),
        toFirestore: (review, _) => review.toJson(),
      );

  CollectionReference<UserModel> get _usersCollection => _firestore
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter<RideModel>(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (ride, _) => ride.toJson(),
      );

  /// Create a new review

  Future<ReviewModel> createReview(
    String? userId,
    CreateReviewRequest request,
  ) async {
    final currentUser = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // FIX V-1: Prevent self-reviews.
    if (currentUser.uid == request.revieweeId) {
      throw Exception('You cannot review yourself');
    }

    // V-2: Enforce comment length (1-500 characters).
    final comment = request.comment;
    if (comment != null && comment.isNotEmpty && comment.length > 500) {
      throw ArgumentError(
        'Review comment must not exceed 500 characters (got ${comment.length}).',
      );
    }

    // V-3: Only allow reviews for completed rides.
    final ride = await _ridesCollection
        .doc(request.rideId)
        .get()
        .then((s) => s.data());
    if (ride == null) {
      throw Exception('Ride not found');
    }
    if (ride.status != RideStatus.completed) {
      throw StateError(
        'Reviews can only be submitted for completed rides (current status: ${ride.status.name}).',
      );
    }

    final eligibleBooking = await _hasCompletedPaidSeat(
      rideId: request.rideId,
      reviewerId: currentUser.uid,
      revieweeId: request.revieweeId,
    );
    if (!eligibleBooking) {
      throw StateError(
        'Reviews require a completed paid seat between these users.',
      );
    }

    // Check if user already reviewed this person for this ride
    final existingReview = await _reviewsCollection
        .where('rideId', isEqualTo: request.rideId)
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('revieweeId', isEqualTo: request.revieweeId)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('You have already reviewed this person for this ride');
    }

    final now = DateTime.now();
    // Use a composite key to enforce uniqueness at the Firestore level,
    // preventing duplicate reviews even under concurrent submission race conditions.
    final reviewId =
        '${request.rideId}_${currentUser.uid}_${request.revieweeId}';

    final review = ReviewModel(
      id: reviewId,
      rideId: request.rideId,
      reviewerId: currentUser.uid,
      reviewerName: currentUser.username,
      reviewerPhotoUrl: currentUser.photoUrl,
      revieweeId: request.revieweeId,
      revieweeName: request.revieweeName,
      revieweePhotoUrl: request.revieweePhotoUrl,
      type: request.type,
      rating: request.rating,
      comment: request.comment,
      tags: request.tags,
      createdAt: now,
    );

    // Write the new review and atomically update the reviewee's rating stats
    // in a single transaction so a crash between the two writes cannot leave
    // the aggregate permanently out of sync.
    await _firestore.runTransaction((txn) async {
      final reviewRef = _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(request.revieweeId);

      // Read the review doc inside the transaction so reviewRef is part of the
      // read set. A concurrent duplicate (same deterministic composite key)
      // will then fail/retry against an existing doc instead of double-applying
      // the aggregate increment (R-D1).
      final reviewSnap = await txn.get(reviewRef);
      if (reviewSnap.exists) {
        throw Exception('You have already reviewed this person for this ride');
      }

      final starKey = _starKey(request.rating.round());

      // Override createdAt with a server timestamp so the stored value is
      // authoritative and not subject to client clock skew (R-05).
      final reviewData = review.toJson()
        ..['createdAt'] = FieldValue.serverTimestamp();
      txn.set(reviewRef, reviewData);
      // Only increment the star buckets; total/average are derived getters on
      // RatingBreakdown (single source of truth), so no read of the user doc is
      // needed and the user doc stays out of the read set (R-D2, R-D3).
      txn.update(userRef, {
        starKey: FieldValue.increment(1),
      });
    });

    return review;
  }

  Future<bool> _hasCompletedPaidSeat({
    required String rideId,
    required String reviewerId,
    required String revieweeId,
  }) async {
    final riderReviewQuery = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('rideId', isEqualTo: rideId)
        .where('passengerId', isEqualTo: reviewerId)
        .where('driverId', isEqualTo: revieweeId)
        .where('status', isEqualTo: BookingStatus.completed.name)
        .limit(1)
        .get();

    if (_containsPaidSeat(riderReviewQuery)) return true;

    final driverReviewQuery = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: reviewerId)
        .where('passengerId', isEqualTo: revieweeId)
        .where('status', isEqualTo: BookingStatus.completed.name)
        .limit(1)
        .get();

    return _containsPaidSeat(driverReviewQuery);
  }

  bool _containsPaidSeat(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.any((doc) {
      final data = doc.data();
      final paymentIntentId = data['paymentIntentId'];
      return paymentIntentId is String && paymentIntentId.trim().isNotEmpty;
    });
  }

  /// Get all reviews for a user (reviews they received).
  ///
  /// Returns a record with the page of reviews and a cursor for the next page.
  /// Pass [startAfterDoc] (the [nextCursor] from the previous call) to fetch
  /// subsequent pages. Uses [limit]+1 fetch to detect whether a next page exists.

  Future<({List<ReviewModel> reviews, DocumentSnapshot? nextCursor})>
  getReviewsForUser(
    String userId, {
    ReviewType? type,
    int limit = 50,
    DocumentSnapshot? startAfterDoc,
  }) async {
    var query = _reviewsCollection
        .where('revieweeId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    query = query.limit(limit + 1);

    final snapshot = await query.get();
    final isLastPage = snapshot.docs.length <= limit;
    return (
      reviews: snapshot.docs.take(limit).map((d) => d.data()).toList(),
      nextCursor: isLastPage ? null : snapshot.docs[limit],
    );
  }

  /// Get all reviews left by a user

  Future<List<ReviewModel>> getReviewsByUser(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _reviewsCollection
        .where('reviewerId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get reviews for a specific ride

  Future<List<ReviewModel>> getReviewsForRide(String rideId) async {
    final snapshot = await _reviewsCollection
        .where('rideId', isEqualTo: rideId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Watch reviews for a user (real-time updates)

  Stream<List<ReviewModel>> watchReviewsForUser(String userId) {
    return _reviewsCollection
        .where('revieweeId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get rating stats for a user

  Future<RatingStats> getRatingStatsForUser(String userId) async {
    // Use the maintained per-user aggregate (star buckets) as the single source
    // of truth rather than deriving stats from a single capped page of reviews,
    // which would be truncated/incorrect for users with many reviews (R-D4).
    final user = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (user == null) {
      return const RatingStats();
    }

    // `rating` lives on the rider/driver variants, not the base UserModel.
    final breakdown =
        user.asRider?.rating ??
        user.asDriver?.rating ??
        const RatingBreakdown();
    return RatingStats(
      totalReviews: breakdown.total,
      averageRating: breakdown.average,
      fiveStarCount: breakdown.fiveStars,
      fourStarCount: breakdown.fourStars,
      threeStarCount: breakdown.threeStars,
      twoStarCount: breakdown.twoStars,
      oneStarCount: breakdown.oneStars,
    );
  }

  /// Add response to a review (by the reviewee)

  Future<void> respondToReview(
    String userId,
    String reviewId,
    String response,
  ) async {
    final currentUser = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Verify the current user is the reviewee
    final reviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final review = reviewDoc.data()!;
    if (review.revieweeId != currentUser.uid) {
      throw Exception('Only the reviewee can respond to this review');
    }

    // R-D5: do not allow responding to a soft-deleted review.
    if (!review.isVisible) {
      throw StateError('Cannot respond to a deleted review');
    }

    // R-D5: validate the response text (non-empty, max 500 chars), mirroring the
    // comment validation in createReview.
    final trimmedResponse = response.trim();
    if (trimmedResponse.isEmpty) {
      throw ArgumentError('Response must not be empty.');
    }
    if (trimmedResponse.length > 500) {
      throw ArgumentError(
        'Response must not exceed 500 characters (got ${trimmedResponse.length}).',
      );
    }

    await _reviewsCollection.doc(reviewId).update({
      'response': trimmedResponse,
      'responseAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a review (by reviewer or admin)

  Future<void> deleteReview(String userId, String reviewId) async {
    final currentUser = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final reviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final review = reviewDoc.data()!;
    if (review.reviewerId != currentUser.uid) {
      throw Exception('Only the reviewer can delete this review');
    }

    // Soft-delete the review and update the reviewee's rating stats atomically
    // so a crash between the two writes cannot leave the aggregate inflated.
    await _firestore.runTransaction((txn) async {
      final reviewRef = _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(review.revieweeId);

      // Read the review inside the transaction so the soft-delete is idempotent:
      // if it is already hidden (concurrent/repeated delete) we must not apply
      // the star-bucket decrement a second time (R-D7).
      final reviewSnap = await txn.get(reviewRef);
      if (!reviewSnap.exists) {
        throw Exception('Review not found');
      }
      final currentlyVisible =
          (reviewSnap.data()?['isVisible'] as bool?) ?? true;
      if (!currentlyVisible) {
        // Already soft-deleted; nothing to do.
        return;
      }

      final starKey = _starKey(review.rating.round());

      txn.update(reviewRef, {
        'isVisible': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Only decrement the star bucket; total/average are derived getters on
      // RatingBreakdown so they need no separate write (R-D2/R-D3).
      txn.update(userRef, {
        starKey: FieldValue.increment(-1),
      });
    });
  }

  /// Returns the Firestore field name for a given star count (1-5).
  String _starKey(int stars) {
    return switch (stars) {
      5 => 'rating.fiveStars',
      4 => 'rating.fourStars',
      3 => 'rating.threeStars',
      2 => 'rating.twoStars',
      _ => 'rating.oneStars',
    };
  }

  /// Check if user can review another user for a specific ride

  Future<bool> canReview(
    String userId, {
    required String rideId,
    required String revieweeId,
  }) async {
    final currentUser = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (currentUser == null) return false;

    // Check if already reviewed
    final existing = await _reviewsCollection
        .where('rideId', isEqualTo: rideId)
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('revieweeId', isEqualTo: revieweeId)
        .get();

    return existing.docs.isEmpty;
  }

  /// Get pending reviews (rides that user participated in but hasn't reviewed)

  Future<List<Map<String, dynamic>>> getPendingReviews(String userId) async {
    final currentUser = await _usersCollection
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    if (currentUser == null) return [];

    // Get completed rides where user was a participant
    final completedRides = await _ridesCollection
        .where('status', isEqualTo: 'completed')
        .where('participantIds', arrayContains: currentUser.uid)
        .orderBy('updatedAt', descending: true)
        .limit(20)
        .get();

    // First pass: gather every candidate (rideId, revieweeId, type) pair
    // locally without any per-iteration Firestore reads. We then resolve the
    // "already reviewed" set and the reviewee user docs in a small number of
    // batched queries instead of the previous O(rides * passengers) N+1 loop.
    final candidates = <_PendingCandidate>[];
    final rideIds = <String>{};
    final revieweeIds = <String>{};

    for (final rideDoc in completedRides.docs) {
      final rideData = rideDoc.data();
      final rideId = rideDoc.id;
      final driverId = rideData.driverId;
      final isDriver = driverId == currentUser.uid;

      if (isDriver) {
        // Driver can review passengers
        for (final booking in rideData.bookings) {
          final passengerId = booking.passengerId;
          candidates.add(
            _PendingCandidate(
              rideId: rideId,
              rideData: rideData,
              revieweeId: passengerId,
              type: ReviewType.rider,
            ),
          );
          rideIds.add(rideId);
          revieweeIds.add(passengerId);
        }
      } else {
        // Passenger can review driver
        candidates.add(
          _PendingCandidate(
            rideId: rideId,
            rideData: rideData,
            revieweeId: driverId,
            type: ReviewType.driver,
          ),
        );
        rideIds.add(rideId);
        revieweeIds.add(driverId);
      }
    }

    if (candidates.isEmpty) return [];

    // Batch: fetch the reviews this user has already written for these rides in
    // chunked whereIn queries, building a set of already-reviewed
    // "rideId|revieweeId" keys locally (replaces per-candidate canReview()).
    final reviewedKeys = <String>{};
    for (final chunk in _chunk(rideIds.toList(), 30)) {
      final snap = await _reviewsCollection
          .where('reviewerId', isEqualTo: currentUser.uid)
          .where('rideId', whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final r = doc.data();
        reviewedKeys.add('${r.rideId}|${r.revieweeId}');
      }
    }

    // Batch: fetch all reviewee user docs in chunked documentId whereIn queries
    // (replaces the per-candidate _usersCollection.doc(...).get()).
    final userById = <String, UserModel>{};
    for (final chunk in _chunk(revieweeIds.toList(), 30)) {
      final snap = await _usersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        userById[doc.id] = doc.data();
      }
    }

    final pending = <Map<String, dynamic>>[];
    for (final c in candidates) {
      if (reviewedKeys.contains('${c.rideId}|${c.revieweeId}')) continue;
      final user = userById[c.revieweeId];
      final isRiderReview = c.type == ReviewType.rider;
      pending.add({
        'rideId': c.rideId,
        'revieweeId': c.revieweeId,
        'revieweeName':
            user?.username ?? (isRiderReview ? 'Passenger' : 'Driver'),
        'revieweePhotoUrl': user?.photoUrl ?? '',
        'type': c.type,
        'rideDate': c.rideData.departureTime,
        'origin': c.rideData.origin,
        'destination': c.rideData.destination,
      });
    }

    return pending;
  }

  /// Splits [items] into sublists of at most [size] elements, for use with
  /// Firestore `whereIn` queries (which accept at most 30 values).
  List<List<T>> _chunk<T>(List<T> items, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < items.length; i += size) {
      chunks.add(
        items.sublist(i, i + size > items.length ? items.length : i + size),
      );
    }
    return chunks;
  }
}

/// Internal holder for a pending-review candidate gathered before batched reads.
class _PendingCandidate {
  const _PendingCandidate({
    required this.rideId,
    required this.rideData,
    required this.revieweeId,
    required this.type,
  });
  final String rideId;
  final RideModel rideData;
  final String revieweeId;
  final ReviewType type;
}
