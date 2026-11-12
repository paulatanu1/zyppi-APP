import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_brand_texture.dart';
import 'package:zippy/core/widgets/z_hero_header.dart';

Widget _app(Widget home, {ThemeData? theme}) =>
    MaterialApp(theme: theme ?? ZyppiTheme.light, home: home);

void main() {
  test('the brand is the logo purple in both themes (no magenta)', () {
    expect(ZColors.light.brand, const Color(0xFF673AB7));
    expect(ZColors.light.header, const Color(0xFF673AB7));
    expect(ZColors.dark.brand, const Color(0xFF7E57C2));
    expect(ZyppiTheme.light.colorScheme.primary, ZColors.light.brand);
  });

  testWidgets('hero header shows back only when the route can pop', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const Scaffold(body: ZHeroHeader(title: 'Root'))),
    );
    expect(find.text('Root'), findsOneWidget);
    expect(find.byType(ZGlassIconButton), findsNothing);
    expect(find.byType(ZBrandTexture), findsOneWidget);

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: ZHeroHeader(title: 'Child')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ZGlassIconButton), findsOneWidget);

    await tester.tap(find.byType(ZGlassIconButton));
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsNothing);
  });

  for (final (name, theme) in [
    ('light', ZyppiTheme.light),
    ('dark', ZyppiTheme.dark),
  ]) {
    testWidgets(
      'filled buttons are textured; disabled ones stay flat ($name)',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _app(
            theme: theme,
            Scaffold(
              body: Column(
                children: [
                  FilledButton(
                    onPressed: () => taps++,
                    child: const Text('Go'),
                  ),
                  const FilledButton(onPressed: null, child: Text('Off')),
                ],
              ),
            ),
          ),
        );
        expect(
          find.ancestor(
            of: find.text('Go'),
            matching: find.byType(ZBrandTexture),
          ),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.text('Off'),
            matching: find.byType(ZBrandTexture),
          ),
          findsNothing,
        );
        // The label stays centred on the textured background.
        final button = tester.getRect(find.byType(FilledButton).first);
        final label = tester.getCenter(find.text('Go'));
        expect((label.dx - button.center.dx).abs(), lessThan(1));
        expect((label.dy - button.center.dy).abs(), lessThan(1));

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
