import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

enum AppNotificationKind { order, offer, support, account }

/// users/{uid}/notifications/{id}: one entry in Account → Notifications.
/// Written only by Cloud Functions (functions/src/notifications/inbox.ts);
/// removed automatically 30 days later (Firestore TTL on `expireAt`).
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required AppNotificationKind kind,
    required String title,
    required String body,
    DateTime? at,
    @Default(false) bool read,
    String? imageUrl,

    /// The same fields a push carries (`orderId`, `linkType`, …), read by
    /// push_destination.dart to decide where a tap goes.
    @Default(<String, String>{}) Map<String, String> data,
  }) = _AppNotification;
}
