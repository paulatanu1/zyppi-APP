import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Blinkit-referenced "Featured this week" ribbon-badge spotlight cards.
class SpotlightCardsSection extends StatelessWidget {
  final HomeSection section;
  final Map<String, Product> productsById;

  const SpotlightCardsSection({
    super.key,
    required this.section,
    required this.productsById,
  });

  @override
  Widget build(BuildContext context) {
    // Skip items whose product is missing or inactive, rather than
    // leaving an empty slot in the row.
    final items = [
      for (final item in section.items)
        if (productsById[item.data['product_id']] case final product?)
          (product: product, badge: item.data.string('badge')),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (:product, :badge) = items[index];

          return InkWell(
            onTap: () =>
                context.push('/productDetailsScreen?productId=${product.id}'),
            borderRadius: BorderRadius.circular(ZRadius.card),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: context.z.line),
                borderRadius: BorderRadius.circular(ZRadius.card),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ZRadius.card),
                      child: CatalogImage(
                        image: product.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: ZSpace.x2,
                        ),
                        decoration: BoxDecoration(
                          color: context.z.brand,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(ZRadius.card),
                            topRight: Radius.circular(ZRadius.card),
                          ),
                        ),
                        // Scale long labels ("Customer favourite") down to
                        // fit the card rather than cutting them off.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            badge,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: AppTypography.overline.copyWith(
                              color: context.z.onBrand,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
