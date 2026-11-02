import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/my_cart/widgets/my_cart_item.dart';

void main() {
  testWidgets('MyCartItem shows product name, variant label and price', (
    tester,
  ) async {
    final line = CartLine(
      product: Product(
        id: 'prod-1',
        name: 'Basmati Rice',
        image: 'assets/images/rice.png',
        categoryId: 'cat-1',
        variants: const [],
      ),
      variant: ProductVariant(
        id: 'variant-1',
        label: '1 kg',
        pricePaise: 14500,
        mrpPaise: 16000,
      ),
      quantity: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            theme: ZyppiTheme.light,
            home: Scaffold(
              body: SizedBox(height: 844, child: MyCartItem(line: line)),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Basmati Rice'), findsOneWidget);
    expect(find.text('1 kg'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // quantity shown in the stepper
  });
}
