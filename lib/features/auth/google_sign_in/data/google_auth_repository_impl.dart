import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zippy/core/firebase/report_error.dart';
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
  } on GoogleSignInException catch (error, stack) {
    // Closing the account picker isn't an error worth reporting. But
    // Credential Manager also reports server-side failures as "canceled"
    // (e.g. "[16] Account reauth failed." when the app's SHA-1 isn't
    // registered in Firebase), so only a real user cancel stays silent.
    if (error.code == GoogleSignInExceptionCode.canceled &&
        _isUserCancel(error)) {
      throw const GoogleSignInCancelled();
    }
    reportNonFatal(error, stack, reason: 'Google sign-in failed');
    rethrow;
  }

  return googleUser.authentication.idToken;
}

/// Whether a `canceled` result came from the user closing the picker
/// ("activity is cancelled by the user.") rather than a failure Google
/// reported as a cancel.
bool _isUserCancel(GoogleSignInException error) {
  final description = error.description?.toLowerCase();
  return description == null || description.contains('cancel');
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
