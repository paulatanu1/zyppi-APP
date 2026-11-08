import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/constants/constants.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Pumps [home] on a 390 × 844 phone with real English translations
/// (`.plural()` needs a live EasyLocalization locale). Assets load with
/// real I/O, so this runs outside the fake clock.
Future<void> pumpLocalizedApp(
  WidgetTester tester, {
  required ProviderContainer container,
  required Widget home,
  ThemeData? theme,
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'UK')],
        fallbackLocale: const Locale('en', 'UK'),
        startLocale: const Locale('en', 'UK'),
        path: Constants.translationPath,
        child: UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) => MaterialApp(
              theme: theme ?? ZyppiTheme.light,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale),
                  disableAnimations: disableAnimations,
                ),
                child: child!,
              ),
              home: home,
            ),
          ),
        ),
      ),
    );
    // Let the translation assets load.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
}
