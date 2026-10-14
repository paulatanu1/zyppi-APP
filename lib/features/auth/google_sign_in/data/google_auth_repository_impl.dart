import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

// Phase 1 keeps the existing google_sign_in + Firebase calls behind this
// interface; Phase 3 swaps the implementation to Supabase Auth's
// signInWithIdToken.
class GoogleAuthRepositoryImpl implements GoogleAuthRepository {
  bool _initialized = false;

  @override
  Future<String?> signIn() async {
    final googleSignIn = GoogleSignIn.instance;

    if (!_initialized) {
      await googleSignIn.initialize();
      _initialized = true;
    }

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    return googleAuth.idToken;
  }
}

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>(
  (ref) => GoogleAuthRepositoryImpl(),
);
