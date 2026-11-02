import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/payments/data/payment_repository_impl.dart';
import 'package:zippy/core/payments/data/pending_payment_store.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// On app start: if a PhonePe payment was started but never confirmed as
/// an order (the app was killed while paying), ask the server once. The
/// server creates the order from a completed payment, so the customer
/// isn't left charged without an order — or asked to pay again.
/// Network failures keep the payment pending for checkout to re-check.
Future<void> resumePendingPayment(ProviderContainer container) async {
  if (Env.isMockDataSource) return;

  final store = container.read(pendingPaymentStoreProvider);
  final merchantOrderId = store.read();
  if (merchantOrderId == null) return;

  try {
    final result = await container
        .read(paymentRepositoryProvider)
        .verifyPayment(merchantOrderId);

    if (result.orderId != null) {
      await store.clear();
      await container.read(cartProvider.notifier).clear();
      showSuccessToast(message: 'orderPlacedAfterPayment'.tr());
    } else if (result.needsReview) {
      await store.clear();
      showSuccessToast(message: 'paymentNeedsReview'.tr());
    } else if (!result.verified && !result.pending) {
      await store.clear(); // never paid; nothing to recover
    }
  } catch (_) {
    // Offline etc.: leave it for checkout to re-check.
  }
}
