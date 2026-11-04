import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_commerce.dart';

/// One search result (docs/screens/light/08-search.png): photo tile, name
/// with the [query] match highlighted, "1 kg · ₹179 ₹199", and ADD/stepper
/// for the first variant. Callers only pass products that have a variant.
class ProductListRow extends ConsumerWidget {
  final Product product;
  final String query;

  const ProductListRow({super.key, required this.product, this.query = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final variant = product.variants.first;
    final quantity = ref.watch(
      cartProvider.select(
        (c) => c.lines
            .where(
              (l) => l.product.id == product.id && l.variant.id == variant.id,
            )
            .fold<int>(0, (sum, l) => sum + l.quantity),
      ),
    );

    // Live quantity at tap time, so quick taps all count.
    void step(int delta) {
      final cart = ref.read(cartProvider.notifier);
      final current = cart.quantityOf(product.id, variant.id);
      current == 0 && delta > 0
          ? cart.addItem(product: product, variant: variant)
          : cart.setQuantity(
              product: product,
              variant: variant,
              quantity: current + delta,
            );
    }

    final hasMrp =
        variant.mrpPaise != null && variant.mrpPaise! > variant.pricePaise;

    return InkWell(
      onTap: () =>
          context.push('/productDetailsScreen?productId=${product.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ZSpace.x3),
        child: Row(
          children: [
            ZImageTile(
              image: CatalogImage(image: product.image, fit: BoxFit.contain),
              color: z.surface2,
              width: ZSize.input,
              height: ZSize.input,
            ),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    _highlight(context, product.name, query),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${variant.label} · '),
                        TextSpan(
                          text: rupees(variant.pricePaise),
                          style: t.labelMedium!.copyWith(
                            color: z.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (hasMrp) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: rupees(variant.mrpPaise!),
                            style: t.mrp,
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: ZSpace.x3),
            ZAddStepper(
              quantity: quantity,
              onAdd: () => step(1),
              onRemove: () => step(-1),
            ),
          ],
        ),
      ),
    );
  }

  /// [name] with every case-insensitive occurrence of [query] tinted.
  static TextSpan _highlight(BuildContext context, String name, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return TextSpan(text: name);
    final z = context.z;
    final lower = name.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final i = lower.indexOf(q, start);
      if (i < 0) break;
      if (i > start) spans.add(TextSpan(text: name.substring(start, i)));
      spans.add(
        TextSpan(
          text: name.substring(i, i + q.length),
          style: TextStyle(color: z.brandText, backgroundColor: z.brandSoft),
        ),
      );
      start = i + q.length;
    }
    if (start < name.length) spans.add(TextSpan(text: name.substring(start)));
    return TextSpan(children: spans);
  }
}
