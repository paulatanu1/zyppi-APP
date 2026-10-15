import 'package:zippy/core/payments/domain/razorpay_order.dart';

abstract class PaymentRepository {
  /// Creates a Razorpay order server-side for [amountPaise]. The returned
  /// [RazorpayOrder.orderId] is what Razorpay Checkout opens against.
  Future<RazorpayOrder> createOrder(int amountPaise);

  /// Verifies the signature Razorpay Checkout returns on success, before
  /// place_order() is trusted to run.
  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}
