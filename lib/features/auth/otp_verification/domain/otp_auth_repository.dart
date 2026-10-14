abstract class OtpAuthRepository {
  /// Triggers an SMS OTP to [phoneNumber] (E.164, e.g. "+9198765...").
  Future<void> sendOtp(String phoneNumber);

  /// Verifies the OTP and signs in. Returns the session's access token
  /// on success.
  Future<String?> verifyOtp({required String phoneNumber, required String otp});
}
