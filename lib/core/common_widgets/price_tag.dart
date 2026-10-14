import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          format(pricePaise),
          style:
              priceStyle ??
              AppTypography.bodyMedium.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (showMrp) ...[
          const SizedBox(width: 6),
          Text(
            format(mrpPaise!),
            style:
                mrpStyle ??
                AppTypography.bodySmall.copyWith(
                  color: AppColors.muted,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
        ],
      ],
    );
  }
}
