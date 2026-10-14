import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

// Phase 1 keeps the existing Firebase phone-auth calls behind this
// interface; Phase 3 swaps the implementation to Supabase Auth OTP.
class OtpAuthRepositoryImpl implements OtpAuthRepository {
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
    required void Function(FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) {
    return FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<void> signInWithCredential(AuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  AuthCredential credentialFromSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}

final otpAuthRepositoryProvider = Provider<OtpAuthRepository>(
  (ref) => OtpAuthRepositoryImpl(),
);
