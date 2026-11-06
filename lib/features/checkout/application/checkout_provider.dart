import 'dart:async';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/analytics/analytics_service.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/data/delivery_slot_repository_impl.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/domain/order.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/payments/data/payment_repository_impl.dart';
import 'package:zippy/core/payments/data/payu_checkout.dart';
import 'package:zippy/core/payments/data/pending_payment_store.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/features/checkout/application/checkout_errors.dart';
import 'package:zippy/features/checkout/application/checkout_state.dart';

// How long to wait before each payment-status check: PayU can report a
// payment as pending for a few seconds after the SDK returns success.
const _verifyDelays = [
  Duration.zero,
  Duration(seconds: 2),
  Duration(seconds: 3),
  Duration(seconds: 5),
  Duration(seconds: 8),
];

class CheckoutProvider extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutProvider(this.ref)
    : super(CheckoutState(paymentMethod: defaultPaymentMethod)) {
    _load();
  }

  Future<void> _load() async {
    // Skeletons only on the first load; a reload (e.g. after adding an
    // address) keeps the current cards on screen.
    state = state.copyWith(loading: state.slots.isEmpty, error: null);

    try {
      // Independent reads: one round trip of wait instead of two.
      final (addresses, slots) = await (
        ref.read(addressRepositoryProvider).fetchAddresses(),
        ref.read(deliverySlotRepositoryProvider).fetchSlots(),
      ).wait;
      if (!mounted) return;

      // Prefer: an address just added on reload, then the current pick,
      // then the default, then the first.
      final previousIds = {for (final a in state.addresses) a.id};
      final added = state.addresses.isEmpty
          ? const <Address>[]
          : addresses.where((a) => !previousIds.contains(a.id));
      final current = addresses.where((a) => a.id == state.selectedAddress?.id);
      final defaultAddress = addresses.where((a) => a.isDefault);
      final keptSlot = slots.where((s) => s.id == state.selectedSlot?.id);

      state = state.copyWith(
        addresses: addresses,
        selectedAddress: added.isNotEmpty
            ? added.first
            : current.isNotEmpty
            ? current.first
            : defaultAddress.isNotEmpty
            ? defaultAddress.first
            : addresses.firstOrNull,
        slots: slots,
        selectedSlot: keptSlot.isNotEmpty ? keptSlot.first : slots.firstOrNull,
        loading: false,
      );
    } catch (error) {
      if (mounted) {
        state = state.copyWith(loading: false, error: error.toString());
      }
      return;
    }

    // Analytics must never turn a loaded checkout into the error state.
    try {
      unawaited(
        AnalyticsService.logBeginCheckout(
          totalPaise: ref.read(cartProvider).bill.totalPaise,
        ).catchError((_) {}),
      );
    } catch (_) {}

    unawaited(_applyPreferredMethod());

    // A payment started earlier (user left checkout, or the app was
    // killed) that never became an order: settle it before anything else
    // so the customer isn't asked to pay twice.
    final pending = ref.read(pendingPaymentStoreProvider).read();
    if (pending != null && !Env.isMockDataSource && mounted) {
      state = state.copyWith(placingOrder: true);
      await _confirmPayment(pending);
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

  bool _methodChosen = false;

  void selectPaymentMethod(String method) {
    _methodChosen = true;
    state = state.copyWith(paymentMethod: method);
  }

  /// Account → Payment settings: start with the user's preferred method,
  /// unless they've already picked one on this screen.
  Future<void> _applyPreferredMethod() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).fetchProfile();
      final preferred = profile.preferredPaymentMethod;
      if (preferred != null &&
          availablePaymentMethods.contains(preferred) &&
          mounted &&
          !_methodChosen) {
        state = state.copyWith(paymentMethod: preferred);
      }
    } catch (_) {
      // Keep the default; this is only a convenience.
    }
  }

  Future<void> placeOrder() async {
    final cart = ref.read(cartProvider);
    if (state.placingOrder ||
        cart.lines.isEmpty ||
        state.selectedAddress == null ||
        state.selectedSlot == null) {
      return;
    }

    // Clear the last payment error so the same message (e.g. still
    // pending) shows again on retry.
    state = state.copyWith(placingOrder: true, error: null, paymentError: null);

    // The server orders what's in *its* copy of the cart, and taps sync to
    // it in the background — push any pending ones first.
    try {
      await ref.read(cartProvider.notifier).flush();
    } catch (_) {
      _fail('cartNotSynced'.tr());
      return;
    }
    if (!mounted) return;

    // The mock flavor has no real payment gateway to open — every method
    // just places the order directly, same as COD always does.
    if (state.paymentMethod == codPaymentMethod || Env.isMockDataSource) {
      try {
        final orderId = await ref
            .read(orderRepositoryProvider)
            .placeOrder(
              _orderFromCart(),
              deliverySlotId: state.selectedSlot!.id,
              couponCode: cart.appliedCoupon?.code,
            );
        await _onOrderPlaced(orderId, cart.bill.totalPaise);
      } catch (error) {
        _fail(friendlyOrderError(error));
      }
      return;
    }

    // Online payments aren't offered in this build (no PayU credentials yet).
    if (!Env.onlinePaymentsEnabled) {
      _fail('paymentFailed'.tr());
      return;
    }

    // A payment from an earlier attempt that never settled: re-check it
    // instead of charging again, whatever the cart total is now.
    final pending = ref.read(pendingPaymentStoreProvider).read();
    if (pending != null) {
      await _confirmPayment(pending);
      return;
    }

    final PaymentOrder paymentOrder;
    try {
      // Priced server-side from the synced cart; fails here (before any
      // money moves) if something is out of stock or undeliverable.
      paymentOrder = await ref
          .read(paymentRepositoryProvider)
          .createOrder(
            paymentMethod: state.paymentMethod,
            addressId: state.selectedAddress!.id,
            deliverySlotId: state.selectedSlot!.id,
            couponCode: cart.appliedCoupon?.code,
            tipPaise: cart.tipPaise,
          );
    } catch (error) {
      _fail(friendlyOrderError(error));
      return;
    }

    await ref.read(pendingPaymentStoreProvider).save(paymentOrder.txnid);

    final PayUCheckoutResult sdkResult;
    try {
      sdkResult = await PayUCheckout(ref.read(paymentRepositoryProvider))
          .open(paymentOrder);
    } catch (_) {
      // The SDK itself failed to open; the server check below settles it.
      return _confirmPayment(paymentOrder.txnid, delays: const [Duration.zero]);
    }
    if (!mounted) return;

    // Even when the SDK reports failure, check once with the server: the
    // payment may have gone through (e.g. the app was backgrounded).
    await _confirmPayment(
      paymentOrder.txnid,
      delays: sdkResult == PayUCheckoutResult.success
          ? _verifyDelays
          : const [Duration.zero],
    );
  }

  /// Asks the server about [txnid] until PayU settles it. The
  /// server creates the order itself once the payment is confirmed, so
  /// this only has to report the outcome. Leaving checkout mid-way is
  /// safe: the payment stays in [PendingPaymentStore] and is re-checked
  /// next time.
  Future<void> _confirmPayment(
    String txnid, {
    List<Duration> delays = _verifyDelays,
  }) async {
    final store = ref.read(pendingPaymentStoreProvider);

    for (final delay in delays) {
      await Future<void>.delayed(delay);
      if (!mounted) return;

      final PaymentVerification verification;
      try {
        verification = await ref
            .read(paymentRepositoryProvider)
            .verifyPayment(txnid);
      } catch (_) {
        continue; // network blip — try again on the next delay
      }
      if (!mounted) return;

      if (verification.orderId != null) {
        await store.clear();
        await _onOrderPlaced(
          verification.orderId!,
          ref.read(cartProvider).bill.totalPaise,
        );
        return;
      }

      if (verification.needsReview) {
        await store.clear();
        _fail('paymentNeedsReview'.tr());
        return;
      }

      if (!verification.verified && !verification.pending) {
        await store.clear();
        _fail('paymentFailed'.tr());
        return;
      }
    }

    _fail('paymentPendingRetry'.tr());
  }

  Future<void> _onOrderPlaced(String orderId, int totalPaise) async {
    try {
      unawaited(
        AnalyticsService.logPurchase(
          orderId: orderId,
          totalPaise: totalPaise,
        ).catchError((_) {}),
      );
    } catch (_) {}

    await ref.read(cartProvider.notifier).clear();
    if (!mounted) return;

    state = state.copyWith(placingOrder: false, placedOrderId: orderId);
  }

  void _fail(String message) {
    if (!mounted) return;
    state = state.copyWith(placingOrder: false, paymentError: message);
  }

  /// The client-side view of the order; only the mock repository stores
  /// it as-is (the placeOrder function re-derives everything server-side).
  Order _orderFromCart() {
    final cart = ref.read(cartProvider);

    return Order(
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
              image: line.product.image,
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
      addressLabel: state.selectedAddress!.label,
      addressText: [
        state.selectedAddress!.line1,
        state.selectedAddress!.area,
        state.selectedAddress!.city,
      ].where((s) => s.isNotEmpty).join(', '),
      paymentMethod: state.paymentMethod,
      etaMinutes: state.selectedSlot?.etaMinutes,
    );
  }
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutProvider, CheckoutState>(
      (ref) => CheckoutProvider(ref),
    );
