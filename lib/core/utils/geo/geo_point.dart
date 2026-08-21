class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  }) : assert(latitude >= -90 && latitude <= 90, 'Latitude must be between -90 and 90'),
       assert(longitude >= -180 && longitude <= 180, 'Longitude must be between -180 and 180');

  factory GeoPoint.fromMap(Map<String, double> map) {
    return GeoPoint(
      latitude: map['latitude']!,
      longitude: map['longitude']!,
    );
  }

  final double latitude;

  final double longitude;

  Map<String, double> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint && latitude == other.latitude && longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
