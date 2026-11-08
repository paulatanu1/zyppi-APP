import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/launch/presentation/launch_screen.dart';

Future<void> _pump(
  WidgetTester tester, {
  String? token,
  bool disableAnimations = false,
  ThemeData? theme,
}) async {
  SharedPreferences.setMockInitialValues({
    KeyNames.token: ?token,
  });
  final prefs = (await tester.runAsync(SharedPreferences.getInstance))!;
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/launch',
    routes: [
      GoRoute(path: '/launch', builder: (_, _) => const LaunchScreen()),
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
}

void main() {
  testWidgets('signed out: shows the mark, then goes to onboarding', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);

    await tester.pump(LaunchScreen.duration ~/ 2);
    expect(find.text('Zyppi'), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('onboarding'), findsOneWidget);
  });

  testWidgets('signed in: goes to home', (tester) async {
    await _pump(tester, token: 'uid-1', theme: ZyppiTheme.dark);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion: static frame, then moves on quickly', (
    tester,
  ) async {
    await _pump(tester, disableAnimations: true);
    // Already in its final pose: wordmark fully visible on the first frame.
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Zyppi'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);

    await tester.pump(LaunchScreen.reducedMotionHold);
    await tester.pump();
    expect(find.text('onboarding'), findsOneWidget);
  });
}
