import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/utils/auth_errors.dart';
import 'package:zippy/features/checkout/application/checkout_errors.dart';

// Without a loaded locale, .tr() returns the key, so these assert which
// translation key each Firebase error maps to.
void main() {
  group('friendlyAuthError', () {
    String keyFor(String code) =>
        friendlyAuthError(FirebaseAuthException(code: code));

    test('maps Firebase Auth codes to messages', () {
      expect(keyFor('invalid-verification-code'), 'otpInvalid');
      expect(keyFor('session-expired'), 'otpInvalid');
      expect(keyFor('too-many-requests'), 'tooManyAttempts');
      expect(keyFor('invalid-phone-number'), 'invalidPhone');
      expect(keyFor('network-request-failed'), 'noInternet');
      expect(keyFor('operation-not-allowed'), 'signInMethodUnavailable');
      expect(keyFor('something-new'), 'somethingWentWrong');
    });

    test('anything else is a generic error', () {
      expect(friendlyAuthError(StateError('x')), 'somethingWentWrong');
    });
  });

  group('friendlyOrderError', () {
    String keyFor(String message) => friendlyOrderError(
      FirebaseFunctionsException(code: 'failed-precondition', message: message),
    );

    test('recognises the placeOrder function messages', () {
      expect(keyFor('Insufficient stock for Toned Milk'), 'errorOutOfStock');
      expect(
        keyFor('Product unavailable: Toned Milk'),
        'errorProductUnavailable',
      );
      expect(keyFor('Delivery slot is not available'), 'errorSlotUnavailable');
      expect(
        keyFor('Address not found or not serviceable'),
        'errorAddressUnserviceable',
      );
      expect(keyFor('Cart is empty'), 'errorCartEmpty');
      expect(keyFor('INTERNAL'), 'errorOrderFailed');
    });
  });
}
