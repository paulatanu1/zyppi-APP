import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/cart/domain/bill_breakdown.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// Matches docs/mockups/Cart.dc.html's "Bill details" section.
class BillDetails extends StatelessWidget {
  final BillBreakdown bill;

  const BillDetails({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('billDetails'.tr(), style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          _row('itemTotal'.tr(), PriceTag.format(bill.itemTotalPaise)),
          _row(
            'deliveryFee'.tr(),
            bill.deliveryFeePaise == 0
                ? 'free'.tr()
                : PriceTag.format(bill.deliveryFeePaise),
          ),
          _row('handlingFee'.tr(), PriceTag.format(bill.handlingFeePaise)),
          if (bill.tipPaise > 0)
            _row('tip'.tr(), PriceTag.format(bill.tipPaise)),
          if (bill.discountPaise > 0)
            _row(
              'discount'.tr(),
              '-${PriceTag.format(bill.discountPaise)}',
              valueColor: context.colors.green,
            ),
          Divider(height: 20, color: context.colors.divider),
          _row('total'.tr(), PriceTag.format(bill.totalPaise), emphasize: true),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool emphasize = false,
    Color? valueColor,
  }) {
    final style = emphasize
        ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)
        : AppTypography.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}
