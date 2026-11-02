abstract class PushTokenRepository {
  /// Saves this device's FCM token to the signed-in user's profile (a
  /// no-op if nobody is signed in yet), so push-on-order-event can find
  /// it. push_notification_service.dart calls this on token
  /// refresh/first-fetch and right after login.
  Future<void> registerToken(String token);

  /// Removes this device's token from the signed-in user's profile, so
  /// the next person to use the device doesn't receive their order
  /// notifications. Called on logout, before the session ends.
  Future<void> clearToken();
}
