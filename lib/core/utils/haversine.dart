import 'dart:math';

import 'package:zippy/core/domain/service_area.dart';

/// Great-circle distance in metres (same formula as the server's
/// functions/src/shared/geo.ts).
double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusMeters = 6371000.0;
  double rad(double deg) => deg * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return 2 * earthRadiusMeters * asin(sqrt(a));
}

/// The nearest active area whose radius covers `(lat, lng)`, or null.
ServiceArea? nearestServiceableArea(
  Iterable<ServiceArea> areas,
  double lat,
  double lng,
) {
  ServiceArea? nearest;
  var nearestDistance = double.infinity;
  for (final area in areas) {
    final centerLat = area.centerLat;
    final centerLng = area.centerLng;
    final radius = area.radiusMeters;
    if (!area.isActive ||
        centerLat == null ||
        centerLng == null ||
        radius == null) {
      continue;
    }
    final distance = haversineMeters(lat, lng, centerLat, centerLng);
    if (distance <= radius && distance < nearestDistance) {
      nearest = area;
      nearestDistance = distance;
    }
  }
  return nearest;
}
