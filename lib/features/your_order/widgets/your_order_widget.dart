import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/your_order/application/reorder_action.dart';

/// Placed, packed or on the way — shows "Track order".
bool isActiveOrder(OrderStatus status) =>
    status == OrderStatus.placed ||
    status == OrderStatus.packed ||
    status == OrderStatus.outForDelivery;

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

/// docs/screens/light/13-orders.png's order card: status badge and date,
/// overlapping item photos with total and count, then "Track order" (active)
/// or Reorder · Order info (delivered). Active orders get a brand border.
class YourOrderWidget extends ConsumerWidget {
  final Order order;

  const YourOrderWidget({super.key, required this.order});

  static const double _thumb = 40, _overlap = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final (bg, fg, label) = _badge(context, order.status);
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final isActive = isActiveOrder(order.status);
    final thumbs = order.items.take(3).toList();
    final extra = order.items.length - thumbs.length;

    // Soft elevated card; an active order gets a lilac edge rather than a
    // heavy brand outline.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: ZRadius.all(ZRadius.card),
        boxShadow: z.elevation,
      ),
      child: Material(
        color: z.surface,
        shape: RoundedRectangleBorder(
          borderRadius: ZRadius.all(ZRadius.card),
          side: BorderSide(color: isActive ? z.brandSoft2 : z.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/orderDetailsScreen?orderId=${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(ZSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Flexible + ellipsis: badge and date share the row at
                    // any text size.
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZSpace.x2,
                          vertical: ZSpace.x1,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: ZRadius.all(ZRadius.badge),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive) ...[
                              Icon(Icons.circle, size: 8, color: fg),
                              const SizedBox(width: ZSpace.x1),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.labelMedium!.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: ZSpace.x2),
                    const Spacer(),
                    Flexible(
                      flex: 3,
                      child: Text(
                        DateFormat.yMMMd(context.locale.toLanguageTag())
                            .add_jm()
                            .format(order.placedAt.toLocal()),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ZSpace.x3),
                Row(
                  children: [
                    SizedBox(
                      width:
                          _thumb +
                          (thumbs.length - 1 + (extra > 0 ? 1 : 0)) * _overlap,
                      height: _thumb,
                      child: Stack(
                        children: [
                          for (var i = 0; i < thumbs.length; i++)
                            Positioned(
                              left: i * _overlap,
                              child: _Thumb(
                                child: thumbs[i].image == null
                                    ? Icon(
                                        Icons.shopping_basket_outlined,
                                        size: 18,
                                        color: z.ink3,
                                      )
                                    : CatalogImage(
                                        image: thumbs[i].image,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                          if (extra > 0)
                            Positioned(
                              left: thumbs.length * _overlap,
                              child: _Thumb(
                                child: Text(
                                  '+$extra',
                                  style: t.labelMedium!.copyWith(
                                    color: z.ink2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ZSpace.x3),
                    // Shrinks at large text sizes rather than overflow.
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                rupees(order.totalPaise),
                                style: t.titleLarge,
                              ),
                              Text(
                                'itemCount'.plural(itemCount),
                                style: t.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: ZSpace.x3),
                  _ActionButton(
                    icon: Icons.delivery_dining_rounded,
                    label: order.etaMinutes == null
                        ? 'trackOrder'.tr()
                        : 'trackOrderEta'.tr(args: ['${order.etaMinutes}']),
                    primary: true,
                    onTap: () => context.push(
                      '/orderTrackingScreen?orderId=${order.id}',
                    ),
                  ),
                ] else if (order.status == OrderStatus.delivered) ...[
                  const SizedBox(height: ZSpace.x3),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.replay_rounded,
                          label: 'reOrder'.tr(),
                          primary: true,
                          onTap: () => reorder(context, ref, order),
                        ),
                      ),
                      const SizedBox(width: ZSpace.x2),
                      Expanded(
                        child: _ActionButton(
                          label: 'orderInfo'.tr(),
                          onTap: () => context.push(
                            '/orderDetailsScreen?orderId=${order.id}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded photo square with a surface ring, for the overlapping stack.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      width: YourOrderWidget._thumb,
      height: YourOrderWidget._thumb,
      padding: const EdgeInsets.all(ZSpace.x1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: z.surface2,
        borderRadius: ZRadius.all(ZRadius.control),
        border: Border.all(color: z.surface, width: 2),
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final fg = primary ? z.brandText : z.ink;
    return ZPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: ZSize.touch),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.x2),
        decoration: BoxDecoration(
          color: primary ? z.brandSoft : z.surface,
          borderRadius: ZRadius.all(ZRadius.control),
          border: Border.all(color: primary ? z.brandSoft : z.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: ZSpace.x1),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge!
                    .copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
