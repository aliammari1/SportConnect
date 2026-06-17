import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Review type - whether it's for a driver or rider
enum ReviewType {
  @JsonValue('driver')
  driver, // Review left for a driver
  @JsonValue('rider')
  rider; // Review left for a rider/passenger

  String get displayName {
    switch (this) {
      case ReviewType.driver:
        return 'Driver Review';
      case ReviewType.rider:
        return 'Passenger Review';
    }
  }
}

/// Predefined review tags for quick feedback
enum ReviewTag {
  @JsonValue('punctual')
  punctual('Punctual', '⏰', ReviewType.driver),
  @JsonValue('great_conversation')
  greatConversation('Great Conversation', '💬', ReviewType.driver),
  @JsonValue('clean_car')
  cleanCar('Clean Car', '✨', ReviewType.driver),
  @JsonValue('safe_driver')
  safeDriver('Safe Driver', '🛡️', ReviewType.driver),
  @JsonValue('comfortable_ride')
  comfortableRide('Comfortable Ride', '🛋️', ReviewType.driver),
  @JsonValue('good_music')
  goodMusic('Good Music', '🎵', ReviewType.driver),
  @JsonValue('friendly')
  friendly('Friendly', '😊', ReviewType.driver),
  @JsonValue('professional')
  professional('Professional', '👔', ReviewType.driver),
  @JsonValue('flexible')
  flexible('Flexible', '🤝', ReviewType.driver),
  @JsonValue('respectful_rider')
  respectfulRider('Respectful', '🙏', ReviewType.rider),
  @JsonValue('on_time_rider')
  onTimeRider('On Time', '⏰', ReviewType.rider),
  @JsonValue('polite')
  polite('Polite', '😊', ReviewType.rider),
  @JsonValue('easy_communication')
  easyCommunication('Easy Communication', '💬', ReviewType.rider);

  final String label;
  final String emoji;
  final ReviewType applicableTo;

  const ReviewTag(this.label, this.emoji, this.applicableTo);

  static List<ReviewTag> getTagsFor(ReviewType type) {
    return ReviewTag.values.where((tag) => tag.applicableTo == type).toList();
  }
}

/// Review model - stored in /reviews collection
/// Firestore structure:
/// /reviews/{reviewId}
///   - id: string
///   - rideId: string (reference to the ride)
///   - reviewerId: string (who wrote the review)
///   - revieweeId: string (who is being reviewed)
///   - type: ReviewType (driver or rider)
///   - rating: double (1-5)
///   - comment: string?
///   - tags: List<ReviewTag>
///   - isVisible: bool
///   - response: string? (optional response from reviewee)
///   - createdAt: timestamp
///   - updatedAt: timestamp
@freezed
abstract class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    required String rideId,
    required String reviewerId,
    required String reviewerName,
    required String revieweeId,
    required String revieweeName,
    required ReviewType type,
    required double rating,
    @RequiredTimestampConverter() required DateTime createdAt,
    String? reviewerPhotoUrl,
    String? revieweePhotoUrl,
    String? comment,
    @Default([])
    List<String> tags, // Store as strings for Firestore compatibility
    @Default(true) bool isVisible,
    String? response, // Response from the person being reviewed
    @TimestampConverter() DateTime? responseAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ReviewModel;
  const ReviewModel._();

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  /// Get the display tags as ReviewTag enums
  List<ReviewTag> get reviewTags {
    return tags
        .map((t) {
          try {
            return ReviewTag.values.firstWhere((tag) => tag.name == t);
          } on Exception {
            return null;
          }
        })
        .whereType<ReviewTag>()
        .toList();
  }

  /// Get formatted rating (e.g., "4.5")
  String get formattedRating => rating.toStringAsFixed(1);

  /// Check if review has a response
  bool get hasResponse => response != null && response!.isNotEmpty;

  /// Check if review has a non-empty comment
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Rating expressed as an integer star count (1-5)
  int get starRating => rating.round().clamp(1, 5);

  /// Whether the review reflects positive sentiment (4-5 stars)
  bool get isPositive => rating >= 4.0;

  /// Whether the review reflects negative sentiment (1-2 stars)
  bool get isNegative => rating <= 2.0;

  /// Whether this review was written by the given user
  bool isWrittenBy(String userId) => reviewerId == userId;

  /// Whether this review is about the given user
  bool isAbout(String userId) => revieweeId == userId;

  /// Whether the review has been edited after creation
  bool get isEdited => updatedAt != null && updatedAt!.isAfter(createdAt);

  /// Get time since review was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Aggregated rating stats - stored as a subcollection or embedded in user document
/// This is computed and cached for performance
@freezed
abstract class RatingStats with _$RatingStats {
  const factory RatingStats({
    @Default(0) int totalReviews,
    @Default(0.0) double averageRating,
    @Default(0) int fiveStarCount,
    @Default(0) int fourStarCount,
    @Default(0) int threeStarCount,
    @Default(0) int twoStarCount,
    @Default(0) int oneStarCount,
    @Default({}) Map<String, int> tagCounts, // Tag -> count
    @TimestampConverter() DateTime? lastReviewAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _RatingStats;

  /// Create stats from a list of reviews
  factory RatingStats.fromReviews(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const RatingStats();
    }

    var fiveStar = 0;
    var fourStar = 0;
    var threeStar = 0;
    var twoStar = 0;
    var oneStar = 0;
    double totalRating = 0;
    final tagCounts = <String, int>{};

    for (final review in reviews) {
      totalRating += review.rating;

      // Count stars
      final rounded = review.rating.round();
      switch (rounded) {
        case 5:
          fiveStar++;
        case 4:
          fourStar++;
        case 3:
          threeStar++;
        case 2:
          twoStar++;
        case 1:
          oneStar++;
      }

      // Count tags
      for (final tag in review.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Sort reviews by date to get latest
    final sortedReviews = List<ReviewModel>.from(reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RatingStats(
      totalReviews: reviews.length,
      averageRating: totalRating / reviews.length,
      fiveStarCount: fiveStar,
      fourStarCount: fourStar,
      threeStarCount: threeStar,
      twoStarCount: twoStar,
      oneStarCount: oneStar,
      tagCounts: tagCounts,
      lastReviewAt: sortedReviews.first.createdAt,
    );
  }
  const RatingStats._();

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  /// Get the distribution percentages
  Map<int, double> get distribution {
    if (totalReviews == 0) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
    return {
      5: (fiveStarCount / totalReviews) * 100,
      4: (fourStarCount / totalReviews) * 100,
      3: (threeStarCount / totalReviews) * 100,
      2: (twoStarCount / totalReviews) * 100,
      1: (oneStarCount / totalReviews) * 100,
    };
  }

  /// Get top tags (most used)
  List<MapEntry<String, int>> get topTags {
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Get formatted average (e.g., "4.5")
  String get formattedAverage => averageRating.toStringAsFixed(1);

  /// Whether there is at least one review
  bool get hasReviews => totalReviews > 0;

  /// Indexed accessor for the per-star count (stars in 1..5)
  int starCount(int stars) {
    switch (stars) {
      case 5:
        return fiveStarCount;
      case 4:
        return fourStarCount;
      case 3:
        return threeStarCount;
      case 2:
        return twoStarCount;
      case 1:
        return oneStarCount;
      default:
        return 0;
    }
  }

  /// Number of positive (4-5 star) reviews
  int get positiveReviewCount => fiveStarCount + fourStarCount;

  /// Percentage of reviews that are positive (4-5 stars)
  double get positivePercentage =>
      totalReviews == 0 ? 0 : (positiveReviewCount / totalReviews) * 100;

  /// Human-readable qualitative band for the average rating
  String get ratingLabel {
    if (totalReviews == 0) return 'No ratings';
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very good';
    if (averageRating >= 3.0) return 'Good';
    if (averageRating >= 2.0) return 'Fair';
    return 'Poor';
  }
}

/// Review request - used when creating a new review
@freezed
abstract class CreateReviewRequest with _$CreateReviewRequest {
  const factory CreateReviewRequest({
    required String rideId,
    required String revieweeId,
    required String revieweeName,
    required ReviewType type,
    required double rating,
    String? revieweePhotoUrl,
    String? comment,
    @Default([]) List<String> tags,
  }) = _CreateReviewRequest;
  const CreateReviewRequest._();

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);

  /// Whether this request satisfies the submit-time validation rules
  bool get isValid =>
      rating >= 1.0 &&
      rating <= 5.0 &&
      revieweeId.isNotEmpty &&
      rideId.isNotEmpty;

  /// Whether the request includes a non-empty comment
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;
}
