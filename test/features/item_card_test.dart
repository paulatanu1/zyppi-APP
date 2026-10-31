import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/common_widgets/add_button.dart';
import 'package:zippy/core/common_widgets/item_card.dart';
import 'package:zippy/core/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SizedBox(width: 200, height: 280, child: child)),
  );
}

void main() {
  testWidgets('ItemCard shows product name, quantity and price', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ItemCard(
          productName: 'Fresh Tomatoes',
          quantity: '500 g',
          pricePaise: 2500,
        ),
      ),
    );

    expect(find.text('Fresh Tomatoes'), findsOneWidget);
    expect(find.text('500 g'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
  });

  testWidgets('ItemCard shows a discount badge when MRP > price', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ItemCard(
          productName: 'Fresh Tomatoes',
          quantity: '500 g',
          pricePaise: 2500,
          mrpPaise: 3000,
        ),
      ),
    );

    expect(find.textContaining('OFF'), findsOneWidget);
  });

  testWidgets('ItemCard calls onClicked when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        ItemCard(
          productName: 'Fresh Tomatoes',
          quantity: '500 g',
          pricePaise: 2500,
          onClicked: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(ItemCard));

    expect(tapped, isTrue);
  });

  testWidgets('ItemCard calls onAddClicked when the ADD button is tapped', (
    tester,
  ) async {
    var addTapped = false;
    var cardTapped = false;

    await tester.pumpWidget(
      _wrap(
        ItemCard(
          productName: 'Fresh Tomatoes',
          quantity: '500 g',
          pricePaise: 2500,
          onClicked: () => cardTapped = true,
          onAddClicked: () => addTapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(AddButton));

    expect(addTapped, isTrue);
    expect(cardTapped, isFalse);
  });
}
