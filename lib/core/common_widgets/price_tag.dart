import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Formats money (always `int` paise, per CLAUDE.md) as ₹ with an
/// optional struck-through MRP, e.g. "₹120  ₹150".
class PriceTag extends StatelessWidget {
  final int pricePaise;
  final int? mrpPaise;
  final TextStyle? priceStyle;
  final TextStyle? mrpStyle;

  const PriceTag({
    super.key,
    required this.pricePaise,
    this.mrpPaise,
    this.priceStyle,
    this.mrpStyle,
  });

  static String format(int paise) {
    final rupees = paise / 100;
    final isWhole = paise % 100 == 0;
    return '₹${isWhole ? rupees.toStringAsFixed(0) : rupees.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final showMrp = mrpPaise != null && mrpPaise! > pricePaise;

    // Cards give the price only what's left beside ADD / the stepper, so
    // scale the pair down rather than overflow when the MRP doesn't fit.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            format(pricePaise),
            maxLines: 1,
            style:
                priceStyle ??
                Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.z.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (showMrp) ...[
            const SizedBox(width: 6),
            Text(
              format(mrpPaise!),
              maxLines: 1,
              style:
                  mrpStyle ??
                  Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: context.z.ink2,
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
