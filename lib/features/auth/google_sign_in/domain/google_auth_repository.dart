abstract class GoogleAuthRepository {
  /// Signs the user in with Google (via Supabase Auth's
  /// signInWithIdToken), returning the session's access token on
  /// success.
  Future<String?> signIn();
}
