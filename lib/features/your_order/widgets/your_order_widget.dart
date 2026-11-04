import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/features/your_order/application/reorder_action.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

(Color, Color, String) _badge(BuildContext context, OrderStatus status) {
  switch (status) {
    case OrderStatus.outForDelivery:
      return (
        context.z.warnSoft,
        context.z.warn,
        'orderStatusOutForDelivery'.tr(),
      );
    case OrderStatus.delivered:
      return (context.z.okSoft, context.z.ok, 'orderStatusDelivered'.tr());
    case OrderStatus.cancelled:
      return (
        context.z.dangerSoft,
        context.z.danger,
        'orderStatusCancelled'.tr(),
      );
    case OrderStatus.placed:
      return (
        context.z.brandSoft,
        context.z.brandPress,
        'orderStatusPlaced'.tr(),
      );
    case OrderStatus.packed:
      return (
        context.z.brandSoft,
        context.z.brandPress,
        'orderStatusPacked'.tr(),
      );
  }
}

/// docs/mockups/Orders.dc.html's order card.
class YourOrderWidget extends ConsumerWidget {
  final Order order;

  const YourOrderWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bg, fg, label) = _badge(context, order.status);
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final isActive =
        order.status == OrderStatus.placed ||
        order.status == OrderStatus.packed ||
        order.status == OrderStatus.outForDelivery;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ZSpace.x3,
        vertical: ZSpace.x2,
      ),
      child: InkWell(
        onTap: () => context.push('/orderDetailsScreen?orderId=${order.id}'),
        borderRadius: BorderRadius.circular(ZRadius.card),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive ? context.z.brand : context.z.line,
              width: isActive ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(ZRadius.card),
          ),
          padding: const EdgeInsets.all(ZSpace.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZSpace.x2,
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
                    DateFormat.yMMMd(context.locale.toLanguageTag())
                        .add_jm()
                        .format(order.placedAt.toLocal()),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.z.ink2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ZSpace.x3),
              Row(
                children: [
                  ...order.items
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: ZSpace.x1),
                          child: Container(
                            width: 32,
                            height: 32,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.z.brandSoft,
                              borderRadius: BorderRadius.circular(ZRadius.chip),
                            ),
                            child: item.image == null
                                ? Icon(
                                    Icons.shopping_basket_outlined,
                                    size: 16,
                                    color: context.z.brandPress,
                                  )
                                : CatalogImage(
                                    image: item.image,
                                    fit: BoxFit.contain,
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
                        'itemCount'.plural(itemCount),
                        style: AppTypography.bodySmall.copyWith(
                          color: context.z.ink2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: ZSpace.x3),
              if (isActive)
                InkWell(
                  onTap: () =>
                      context.push('/orderTrackingScreen?orderId=${order.id}'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
                    decoration: BoxDecoration(
                      color: context.z.brand,
                      borderRadius: BorderRadius.circular(ZRadius.chip),
                    ),
                    child: Text(
                      'trackOrder'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: context.z.onBrand,
                      ),
                    ),
                  ),
                )
              else if (order.status == OrderStatus.delivered)
                Row(
                  children: [
                    _ActionChip(
                      label: 'reOrder'.tr(),
                      onTap: () => reorder(context, ref, order),
                    ),
                    const SizedBox(width: ZSpace.x2),
                    _ActionChip(
                      label: 'orderInfo'.tr(),
                      onTap: () => context.push(
                        '/orderDetailsScreen?orderId=${order.id}',
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
      borderRadius: BorderRadius.circular(ZRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ZSpace.x3,
          vertical: ZSpace.x2,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.z.line),
          borderRadius: BorderRadius.circular(ZRadius.chip),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: context.z.ink2),
        ),
      ),
    );
  }
}
