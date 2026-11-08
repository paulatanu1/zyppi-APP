import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// One cart line (docs/screens/light/09-cart.png): photo tile, name and
/// pack size; stepper above the line total. − at 1 removes the line.
class MyCartItem extends ConsumerWidget {
  final CartLine line;

  const MyCartItem({super.key, required this.line});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    // Live quantity at tap time, so quick taps all count.
    void step(int delta) {
      final cart = ref.read(cartProvider.notifier);
      cart.setQuantity(
        product: line.product,
        variant: line.variant,
        quantity: cart.quantityOf(line.product.id, line.variant.id) + delta,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZImageTile(
            image: CatalogImage(image: line.product.image, fit: BoxFit.contain),
            color: z.surface2,
            width: ZSize.input,
            height: ZSize.input,
          ),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: ZSpace.x2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelLarge,
                  ),
                  Text(line.variant.label, style: t.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(width: ZSpace.x3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ZAddStepper(
                quantity: line.quantity,
                onAdd: () => step(1),
                onRemove: () => step(-1),
              ),
              const SizedBox(height: ZSpace.x2),
              ZPrice(
                price: line.lineTotalPaise,
                mrp: line.lineMrpPaise,
                horizontal: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
