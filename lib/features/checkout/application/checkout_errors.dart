import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';

/// Turns a place_order / quote_order failure into a translated message.
/// The SQL raises fixed English sentences (see
/// supabase/migrations/20261101120000_secure_payments.sql); anything
/// unrecognised falls back to a generic message rather than a raw
/// exception dump.
String friendlyOrderError(Object error) {
  final message = switch (error) {
    PostgrestException(:final message) => message,
    PaymentException(:final message) => message,
    _ => '',
  };

  final outOfStock = RegExp(r'Insufficient stock for (.+)').firstMatch(message);
  if (outOfStock != null) {
    return 'errorOutOfStock'.tr(args: [outOfStock.group(1)!]);
  }
  final unavailable = RegExp(r'Product unavailable: (.+)').firstMatch(message);
  if (unavailable != null) {
    return 'errorProductUnavailable'.tr(args: [unavailable.group(1)!]);
  }
  if (message.contains('Delivery slot')) return 'errorSlotUnavailable'.tr();
  if (message.contains('not serviceable') ||
      message.contains('do not deliver')) {
    return 'errorAddressUnserviceable'.tr();
  }
  if (message.contains('Cart is empty')) return 'errorCartEmpty'.tr();
  return 'errorOrderFailed'.tr();
}
