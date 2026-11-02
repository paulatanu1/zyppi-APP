import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A translated, user-facing message for a sign-in failure, instead of the
/// raw `AuthApiException(message: …, statusCode: …)` dump.
String friendlyAuthError(Object error) {
  if (error is SocketException || error is AuthRetryableFetchException) {
    return 'noInternet'.tr();
  }
  if (error is AuthException) {
    return switch (error.code) {
      'otp_expired' => 'otpInvalid'.tr(),
      'over_sms_send_rate_limit' ||
      'over_request_rate_limit' => 'tooManyAttempts'.tr(),
      'sms_send_failed' => 'smsSendFailed'.tr(),
      'validation_failed' => 'invalidPhone'.tr(),
      'anonymous_provider_disabled' ||
      'phone_provider_disabled' => 'signInMethodUnavailable'.tr(),
      _ => 'somethingWentWrong'.tr(),
    };
  }
  return 'somethingWentWrong'.tr();
}
