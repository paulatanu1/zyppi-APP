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
}
