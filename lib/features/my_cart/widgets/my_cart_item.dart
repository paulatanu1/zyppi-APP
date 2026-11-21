import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/marketplace/application/marketplace_providers.dart';
import 'package:zippy/core/marketplace/presentation/sold_by.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// One cart line (Cart B): photo tile, name with pack size and line total,
/// stepper on the right. − at 1 removes the line.
class MyCartItem extends ConsumerWidget {
  final CartLine line;

  const MyCartItem({super.key, required this.line});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final inStock = variantInStock(
      line.product,
      line.variant.id,
      ref.watch(shoppingAreaIdProvider),
    );
    // Live quantity at tap time, so quick taps all count.
    void step(int delta) {
      final cart = ref.read(cartProvider.notifier);
      cart.setQuantity(
        product: line.product,
        variant: line.variant,
        offer: line.offer,
        quantity:
            cart.quantityOf(
              line.product.id,
              line.variant.id,
              offer: line.offer,
            ) +
            delta,
      );
    }

    // Cart B: a 3-column row — tile · name, pack and price · stepper.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
      child: Row(
        children: [
          ZImageTile(
            image: CatalogImage(image: line.product.image, fit: BoxFit.contain),
            color: z.surface2,
            width: ZSize.input,
            height: ZSize.input,
          ),
          const SizedBox(width: ZSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelLarge,
                ),
                const SizedBox(height: 2),
                // Wraps (instead of a fixed row) so a long price and MRP
                // drop to the next line at large text sizes.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text('${line.variant.label} · ', style: t.bodySmall),
                    Text(rupees(line.lineTotalPaise), style: t.price),
                    if (line.lineMrpPaise > line.lineTotalPaise)
                      Text(rupees(line.lineMrpPaise), style: t.mrp),
                  ],
                ),
                if (line.offer case final offer?)
                  SoldByLink(
                    sellerId: offer.sellerId,
                    sellerName: offer.sellerName,
                  ),
                if (!inStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'cartItemOutOfStock'.tr(),
                      style: t.bodySmall!.copyWith(
                        color: z.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: ZSpace.x3),
          ZAddStepper(
            quantity: line.quantity,
            onAdd: () => step(1),
            onRemove: () => step(-1),
          ),
        ],
      ),
    );
  }
}
