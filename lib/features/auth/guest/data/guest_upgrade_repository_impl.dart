import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_upgrade_repository.dart';

/// Firebase account linking: the anonymous user gains a Google account or
/// an email and stops being anonymous; the uid — and everything keyed to
/// it — stays the same.
class FirebaseGuestUpgradeRepository implements GuestUpgradeRepository {
  final FirebaseAuth auth;

  FirebaseGuestUpgradeRepository(this.auth);

  @override
  Future<void> linkEmail({required String email, required String password}) =>
      _guard(
        () => _currentUser().linkWithCredential(
          EmailAuthProvider.credential(email: email.trim(), password: password),
        ),
      );

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

final guestUpgradeRepositoryProvider = Provider<GuestUpgradeRepository>(
  (ref) => FirebaseGuestUpgradeRepository(FirebaseAuth.instance),
);
