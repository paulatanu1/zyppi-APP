import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/checkout/application/checkout_provider.dart';

const _paymentMethods = ['UPI', 'Cash on delivery', 'Credit or debit card'];

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    final cart = ref.watch(cartProvider);

    ref.listen(checkoutProvider, (previous, next) {
      if (next.placedOrderId != null &&
          previous?.placedOrderId != next.placedOrderId) {
        context.go('/orderPlacedScreen?orderId=${next.placedOrderId}');
      }
    });

    if (state.error != null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
              const SizedBox(height: 12),
              SizedBox(
                width: 160,
                child: PrimaryButton(
                  buttonTitle: 'retry'.tr(),
                  action: notifier.retry,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('checkout'.tr())),
      body: AppSkeleton(
        enabled: state.loading,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(
                      title: 'deliverTo'.tr(),
                      child: RadioGroup<String>(
                        groupValue: state.selectedAddress?.id,
                        onChanged: (value) => notifier.selectAddress(value!),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: state.addresses.map((address) {
                            final selected =
                                address.id == state.selectedAddress?.id;

                            return RadioListTile<String>(
                              value: address.id,
                              activeColor: AppColors.primary,
                              title: Text(
                                address.label,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: selected ? FontWeight.w700 : null,
                                ),
                              ),
                              subtitle: Text(
                                '${address.line1}, ${address.area}, ${address.city}',
                                style: AppTypography.bodySmall,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    _section(
                      title: 'deliveryTime'.tr(),
                      child: RadioGroup<String>(
                        groupValue: state.selectedSlot?.id,
                        onChanged: (value) => notifier.selectSlot(value!),
                        child: Column(
                          children: state.slots.map((slot) {
                            return RadioListTile<String>(
                              value: slot.id,
                              activeColor: AppColors.primary,
                              title: Text(
                                slot.label,
                                style: AppTypography.bodyLarge,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    _section(
                      title: 'paymentMethod'.tr(),
                      child: RadioGroup<String>(
                        groupValue: state.paymentMethod,
                        onChanged: (value) =>
                            notifier.selectPaymentMethod(value!),
                        child: Column(
                          children: _paymentMethods.map((method) {
                            return RadioListTile<String>(
                              value: method,
                              activeColor: AppColors.primary,
                              title: Text(
                                method,
                                style: AppTypography.bodyLarge,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$itemCount items${cart.bill.savingsPaise > 0 ? ' · ${'youSave'.tr(args: [PriceTag.format(cart.bill.savingsPaise)])}' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        '${'toPay'.tr()} ${PriceTag.format(cart.bill.totalPaise)}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  PrimaryButton(
                    buttonTitle: state.placingOrder
                        ? '…'
                        : 'payWithAmount'.tr(
                            args: [
                              PriceTag.format(cart.bill.totalPaise),
                              state.paymentMethod,
                            ],
                          ),
                    action: state.placingOrder ? () {} : notifier.placeOrder,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          child,
          const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}
