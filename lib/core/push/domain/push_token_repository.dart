abstract class PushTokenRepository {
  /// Saves this device's FCM token (and the app language, when known) to
  /// the signed-in user's profile (a no-op if nobody is signed in yet), so
  /// order and offer pushes can find it. push_notification_service.dart
  /// calls this on token refresh/first-fetch and right after login.
  Future<void> registerToken(String token, {String? languageCode});

  /// Removes this device's token from the signed-in user's profile, so
  /// the next person to use the device doesn't receive their order
  /// notifications. Called on logout, before the session ends.
  Future<void> clearToken();

  /// The app language (`en`, `bn`, `hi`, `pa`) offer pushes are written in.
  Future<void> setLanguage(String languageCode);

  /// Counts a tap on an offer push (admin campaign stats). Best effort.
  Future<void> recordCampaignOpen(String campaignId);
}
