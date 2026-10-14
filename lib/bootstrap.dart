import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/app/app.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/constants/constants.dart';
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

  if (!Env.isMockDataSource) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  final container = ProviderContainer();

  await container
      .read(checkAndRequestLocation.notifier)
      .checkAndRequestLocationPermission();

  final routes = Routes(container);
  final router = await routes.getRouter();

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
