import 'dart:math';

class GeoMath {
  static const double earthRadius = 6371000;

  static const double earthRadiusEquatorial = 6378137;

  static const double earthRadiusPolar = 6356752;

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  static double normalizeDegrees(double degrees) {
    degrees = degrees % 360;
    if (degrees < 0) degrees += 360;
    return degrees;
  }

  static double normalizeLongitude(double longitude) {
    longitude = normalizeDegrees(longitude);
    if (longitude > 180) longitude -= 360;
    return longitude;
  }

  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = degreesToRadians(lat2 - lat1);
    final dLon = degreesToRadians(lon2 - lon1);

    final lat1Rad = degreesToRadians(lat1);
    final lat2Rad = degreesToRadians(lat2);

    final a = pow(sin(dLat / 2), 2) + cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double planarDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert to meters (approximate)
    final latDiff = (lat2 - lat1) * 111320; // meters per degree latitude
    final lonDiff =
        (lon2 - lon1) * 111320 * cos(degreesToRadians((lat1 + lat2) / 2)); // adjust for latitude

    return sqrt(latDiff * latDiff + lonDiff * lonDiff);
  }

  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = degreesToRadians(lat1);
    final lat2Rad = degreesToRadians(lat2);
    final dLon = degreesToRadians(lon2 - lon1);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = radiansToDegrees(atan2(y, x));

    return normalizeDegrees(bearing);
  }

  static Map<String, double> calculateDestination({
    required double lat,
    required double lon,
    required double bearing,
    required double distance,
  }) {
    final latRad = degreesToRadians(lat);
    final lonRad = degreesToRadians(lon);
    final bearingRad = degreesToRadians(bearing);

    final angularDistance = distance / earthRadius;

    final lat2Rad = asin(
      sin(latRad) * cos(angularDistance) + cos(latRad) * sin(angularDistance) * cos(bearingRad),
    );

    final lon2Rad =
        lonRad +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(latRad),
          cos(angularDistance) - sin(latRad) * sin(lat2Rad),
        );

    return {
      'latitude': radiansToDegrees(lat2Rad),
      'longitude': radiansToDegrees(lon2Rad),
    };
  }

  static Map<String, double> calculateMidpoint(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = degreesToRadians(lat1);
    final lon1Rad = degreesToRadians(lon1);
    final lat2Rad = degreesToRadians(lat2);
    final dLon = degreesToRadians(lon2 - lon1);

    final bx = cos(lat2Rad) * cos(dLon);
    final by = cos(lat2Rad) * sin(dLon);

    final latMidRad = atan2(
      sin(lat1Rad) + sin(lat2Rad),
      sqrt((cos(lat1Rad) + bx) * (cos(lat1Rad) + bx) + by * by),
    );

    final lonMidRad = lon1Rad + atan2(by, cos(lat1Rad) + bx);

    return {
      'latitude': radiansToDegrees(latMidRad),
      'longitude': radiansToDegrees(lonMidRad),
    };
  }
}
