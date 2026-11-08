import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_upgrade_repository.dart';
import 'package:zippy/features/auth/otp_verification/data/phone_verifier.dart';

/// Firebase account linking: the anonymous user gains a phone number or a
/// Google account and stops being anonymous; the uid — and everything keyed
/// to it — stays the same.
class FirebaseGuestUpgradeRepository implements GuestUpgradeRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final PhoneVerifier _verifier;

  FirebaseGuestUpgradeRepository(this.auth, this.firestore)
    : _verifier = PhoneVerifier(auth);

  @override
  Future<void> sendPhoneCode(String phone) =>
      _guard(() => _verifier.sendCode(phone));

  @override
  Future<void> verifyPhoneCode({
    required String phone,
    required String code,
  }) async {
    final user = _currentUser();
    await _guard(() => user.linkWithCredential(_verifier.credentialFor(code)));

    // Keep the profile's phone in step for the account screen.
    await firestore.collection('users').doc(user.uid).set({
      'phone': phone,
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> linkGoogle() async {
    final String? idToken;
    try {
      idToken = await fetchGoogleIdToken();
    } on GoogleSignInCancelled {
      return false;
    }
    if (idToken == null) return false;

    final user = _currentUser();
    await _guard(
      () => user.linkWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      ),
    );
    return true;
  }

  User _currentUser() {
    final user = auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');
    return user;
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use' ||
          error.code == 'provider-already-linked' ||
          error.code == 'account-exists-with-different-credential' ||
          error.code == 'email-already-in-use') {
        throw const AccountAlreadyExists();
      }
      rethrow;
    }
  }
}

// Not autoDispose: the verifier must survive from "send code" to "verify".
final guestUpgradeRepositoryProvider = Provider<GuestUpgradeRepository>(
  (ref) => FirebaseGuestUpgradeRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  ),
);
