import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/zyppi_theme.dart';
import 'z_commerce.dart';
import 'z_motion.dart';

/// Product card from docs/screens/light/05-home.png and 06-category.png.
///
/// Layout (top → bottom): image tile 112 high with OFF badge top-left and
/// heart top-right, ETA chip, 2-line name (13.5/700), weight (12/600 ink3),
/// then price block left + ADD/stepper right.
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
    required this.onAdd,
    required this.onRemove,
    this.onFavourite,
    this.width,
    this.eta,
  });

  final String name, weight;

  /// ETA chip label; defaults to the store-wide `etaBadge`.
  final String? eta;

  /// Usually `CatalogImage(image: url, fit: BoxFit.contain)`.
  final Widget image;
  final int price;
  final int? mrp;
  final Color? tileColor;
  final int quantity;
  final bool favourite;
  final VoidCallback? onTap;

  /// Heart button; hidden when null.
  final VoidCallback? onFavourite;
  final VoidCallback onAdd, onRemove;
  final double? width;

  int? get _offPercent => (mrp != null && mrp! > price)
      ? (((mrp! - price) * 100) / mrp!).round()
      : null;

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
            Text(
              weight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ZPrice(price: price, mrp: mrp),
                ),
                ZAddStepper(
                  quantity: quantity,
                  onAdd: onAdd,
                  onRemove: onRemove,
                  minWidth: 76,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
