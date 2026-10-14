import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/cart/domain/bill_breakdown.dart';
import 'package:zippy/core/cart/domain/bill_calculator.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

Product _product({required String id, required String name}) => Product(
  id: id,
  name: name,
  image: 'assets/images/item.png',
  categoryId: 'cat-1',
  variants: const [],
);

CartLine _line({
  required int pricePaise,
  int? mrpPaise,
  required int quantity,
}) {
  final variant = ProductVariant(
    id: 'variant-1',
    label: '1 kg',
    pricePaise: pricePaise,
    mrpPaise: mrpPaise,
  );

  return CartLine(
    product: _product(id: 'prod-1', name: 'Test product'),
    variant: variant,
    quantity: quantity,
  );
}

void main() {
  group('BillCalculator.calculate', () {
    test('returns zero breakdown for an empty cart', () {
      final bill = BillCalculator.calculate(lines: const []);

      expect(bill, BillBreakdown.zero);
    });

    test('sums item total across lines and quantities', () {
      final bill = BillCalculator.calculate(
        lines: [
          _line(pricePaise: 10000, quantity: 2), // 20000
          _line(pricePaise: 5000, quantity: 1), // 5000
        ],
      );

      expect(bill.itemTotalPaise, 25000);
    });

    test('computes savings from MRP vs price', () {
      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 8000, mrpPaise: 10000, quantity: 3)],
      );

      // itemTotal = 24000, mrpTotal = 30000 -> savings 6000
      expect(bill.itemTotalPaise, 24000);
      expect(bill.savingsPaise, 6000);
    });

    test('adds the flat handling fee and free delivery', () {
      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 10000, quantity: 1)],
      );

      expect(bill.deliveryFeePaise, BillCalculator.freeDeliveryPaise);
      expect(bill.handlingFeePaise, BillCalculator.handlingFeePaise);
      expect(
        bill.totalPaise,
        10000 +
            BillCalculator.freeDeliveryPaise +
            BillCalculator.handlingFeePaise,
      );
    });

    test('adds tip to the total', () {
      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 10000, quantity: 1)],
        tipPaise: 2000,
      );

      expect(bill.tipPaise, 2000);
      expect(bill.totalPaise, 10000 + BillCalculator.handlingFeePaise + 2000);
    });

    test('applies a coupon discount when the minimum order is met', () {
      final coupon = Coupon(
        code: 'ZYPPI50',
        description: 'Flat 50 off',
        discountPaise: 5000,
        minOrderPaise: 20000,
      );

      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 25000, quantity: 1)],
        coupon: coupon,
      );

      expect(bill.discountPaise, 5000);
      expect(bill.totalPaise, 25000 + BillCalculator.handlingFeePaise - 5000);
    });

    test('ignores a coupon when the order is below its minimum', () {
      final coupon = Coupon(
        code: 'ZYPPI50',
        description: 'Flat 50 off',
        discountPaise: 5000,
        minOrderPaise: 50000,
      );

      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 10000, quantity: 1)],
        coupon: coupon,
      );

      expect(bill.discountPaise, 0);
    });

    test('never discounts more than the item total', () {
      final coupon = Coupon(
        code: 'BIG',
        description: 'Huge off',
        discountPaise: 100000,
        minOrderPaise: 0,
      );

      final bill = BillCalculator.calculate(
        lines: [_line(pricePaise: 5000, quantity: 1)],
        coupon: coupon,
      );

      expect(bill.discountPaise, 5000);
    });
  });
}
