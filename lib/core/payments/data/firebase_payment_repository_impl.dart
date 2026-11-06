import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// Calls the createPayUOrder / signPayUHash / verifyPayUPayment Cloud
/// Functions — the PayU salt never reaches the app, and the server both
/// prices the order and creates it once the payment is confirmed.
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
      final result = await functions.httpsCallable('createPayUOrder').call({
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
      txnid: data['txnid'] as String,
      key: data['key'] as String,
      amount: data['amount'] as String,
      productInfo: data['productInfo'] as String,
      firstName: data['firstName'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      environment: data['environment'] as String,
      userCredential: data['userCredential'] as String,
      amountPaise: data['amountPaise'] as int,
    );
  }

  @override
  Future<Map<String, String>> signHash(Map<dynamic, dynamic> request) async {
    final result = await functions.httpsCallable('signPayUHash').call({
      'hashName': request['hashName'],
      'hashString': request['hashString'],
      'hashType': request['hashType'],
      'postSalt': request['postSalt'],
    });
    return (result.data as Map<dynamic, dynamic>).map(
      (name, hash) => MapEntry(name as String, hash as String),
    );
  }

  @override
  Future<PaymentVerification> verifyPayment(String txnid) async {
    final result = await functions.httpsCallable('verifyPayUPayment').call({
      'txnid': txnid,
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
