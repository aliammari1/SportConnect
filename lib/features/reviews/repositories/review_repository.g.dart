// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

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

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewRepository,
          ReviewRepository,
          ReviewRepository
        >
    with $Provider<ReviewRepository> {
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
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'9398c52571ecc5d400c5f3d8371891cdd65b0b21';

/// Provider to get reviews for a specific user

@ProviderFor(userReviews)
final userReviewsProvider = UserReviewsFamily._();

/// Provider to get reviews for a specific user

final class UserReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          FutureOr<List<ReviewModel>>
        >
    with
        $FutureModifier<List<ReviewModel>>,
        $FutureProvider<List<ReviewModel>> {
  /// Provider to get reviews for a specific user
  UserReviewsProvider._({
    required UserReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userReviewsHash();

  @override
  String toString() {
    return r'userReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReviewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReviewModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userReviews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userReviewsHash() => r'66cff536143702ac5eca7dbd1fbc6189b6b4cb80';

/// Provider to get reviews for a specific user

final class UserReviewsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReviewModel>>, String> {
  UserReviewsFamily._()
    : super(
        retry: null,
        name: r'userReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get reviews for a specific user

  UserReviewsProvider call(String userId) =>
      UserReviewsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userReviewsProvider';
}

/// Provider to get reviews left by a specific user

@ProviderFor(reviewsByUser)
final reviewsByUserProvider = ReviewsByUserFamily._();

/// Provider to get reviews left by a specific user

final class ReviewsByUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          FutureOr<List<ReviewModel>>
        >
    with
        $FutureModifier<List<ReviewModel>>,
        $FutureProvider<List<ReviewModel>> {
  /// Provider to get reviews left by a specific user
  ReviewsByUserProvider._({
    required ReviewsByUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewsByUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewsByUserHash();

  @override
  String toString() {
    return r'reviewsByUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReviewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReviewModel>> create(Ref ref) {
    final argument = this.argument as String;
    return reviewsByUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewsByUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewsByUserHash() => r'908cabf0c9abb912da7b135b6f4a01737ee41cd3';

/// Provider to get reviews left by a specific user

final class ReviewsByUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReviewModel>>, String> {
  ReviewsByUserFamily._()
    : super(
        retry: null,
        name: r'reviewsByUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get reviews left by a specific user

  ReviewsByUserProvider call(String userId) =>
      ReviewsByUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'reviewsByUserProvider';
}

/// Provider to get rating stats for a user

@ProviderFor(userRatingStats)
final userRatingStatsProvider = UserRatingStatsFamily._();

/// Provider to get rating stats for a user

final class UserRatingStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RatingStats>,
          RatingStats,
          FutureOr<RatingStats>
        >
    with $FutureModifier<RatingStats>, $FutureProvider<RatingStats> {
  /// Provider to get rating stats for a user
  UserRatingStatsProvider._({
    required UserRatingStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRatingStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRatingStatsHash();

  @override
  String toString() {
    return r'userRatingStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RatingStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RatingStats> create(Ref ref) {
    final argument = this.argument as String;
    return userRatingStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRatingStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRatingStatsHash() => r'da339c1003ced61a09016fc70cc22a2e9204f712';

/// Provider to get rating stats for a user

final class UserRatingStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RatingStats>, String> {
  UserRatingStatsFamily._()
    : super(
        retry: null,
        name: r'userRatingStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to get rating stats for a user

  UserRatingStatsProvider call(String userId) =>
      UserRatingStatsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userRatingStatsProvider';
}

/// Stream provider for real-time review updates for a user

@ProviderFor(userReviewsStream)
final userReviewsStreamProvider = UserReviewsStreamFamily._();

/// Stream provider for real-time review updates for a user

final class UserReviewsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          Stream<List<ReviewModel>>
        >
    with
        $FutureModifier<List<ReviewModel>>,
        $StreamProvider<List<ReviewModel>> {
  /// Stream provider for real-time review updates for a user
  UserReviewsStreamProvider._({
    required UserReviewsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userReviewsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userReviewsStreamHash();

  @override
  String toString() {
    return r'userReviewsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReviewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReviewModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userReviewsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserReviewsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userReviewsStreamHash() => r'dcb31a793e84c7bb9a9eed48be3f158008086d20';

/// Stream provider for real-time review updates for a user

final class UserReviewsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReviewModel>>, String> {
  UserReviewsStreamFamily._()
    : super(
        retry: null,
        name: r'userReviewsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for real-time review updates for a user

  UserReviewsStreamProvider call(String userId) =>
      UserReviewsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'userReviewsStreamProvider';
}
