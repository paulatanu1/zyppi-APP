import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/delivery_slot_repository_impl.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/features/checkout/application/checkout_state.dart';

class CheckoutProvider extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutProvider(this.ref) : super(CheckoutState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final addresses = await ref
          .read(addressRepositoryProvider)
          .fetchAddresses();
      final slots = await ref.read(deliverySlotRepositoryProvider).fetchSlots();

      final defaultAddress = addresses.where((a) => a.isDefault);

      state = state.copyWith(
        addresses: addresses,
        selectedAddress: defaultAddress.isNotEmpty
            ? defaultAddress.first
            : addresses.isNotEmpty
            ? addresses.first
            : null,
        slots: slots,
        selectedSlot: slots.isNotEmpty ? slots.first : null,
        loading: false,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();

  void selectAddress(String addressId) {
    final match = state.addresses.where((a) => a.id == addressId);
    if (match.isEmpty) return;

    state = state.copyWith(selectedAddress: match.first);
  }

  void selectSlot(String slotId) {
    final match = state.slots.where((s) => s.id == slotId);
    if (match.isEmpty) return;

    state = state.copyWith(selectedSlot: match.first);
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<void> placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.lines.isEmpty ||
        state.selectedAddress == null ||
        state.selectedSlot == null) {
      return;
    }

    state = state.copyWith(placingOrder: true);

    final order = Order(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      items: cart.lines
          .map(
            (line) => OrderItem(
              productId: line.product.id,
              variantId: line.variant.id,
              name: line.product.name,
              unit: line.variant.label,
              quantity: line.quantity,
              pricePaise: line.variant.pricePaise,
            ),
          )
          .toList(),
      status: OrderStatus.placed,
      placedAt: DateTime.now(),
      itemTotalPaise: cart.bill.itemTotalPaise,
      deliveryFeePaise: cart.bill.deliveryFeePaise,
      handlingFeePaise: cart.bill.handlingFeePaise,
      tipPaise: cart.bill.tipPaise,
      discountPaise: cart.bill.discountPaise,
      totalPaise: cart.bill.totalPaise,
      addressId: state.selectedAddress!.id,
      paymentMethod: state.paymentMethod,
    );

    final orderId = await ref
        .read(orderRepositoryProvider)
        .placeOrder(order, deliverySlotId: state.selectedSlot!.id);
    await ref.read(cartProvider.notifier).clear();

    state = state.copyWith(placingOrder: false, placedOrderId: orderId);
  }
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutProvider, CheckoutState>(
      (ref) => CheckoutProvider(ref),
    );
