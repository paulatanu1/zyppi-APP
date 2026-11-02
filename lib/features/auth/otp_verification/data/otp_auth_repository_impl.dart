import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/otp_verification/data/phone_verifier.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

/// Firebase phone auth. For testing without real SMS, add test numbers
/// under Authentication → Sign-in method → Phone in the Firebase console.
class FirebaseOtpAuthRepository implements OtpAuthRepository {
  final FirebaseAuth auth;
  final PhoneVerifier _verifier;

  FirebaseOtpAuthRepository(this.auth) : _verifier = PhoneVerifier(auth);

  @override
  Future<void> sendOtp(String phoneNumber) => _verifier.sendCode(phoneNumber);

  /// Returns the user id as the app's local "signed in" marker; Firebase
  /// keeps (and refreshes) the real session itself.
  @override
  Future<String?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final result = await auth.signInWithCredential(
      _verifier.credentialFor(otp),
    );
    return result.user?.uid;
  }
}

// Not autoDispose: the verifier must survive from "send code" to "verify".
final otpAuthRepositoryProvider = Provider<OtpAuthRepository>(
  (ref) => FirebaseOtpAuthRepository(FirebaseAuth.instance),
);
