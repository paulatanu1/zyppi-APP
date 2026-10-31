import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// Calls create-phonepe-order / verify-phonepe-payment (Edge Functions) -
/// PHONEPE_CLIENT_SECRET never reaches the client.
class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient client;

  SupabasePaymentRepository(this.client);

  @override
  Future<PaymentOrder> createOrder(
    int amountPaise, {
    required String paymentMethod,
  }) async {
    final response = await client.functions.invoke(
      'create-phonepe-order',
      body: {'amountPaise': amountPaise, 'paymentMethod': paymentMethod},
    );
    final data = response.data as Map<String, dynamic>;

    return PaymentOrder(
      merchantOrderId: data['merchantOrderId'] as String,
      orderId: data['orderId'] as String,
      token: data['token'] as String,
      merchantId: data['merchantId'] as String,
    );
  }

  @override
  Future<({bool verified, String? transactionId})> verifyPayment(
    String merchantOrderId,
  ) async {
    final response = await client.functions.invoke(
      'verify-phonepe-payment',
      body: {'merchantOrderId': merchantOrderId},
    );
    final data = response.data as Map<String, dynamic>;

    return (
      verified: data['verified'] as bool,
      transactionId: data['transactionId'] as String?,
    );
  }
}
