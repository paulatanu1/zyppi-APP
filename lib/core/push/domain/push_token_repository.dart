abstract class PushTokenRepository {
  /// Saves this device's FCM token to the signed-in user's profile (a
  /// no-op if nobody is signed in yet), so push-on-order-event can find
  /// it. push_notification_service.dart calls this on token
  /// refresh/first-fetch and right after login.
  Future<void> registerToken(String token);
}
