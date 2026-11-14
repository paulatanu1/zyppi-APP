/// Where tapping a push takes the customer. Pure, so it can be tested
/// without FCM. Payloads come from functions/src/push.ts (orders),
/// support/chat.ts (support replies) and notifications/model.ts
/// (campaigns: `campaignId`, `linkType`, `linkTarget`).
sealed class PushDestination {
  const PushDestination();
}

/// A route in the app.
class OpenRoute extends PushDestination {
  final String location;

  /// Replace the stack (order tracking) instead of pushing on top.
  final bool replace;

  const OpenRoute(this.location, {this.replace = false});
}

/// A web page, outside the app.
class OpenUrl extends PushDestination {
  final Uri url;

  const OpenUrl(this.url);
}

/// The cart, with this coupon applied.
class ApplyCoupon extends PushDestination {
  final String code;

  const ApplyCoupon(this.code);
}

PushDestination? pushDestination(Map<String, dynamic> data) {
  if (data['chatId'] != null) {
    final orderId = data['chatOrderId'] as String? ?? '';
    return OpenRoute(
      orderId.isEmpty ? '/supportChat' : '/supportChat?orderId=$orderId',
    );
  }
  if (data['orderId'] case final String orderId when orderId.isNotEmpty) {
    return OpenRoute('/orderTrackingScreen?orderId=$orderId', replace: true);
  }
  final target = data['linkTarget'] as String? ?? '';
  if (target.isEmpty) return null;
  final encoded = Uri.encodeQueryComponent(target);
  return switch (data['linkType']) {
    'product' => OpenRoute('/productDetailsScreen?productId=$encoded'),
    'category' => OpenRoute('/categoryDetailsScreen?categoryId=$encoded'),
    'coupon' => ApplyCoupon(target),
    'url' => switch (Uri.tryParse(target)) {
      final uri? when uri.scheme == 'https' => OpenUrl(uri),
      _ => null,
    },
    _ => null,
  };
}
