import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/service_area_repository.dart';
import 'package:zippy/core/domain/service_area.dart';
import 'package:zippy/core/utils/haversine.dart';

class MockServiceAreaRepository implements ServiceAreaRepository {
  @override
  Future<ServiceArea?> findServiceableArea(double lat, double lng) async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/service_areas.json',
    );
    final areas = json.map(
      (e) => ServiceArea.fromJson(e as Map<String, dynamic>),
    );

    return nearestServiceableArea(areas, lat, lng);
  }
}
