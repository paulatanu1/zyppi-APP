import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/coupon.dart';

void main() {
  group('Coupon.discountFor', () {
    test('flat: nothing below the minimum, never more than the items', () {
      final c = Coupon(
        code: 'ZYPPI50',
        description: '',
        discountPaise: 5000,
        minOrderPaise: 30000,
      );
      expect(c.discountFor(29999), 0);
      expect(c.discountFor(30000), 5000);
      expect(
        Coupon(
          code: 'X',
          description: '',
          discountPaise: 9000,
        ).discountFor(6400),
        6400,
      );
    });

    test('percent rounds down to the paisa, like the server', () {
      final c = Coupon(
        code: 'P15',
        description: '',
        type: CouponType.percent,
        percent: 15,
      );
      expect(c.discountFor(12345), 1851);
    });

    test('percent stops at its cap', () {
      final c = Coupon(
        code: 'P20',
        description: '',
        type: CouponType.percent,
        percent: 20,
        maxDiscountPaise: 10000,
      );
      expect(c.discountFor(40000), 8000);
      expect(c.discountFor(80000), 10000);
    });
  });

  test('server reasons map to their own messages', () {
    expect(CouponProblem.fromWire('user_limit').messageKey, 'couponUserLimit');
    expect(
      CouponProblem.fromWire('first_order').messageKey,
      'couponFirstOrderOnly',
    );
    expect(CouponProblem.fromWire('area').messageKey, 'couponNotInArea');
    expect(CouponProblem.fromWire('used_up').messageKey, 'couponUsedUp');
    expect(CouponProblem.fromWire('expired').messageKey, 'couponExpired');
    expect(CouponProblem.fromWire('nonsense'), CouponProblem.invalid);
  });
}
