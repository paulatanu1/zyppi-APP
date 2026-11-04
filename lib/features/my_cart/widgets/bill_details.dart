import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/cart/domain/bill_breakdown.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// docs/screens/light/09-cart.png's "Bill details": item total, fees, tip,
/// discount, then [tipSelector] and "To pay".
class BillDetails extends StatelessWidget {
  final BillBreakdown bill;
  final Widget? tipSelector;

  const BillDetails({super.key, required this.bill, this.tipSelector});

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('billDetails'.tr(), style: t.titleMedium),
        const SizedBox(height: ZSpace.x2),
        _row(context, 'itemTotal'.tr(), rupees(bill.itemTotalPaise)),
        _row(
          context,
          'deliveryFee'.tr(),
          bill.deliveryFeePaise == 0
              ? 'free'.tr()
              : rupees(bill.deliveryFeePaise),
          valueColor: bill.deliveryFeePaise == 0 ? z.ok : null,
        ),
        _row(context, 'handlingFee'.tr(), rupees(bill.handlingFeePaise)),
        _row(context, 'tip'.tr(), rupees(bill.tipPaise)),
        if (bill.discountPaise > 0)
          _row(
            context,
            'discount'.tr(),
            '-${rupees(bill.discountPaise)}',
            valueColor: z.ok,
          ),
        if (tipSelector != null) ...[
          const SizedBox(height: ZSpace.x2),
          tipSelector!,
        ],
        const SizedBox(height: ZSpace.x3),
        Divider(color: z.line),
        const SizedBox(height: ZSpace.x1),
        Row(
          children: [
            Expanded(child: Text('toPay'.tr(), style: t.titleMedium)),
            Text(rupees(bill.totalPaise), style: t.titleMedium),
          ],
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: t.bodyMedium!.copyWith(color: context.z.ink2),
            ),
          ),
          const SizedBox(width: ZSpace.x3),
          Text(
            value,
            style: t.labelLarge!.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
