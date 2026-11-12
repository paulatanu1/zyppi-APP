import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/widgets/z_hero_header.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/help_sheet.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/application/order_by_id_provider.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/your_order/application/reorder_action.dart';

String orderStatusLabel(OrderStatus status) => switch (status) {
  OrderStatus.placed => 'orderStatusPlaced'.tr(),
  OrderStatus.packed => 'orderStatusPacked'.tr(),
  OrderStatus.outForDelivery => 'orderStatusOutForDelivery'.tr(),
  OrderStatus.delivered => 'orderStatusDelivered'.tr(),
  OrderStatus.cancelled => 'orderStatusCancelled'.tr(),
};

/// "Order info": items, bill, address and payment for one past order,
/// with Reorder / Track / Help.
class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final z = context.z;

    return Scaffold(
      backgroundColor: z.bg,
      appBar: ZHeroAppBar(
        title: 'orderDetails'.tr(),
        actions: [
          TextButton(
            onPressed: () =>
                showHelpSheet(context, orderId: orderAsync.value?.id),
            child: Text('help'.tr()),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(ZSpace.screen),
          children: const [
            ZSkeleton(height: 72, radius: ZRadius.card),
            SizedBox(height: ZSpace.x3),
            ZSkeleton(height: 200, radius: ZRadius.card),
            SizedBox(height: ZSpace.x3),
            ZSkeleton(height: 160, radius: ZRadius.card),
          ],
        ),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr()),
              TextButton(
                onPressed: () => ref.invalidate(orderByIdProvider(orderId)),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
        data: (order) => order == null
            ? Center(child: Text('orderNotFound'.tr()))
            : _OrderDetailsBody(order: order),
      ),
    );
  }
}

class _OrderDetailsBody extends ConsumerWidget {
  final Order order;

  const _OrderDetailsBody({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final isActive =
        order.status == OrderStatus.placed ||
        order.status == OrderStatus.packed ||
        order.status == OrderStatus.outForDelivery;

    Widget billRow(String label, int paise, {bool negative = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodyMedium)),
          Text(
            '${negative ? '−' : ''}${PriceTag.format(paise)}',
            style: text.bodyMedium?.copyWith(color: negative ? z.ok : null),
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(ZSpace.screen),
      children: [
        SectionCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${shortOrderId(order.id)}', style: text.titleMedium),
                    Text(
                      DateFormat.yMMMd(context.locale.toLanguageTag())
                          .add_jm()
                          .format(order.placedAt.toLocal()),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZSpace.x3,
                  vertical: ZSpace.x1,
                ),
                decoration: BoxDecoration(
                  color: order.status == OrderStatus.cancelled
                      ? z.dangerSoft
                      : z.brandSoft,
                  borderRadius: ZRadius.all(ZRadius.badge),
                ),
                child: Text(
                  orderStatusLabel(order.status),
                  style: text.labelSmall?.copyWith(
                    color: order.status == OrderStatus.cancelled
                        ? z.danger
                        : z.brandText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'itemCount'.plural(
            order.items.fold<int>(0, (sum, i) => sum + i.quantity),
          ),
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: z.surface2,
                          borderRadius: ZRadius.all(ZRadius.control),
                        ),
                        child: item.image == null
                            ? Icon(
                                Icons.shopping_basket_outlined,
                                color: z.ink3,
                              )
                            : CatalogImage(
                                image: item.image,
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(width: ZSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: text.labelLarge),
                            Text(
                              '${item.unit} × ${item.quantity}',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        PriceTag.format(item.pricePaise * item.quantity),
                        style: text.labelLarge,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: ZSpace.x3),
        SectionCard(
          title: 'billDetails'.tr(),
          child: Column(
            children: [
              billRow('itemTotal'.tr(), order.itemTotalPaise),
              billRow('deliveryFee'.tr(), order.deliveryFeePaise),
              billRow('handlingFee'.tr(), order.handlingFeePaise),
              if (order.tipPaise > 0) billRow('tipLabel'.tr(), order.tipPaise),
              if (order.discountPaise > 0)
                billRow('discount'.tr(), order.discountPaise, negative: true),
              Divider(color: z.line, height: ZSpace.x6),
              Row(
                children: [
                  Expanded(
                    child: Text('orderTotal'.tr(), style: text.titleMedium),
                  ),
                  Text(
                    PriceTag.format(order.totalPaise),
                    style: text.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: ZSpace.x1),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  order.paymentMethod == codPaymentMethod
                      ? 'payOnDelivery'.tr()
                      : 'paidVia'.tr(
                          args: [paymentMethodTitle(order.paymentMethod)],
                        ),
                  style: text.bodySmall,
                ),
              ),
            ],
          ),
        ),
        if (order.addressText != null) ...[
          const SizedBox(height: ZSpace.x3),
          SectionCard(
            title: 'deliverTo'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.addressLabel != null)
                  Text(
                    addressLabelText(order.addressLabel!),
                    style: text.labelLarge,
                  ),
                Text(order.addressText!, style: text.bodyMedium),
              ],
            ),
          ),
        ],
        const SizedBox(height: ZSpace.x4),
        if (isActive)
          FilledButton(
            onPressed: () =>
                context.push('/orderTrackingScreen?orderId=${order.id}'),
            child: Text('trackOrder'.tr()),
          )
        else
          FilledButton(
            onPressed: () => reorder(context, ref, order),
            child: Text('reOrder'.tr()),
          ),
      ],
    );
  }
}
