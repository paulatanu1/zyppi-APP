import 'dart:math';

import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/service_area_repository.dart';
import 'package:zippy/core/domain/service_area.dart';

class MockServiceAreaRepository implements ServiceAreaRepository {
  @override
  Future<ServiceArea?> findServiceableArea(double lat, double lng) async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/service_areas.json',
    );
    final areas = json
        .map((e) => ServiceArea.fromJson(e as Map<String, dynamic>))
        .where((area) => area.isActive && area.centerLat != null)
        .toList();

    ServiceArea? nearest;
    var nearestDistance = double.infinity;

    for (final area in areas) {
      final distance = _haversineMeters(
        lat,
        lng,
        area.centerLat!,
        area.centerLng!,
      );
      if (distance <= area.radiusMeters! && distance < nearestDistance) {
        nearest = area;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  static double _haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    return 2 * earthRadiusMeters * asin(sqrt(a));
  }

  static double _degToRad(double deg) => deg * pi / 180;
}
