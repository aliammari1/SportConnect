import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:uuid/uuid.dart';

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

/// Provider to get reviews for a specific ride
@riverpod
Future<List<ReviewModel>> rideReviews(Ref ref, String rideId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForRide(rideId);
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
  final _uuid = const Uuid();

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
        fromFirestore: (snap, _) => RideModel.fromJson(snap.data()!),
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
    final reviewId = _uuid.v4();

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

    await _reviewsCollection.doc(reviewId).set(review);

    // Update the user's aggregated rating stats
    await _updateUserRatingStats(request.revieweeId);

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
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get reviews for a specific ride

  Future<List<ReviewModel>> getReviewsForRide(String rideId) async {
    final snapshot = await _reviewsCollection
        .where('rideId', isEqualTo: rideId)
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
    final result = await getReviewsForUser(userId);
    return RatingStats.fromReviews(result.reviews);
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

    await _reviewsCollection.doc(reviewId).update({
      'response': response,
      'responseAt': DateTime.now(),
      'updatedAt': DateTime.now(),
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

    // Soft delete - just hide the review
    await _reviewsCollection.doc(reviewId).update({
      'isVisible': false,
      'updatedAt': DateTime.now(),
    });

    // Update the user's aggregated rating stats
    await _updateUserRatingStats(review.revieweeId);
  }

  /// Update user's aggregated rating stats
  Future<void> _updateUserRatingStats(String userId) async {
    final result = await getReviewsForUser(userId);
    final stats = RatingStats.fromReviews(result.reviews);

    // Update the user document with new stats
    await _usersCollection.doc(userId).update({
      'rating': {
        'total': stats.totalReviews,
        'average': stats.averageRating,
        'fiveStars': stats.fiveStarCount,
        'fourStars': stats.fourStarCount,
        'threeStars': stats.threeStarCount,
        'twoStars': stats.twoStarCount,
        'oneStars': stats.oneStarCount,
      },
    });
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

    final pending = <Map<String, dynamic>>[];

    for (final rideDoc in completedRides.docs) {
      final rideData = rideDoc.data();
      final rideId = rideDoc.id;
      final driverId = rideData.driverId;

      // Check if user is the driver or a passenger
      final isDriver = driverId == currentUser.uid;

      if (isDriver) {
        // Driver can review passengers
        final bookings = rideData.bookings;
        for (final booking in bookings) {
          final passengerId = booking.passengerId;
          final canReviewPassenger = await canReview(
            userId,
            rideId: rideId,
            revieweeId: passengerId,
          );
          final passenger = await _usersCollection
              .doc(passengerId)
              .get()
              .then((doc) => doc.data());
          if (canReviewPassenger) {
            pending.add({
              'rideId': rideId,
              'revieweeId': passengerId,
              'revieweeName': passenger?.username ?? 'Passenger',
              'revieweePhotoUrl': passenger?.photoUrl ?? '',
              'type': ReviewType.rider,
              'rideDate': rideData.departureTime,
              'origin': rideData.origin,
              'destination': rideData.destination,
            });
          }
        }
      } else {
        // Passenger can review driver
        final canReviewDriver = await canReview(
          userId,
          rideId: rideId,
          revieweeId: driverId,
        );
        final driver = await _usersCollection
            .doc(driverId)
            .get()
            .then((doc) => doc.data());
        if (canReviewDriver) {
          pending.add({
            'rideId': rideId,
            'revieweeId': driverId,
            'revieweeName': driver?.username ?? 'Driver',
            'revieweePhotoUrl': driver?.photoUrl ?? '',
            'type': ReviewType.driver,
            'rideDate': rideData.departureTime,
            'origin': rideData.origin,
            'destination': rideData.destination,
          });
        }
      }
    }

    return pending;
  }
}
