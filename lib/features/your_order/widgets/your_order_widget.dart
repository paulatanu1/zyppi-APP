import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

(Color, Color, String) _badge(BuildContext context, OrderStatus status) {
  switch (status) {
    case OrderStatus.outForDelivery:
      return (
        context.colors.outForDeliveryBg,
        context.colors.outForDeliveryFg,
        'orderStatusOutForDelivery'.tr(),
      );
    case OrderStatus.delivered:
      return (
        context.colors.deliveredBg,
        context.colors.deliveredFg,
        'orderStatusDelivered'.tr(),
      );
    case OrderStatus.cancelled:
      return (
        context.colors.cancelledBg,
        context.colors.cancelledFg,
        'orderStatusCancelled'.tr(),
      );
    case OrderStatus.placed:
      return (
        context.colors.primaryTint,
        context.colors.primaryDark,
        'orderStatusPlaced'.tr(),
      );
    case OrderStatus.packed:
      return (
        context.colors.primaryTint,
        context.colors.primaryDark,
        'orderStatusPacked'.tr(),
      );
  }
}

/// docs/mockups/Orders.dc.html's order card.
class YourOrderWidget extends StatelessWidget {
  final Order order;

  const YourOrderWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _badge(context, order.status);
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final isActive =
        order.status == OrderStatus.placed ||
        order.status == OrderStatus.packed ||
        order.status == OrderStatus.outForDelivery;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? context.colors.primary : context.colors.line,
            width: isActive ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(color: fg),
                  ),
                ),
                Text(
                  '${order.placedAt.day}/${order.placedAt.month}/${order.placedAt.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                ...order.items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.colors.primaryTint,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Icon(
                            Icons.shopping_basket_outlined,
                            size: 16,
                            color: context.colors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PriceTag.format(order.totalPaise),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$itemCount items',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            if (isActive)
              InkWell(
                onTap: () =>
                    context.push('/orderTrackingScreen?orderId=${order.id}'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    'trackOrder'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            else if (order.status == OrderStatus.delivered)
              Row(
                children: [
                  _ActionChip(label: 'reOrder'.tr(), onTap: () {}),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionChip(label: 'orderInfo'.tr(), onTap: () {}),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.line),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: context.colors.muted),
        ),
      ),
    );
  }
}
