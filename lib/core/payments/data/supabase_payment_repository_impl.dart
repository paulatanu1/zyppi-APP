import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// Calls create-phonepe-order / verify-phonepe-payment (Edge Functions) -
/// PHONEPE_CLIENT_SECRET never reaches the client, and the server both
/// prices the order and creates it once the payment is confirmed.
class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient client;

  SupabasePaymentRepository(this.client);

  @override
  Future<PaymentOrder> createOrder({
    required String paymentMethod,
    required String addressId,
    required String deliverySlotId,
    String? couponCode,
    int tipPaise = 0,
  }) async {
    final Map<String, dynamic> data;
    try {
      final response = await client.functions.invoke(
        'create-phonepe-order',
        body: {
          'paymentMethod': paymentMethod,
          'addressId': addressId,
          'deliverySlotId': deliverySlotId,
          'couponCode': couponCode,
          'tipPaise': tipPaise,
        },
      );
      data = response.data as Map<String, dynamic>;
    } on FunctionException catch (error) {
      // 409 = the order can't be placed (stock, slot, address); the
      // server's message names the reason.
      final details = error.details;
      final message = details is Map ? details['error'] as String? : null;
      throw PaymentException(message ?? error.reasonPhrase ?? 'Payment failed');
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
    final response = await client.functions.invoke(
      'verify-phonepe-payment',
      body: {'merchantOrderId': merchantOrderId},
    );
    final data = response.data as Map<String, dynamic>;

    return (
      verified: data['verified'] as bool? ?? false,
      pending: data['pending'] as bool? ?? false,
      orderId: data['orderId'] as String?,
      needsReview: data['needsReview'] as bool? ?? false,
    );
  }
}
