import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/utils/order_id.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/order/application/order_by_id_provider.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Placed.dc.html — full-bleed pink confirmation.
class OrderPlacedScreen extends ConsumerWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final order = orderAsync.value;

    return Scaffold(
      backgroundColor: context.z.brand,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZSpace.x6,
            vertical: ZSpace.x8,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: context.z.brandPress,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: context.z.deal,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: context.z.brandPress,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ZSpace.x6),
                    Text(
                      'orderPlaced'.tr(),
                      style: AppTypography.headlineMedium.copyWith(
                        color: context.z.onBrand,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x3),
                    Text(
                      'orderPlacedDescription'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: context.z.headerInk2,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x4),
                    if (orderAsync.isLoading && order == null)
                      SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: context.z.headerInk2,
                        ),
                      )
                    else if (order == null)
                      // The order exists (we just placed it); only its
                      // details failed to load. Offer a retry, not an error.
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(orderByIdProvider(orderId)),
                        child: Text(
                          'loadOrderDetails'.tr(),
                          style: AppTypography.labelLarge.copyWith(
                            color: context.z.onBrand,
                          ),
                        ),
                      )
                    else ...[
                      _KeyValueRow(
                        label: 'orderId'.tr(),
                        value: '#${shortOrderId(order.id)}',
                      ),
                      _KeyValueRow(
                        label: order.paymentMethod == codPaymentMethod
                            ? 'payOnDelivery'.tr()
                            : 'paidVia'.tr(
                                args: [paymentMethodTitle(order.paymentMethod)],
                              ),
                        value: PriceTag.format(order.totalPaise),
                      ),
                      _KeyValueRow(
                        label: 'deliverTo'.tr(),
                        value: order.addressLabel != null
                            ? addressLabelText(order.addressLabel!)
                            : (order.addressText ?? ''),
                        showDivider: false,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: ZSize.button,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.z.deal,
                        foregroundColor: context.z.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ZRadius.input),
                        ),
                      ),
                      onPressed: () =>
                          context.go('/orderTrackingScreen?orderId=$orderId'),
                      child: Text(
                        'trackOrder'.tr(),
                        style: AppTypography.labelLarge.copyWith(
                          color: context.z.ink,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/navBar'),
                    child: Text(
                      'backToHome'.tr(),
                      style: AppTypography.labelLarge.copyWith(
                        color: context.z.onBrand,
                      ),
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

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _KeyValueRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x3),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: context.colors.dividerOnPrimary))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: context.z.headerInk2,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: context.z.onBrand,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
