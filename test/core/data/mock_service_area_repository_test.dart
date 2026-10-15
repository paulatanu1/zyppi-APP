import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/mock_service_area_repository_impl.dart';

void main() {
  late MockServiceAreaRepository repository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = MockServiceAreaRepository();
  });

  test('finds the launch town a point sits inside', () async {
    // Purulia's seeded center, from assets/mock/service_areas.json.
    final area = await repository.findServiceableArea(23.3324, 86.3617);

    expect(area, isNotNull);
    expect(area!.name, 'Purulia');
  });

  test('returns null for a point outside every launch town radius', () async {
    // Kolkata - nowhere near Purulia/Raghunathpur/Chelyama.
    final area = await repository.findServiceableArea(22.5726, 88.3639);

    expect(area, isNull);
  });

  test('picks the nearest area when radii could plausibly overlap', () async {
    // A hair off Raghunathpur's own seeded center.
    final area = await repository.findServiceableArea(23.567, 86.667);

    expect(area?.name, 'Raghunathpur');
  });
}
