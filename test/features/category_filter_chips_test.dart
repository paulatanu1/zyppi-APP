import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/product_filter.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/category_details/widgets/category_filter_chips.dart';

void main() {
  const id = 'c1';

  Future<ProviderContainer> pumpChips(WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // autoDispose: keep the filter alive for the test's reads.
    container.listen(productFilterProvider(id), (_, _) {});
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ZyppiTheme.light,
          home: const Scaffold(body: CategoryFilterChips(categoryId: id)),
        ),
      ),
    );
    return container;
  }

  ProductFilter filter(ProviderContainer c) =>
      c.read(productFilterProvider(id));

  testWidgets('Offers toggles "only discounted"', (tester) async {
    final container = await pumpChips(tester);

    await tester.tap(find.text('offersChip'));
    await tester.pumpAndSettle();
    expect(filter(container).onlyDiscounted, isTrue);
    expect(
      tester.getSemantics(find.text('offersChip')),
      isSemantics(isSelected: true),
    );

    await tester.tap(find.text('offersChip'));
    await tester.pumpAndSettle();
    expect(filter(container).onlyDiscounted, isFalse);
  });

  testWidgets('Sort sheet applies the chosen order and relabels the chip', (
    tester,
  ) async {
    final container = await pumpChips(tester);

    await tester.tap(find.text('sortBy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('sortPriceLowHigh'));
    await tester.pumpAndSettle();

    expect(filter(container).sort, ProductSort.priceLowToHigh);
    expect(find.text('sortPriceLowHigh'), findsOneWidget); // chip label
  });

  testWidgets('Filter chip shows the active filter count', (tester) async {
    final container = await pumpChips(tester);
    container
        .read(productFilterProvider(id).notifier)
        .state = const ProductFilter(
      onlyDiscounted: true,
      priceBands: {PriceBand.under50},
    );
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
  });
}
