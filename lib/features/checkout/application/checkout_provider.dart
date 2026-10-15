import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zippy/core/analytics/analytics_service.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/delivery_slot_repository_impl.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/payments/data/payment_repository_impl.dart';
import 'package:zippy/core/payments/domain/razorpay_order.dart';
import 'package:zippy/features/checkout/application/checkout_state.dart';

const codPaymentMethod = 'Cash on delivery';

class CheckoutProvider extends StateNotifier<CheckoutState> {
  final Ref ref;
  Razorpay? _razorpay;

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

      AnalyticsService.logBeginCheckout(
        totalPaise: ref.read(cartProvider).bill.totalPaise,
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

    state = state.copyWith(placingOrder: true, error: null);

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

    // The mock flavor has no real payment gateway to open — every method
    // just places the order directly, same as COD always does.
    if (state.paymentMethod == codPaymentMethod || Env.isMockDataSource) {
      await _finishPlacingOrder(order);
      return;
    }

    try {
      final razorpayOrder = await ref
          .read(paymentRepositoryProvider)
          .createOrder(cart.bill.totalPaise);

      _openRazorpayCheckout(order, razorpayOrder);
    } catch (error) {
      state = state.copyWith(
        placingOrder: false,
        paymentError: error.toString(),
      );
    }
  }

  void _openRazorpayCheckout(Order order, RazorpayOrder razorpayOrder) {
    final razorpay = Razorpay();
    _razorpay = razorpay;

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) async {
      razorpay.clear();

      try {
        final verified = await ref
            .read(paymentRepositoryProvider)
            .verifyPayment(
              razorpayOrderId: response.orderId ?? razorpayOrder.orderId,
              razorpayPaymentId: response.paymentId!,
              razorpaySignature: response.signature!,
            );

        if (!verified) {
          state = state.copyWith(
            placingOrder: false,
            paymentError: 'Payment could not be verified',
          );
          return;
        }

        await _finishPlacingOrder(
          order,
          razorpayOrderId: response.orderId ?? razorpayOrder.orderId,
          razorpayPaymentId: response.paymentId!,
        );
      } catch (error) {
        state = state.copyWith(
          placingOrder: false,
          paymentError: error.toString(),
        );
      }
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      razorpay.clear();
      state = state.copyWith(
        placingOrder: false,
        paymentError: response.message ?? 'Payment failed',
      );
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
      ExternalWalletResponse response,
    ) {
      razorpay.clear();
      state = state.copyWith(placingOrder: false);
    });

    razorpay.open({
      'key': razorpayOrder.keyId,
      'order_id': razorpayOrder.orderId,
      'amount': razorpayOrder.amountPaise,
      'currency': razorpayOrder.currency,
      'name': 'Zyppi',
    });
  }

  Future<void> _finishPlacingOrder(
    Order order, {
    String? razorpayOrderId,
    String? razorpayPaymentId,
  }) async {
    final orderId = await ref
        .read(orderRepositoryProvider)
        .placeOrder(
          order,
          deliverySlotId: state.selectedSlot!.id,
          razorpayOrderId: razorpayOrderId,
          razorpayPaymentId: razorpayPaymentId,
        );
    AnalyticsService.logPurchase(
      orderId: orderId,
      totalPaise: order.totalPaise,
    );

    await ref.read(cartProvider.notifier).clear();

    state = state.copyWith(placingOrder: false, placedOrderId: orderId);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutProvider, CheckoutState>(
      (ref) => CheckoutProvider(ref),
    );
