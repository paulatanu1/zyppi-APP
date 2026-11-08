import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/payments/data/firebase_payment_repository_impl.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// The mock flavor has no real gateway to open, so checkout_provider.dart
/// never actually calls this - it short-circuits straight to placeOrder()
/// for any payment method when Env.isMockDataSource. This exists only so
/// the provider stays safe to read either way.
class MockPaymentRepository implements PaymentRepository {
  @override
  Future<PaymentOrder> createOrder({
    required String paymentMethod,
    required String addressId,
    required String deliverySlotId,
    String? couponCode,
    int tipPaise = 0,
  }) async {
    throw UnsupportedError('No PayU gateway in the mock flavor');
  }

  @override
  Future<PaymentVerification> verifyPayment(String txnid) async {
    throw UnsupportedError('No PayU gateway in the mock flavor');
  }

  @override
  Future<Map<String, String>> signHash(Map<dynamic, dynamic> request) async {
    throw UnsupportedError('No PayU gateway in the mock flavor');
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => Env.isMockDataSource
      ? MockPaymentRepository()
      : FirebasePaymentRepository(zyppiFunctions()),
);
