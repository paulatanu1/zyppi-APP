import 'package:zippy/core/cart/domain/bill_breakdown.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/domain/coupon.dart';
import 'package:zippy/core/domain/delivery_config.dart';

/// Pure bill math (PLAN.md: "Unit tests for bill math") — no I/O, so it
/// can be tested without a Hive box or mock repository.
class BillCalculator {
  BillCalculator._();

  static const handlingFeePaise = 500; // ₹5, matches docs/mockups/Cart.dc.html

  static BillBreakdown calculate({
    required List<CartLine> lines,
    int tipPaise = 0,
    Coupon? coupon,
    DeliveryConfig delivery = DeliveryConfig.free,
  }) {
    if (lines.isEmpty) return BillBreakdown.zero;

    final itemTotalPaise = lines.fold<int>(
      0,
      (sum, line) => sum + line.lineTotalPaise,
    );
    final mrpTotalPaise = lines.fold<int>(
      0,
      (sum, line) => sum + line.lineMrpPaise,
    );
    final savingsPaise = mrpTotalPaise - itemTotalPaise;

    var discountPaise = 0;
    if (coupon != null && itemTotalPaise >= (coupon.minOrderPaise ?? 0)) {
      discountPaise = coupon.discountPaise.clamp(0, itemTotalPaise);
    }

    // Same rule as quoteOrder: fee below the free-delivery threshold.
    final deliveryFeePaise = delivery.feeFor(itemTotalPaise);

    final totalPaise =
        itemTotalPaise +
        deliveryFeePaise +
        handlingFeePaise +
        tipPaise -
        discountPaise;

    return BillBreakdown(
      itemTotalPaise: itemTotalPaise,
      savingsPaise: savingsPaise,
      deliveryFeePaise: deliveryFeePaise,
      handlingFeePaise: handlingFeePaise,
      tipPaise: tipPaise,
      discountPaise: discountPaise,
      totalPaise: totalPaise,
    );
  }
}
