abstract class GoogleAuthRepository {
  /// Signs the user in with Google (via Firebase Auth
  /// signInWithCredential), returning the user id on
  /// success.
  Future<String?> signIn();
}
