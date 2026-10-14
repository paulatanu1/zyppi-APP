abstract class GoogleAuthRepository {
  /// Signs the user in with Google and Firebase, returning the Google ID
  /// token on success.
  Future<String?> signIn();
}
