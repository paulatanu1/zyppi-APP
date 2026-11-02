import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/app/app.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/common_widgets/app_error_widget.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/favourites/data/favourites_repository_impl.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
import 'package:zippy/core/payments/application/resume_pending_payment.dart';
import 'package:zippy/core/push/push_notification_service.dart';
import 'package:zippy/core/shared_providers/location/provider/request_location_provider.dart';
import 'package:zippy/routes/routes.dart';

/// Shared startup for every flavor (dev/staging/prod), selected via
/// `--dart-define-from-file=env/<flavor>.json`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp();

  // Chain rather than replace: FlutterError.onError already points to the
  // test harness's own handler when running under flutter_test (replacing
  // it outright breaks expect()'s own error capturing), and in production
  // there may be other framework-installed handlers worth preserving too.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    previousOnError?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Release users get a small "Something went wrong" card instead of a
  // blank grey box for a widget that failed to build; the rest of the
  // screen keeps working. Debug keeps the red error screen.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const AppErrorWidget();
  }

  // Auth always goes through Supabase (Phase 3), independent of
  // Env.dataSource — that flag only picks mock-JSON vs live Supabase
  // tables for the *catalog* repositories.
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  await Hive.initFlutter();
  final cartBox = await Hive.openBox('cart');
  final orderBox = await Hive.openBox('orders');
  final favouritesBox = await Hive.openBox('favourites');
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      cartBoxProvider.overrideWithValue(cartBox),
      orderBoxProvider.overrideWithValue(orderBox),
      favouritesBoxProvider.overrideWithValue(favouritesBox),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final routes = Routes(container);
  final router = await routes.getRouter();

  _watchAuthSession(container);

  // Neither of these should gate runApp() behind a native permission
  // dialog — nothing on the first frame requires location or push
  // permission to already be granted (Home's own location provider and
  // the push service both handle "not granted yet" on their own), and
  // blocking here means a user (or an automated test) who doesn't
  // immediately answer the system prompt never sees the app at all.
  // Sequenced so the location and notification permission dialogs never
  // overlap (Android only shows one permission request at a time).
  unawaited(
    container
        .read(checkAndRequestLocation.notifier)
        .checkAndRequestLocationPermission()
        .whenComplete(
          () => PushNotificationService.initialize(container, router),
        ),
  );

  if (_isLoggedIn(container)) {
    unawaited(resumePendingPayment(container));
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'UK'),
        Locale('bn', 'BN'),
        Locale('hi', 'IN'),
        Locale('pa', 'Guru'),
      ],
      path: Constants.translationPath,
      // A key missing from a language shows English, never the raw key.
      fallbackLocale: const Locale('en', 'UK'),
      child: UncontrolledProviderScope(
        container: container,
        child: Zyppi(router: router),
      ),
    ),
  );
}

bool _isLoggedIn(ProviderContainer container) {
  final token = container.read(sharedPreferenceProvider).authToken;
  return token != null && token.isNotEmpty;
}

/// The router's "logged in" check is a flag in SharedPreferences; Supabase
/// owns the real session. Keep them in step: if the session is gone at
/// startup, or Supabase ends it later (refresh token expired/revoked, user
/// deleted), log out locally so the router returns to the login screen
/// instead of leaving every user-scoped request failing.
void _watchAuthSession(ProviderContainer container) {
  final auth = Supabase.instance.client.auth;
  // Read the notifier fresh each time: the provider is autoDispose.
  void logOut() =>
      unawaited(container.read(sharedPreferenceProvider.notifier).logOut());

  if (_isLoggedIn(container) && auth.currentSession == null) {
    logOut();
  }

  auth.onAuthStateChange.listen(
    (event) {
      if (event.event == AuthChangeEvent.signedOut && _isLoggedIn(container)) {
        logOut();
      }
    },
    // A failed token refresh surfaces here; the session is unusable.
    onError: (_) {
      if (_isLoggedIn(container)) logOut();
    },
  );
}
