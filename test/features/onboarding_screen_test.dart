import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/intro/presentation/slider/slider.dart';

import '../helpers/localized_app.dart';

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        await pumpLocalizedApp(
          tester,
          container: c,
          home: const SliderScreen(),
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
          disableAnimations: true,
        );
        expect(find.text('Get Started'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('swiping changes the headline and chips per step', (
    tester,
  ) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await pumpLocalizedApp(
      tester,
      container: c,
      home: const SliderScreen(),
      disableAnimations: true,
    );
    expect(find.textContaining('12 minutes'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('Track every order'), findsOneWidget);
    expect(find.text('Live tracking'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('right to your door'), findsOneWidget);
    expect(find.text('Cash on delivery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('last step has no overflow ($scale× text)', (tester) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await pumpLocalizedApp(
        tester,
        container: c,
        home: const SliderScreen(),
        textScale: scale,
        disableAnimations: true,
      );
      for (var i = 0; i < 2; i++) {
        await tester.drag(find.byType(PageView), const Offset(-250, 0));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
