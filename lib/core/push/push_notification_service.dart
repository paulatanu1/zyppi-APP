import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/push/domain/push_token_repository.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// Wires FCM: permission + token registration (push_token_repository_impl
/// writes it to `profiles.fcm_token`), a SnackBar for foreground
/// notifications, and deep-linking into order tracking when the user
/// taps one (background or cold-start). The push-on-order-event Edge
/// Function is what actually sends these (PLAN.md Phase 4).
class PushNotificationService {
  PushNotificationService._();

  static Future<void> initialize(
    ProviderContainer container,
    GoRouter router,
  ) async {
    if (Env.isMockDataSource) return; // no backend to deliver tokens to

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    Future<void> registerCurrentToken() async {
      final token = await messaging.getToken();
      if (token != null) {
        await container.read(pushTokenRepositoryProvider).registerToken(token);
      }
    }

    await registerCurrentToken();
    messaging.onTokenRefresh.listen((_) => registerCurrentToken());

    FirebaseMessaging.onMessage.listen((message) {
      final body = message.notification?.body;
      if (body != null) showSuccessToast(message: body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openTracking(router, message),
    );

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _openTracking(router, initialMessage);
  }

  /// Call right after login, in case the device token was already fetched
  /// before the user signed in (so it was skipped - no user id yet).
  /// Takes a bare `.read` tear-off so it works from both a `Ref` (login
  /// notifiers) and the bootstrap `ProviderContainer`.
  static Future<void> registerTokenAfterLogin(
    PushTokenRepository Function(Provider<PushTokenRepository>) read,
  ) async {
    if (Env.isMockDataSource) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await read(pushTokenRepositoryProvider).registerToken(token);
    }
  }

  static void _openTracking(GoRouter router, RemoteMessage message) {
    final orderId = message.data['orderId'] as String?;
    if (orderId != null) {
      router.go('/orderTrackingScreen?orderId=$orderId');
    }
  }
}
