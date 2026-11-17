import 'package:zippy/features/notifications/domain/app_notification.dart';

/// The signed-in customer's notification list. Screens use only this
/// interface; Firestore stays in the data layer.
abstract class NotificationsRepository {
  /// Newest first, at most [limit]. Empty when nobody is signed in.
  Stream<List<AppNotification>> watch({int limit = 50});

  Future<void> markRead(String id);

  Future<void> markAllRead(Iterable<String> ids);

  Future<void> remove(String id);
}
