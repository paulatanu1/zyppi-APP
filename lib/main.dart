import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/data/application/shared_preference_state.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/shared_providers/location/provider/request_location_provider.dart';
import 'package:zippy/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp();

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

class Zyppi extends ConsumerWidget {
  final GoRouter router;

  const Zyppi({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sharedPreferenceProvider);

    ref.listen<SharedPreferenceState>(sharedPreferenceProvider, (_, next) {
      final token = next.authToken;
      if (token == null || token.isEmpty) {
        // Navigate to Login Screen
        context.goNamed('LoginScreen');
      } else {
        // Navigate to Home Screen
        context.goNamed('NavigationBar');
      }
    });

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp.router(
        // routerConfig: createRouter(ref),
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
