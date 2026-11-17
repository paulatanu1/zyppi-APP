import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/push/domain/push_token_repository.dart';
import 'package:zippy/core/push/push_destination.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/snack_bar.dart';

/// Wires FCM: permission + token registration (push_token_repository_impl
/// writes it to `users/{uid}.fcmToken`), a SnackBar for foreground
/// notifications, and deep links when the user taps one (background or
/// cold-start): order tracking, support chat, or an offer's product,
/// category, coupon or web page (push_destination.dart).
class PushNotificationService {
  PushNotificationService._();

  /// The app language (`en`, `bn`, `hi`, `pa`), kept current by the app
  /// root, so offer pushes arrive in it.
  static String? languageCode;

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
      (message) => _open(container, router, message),
    );

    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _open(container, router, initialMessage);
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
      if (token != null) {
        await repository.registerToken(token, languageCode: languageCode);
      }
    } catch (_) {
      // Retried on the next token refresh / login.
    }
  }

  /// A tapped notification: open what it points at, and count the tap
  /// for offer campaigns.
  static void _open(
    ProviderContainer container,
    GoRouter router,
    RemoteMessage message,
  ) {
    if (message.data['campaignId'] case final String id when id.isNotEmpty) {
      unawaited(
        container
            .read(pushTokenRepositoryProvider)
            .recordCampaignOpen(id)
            .catchError((Object _) {}),
      );
    }
    switch (pushDestination(message.data)) {
      case OpenRoute(:final location, replace: true):
        router.go(location);
      case OpenRoute(:final location):
        router.push(location);
      case OpenUrl(:final url):
        unawaited(openExternal(url));
      case ApplyCoupon(:final code):
        router.push('/myCartScreen');
        unawaited(container.read(cartProvider.notifier).applyCoupon(code));
      case null:
        break;
    }
  }
}
