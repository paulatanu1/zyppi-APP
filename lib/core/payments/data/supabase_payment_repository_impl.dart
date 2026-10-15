import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';
import 'package:zippy/core/payments/domain/razorpay_order.dart';

/// Calls create-razorpay-order / verify-razorpay-payment (Edge Functions) -
/// RAZORPAY_KEY_SECRET never reaches the client.
class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient client;

  SupabasePaymentRepository(this.client);

  @override
  Future<RazorpayOrder> createOrder(int amountPaise) async {
    final response = await client.functions.invoke(
      'create-razorpay-order',
      body: {'amountPaise': amountPaise},
    );
    final data = response.data as Map<String, dynamic>;

    return RazorpayOrder(
      orderId: data['orderId'] as String,
      amountPaise: data['amountPaise'] as int,
      currency: data['currency'] as String,
      keyId: data['keyId'] as String,
    );
  }

  @override
  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await client.functions.invoke(
      'verify-razorpay-payment',
      body: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    final data = response.data as Map<String, dynamic>;

    return data['verified'] as bool;
  }
}
