import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/splash/data/splash_seen_store.dart';
import 'package:zippy/features/splash/presentation/splash_timeline.dart';
import 'package:zippy/features/splash/presentation/zyppi_splash_screen.dart';

const _seenKey = 'splashSeenRevision';

// Never pumpAndSettle here: drive the timeline with explicit pumps.
Future<SharedPreferences> _pump(
  WidgetTester tester, {
  String? token,
  bool seen = false,
  bool disableAnimations = false,
  ThemeData? theme,
}) async {
  SharedPreferences.setMockInitialValues({
    KeyNames.token: ?token,
    if (seen) _seenKey: SplashSeenStore.revision,
  });
  final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await container.read(sharedPreferenceProvider.notifier).getLocalStorage();
  final router = GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(path: '/launch', builder: (_, _) => const SplashRoute()),
      GoRoute(path: '/slider', builder: (_, _) => const Text('onboarding')),
      GoRoute(path: '/navBar', builder: (_, _) => const Text('home')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: theme ?? ZyppiTheme.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
      ),
    ),
  );
  return prefs;
}

/// Steps through [total] a frame at a time so every painter runs.
Future<void> _play(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 50);
  for (var t = Duration.zero; t < total; t += step) {
    await tester.pump(step);
  }
}

/// Lets the route transition finish after navigating.
Future<void> _settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  final full = ZyppiSplashScreen.durationOf(SplashMode.full);
  final short = ZyppiSplashScreen.durationOf(SplashMode.short);

  test('full runs through the exit zoom; short is 1.5 s', () {
    expect(full, const Duration(milliseconds: 4950));
    expect(short, const Duration(milliseconds: 1500));
  });

  testWidgets('first launch: full splash, then onboarding; remembers it', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final prefs = await _pump(tester);

    // The tile has landed (it starts above the screen as a falling ball).
    await _play(tester, const Duration(milliseconds: 2000));
    expect(find.bySemanticsLabel('Zyppi'), findsOneWidget);
    semantics.dispose();

    await _play(tester, const Duration(milliseconds: 2800));
    expect(find.text('onboarding'), findsNothing);
    expect(find.byKey(ZyppiSplashScreen.wordmarkKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await _settleRoute(tester);
    expect(find.text('onboarding'), findsOneWidget);
    expect(prefs.getInt(_seenKey), SplashSeenStore.revision);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returning signed-in user: short splash, then home', (
    tester,
  ) async {
    await _pump(tester, token: 'uid-1', seen: true);
    // The short version has no wordmark.
    expect(find.byKey(ZyppiSplashScreen.wordmarkKey), findsNothing);

    await _play(tester, const Duration(milliseconds: 1400));
    expect(find.text('home'), findsNothing);

    await tester.pump(const Duration(milliseconds: 150));
    await _settleRoute(tester);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('tap anywhere skips to the exit', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(ZyppiSplashScreen));
    // Only the 600 ms exit zoom is left.
    await _play(tester, const Duration(milliseconds: 650));
    await _settleRoute(tester);
    expect(find.text('onboarding'), findsOneWidget);
  });

  testWidgets('reduced motion: resting frame, then moves on quickly', (
    tester,
  ) async {
    await _pump(tester, disableAnimations: true);
    final word = tester.widget<Opacity>(
      find.byKey(ZyppiSplashScreen.wordmarkKey),
    );
    expect(word.opacity, 1);

    await tester.pump(ZyppiSplashScreen.reducedMotionHold);
    await _settleRoute(tester);
    expect(find.text('onboarding'), findsOneWidget);
  });

  for (final (name, size) in const [
    ('small', Size(320, 568)),
    ('large', Size(1024, 1366)),
  ]) {
    testWidgets('$name screen, dark theme: whole timeline paints', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pump(tester, theme: ZyppiTheme.dark);
      await _play(tester, full + const Duration(milliseconds: 100));
      await _settleRoute(tester);
      expect(find.text('onboarding'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
