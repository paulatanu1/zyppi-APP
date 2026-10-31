import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Main.dc.html's floating "View cart" bar. Renders
/// nothing while the cart is empty.
class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.loading || cart.lines.isEmpty) return const SizedBox.shrink();

    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    return InkWell(
      onTap: () => context.push('/myCartScreen'),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        height: AppSizes.floatingCartBarMax,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        decoration: BoxDecoration(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.white),
                const SizedBox(width: AppSpacing.base),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'itemCount'.plural(itemCount)} · ${PriceTag.format(cart.bill.totalPaise)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cart.bill.savingsPaise > 0)
                      Text(
                        'youSave'.tr(
                          args: [PriceTag.format(cart.bill.savingsPaise)],
                        ),
                        style: AppTypography.labelSmall.copyWith(
                          color: context.colors.onPrimaryMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'viewCart'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
