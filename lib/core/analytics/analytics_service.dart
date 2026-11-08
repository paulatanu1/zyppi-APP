import 'package:firebase_analytics/firebase_analytics.dart';

/// The four funnel events PLAN.md names for Phase 5
/// (view_item/add_to_cart/begin_checkout/purchase); money stays `int`
/// paise everywhere else, but Firebase Analytics' own `value` parameter
/// is a decimal currency amount, so this is the one place paise gets
/// divided by 100 for display to an external system.
class AnalyticsService {
  AnalyticsService._();

  /// Analytics must never break a user action: if Firebase isn't set up
  /// (tests, a failed init), events are simply dropped. Accessing
  /// `FirebaseAnalytics.instance` throws synchronously in that case, so
  /// every call goes through [_log].
  static Future<void> _log(
    Future<void> Function(FirebaseAnalytics analytics) send,
  ) async {
    try {
      await send(FirebaseAnalytics.instance);
    } catch (_) {}
  }

  static Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required int pricePaise,
  }) {
    return _log(
      (a) => a.logViewItem(
        currency: 'INR',
        value: pricePaise / 100,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            price: pricePaise / 100,
          ),
        ],
      ),
    );
  }

  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required int pricePaise,
    required int quantity,
  }) {
    return _log(
      (a) => a.logAddToCart(
        currency: 'INR',
        value: pricePaise * quantity / 100,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            price: pricePaise / 100,
            quantity: quantity,
          ),
        ],
      ),
    );
  }

  static Future<void> logBeginCheckout({required int totalPaise}) {
    return _log(
      (a) => a.logBeginCheckout(currency: 'INR', value: totalPaise / 100),
    );
  }

  static Future<void> logPurchase({
    required String orderId,
    required int totalPaise,
  }) {
    return _log(
      (a) => a.logPurchase(
        transactionId: orderId,
        currency: 'INR',
        value: totalPaise / 100,
      ),
    );
  }
}
