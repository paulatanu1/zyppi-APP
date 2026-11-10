import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/product_details/application/product_detail_provider.dart';

/// docs/screens/light/07-product.png's hero: tinted panel with the photo on
/// a soft disc, back and favourite buttons. (No share button or image
/// dots: there's no share package and products have one image.)
class ProductSlider extends ConsumerWidget {
  final String productId;
  final String? heroTag;

  const ProductSlider({super.key, required this.productId, this.heroTag});

  /// Photo panel height below the status bar.
  static const double _panelHeight = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    // Only what the hero shows, so price/stock/variant updates elsewhere on
    // the page don't rebuild (and re-layout) the photo panel.
    final (:loading, :image) = ref.watch(
      productDetailProvider(productId)
          .select((s) => (loading: s.loading, image: s.product?.image)),
    );
    final isFavourite = ref.watch(
      favouritesProvider.select((ids) => ids.contains(productId)),
    );
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      color: z.surface2,
      height: top + _panelHeight,
      padding: EdgeInsets.only(top: top),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: z.surface.withValues(alpha: .6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _hero(
                loading
                    ? const ZSkeleton(width: 180, height: 180, radius: 90)
                    : CatalogImage(
                        image: image,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          Positioned(
            left: ZSpace.screen,
            top: ZSpace.x2,
            child: _SquareButton(
              icon: Icons.arrow_back_ios_new_rounded,
              label: 'back'.tr(),
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/navBar'),
            ),
          ),
          Positioned(
            right: ZSpace.screen,
            top: ZSpace.x2,
            child: _SquareButton(
              icon: isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavourite ? z.brandText : z.ink,
              label: isFavourite
                  ? 'removeFromFavourites'.tr()
                  : 'addToFavourites'.tr(),
              onTap: () =>
                  ref.read(favouritesProvider.notifier).toggle(productId),
            ),
          ),
        ],
      ),
    );
  }
}

extension on ProductSlider {
  /// The landing spot for the tapped card's photo. The flight always shows
  /// the card's (already decoded) photo, so it lands smoothly even if this
  /// screen is still on its skeleton.
  Widget _hero(Widget child) {
    final tag = heroTag;
    if (tag == null) return child;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, _, direction, fromContext, toContext) {
        final source = direction == HeroFlightDirection.push
            ? fromContext
            : toContext;
        return (source.widget as Hero).child;
      },
      child: child,
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: ZPressable(
        onTap: onTap,
        child: Container(
          width: ZSize.touch,
          height: ZSize.touch,
          decoration: BoxDecoration(
            color: z.surface,
            borderRadius: ZRadius.all(ZRadius.input),
            boxShadow: [
              BoxShadow(
                color: z.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: color ?? z.ink),
        ),
      ),
    );
  }
}
