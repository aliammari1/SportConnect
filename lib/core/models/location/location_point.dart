import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'location_point.freezed.dart';
part 'location_point.g.dart';

/// Unified location model used across all features
/// Replaces scattered LatLng and LocationPoint usage
@freezed
abstract class LocationPoint with _$LocationPoint {
  const factory LocationPoint({
    required double latitude,
    required double longitude,
    required String address,
    String? city,
    String? country,
    String? placeId,
  }) = _LocationPoint;

  /// Create from LatLng
  factory LocationPoint.fromLatLng(
    LatLng latLng,
    String address, {
    String? city,
    String? country,
    String? placeId,
  }) {
    return LocationPoint(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      address: address,
      city: city,
      country: country,
      placeId: placeId,
    );
  }
  const LocationPoint._();

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);

  /// Convert to LatLng for map libraries
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Calculate distance to another point in kilometers
  double distanceTo(LocationPoint other) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, toLatLng(), other.toLatLng());
  }

  /// Check if within radius (km)
  bool isWithinRadius(LocationPoint other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  /// Get short display string
  String get shortDisplay => city ?? address.split(',').first;

  /// "lat, lng" string with fixed precision, for compact coordinate display.
  String get coordinatesString =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Address suitable for display, falling back to [coordinatesString] when no
  /// address text is available.
  String get displayAddress =>
      address.trim().isNotEmpty ? address : coordinatesString;

  /// Whether this point is backed by a known place identifier.
  bool get hasPlaceId => placeId != null && placeId!.isNotEmpty;
}
