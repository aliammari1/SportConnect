import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/repositories/review_repository.dart';

part 'review_view_model.g.dart';

/// State for the review submission form
class ReviewFormState {
  const ReviewFormState({
    this.rating = 0,
    this.comment = '',
    this.selectedTags = const [],
    this.isSubmitting = false,
    this.error,
  });
  final int rating;
  final String comment;
  final List<ReviewTag> selectedTags;
  final bool isSubmitting;
  final String? error;

  ReviewFormState copyWith({
    int? rating,
    String? comment,
    List<ReviewTag>? selectedTags,
    bool? isSubmitting,
    String? error,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      selectedTags: selectedTags ?? this.selectedTags,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  bool get isValid => rating > 0 && rating <= 5;
}

/// Sentinel used by [ReviewsListState.copyWith] to distinguish "argument
/// omitted" (preserve current value) from "explicitly passed null" (clear).
const Object _sentinel = Object();

/// State for the reviews list screen
class ReviewsListState {
  const ReviewsListState({
    this.reviews = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.filterType,
    this.hasMore = true,
    this.nextCursor,
  });
  final List<ReviewModel> reviews;
  final RatingStats? stats;
  final bool isLoading;
  final String? error;
  final ReviewType? filterType;
  final bool hasMore;
  // DocumentSnapshot cursor for Firestore cursor-based pagination
  final DocumentSnapshot? nextCursor;

  ReviewsListState copyWith({
    List<ReviewModel>? reviews,
    RatingStats? stats,
    bool? isLoading,
    Object? error = _sentinel,
    Object? filterType = _sentinel,
    bool? hasMore,
    DocumentSnapshot? nextCursor,
    bool clearCursor = false,
  }) {
    return ReviewsListState(
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      // Use a sentinel so callers can preserve the existing value (omit the
      // arg) or explicitly clear it by passing null. Previously these were
      // reset to null on every copyWith, silently wiping the active filter
      // (e.g. during loadMore) and the error.
      error: error == _sentinel ? this.error : error as String?,
      filterType: filterType == _sentinel
          ? this.filterType
          : filterType as ReviewType?,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    );
  }

  /// Filter reviews by type if filter is set
  List<ReviewModel> get filteredReviews {
    final visible = reviews.where((r) => r.isVisible);
    if (filterType == null) return visible.toList();
    return visible.where((r) => r.type == filterType).toList();
  }

  /// Get average rating
  double get averageRating => stats?.averageRating ?? 0.0;

  /// Get total review count
  int get totalReviews => stats?.totalReviews ?? reviews.length;
}

/// ViewModel for submitting reviews
@riverpod
class ReviewFormViewModel extends _$ReviewFormViewModel {
  @override
  ReviewFormState build() => const ReviewFormState();

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  void toggleTag(ReviewTag tag) {
    final tags = List<ReviewTag>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  void clearTags() {
    state = state.copyWith(selectedTags: []);
  }

  /// Submit a review for a ride
  Future<bool> submitReview({
    required String rideId,
    required String revieweeId,
    required String revieweeName,
    required ReviewType type,
    String? revieweePhotoUrl,
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please provide a rating');
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: 'You must be logged in to submit a review',
        );
        return false;
      }

      final repo = ref.read(reviewRepositoryProvider);

      // Convert ReviewTag enums to string names
      final tagStrings = state.selectedTags.map((tag) => tag.name).toList();

      await repo.createReview(
        currentUser.uid,
        CreateReviewRequest(
          rideId: rideId,
          revieweeId: revieweeId,
          revieweeName: revieweeName,
          revieweePhotoUrl: revieweePhotoUrl,
          type: type,
          rating: state.rating.toDouble(),
          comment: state.comment.isEmpty ? null : state.comment,
          tags: tagStrings,
        ),
      );

      // Invalidate the reviewee's review/rating providers so any screen
      // currently showing their reviews or aggregate rating refetches the
      // newly-written data. createReview atomically writes both the review doc
      // and the reviewee's star-bucket aggregate, but these are one-shot
      // Future providers that otherwise serve stale cached values until a
      // manual refresh/restart.
      if (ref.mounted) {
        invalidateRevieweeProviders(ref, revieweeId: revieweeId, rideId: rideId);
      }

      // Award XP for submitting a review
      if (!ref.mounted) return true;
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.addXP(currentUser.uid, 15);
      } on Exception {
        // XP failure is non-fatal
      }

      if (!ref.mounted) return true;
      // Reset form after successful submission
      state = const ReviewFormState();
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit review: $e',
      );
      return false;
    } finally {
      // Ensure isSubmitting is always reset if the state was not already updated
      if (ref.mounted && state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }
}

/// ViewModel for viewing reviews list
@riverpod
class ReviewsListViewModel extends _$ReviewsListViewModel {
  @override
  Future<ReviewsListState> build(String userId) async {
    return _loadReviews();
  }

  static const _pageSize = 20;

  Future<ReviewsListState> _loadReviews() async {
    try {
      final repo = ref.read(reviewRepositoryProvider);
      final (:reviews, :nextCursor) = await repo.getReviewsForUser(
        userId,
        limit: _pageSize,
      );
      final stats = await repo.getRatingStatsForUser(userId);

      return ReviewsListState(
        reviews: reviews,
        stats: stats,
        hasMore: nextCursor != null,
        nextCursor: nextCursor,
      );
    } on Exception catch (e) {
      return ReviewsListState(
        error: 'Failed to load reviews: $e',
      );
    }
  }

  void setFilterType(ReviewType? type) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(filterType: type));
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final reviews = await _loadReviews();
    if (!ref.mounted) return;
    state = AsyncValue.data(reviews);
  }

  /// Load next page of reviews using DocumentSnapshot cursor-based pagination.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoading) return;

    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final repo = ref.read(reviewRepositoryProvider);
      final (:reviews, :nextCursor) = await repo.getReviewsForUser(
        userId,
        limit: _pageSize,
        startAfterDoc: current.nextCursor,
      );

      if (!ref.mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          reviews: [...current.reviews, ...reviews],
          isLoading: false,
          hasMore: nextCursor != null,
          nextCursor: nextCursor,
        ),
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          isLoading: false,
          error: 'Failed to load more: $e',
        ),
      );
    }
  }
}

/// ViewModel for responding to a review
@riverpod
class ReviewResponseViewModel extends _$ReviewResponseViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> submitResponse(String reviewId, String response) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return false;
      }

      final repo = ref.read(reviewRepositoryProvider);
      await repo.respondToReview(currentUser.uid, reviewId, response);

      if (!ref.mounted) return true;
      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// VM-layer provider to get reviews for a specific ride
@riverpod
Future<List<ReviewModel>> rideReviews(Ref ref, String rideId) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getReviewsForRide(rideId);
}

/// Provider exposing the rides [userId] participated in (and completed) but has
/// not yet reviewed the counterpart for. Each entry is a map with rideId,
/// revieweeId, revieweeName, revieweePhotoUrl, type, rideDate, origin and
/// destination keys (see [ReviewRepository.getPendingReviews]). Surfaces a
/// "reviews you owe" list so the review flow is discoverable outside the
/// post-completion prompt.
@riverpod
Future<List<Map<String, dynamic>>> pendingReviews(Ref ref, String userId) {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getPendingReviews(userId);
}

/// Invalidate every cached provider that reflects [revieweeId]'s reviews or
/// aggregate rating after a review for them is created or deleted.
///
/// Reviews owns the wiring contract for keeping the cross-feature rating in
/// sync, so both review entry points (passenger->driver via
/// [ReviewFormViewModel] and driver->passenger flows) must route through this
/// helper. createReview/deleteReview write the review doc and the reviewee's
/// star-bucket aggregate atomically, but the consuming providers are one-shot
/// Futures (notably [userProfileProvider], which has a 5-minute keepAlive
/// cache) and would otherwise serve stale data until a manual refresh.
void invalidateRevieweeProviders(
  Ref ref, {
  required String revieweeId,
  String? rideId,
}) {
  ref.invalidate(reviewsListViewModelProvider(revieweeId));
  ref.invalidate(userReviewsProvider(revieweeId));
  ref.invalidate(userRatingStatsProvider(revieweeId));
  if (rideId != null) {
    ref.invalidate(rideReviewsProvider(rideId));
  }
  // userProfile feeds the cross-feature asDriver/asRider.rating.average shown
  // in profile, my_rides and driver_requests screens.
  ref.invalidate(userProfileProvider(revieweeId));
}
