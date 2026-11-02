import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/service_area.dart';
import 'package:zippy/core/utils/haversine.dart';

void main() {
  final purulia = ServiceArea(
    id: 'purulia',
    name: 'Purulia',
    centerLat: 23.3324,
    centerLng: 86.3617,
    radiusMeters: 6000,
  );
  final raghunathpur = ServiceArea(
    id: 'raghunathpur',
    name: 'Raghunathpur',
    centerLat: 23.5667,
    centerLng: 86.6667,
    radiusMeters: 5000,
  );

  test('distance between a point and itself is zero', () {
    expect(haversineMeters(23.3, 86.3, 23.3, 86.3), closeTo(0, 0.001));
  });

  test('one degree of latitude is about 111 km', () {
    expect(haversineMeters(23, 86, 24, 86), closeTo(111195, 100));
  });

  test('finds the area covering the point', () {
    final area = nearestServiceableArea([raghunathpur, purulia], 23.34, 86.37);
    expect(area?.id, 'purulia');
  });

  test('ignores inactive areas and points outside every radius', () {
    expect(
      nearestServiceableArea([purulia.copyWith(isActive: false)], 23.34, 86.37),
      isNull,
    );
    expect(nearestServiceableArea([purulia], 22.57, 88.36), isNull);
  });
}
