import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'ride_review_model.freezed.dart';
part 'ride_review_model.g.dart';

/// Review model
@freezed
abstract class RideReviewModel with _$RideReviewModel {
  const factory RideReviewModel({
    required String id,
    required String reviewerId,
    required String reviewerName,
    required String revieweeId,
    required double rating,
    String? reviewerPhotoUrl,
    String? comment,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
  }) = _RideReviewModel;
  const RideReviewModel._();

  factory RideReviewModel.fromJson(Map<String, dynamic> json) =>
      _$RideReviewModelFromJson(json);

  /// Whether the reviewer left written feedback.
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Whether the reviewer attached a profile photo.
  bool get hasReviewerPhoto =>
      reviewerPhotoUrl != null && reviewerPhotoUrl!.trim().isNotEmpty;

  /// A 4-or-5 star review.
  bool get isPositive => rating >= 4.0;
}
