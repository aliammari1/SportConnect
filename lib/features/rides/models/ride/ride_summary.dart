import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

part 'ride_summary.freezed.dart';
part 'ride_summary.g.dart';

/// Lightweight ride summary for list views
/// Avoids loading full nested data
@freezed
abstract class RideSummary with _$RideSummary {
  const factory RideSummary({
    required String id,
    required String driverId,
    required String originAddress,
    required String destinationAddress,
    @RequiredTimestampConverter() required DateTime departureTime,
    required String formattedPrice,
    required int seatsAvailable,
    required bool isBookable,
  }) = _RideSummary;

  factory RideSummary.fromJson(Map<String, dynamic> json) =>
      _$RideSummaryFromJson(json);
}

/// Detailed ride state for detail view
/// Aggregates data from multiple sources.
///
/// This is transient view-state (holds [isLoading]/[errorMessage] and runtime
/// aggregates), not a persistable model, so JSON serialization is disabled.
@Freezed(toJson: false, fromJson: false)
abstract class RideDetailState with _$RideDetailState {
  const factory RideDetailState({
    required String id,
    String? driverId,
    LocationPoint? origin,
    LocationPoint? destination,
    DateTime? departureTime,
    String? formattedPrice,
    int? seatsAvailable,
    @Default([]) List<RideBooking> activeBookings,
    @Default(0) int pendingRequestsCount,
    @Default(false) bool canBook,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RideDetailState;
}
