import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'ride_search_filters.freezed.dart';
part 'ride_search_filters.g.dart';

/// Supported ride sort keys.
///
/// Backed by the existing [RideSearchFilters.sortBy] string so persisted
/// values stay stable; use [RideSortBy.fromKey] / [RideSortBy.key] to convert.
enum RideSortBy {
  departureTime('departure_time'),
  price('price'),
  driverRating('driver_rating'),
  distance('distance');

  const RideSortBy(this.key);

  /// The string value stored in [RideSearchFilters.sortBy].
  final String key;

  /// Parse a stored key, falling back to [departureTime] for unknown values.
  static RideSortBy fromKey(String key) => RideSortBy.values.firstWhere(
        (e) => e.key == key,
        orElse: () => RideSortBy.departureTime,
      );
}

/// Ride search filters
@freezed
abstract class RideSearchFilters with _$RideSearchFilters {
  const factory RideSearchFilters({
    LocationPoint? origin,
    LocationPoint? destination,
    @TimestampConverter() DateTime? departureDate,
    @TimestampConverter() DateTime? departureTimeFrom,
    @TimestampConverter() DateTime? departureTimeTo,
    @Default(1) int minSeats,
    int? maxPrice,
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(false) bool womenOnly,
    double? minDriverRating,
    @Default('departure_time') String sortBy,
    @Default(true) bool sortAscending,
  }) = _RideSearchFilters;
  const RideSearchFilters._();

  factory RideSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$RideSearchFiltersFromJson(json);

  /// Strongly-typed view over the [sortBy] string.
  RideSortBy get sort => RideSortBy.fromKey(sortBy);

  /// Whether the user has narrowed the search beyond the defaults.
  bool get hasActiveFilters =>
      origin != null ||
      destination != null ||
      departureDate != null ||
      departureTimeFrom != null ||
      departureTimeTo != null ||
      minSeats > 1 ||
      maxPrice != null ||
      allowPets ||
      allowSmoking ||
      womenOnly ||
      minDriverRating != null;
}
