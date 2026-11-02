abstract class GuestAuthRepository {
  /// Signs in without credentials (Play Store / payment-gateway review).
  /// Returns the session's access token on success.
  Future<String?> signIn();
}
