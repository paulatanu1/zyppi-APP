import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/common_widgets/add_button.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/main.dart' as app;

/// Covers the offline golden path (PLAN.md Phase 2/5): home -> add to cart
/// -> checkout -> order placed -> tracking, against the mock flavor
/// (env/dev.json's DATA_SOURCE). Run with:
///   fvm flutter test integration_test/order_flow_test.dart \
///     -d `<device>` --flavor dev --dart-define-from-file=env/dev.json
///
/// Pre-seeds a fake auth token so the router's auth gate is bypassed —
/// login itself always goes through real Supabase (see bootstrap.dart),
/// so it can't be driven here without live credentials; that boundary is
/// covered manually, not by this test.
/// Live/on-device integration tests don't reliably settle via
/// pumpAndSettle() alone (real async platform-channel + Hive I/O in
/// between frames), so every wait in this file polls with real
/// wall-clock gaps for a condition instead.
Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  int attempts = 20,
}) async {
  for (var i = 0; i < attempts && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('places an order end to end and reaches tracking', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      KeyNames.token: 'integration-test-token',
    });

    // app.main() doesn't await bootstrap() (fire-and-forget by design, see
    // main.dart), so runApp() hasn't necessarily happened yet when this
    // call returns — pumpAndSettle alone can return immediately with no
    // widget tree mounted. Pump with real wall-clock gaps first so
    // bootstrap()'s Firebase/Supabase/Hive chain gets a chance to finish.
    app.main();
    await _waitUntil(
      tester,
      () => find.text('Deals for you').evaluate().isNotEmpty,
    );
    expect(find.text('Deals for you'), findsOneWidget);

    // The product grid shows a non-interactive skeleton (AddButton with a
    // null onTap, under an AbsorbPointer) until the mock catalog call
    // resolves (300-800ms) - wait for a real, tappable one.
    AddButton? addButton;
    await _waitUntil(tester, () {
      final tappable = find
          .byType(AddButton)
          .evaluate()
          .map((e) => e.widget as AddButton)
          .where((w) => w.onTap != null);
      if (tappable.isEmpty) return false;
      addButton = tappable.first;
      return true;
    });
    expect(addButton, isNotNull, reason: 'product grid never finished loading');

    // Home: add the first product to the cart. warnIfMissed: false - the
    // tap target is correct (verified via onTap != null above); the
    // warning is just AppSkeleton's always-present IgnorePointer showing
    // up in the hit-test chain even once it's not actually absorbing.
    await tester.tap(
      find.byWidgetPredicate((w) => w == addButton),
      warnIfMissed: false,
    );
    await _waitUntil(
      tester,
      () => find.text('View cart').evaluate().isNotEmpty,
    );

    // Floating cart bar -> cart screen.
    expect(find.text('View cart'), findsOneWidget);
    await tester.tap(find.text('View cart'));
    await _waitUntil(
      tester,
      () => find.text('Proceed to checkout →').evaluate().isNotEmpty,
    );

    // Cart -> checkout.
    expect(find.text('Proceed to checkout →'), findsOneWidget);
    await tester.tap(find.text('Proceed to checkout →'));
    await _waitUntil(
      tester,
      () => find.byType(PrimaryButton).evaluate().isNotEmpty,
    );

    // Checkout: a default address + slot are pre-selected from mock data;
    // place the order (mock flavor skips Razorpay for every payment
    // method - see checkout_provider.dart).
    expect(find.byType(PrimaryButton), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    await _waitUntil(
      tester,
      () => find.text('Track order').evaluate().isNotEmpty,
    );

    // Order placed -> tracking.
    expect(find.text('Track order'), findsOneWidget);
    await tester.tap(find.text('Track order'));
    await _waitUntil(tester, () => find.text('Track order').evaluate().isEmpty);

    expect(find.text('Track order'), findsNothing);
  });
}
