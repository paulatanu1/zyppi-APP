import 'package:zippy/core/payments/domain/payment_order.dart';

/// Result of asking the server whether a PayU payment went through.
typedef PaymentVerification = ({
  /// PayU reports the payment captured for the quoted amount.
  bool verified,

  /// Not settled yet; check again shortly.
  bool pending,

  /// The order the server created from this payment, once it has.
  String? orderId,

  /// Paid, but the order couldn't be created (stock ran out, amount
  /// mismatch…). Support has to refund or fulfil it manually.
  bool needsReview,
});

abstract class PaymentRepository {
  /// Quotes the caller's server cart and opens a PayU payment for that
  /// amount ([paymentMethod] is `'UPI'` or `'Credit or debit card'`). The amount is computed server-side; the
  /// returned [PaymentOrder.amountPaise] is what the customer will pay.
  /// Throws [PaymentException] if the order can't be placed (stock,
  /// serviceability…) — before any money moves.
  Future<PaymentOrder> createOrder({
    required String paymentMethod,
    required String addressId,
    required String deliverySlotId,
    String? couponCode,
    int tipPaise = 0,
  });

  /// Checks a payment and, once it has completed, lets the server create
  /// the order. Safe to call repeatedly for the same [txnid].
  Future<PaymentVerification> verifyPayment(String txnid);

  /// Has the server sign a hash PayU CheckoutPro asks for (its
  /// `generateHash` callback) — the salt never reaches the app. [request]
  /// is the SDK's map (hashName, hashString, hashType, postSalt); returns
  /// `{hashName: hash}` for `hashGenerated`.
  Future<Map<String, String>> signHash(Map<dynamic, dynamic> request);
}

/// A user-presentable reason a payment couldn't start.
class PaymentException implements Exception {
  final String message;

  const PaymentException(this.message);

  @override
  String toString() => message;
}
