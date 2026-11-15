import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/push/push_destination.dart';

void main() {
  test('order updates replace the stack with tracking', () {
    final d = pushDestination({'orderId': 'o1', 'status': 'packed'});
    expect(d, isA<OpenRoute>());
    d as OpenRoute;
    expect(d.location, '/orderTrackingScreen?orderId=o1');
    expect(d.replace, isTrue);
  });

  test('support replies open the chat, with the order when there is one', () {
    expect(
      (pushDestination({
        'chatId': 'c',
        'chatOrderId': 'o9',
      }) as OpenRoute).location,
      '/supportChat?orderId=o9',
    );
    expect(
      (pushDestination({'chatId': 'c'}) as OpenRoute).location,
      '/supportChat',
    );
  });

  test('offer pushes open their product, category, coupon or page', () {
    final product = pushDestination({
      'campaignId': 'k',
      'linkType': 'product',
      'linkTarget': 'p 1',
    });
    expect(
      (product as OpenRoute).location,
      '/productDetailsScreen?productId=p+1',
    );
    expect(product.replace, isFalse);
    expect(
      (pushDestination({
        'linkType': 'category',
        'linkTarget': 'c1',
      }) as OpenRoute).location,
      '/categoryDetailsScreen?categoryId=c1',
    );
    expect(
      (pushDestination({
        'linkType': 'coupon',
        'linkTarget': 'FRESH20',
      }) as ApplyCoupon).code,
      'FRESH20',
    );
    expect(
      (pushDestination({
        'linkType': 'url',
        'linkTarget': 'https://zyppi.one/x',
      }) as OpenUrl).url.host,
      'zyppi.one',
    );
  });

  test('anything else just opens the app', () {
    expect(pushDestination({'linkType': 'none', 'linkTarget': ''}), isNull);
    expect(
      pushDestination({'linkType': 'url', 'linkTarget': 'http://x.y'}),
      isNull,
    );
    expect(pushDestination({'linkType': 'product'}), isNull);
    expect(pushDestination(const {}), isNull);
  });
}
