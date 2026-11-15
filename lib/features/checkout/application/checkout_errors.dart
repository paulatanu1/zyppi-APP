import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// Turns a placeOrder / createPayUOrder failure into a translated
/// message. The functions return fixed English sentences (OrderError in
/// functions/src/orders/quote.ts) as the error message; anything
/// unrecognised falls back to a generic message rather than a raw
/// exception dump.
String friendlyOrderError(Object error) {
  final message = switch (error) {
    FirebaseFunctionsException(:final message) => message ?? '',
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
  final minOrder = RegExp(r'MIN_ORDER_NOT_MET:(\d+)').firstMatch(message);
  if (minOrder != null) {
    return 'errorMinOrder'.tr(args: [rupees(int.parse(minOrder.group(1)!))]);
  }
  if (message.contains('Delivery slot')) return 'errorSlotUnavailable'.tr();
  if (message.contains('not serviceable') ||
      message.contains('do not deliver')) {
    return 'errorAddressUnserviceable'.tr();
  }
  if (message.contains('Cart is empty')) return 'errorCartEmpty'.tr();
  // functions/src: STORES_CLOSED (store hours), ACCOUNT_BLOCKED (admin),
  // closed areas and switched-off payment methods (config/features).
  if (message.contains('STORES_CLOSED')) return 'errorStoresClosed'.tr();
  if (message.contains('ACCOUNT_BLOCKED')) return 'errorAccountBlocked'.tr();
  if (message.contains('Ordering is paused')) return 'errorOrderingPaused'.tr();
  if (message.contains('payment method is unavailable')) {
    return 'errorPaymentMethodOff'.tr();
  }
  if (message.contains('taking a short break')) {
    return 'maintenanceMessage'.tr();
  }
  // COUPON_MESSAGES in functions/src/coupons/model.ts.
  final coupon = switch (message) {
    'Coupon has expired' => 'couponExpired',
    'Coupon has been fully used' => 'couponUsedUp',
    'Coupon limit reached for your account' => 'couponUserLimit',
    'Coupon is for first orders only' => 'couponFirstOrderOnly',
    'Coupon is not available in your area' => 'couponNotInArea',
    'Coupon is not valid' => 'invalidCoupon',
    _ => null,
  };
  if (coupon != null) return coupon.tr();
  return 'errorOrderFailed'.tr();
}
