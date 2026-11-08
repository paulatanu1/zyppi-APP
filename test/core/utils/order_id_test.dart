import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/utils/order_id.dart';

void main() {
  test('shortens server UUIDs to their first block', () {
    expect(shortOrderId('3f2a9c1b-1234-4abc-9def-0123456789ab'), '3F2A9C1B');
  });

  test('leaves mock ids alone', () {
    expect(shortOrderId('order-1730000000000'), 'order-1730000000000');
  });
}
