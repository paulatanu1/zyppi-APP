import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/widgets/z_back_to_exit.dart';

void main() {
  late int exits, homes;
  setUp(() {
    exits = 0;
    homes = 0;
  });

  Future<void> pump(WidgetTester tester, {required bool atHome}) =>
      tester.pumpWidget(
        MaterialApp(
          home: ZBackToExit(
            atHome: atHome,
            onGoHome: () => homes++,
            onExit: () async => exits++,
            child: const Scaffold(body: Text('tabs')),
          ),
        ),
      );

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  testWidgets('first Back on Home warns; the second exits', (tester) async {
    await pump(tester, atHome: true);
    await back(tester);
    expect(exits, 0);
    expect(find.text('pressBackAgainToExit'), findsOneWidget);

    await back(tester);
    expect(exits, 1);
  });

  testWidgets('a second Back after the window warns again', (tester) async {
    await pump(tester, atHome: true);
    await back(tester);
    await tester.pump(const Duration(seconds: 3));
    await back(tester);
    expect(exits, 0);
  });

  testWidgets('Back on another tab returns to Home', (tester) async {
    await pump(tester, atHome: false);
    await back(tester);
    expect(homes, 1);
    expect(exits, 0);
    expect(find.text('pressBackAgainToExit'), findsNothing);
  });
}
