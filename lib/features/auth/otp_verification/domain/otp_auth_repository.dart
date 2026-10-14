import 'package:firebase_auth/firebase_auth.dart';

abstract class OtpAuthRepository {
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
    required void Function(FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });

  Future<void> signInWithCredential(AuthCredential credential);

  AuthCredential credentialFromSmsCode({
    required String verificationId,
    required String smsCode,
  });
}
