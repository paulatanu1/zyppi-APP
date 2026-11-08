import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zippy/features/auth/google_sign_in/domain/google_auth_repository.dart';

// google_sign_in only obtains the Google ID token; Firebase Auth exchanges
// it for a Firebase session (signInWithCredential).
bool _googleInitialized = false;

/// Google's ID token for the user's chosen account (Firebase exchanges or
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

    final result = await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );

    // The uid is the app's local "signed in" marker; Firebase keeps the
    // real session.
    return result.user?.uid;
  }
}

/// The user closed Google's account picker.
class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

final googleAuthRepositoryProvider = Provider<GoogleAuthRepository>(
  (ref) => GoogleAuthRepositoryImpl(),
);
