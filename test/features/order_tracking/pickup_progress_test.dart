import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/features/order_tracking/data/delivery_info_repository.dart';

void main() {
  test('single-store orders show nothing', () {
    expect(PickupProgress.tryFrom(null), isNull);
    expect(PickupProgress.tryFrom({'s1': {}}), isNull);
  });

  test('counts the stores already picked up', () {
    final p = PickupProgress.tryFrom({
      's1': {'pickedAt': 1},
      's2': {'pickedAt': null},
      's3': {},
    })!;
    expect(p.total, 3);
    expect(p.picked, 1);
  });
}
