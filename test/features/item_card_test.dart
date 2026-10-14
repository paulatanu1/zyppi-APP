import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/common_widgets/item_card.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 200, height: 280, child: child)),
    ),
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
          price: '25',
        ),
      ),
    );

    expect(find.text('Fresh Tomatoes'), findsOneWidget);
    expect(find.text('500 g'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
  });

  testWidgets('ItemCard calls onClicked when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        ItemCard(
          productName: 'Fresh Tomatoes',
          quantity: '500 g',
          price: '25',
          onClicked: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(ItemCard));

    expect(tapped, isTrue);
  });
}
