import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/payments/data/supabase_payment_repository_impl.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';
import 'package:zippy/core/payments/domain/razorpay_order.dart';

/// The mock flavor has no real gateway to open, so checkout_provider.dart
/// never actually calls this - it short-circuits straight to place_order()
/// for any payment method when Env.isMockDataSource. This exists only so
/// the provider stays safe to read either way (Supabase.instance.client
/// isn't initialized in mock mode).
class MockPaymentRepository implements PaymentRepository {
  @override
  Future<RazorpayOrder> createOrder(int amountPaise) async {
    throw UnsupportedError('No Razorpay gateway in the mock flavor');
  }

  @override
  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    throw UnsupportedError('No Razorpay gateway in the mock flavor');
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => Env.isMockDataSource
      ? MockPaymentRepository()
      : SupabasePaymentRepository(Supabase.instance.client),
);
