import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/common_widgets/price_tag.dart';
import 'package:zippy/core/common_widgets/quantity_stepper.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_typography.dart';

class MyCartItem extends ConsumerWidget {
  final CartLine line;

  const MyCartItem({super.key, required this.line});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    void updateQuantity(int quantity) {
      ref
          .read(cartProvider.notifier)
          .setQuantity(
            productId: line.product.id,
            variantId: line.variant.id,
            quantity: quantity,
          );
    }

    return Padding(
      padding: EdgeInsets.only(left: height * 0.02, right: height * 0.02),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: height * 0.02, bottom: height * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CatalogImage(
                  image: line.product.image,
                  height: height * 0.08,
                  width: width * 0.15,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: height * 0.025),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.product.name, style: AppTypography.bodyLarge),
                      Text(
                        line.variant.label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      QuantityStepper(
                        quantity: line.quantity,
                        onDecrement: () => updateQuantity(line.quantity - 1),
                        onIncrement: () => updateQuantity(line.quantity + 1),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Bounce(
                      duration: Duration(milliseconds: 300),
                      onPressed: () => updateQuantity(0),
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: context.colors.muted,
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    PriceTag(
                      pricePaise: line.lineTotalPaise,
                      mrpPaise: line.lineMrpPaise,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(height: 1, color: context.colors.divider),
          ),
        ],
      ),
    );
  }
}
