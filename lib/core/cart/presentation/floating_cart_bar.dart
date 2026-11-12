import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/widgets/z_chrome.dart';

/// docs/mockups/Main.dc.html's floating "View cart" bar, fed from the
/// cart. Renders nothing while the cart is loading or empty.
class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key, this.textured = false});

  /// See [ZCartBar.textured].
  final bool textured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.loading || cart.lines.isEmpty) return const SizedBox.shrink();

    final itemCount = cart.lines.fold<int>(0, (sum, l) => sum + l.quantity);

    return ZCartBar(
      thumbnails: [
        for (final line in cart.lines.take(3))
          CatalogImage(image: line.product.image, fit: BoxFit.contain),
      ],
      itemCount: itemCount,
      total: cart.bill.totalPaise,
      saved: cart.bill.savingsPaise,
      onTap: () => context.push('/myCartScreen'),
      textured: textured,
    );
  }
}
