import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/widgets/z_chrome.dart';

/// docs/mockups/Main.dc.html's floating "View cart" bar, fed from the
/// cart. Renders nothing while the cart is loading or empty.
class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only what the bar shows (records compare by value), so a change
    // elsewhere in the cart state — tip, coupon text, sync flags — doesn't
    // rebuild it and its thumbnails.
    final bar = ref.watch(
      cartProvider.select(
        (cart) => cart.loading || cart.lines.isEmpty
            ? null
            : (
                count: cart.lines.fold<int>(0, (sum, l) => sum + l.quantity),
                total: cart.bill.totalPaise,
                saved: cart.bill.savingsPaise,
                // Joined so equal thumbnails compare equal.
                images: cart.lines
                    .take(3)
                    .map((l) => l.product.image ?? '')
                    .join('\n'),
              ),
      ),
    );

    if (bar == null) return const SizedBox.shrink();

    return ZCartBar(
      thumbnails: [
        for (final image in bar.images.split('\n'))
          CatalogImage(image: image, fit: BoxFit.contain),
      ],
      itemCount: bar.count,
      total: bar.total,
      saved: bar.saved,
      onTap: () => context.push('/myCartScreen'),
    );
  }
}
