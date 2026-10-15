import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/app/app.dart';
import 'package:zippy/core/cart/data/cart_repository_impl.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/favourites/data/favourites_repository_impl.dart';
import 'package:zippy/core/order/data/order_repository_impl.dart';
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

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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

  await container
      .read(checkAndRequestLocation.notifier)
      .checkAndRequestLocationPermission();

  final routes = Routes(container);
  final router = await routes.getRouter();

  await PushNotificationService.initialize(container, router);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'UK'),
        Locale('bn', 'BN'),
        Locale('hi', 'IN'),
        Locale('pa', 'Guru'),
      ],
      path: Constants.translationPath,
      child: UncontrolledProviderScope(
        container: container,
        child: Zyppi(router: router),
      ),
    ),
  );
}
