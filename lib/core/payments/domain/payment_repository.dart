import 'package:zippy/core/payments/domain/payment_order.dart';

abstract class PaymentRepository {
  /// Creates a PhonePe order server-side for [amountPaise], restricted to
  /// the instrument the user picked ([paymentMethod]: `'UPI'` or
  /// `'Credit or debit card'`). The returned [PaymentOrder] is what the
  /// PhonePe SDK's PAY_PAGE opens against.
  Future<PaymentOrder> createOrder(
    int amountPaise, {
    required String paymentMethod,
  });

  /// Confirms a PhonePe order's status server-side before place_order()
  /// is trusted to run.
  Future<({bool verified, String? transactionId})> verifyPayment(
    String merchantOrderId,
  );
}
