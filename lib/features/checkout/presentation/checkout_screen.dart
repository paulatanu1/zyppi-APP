import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/delivery_slot.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/checkout/application/checkout_provider.dart';

const _paymentMethods = ['UPI', codPaymentMethod, 'Credit or debit card'];

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
      if (next.paymentError != null &&
          previous?.paymentError != next.paymentError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.paymentError!)));
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
                      child: _DeliverySlotPicker(
                        slots: state.slots,
                        selectedSlot: state.selectedSlot,
                        onSelect: notifier.selectSlot,
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

/// docs/mockups/Checkout.dc.html's two-button Express/Schedule toggle;
/// tapping "Schedule" reveals the concrete scheduled windows below it.
class _DeliverySlotPicker extends StatelessWidget {
  final List<DeliverySlot> slots;
  final DeliverySlot? selectedSlot;
  final ValueChanged<String> onSelect;

  const _DeliverySlotPicker({
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final expressSlot = slots.where((s) => s.isExpress).firstOrNull;
    final scheduledSlots = slots.where((s) => !s.isExpress).toList();
    final isScheduleSelected = selectedSlot != null && !selectedSlot!.isExpress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (expressSlot != null)
              Expanded(
                child: _SlotCategoryCard(
                  title: 'express'.tr(),
                  subtitle: expressSlot.label,
                  selected: selectedSlot?.id == expressSlot.id,
                  onTap: () => onSelect(expressSlot.id),
                ),
              ),
            if (expressSlot != null && scheduledSlots.isNotEmpty)
              const SizedBox(width: AppSpacing.base),
            if (scheduledSlots.isNotEmpty)
              Expanded(
                child: _SlotCategoryCard(
                  title: 'scheduleLabel'.tr(),
                  subtitle: 'pickASlot'.tr(),
                  selected: isScheduleSelected,
                  onTap: () => onSelect(scheduledSlots.first.id),
                ),
              ),
          ],
        ),
        if (isScheduleSelected) ...[
          const SizedBox(height: AppSpacing.base),
          Wrap(
            spacing: AppSpacing.base,
            runSpacing: AppSpacing.base,
            children: scheduledSlots.map((slot) {
              final selected = selectedSlot?.id == slot.id;

              return ChoiceChip(
                label: Text(slot.label),
                selected: selected,
                onSelected: (_) => onSelect(slot.id),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _SlotCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SlotCategoryCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.input),
          color: selected ? AppColors.primarySurface : AppColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
