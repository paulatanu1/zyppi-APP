import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase's callback-style `verifyPhoneNumber` as two awaitable
/// steps — send a code, then turn the typed code into a credential — and
/// keeps the verification id / resend token in between.
///
/// On Android, Firebase may verify the number by itself (instant
/// verification or SMS auto-retrieval); that credential is kept and used
/// whatever code the user then confirms.
class PhoneVerifier {
  final FirebaseAuth auth;

  PhoneVerifier(this.auth);

  String? _phone;
  String? _verificationId;
  int? _resendToken;
  PhoneAuthCredential? _autoCredential;

  /// Texts a code to [phoneNumber] (E.164). Completes once the code is
  /// sent (or the number was verified automatically).
  Future<void> sendCode(String phoneNumber) {
    final completer = Completer<void>();
    final resend = phoneNumber == _phone ? _resendToken : null;
    _phone = phoneNumber;
    _verificationId = null;
    _autoCredential = null;

    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resend,
      verificationCompleted: (credential) {
        _autoCredential = credential;
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId ??= verificationId;
      },
    );

    return completer.future;
  }

  /// The credential for [code], or the auto-verified one.
  PhoneAuthCredential credentialFor(String code) {
    final auto = _autoCredential;
    if (auto != null) return auto;

    final verificationId = _verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(code: 'session-expired');
    }
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
  }
}
