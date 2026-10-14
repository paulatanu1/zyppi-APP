import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

// Phase 3: google_sign_in only obtains the Google ID token; Supabase
// Auth's signInWithIdToken exchanges it for a Supabase session
// (replacing the Firebase credential exchange used through Phase 2).
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

    final idToken = googleAuth.idToken;
    if (idToken == null) return null;

    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return response.session?.accessToken;
  }
}

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>(
  (ref) => GoogleAuthRepositoryImpl(),
);
