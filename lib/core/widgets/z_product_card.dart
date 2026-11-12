import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';
import 'z_commerce.dart';
import 'z_motion.dart';

/// Product card from docs/screens/light/05-home.png and 06-category.png.
///
/// Layout (top → bottom): image tile 112 high with OFF badge top-left and
/// heart top-right, ETA chip, 2-line name (13.5/700), weight (12/600 ink3),
/// then price block left + ADD/stepper right.
///
/// Every card has the same height for a given text scale — use [height]
/// for grid `mainAxisExtent` / carousel height.
class ZProductCard extends StatelessWidget {
  const ZProductCard({
    super.key,
    required this.name,
    required this.weight,
    required this.image,
    required this.price,
    this.mrp,
    this.tileColor,
    this.quantity = 0,
    this.favourite = false,
    this.onTap,
    this.onAdd,
    this.onRemove,
    this.onFavourite,
    this.width,
    this.eta,
    this.compact = false,
  });

  /// Narrow cards (about 125 px, beside the product page's left menu):
  /// the price gets its own line and ADD spans the card below it. Use
  /// [height] with the same flag.
  final bool compact;

  final String name, weight;

  /// ETA chip label; defaults to the store-wide `etaBadge`.
  final String? eta;

  /// Usually `CatalogImage(image: url, fit: BoxFit.contain)`.
  final Widget image;

  /// Null when the product can't be bought (no variant): the card then
  /// shows `productUnavailable` and no ADD button.
  final int? price;
  final int? mrp;
  final Color? tileColor;
  final int quantity;
  final bool favourite;
  final VoidCallback? onTap;

  /// Heart button; hidden when null.
  final VoidCallback? onFavourite;
  final VoidCallback? onAdd, onRemove;
  final double? width;

  int? get _offPercent => (price != null && mrp != null && mrp! > price!)
      ? (((mrp! - price!) * 100) / mrp!).round()
      : null;

  static double _lineHeight(
    TextStyle style,
    TextScaler scaler, {
    String sample = 'Ag',
  }) {
    final painter = TextPainter(
      text: TextSpan(text: sample, style: style),
      textScaler: scaler,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final h = painter.height;
    painter.dispose();
    return h;
  }

  /// Height of the price + ADD row: two text lines (price and struck MRP)
  /// or the ADD button, whichever is taller.
  static double _priceBlockHeight(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = MediaQuery.textScalerOf(context);
    final text =
        _lineHeight(t.price, s, sample: '₹9') +
        _lineHeight(t.mrp, s, sample: '₹9');
    return text > ZSize.addButton ? text : ZSize.addButton;
  }

  /// Compact: price text on its own line, then a full-width ADD.
  static double _compactPriceBlockHeight(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = MediaQuery.textScalerOf(context);
    return _lineHeight(t.price, s, sample: '₹9') +
        _lineHeight(t.mrp, s, sample: '₹9') +
        6 +
        ZSize.addButton;
  }

  /// The card's height at the current text scale.
  static double height(BuildContext context, {bool compact = false}) {
    final t = Theme.of(context).textTheme;
    final s = MediaQuery.textScalerOf(context);
    final etaText = _lineHeight(ZEtaBadge.textStyle(context), s);
    final eta =
        (etaText > ZEtaBadge.iconSize ? etaText : ZEtaBadge.iconSize) +
        2 * ZEtaBadge.verticalPadding;
    return 2 + // border
        8 + // top padding
        ZSize.productTile +
        6 +
        eta +
        6 +
        s.scale(34) + // two-line name box
        2 +
        _lineHeight(t.bodySmall!, s) +
        6 +
        (compact
            ? _compactPriceBlockHeight(context)
            : _priceBlockHeight(context)) +
        10; // bottom padding
  }

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return ZPressable(
      onTap: onTap,
      scale: .98,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: z.surface,
          borderRadius: ZRadius.all(ZRadius.card),
          border: Border.all(color: z.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ZImageTile(image: image, color: tileColor ?? z.surface2),
                if (_offPercent != null)
                  Positioned(left: 6, top: 6, child: ZOffBadge(_offPercent!)),
                if (onFavourite != null)
                  // 44 pt tap target around the 30 pt visible circle.
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Semantics(
                      button: true,
                      label: favourite
                          ? 'removeFromFavourites'.tr()
                          : 'addToFavourites'.tr(),
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onFavourite,
                        child: SizedBox.square(
                          dimension: ZSize.touch,
                          child: Center(
                            child: Material(
                              color: z.surface,
                              shape: const CircleBorder(),
                              elevation: 1,
                              shadowColor: z.shadow,
                              child: SizedBox.square(
                                dimension: 30,
                                child: Icon(
                                  favourite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: favourite ? z.brandText : z.ink2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ZEtaBadge(label: eta),
            const SizedBox(height: 6),
            // Two lines of name at any text size, so cards in a row align.
            SizedBox(
              height: MediaQuery.textScalerOf(context).scale(34),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.labelLarge!.copyWith(fontSize: 13.5, height: 1.25),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: _lineHeight(
                t.bodySmall!,
                MediaQuery.textScalerOf(context),
              ),
              child: Text(
                weight,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall,
              ),
            ),
            const SizedBox(height: 6),
            if (compact)
              SizedBox(
                height: _compactPriceBlockHeight(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: price == null
                          ? Text(
                              'productUnavailable'.tr(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall,
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: ZPrice(price: price!, mrp: mrp),
                            ),
                    ),
                    const SizedBox(height: 6),
                    if (price != null && onAdd != null && onRemove != null)
                      ZAddStepper(
                        quantity: quantity,
                        onAdd: onAdd!,
                        onRemove: onRemove!,
                        minWidth: double.infinity,
                      )
                    else
                      const SizedBox(height: ZSize.addButton),
                  ],
                ),
              )
            else
              SizedBox(
                height: _priceBlockHeight(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: price == null
                          ? Text(
                              'productUnavailable'.tr(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall,
                            )
                          // Shrinks rather than wraps at large text sizes.
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: ZPrice(price: price!, mrp: mrp),
                            ),
                    ),
                    if (price != null && onAdd != null && onRemove != null)
                      ZAddStepper(
                        quantity: quantity,
                        onAdd: onAdd!,
                        onRemove: onRemove!,
                        minWidth: 76,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder with the same size and shape as [ZProductCard].
class ZProductCardSkeleton extends StatelessWidget {
  const ZProductCardSkeleton({super.key, this.width});
  final double? width;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    return Container(
      width: width,
      height: ZProductCard.height(context),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: z.surface,
        borderRadius: ZRadius.all(ZRadius.card),
        border: Border.all(color: z.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ZSkeleton(height: ZSize.productTile, radius: ZRadius.tile),
          const SizedBox(height: ZSpace.x2),
          const ZSkeleton(width: 56, height: 16, radius: ZRadius.badge),
          const SizedBox(height: ZSpace.x2),
          const ZSkeleton(height: 14),
          const SizedBox(height: ZSpace.x1),
          const ZSkeleton(width: 60, height: 12),
          const Spacer(),
          Row(
            children: const [
              ZSkeleton(width: 48, height: 18),
              Spacer(),
              ZSkeleton(
                width: 70,
                height: ZSize.addButton,
                radius: ZRadius.control,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
