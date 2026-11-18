import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/checkout/application/checkout_provider.dart';
import 'package:zippy/features/checkout/application/checkout_state.dart';
import 'package:zippy/features/checkout/widgets/address_card.dart';
import 'package:zippy/core/common_widgets/section_card.dart';
import 'package:zippy/features/checkout/widgets/checkout_steps.dart';
import 'package:zippy/features/checkout/widgets/delivery_time_card.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/features/checkout/widgets/wallet_pay_card.dart';
import 'package:zippy/features/wallet/data/wallet_repository.dart';

/// docs/screens/{light,dark}/10-checkout.png. Payment and the bill footer
/// need no network data and render at once; only the address and delivery
/// time cards show shaped skeletons while they load.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    final z = context.z;
    final text = Theme.of(context).textTheme;
    final balance = ref.watch(walletBalanceProvider).value ?? 0;
    final total = ref.watch(cartProvider.select((c) => c.bill.totalPaise));
    final walletApplied = walletToApply(balance, total, use: state.useWallet);
    final walletCoversAll = walletApplied > 0 && walletApplied >= total;

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

    Future<void> addAddress() async {
      // extra: true = "save as a new address" mode (add_new_address_row.dart).
      await context.pushNamed('SearchAddressScreen', extra: true);
      await notifier.retry();
    }

    // While a payment is being confirmed, leaving would only hide the
    // outcome (the payment itself is safe — see PendingPaymentStore).
    return PopScope(
      canPop: !state.placingOrder,
      child: Scaffold(
        backgroundColor: z.bg,
        appBar: AppBar(
          title: Text('checkout'.tr()),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: ZSpace.screen),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: z.ok),
                  const SizedBox(width: ZSpace.x1),
                  Text(
                    'secure'.tr(),
                    style: text.labelMedium?.copyWith(color: z.ok),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const CheckoutSteps(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(ZSpace.screen),
                children: [
                  ContentFade(
                    child: _addressSection(state, notifier, addAddress),
                  ),
                  const SizedBox(height: ZSpace.x3),
                  ContentFade(child: _timeSection(state, notifier)),
                  if (balance > 0) ...[
                    const SizedBox(height: ZSpace.x3),
                    ZEntrance(
                      index: 2,
                      child: WalletPayCard(
                        balancePaise: balance,
                        appliedPaise: walletApplied,
                        use: state.useWallet,
                        onChanged: state.placingOrder
                            ? (_) {}
                            : notifier.setUseWallet,
                      ),
                    ),
                  ],
                  const SizedBox(height: ZSpace.x3),
                  // Nothing left to pay outside the wallet: no method to pick.
                  if (walletCoversAll)
                    Text(
                      'walletCoversOrder'.tr(),
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: z.ok),
                    )
                  else
                    ZEntrance(
                      index: 3,
                      child: PaymentOptions(
                        selected: state.paymentMethod,
                        onSelect: notifier.selectPaymentMethod,
                      ),
                    ),
                ],
              ),
            ),
            _CheckoutFooter(
              state: state,
              walletPaise: walletApplied,
              onPay: notifier.placeOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressSection(
    CheckoutState state,
    CheckoutProvider notifier,
    VoidCallback onAddNew,
  ) {
    if (state.loading) {
      return const AddressCardSkeleton(key: ValueKey('address-loading'));
    }
    if (state.error != null) {
      return _LoadError(key: const ValueKey('error'), onRetry: notifier.retry);
    }
    final address = state.selectedAddress;
    if (address == null) {
      return AddressEmptyCard(
        key: const ValueKey('address-empty'),
        onAddNew: onAddNew,
      );
    }
    return AddressCard(
      key: const ValueKey('address'),
      address: address,
      addresses: state.addresses,
      onSelect: notifier.selectAddress,
      onAddNew: onAddNew,
    );
  }

  Widget _timeSection(CheckoutState state, CheckoutProvider notifier) {
    if (state.loading) {
      return const DeliveryTimeCardSkeleton(key: ValueKey('time-loading'));
    }
    // The error card above already offers retry.
    if (state.error != null || state.slots.isEmpty) {
      return const SizedBox.shrink(key: ValueKey('time-none'));
    }
    return DeliveryTimeCard(
      key: const ValueKey('time'),
      slots: state.slots,
      selectedSlot: state.selectedSlot,
      onSelect: notifier.selectSlot,
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'somethingWentWrong'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}

class _CheckoutFooter extends ConsumerWidget {
  final CheckoutState state;
  final VoidCallback onPay;

  /// What the wallet pays; the rest is paid by [CheckoutState.paymentMethod].
  final int walletPaise;

  const _CheckoutFooter({
    required this.state,
    required this.onPay,
    required this.walletPaise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final z = context.z;
    final text = Theme.of(context).textTheme;

    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);
    final payable = cart.bill.totalPaise - walletPaise;
    final total = PriceTag.format(payable);
    final canPay =
        !state.loading &&
        !state.placingOrder &&
        state.selectedAddress != null &&
        state.selectedSlot != null &&
        cart.lines.isNotEmpty;

    // Why Pay is disabled, when it isn't obvious from the cards above.
    final blocker = state.loading || state.placingOrder || state.error != null
        ? null
        : cart.lines.isEmpty
        ? 'errorCartEmpty'.tr()
        : state.slots.isEmpty
        ? 'noDeliverySlots'.tr()
        : null;

    final summary = [
      'itemCount'.plural(itemCount),
      if (cart.bill.savingsPaise > 0)
        'youSave'.tr(args: [PriceTag.format(cart.bill.savingsPaise)]),
    ].join(' · ');

    return Container(
      padding: EdgeInsets.fromLTRB(
        ZSpace.screen,
        ZSpace.x3,
        ZSpace.screen,
        ZSpace.x3 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: z.surface,
        border: Border(top: BorderSide(color: z.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (walletPaise > 0) ...[
            Row(
              children: [
                Expanded(
                  child: Text('paidFromWallet'.tr(), style: text.bodySmall),
                ),
                Text(
                  '−${PriceTag.format(walletPaise)}',
                  style: text.bodySmall?.copyWith(color: z.ok),
                ),
              ],
            ),
            const SizedBox(height: ZSpace.x1),
          ],
          Row(
            children: [
              Expanded(child: Text(summary, style: text.bodySmall)),
              Text('${'toPay'.tr()} ', style: text.bodyMedium),
              Text(total, style: text.titleMedium),
            ],
          ),
          if (blocker != null) ...[
            const SizedBox(height: ZSpace.x2),
            Text(
              blocker,
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: z.danger),
            ),
          ],
          const SizedBox(height: ZSpace.x3),
          FilledButton(
            onPressed: canPay ? onPay : null,
            child: state.placingOrder
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: z.onBrand,
                    ),
                  )
                : Text(
                    walletPaise > 0 && payable <= 0
                        ? 'payFromWallet'.tr(
                            args: [PriceTag.format(walletPaise)],
                          )
                        : state.paymentMethod == codPaymentMethod
                        ? 'placeOrderWithAmount'.tr(args: [total])
                        : 'payWithAmount'.tr(
                            args: [
                              total,
                              paymentMethodTitle(state.paymentMethod),
                            ],
                          ),
                  ),
          ),
          const SizedBox(height: ZSpace.x2),
          Text(
            'paymentsSecuredBy'.tr(),
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
