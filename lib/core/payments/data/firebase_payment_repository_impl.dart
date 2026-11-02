import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// Calls the createPhonePeOrder / verifyPhonePePayment Cloud Functions —
/// PhonePe secrets never reach the app, and the server both prices the
/// order and creates it once the payment is confirmed.
class FirebasePaymentRepository implements PaymentRepository {
  final FirebaseFunctions functions;

  FirebasePaymentRepository(this.functions);

  @override
  Future<PaymentOrder> createOrder({
    required String paymentMethod,
    required String addressId,
    required String deliverySlotId,
    String? couponCode,
    int tipPaise = 0,
  }) async {
    final Map<dynamic, dynamic> data;
    try {
      final result = await functions.httpsCallable('createPhonePeOrder').call({
        'paymentMethod': paymentMethod,
        'addressId': addressId,
        'deliverySlotId': deliverySlotId,
        'couponCode': couponCode,
        'tipPaise': tipPaise,
      });
      data = result.data as Map<dynamic, dynamic>;
    } on FirebaseFunctionsException catch (error) {
      // failed-precondition = the order can't be placed (stock, slot,
      // address); the message names the reason.
      throw PaymentException(error.message ?? 'Payment failed');
    }

    return PaymentOrder(
      merchantOrderId: data['merchantOrderId'] as String,
      orderId: data['orderId'] as String,
      token: data['token'] as String,
      merchantId: data['merchantId'] as String,
      amountPaise: data['amountPaise'] as int,
    );
  }

  @override
  Future<PaymentVerification> verifyPayment(String merchantOrderId) async {
    final result = await functions.httpsCallable('verifyPhonePePayment').call({
      'merchantOrderId': merchantOrderId,
    });
    final data = result.data as Map<dynamic, dynamic>;

    return (
      verified: data['verified'] as bool? ?? false,
      pending: data['pending'] as bool? ?? false,
      orderId: data['orderId'] as String?,
      needsReview: data['needsReview'] as bool? ?? false,
    );
  }
}
