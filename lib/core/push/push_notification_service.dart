import 'dart:async';

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
    final repository = container.read(pushTokenRepositoryProvider);

    // Handlers first: a token or permission failure (offline, no APNs
    // token on iOS…) must never leave taps and foreground messages
    // unhandled.
    FirebaseMessaging.onMessage.listen((message) {
      final body = message.notification?.body;
      if (body != null) showSuccessToast(message: body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openTracking(router, message),
    );

    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _openTracking(router, initialMessage);
    } catch (_) {}

    try {
      await messaging.requestPermission();
    } catch (_) {}

    await _register(repository);
    messaging.onTokenRefresh.listen((_) => _register(repository));
  }

  /// Call right after login, in case the device token was already fetched
  /// before the user signed in (so it was skipped - no user id yet).
  /// Takes the repository itself (read it *before* the login flow
  /// navigates away and disposes its provider). Never throws: a push
  /// failure must not make a successful login look failed.
  static void registerTokenAfterLogin(PushTokenRepository repository) {
    if (Env.isMockDataSource) return;
    unawaited(_register(repository));
  }

  static Future<void> _register(PushTokenRepository repository) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await repository.registerToken(token);
    } catch (_) {
      // Retried on the next token refresh / login.
    }
  }

  static void _openTracking(GoRouter router, RemoteMessage message) {
    // Support team replies (functions/src/support/chat.ts).
    if (message.data['chatId'] != null) {
      final orderId = message.data['chatOrderId'] as String? ?? '';
      router.push(
        orderId.isEmpty ? '/supportChat' : '/supportChat?orderId=$orderId',
      );
      return;
    }
    final orderId = message.data['orderId'] as String?;
    if (orderId != null) {
      router.go('/orderTrackingScreen?orderId=$orderId');
    }
  }
}
