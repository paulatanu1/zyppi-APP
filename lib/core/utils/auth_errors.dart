import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A translated, user-facing message for a sign-in failure, instead of the
/// raw `[firebase_auth/…]` exception dump.
String friendlyAuthError(Object error) {
  if (error is SocketException) return 'noInternet'.tr();
  if (error is! FirebaseAuthException) return 'somethingWentWrong'.tr();

  return switch (error.code) {
    'network-request-failed' => 'noInternet'.tr(),
    'invalid-verification-code' ||
    'invalid-verification-id' ||
    'session-expired' ||
    'code-expired' => 'otpInvalid'.tr(),
    'too-many-requests' || 'quota-exceeded' => 'tooManyAttempts'.tr(),
    'invalid-phone-number' || 'missing-phone-number' => 'invalidPhone'.tr(),
    'app-not-authorized' ||
    'missing-client-identifier' ||
    'captcha-check-failed' => 'smsSendFailed'.tr(),
    'operation-not-allowed' ||
    'admin-restricted-operation' => 'signInMethodUnavailable'.tr(),
    _ => 'somethingWentWrong'.tr(),
  };
}
