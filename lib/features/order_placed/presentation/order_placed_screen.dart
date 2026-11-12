import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/order/application/order_by_id_provider.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/widgets/z_commerce.dart';
import 'package:zippy/core/widgets/z_motion.dart';

/// docs/screens/light/11-order-placed.png: green check, "Order placed!",
/// illustration, order ID / payment / address card, Track order and
/// Continue shopping.
class OrderPlacedScreen extends ConsumerWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final order = orderAsync.value;

    return Scaffold(
      backgroundColor: z.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  ZSpace.x5,
                  ZSpace.x6,
                  ZSpace.x5,
                  ZSpace.x4,
                ),
                child: Column(
                  children: [
                    ZEntrance(
                      index: 0,
                      child: ZBrandTexture(
                        borderRadius: ZRadius.all(ZRadius.sheet),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ZSpace.x5,
                            ZSpace.x6,
                            ZSpace.x5,
                            ZSpace.x6,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: z.onBrand.withValues(alpha: .16),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: z.onBrand.withValues(alpha: .22),
                                  ),
                                ),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: z.onBrand,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: z.ok,
                                    size: 44,
                                  ),
                                ),
                              ),
                              const SizedBox(height: ZSpace.x4),
                              Text(
                                'orderPlaced'.tr(),
                                textAlign: TextAlign.center,
                                style: t.headlineMedium!.copyWith(
                                  color: z.headerInk,
                                ),
                              ),
                              const SizedBox(height: ZSpace.x2),
                              Text(
                                order?.etaMinutes == null
                                    ? 'orderPlacedDescription'.tr()
                                    : 'orderPlacedArriving'.tr(
                                        args: ['${order!.etaMinutes}'],
                                      ),
                                textAlign: TextAlign.center,
                                style: t.bodyLarge!.copyWith(
                                  color: z.headerInk2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x5),
                    ZEntrance(
                      index: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ZSpace.x4),
                        decoration: BoxDecoration(
                          color: z.brandSoft,
                          borderRadius: ZRadius.all(ZRadius.sheet),
                        ),
                        child: ZLoop(
                          kind: ZLoopKind.bob,
                          child: Image.asset(
                            'assets/images/Splash-3.png',
                            height: 180,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x4),
                    ZEntrance(
                      index: 2,
                      child: _Details(
                        orderId: orderId,
                        loading: orderAsync.isLoading && order == null,
                        rows: order == null
                            ? null
                            : [
                                ('orderId'.tr(), '#${shortOrderId(order.id)}'),
                                (
                                  order.paymentMethod == codPaymentMethod
                                      ? 'payOnDelivery'.tr()
                                      : 'paidVia'.tr(
                                          args: [
                                            paymentMethodTitle(
                                              order.paymentMethod,
                                            ),
                                          ],
                                        ),
                                  rupees(order.totalPaise),
                                ),
                                (
                                  'deliverTo'.tr(),
                                  order.addressLabel != null
                                      ? addressLabelText(order.addressLabel!)
                                      : (order.addressText ?? ''),
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ZSpace.x5,
                0,
                ZSpace.x5,
                ZSpace.x4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, ZSize.button),
                    ),
                    onPressed: () =>
                        context.go('/orderTrackingScreen?orderId=$orderId'),
                    child: Text('trackOrder'.tr()),
                  ),
                  const SizedBox(height: ZSpace.x3),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, ZSize.button),
                    ),
                    onPressed: () => context.go('/navBar'),
                    child: Text('continueShopping'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order ID · payment · address card. While loading: skeleton rows; if the
/// details failed to load: a retry (the order itself was placed).
class _Details extends ConsumerWidget {
  const _Details({
    required this.orderId,
    required this.loading,
    required this.rows,
  });

  final String orderId;
  final bool loading;
  final List<(String, String)>? rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final rows = this.rows;

    Widget child;
    if (loading) {
      child = const Column(
        children: [
          ZSkeleton(height: 18),
          SizedBox(height: ZSpace.x4),
          ZSkeleton(height: 18),
          SizedBox(height: ZSpace.x4),
          ZSkeleton(height: 18),
        ],
      );
    } else if (rows == null) {
      child = Center(
        child: TextButton(
          onPressed: () => ref.invalidate(orderByIdProvider(orderId)),
          child: Text('loadOrderDetails'.tr()),
        ),
      );
    } else {
      child = Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: ZSpace.x6, color: z.line),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    rows[i].$1,
                    style: t.bodyMedium!.copyWith(color: z.ink2),
                  ),
                ),
                const SizedBox(width: ZSpace.x3),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    textAlign: TextAlign.end,
                    style: t.labelLarge,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ZSpace.x4),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        border: Border.all(color: z.line),
      ),
      child: child,
    );
  }
}
