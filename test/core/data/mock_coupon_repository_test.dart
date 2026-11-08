import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/coupon_repository_impl.dart';

void main() {
  late MockCouponRepository repository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = MockCouponRepository();
  });

  test('finds a coupon regardless of case and surrounding spaces', () async {
    // ZYPPI50, from assets/mock/coupons.json.
    final coupon = await repository.findByCode('  zyppi50 ');

    expect(coupon, isNotNull);
    expect(coupon!.discountPaise, 5000);
    expect(coupon.minOrderPaise, 30000);
  });

  test('returns null for an unknown code', () async {
    expect(await repository.findByCode('NOPE'), isNull);
  });
}
