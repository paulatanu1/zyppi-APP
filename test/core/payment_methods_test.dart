import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/payments/presentation/payment_options.dart';

void main() {
  test('without ONLINE_PAYMENTS_ENABLED only cash on delivery is offered', () {
    expect(availablePaymentMethods, [codPaymentMethod]);
    expect(defaultPaymentMethod, codPaymentMethod);
  });
}
