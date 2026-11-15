import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/routes/home_fallback_scope.dart';

GoRouter _router(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/navBar', builder: (_, _) => const Text('home')),
    GoRoute(
      path: '/tracking',
      builder: withHomeFallback((_, _) => const Text('tracking')),
    ),
    GoRoute(
      path: '/product',
      builder: withHomeFallback((_, _) => const Text('product')),
    ),
  ],
);

void main() {
  testWidgets('back on a lone screen (go/deep link) goes Home, not out', (
    tester,
  ) async {
    final router = _router('/tracking');
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('tracking'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue, reason: 'the app must not be closed');
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('back on a pushed screen pops normally', (tester) async {
    final router = _router('/navBar');
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/product');
    await tester.pumpAndSettle();
    expect(find.text('product'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}
