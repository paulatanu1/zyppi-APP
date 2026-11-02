import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

// Phase 3: google_sign_in only obtains the Google ID token; Supabase
// Auth's signInWithIdToken exchanges it for a Supabase session
// (replacing the Firebase credential exchange used through Phase 2).
bool _googleInitialized = false;

/// Google's ID token for the user's chosen account (Supabase exchanges or
/// links it). Throws [GoogleSignInCancelled] if they close the picker.
Future<String?> fetchGoogleIdToken() async {
  final googleSignIn = GoogleSignIn.instance;

  if (!_googleInitialized) {
    await googleSignIn.initialize();
    _googleInitialized = true;
  }

  final GoogleSignInAccount googleUser;
  try {
    googleUser = await googleSignIn.authenticate();
  } on GoogleSignInException catch (error) {
    // Closing the account picker isn't an error worth reporting.
    if (error.code == GoogleSignInExceptionCode.canceled) {
      throw const GoogleSignInCancelled();
    }
    rethrow;
  }

  return googleUser.authentication.idToken;
}

class GoogleAuthRepositoryImpl implements GoogleAuthRepository {
  @override
  Future<String?> signIn() async {
    final idToken = await fetchGoogleIdToken();
    if (idToken == null) return null;

    final response = await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return response.session?.accessToken;
  }
}

/// The user closed Google's account picker.
class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>(
  (ref) => GoogleAuthRepositoryImpl(),
);
