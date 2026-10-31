import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

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
    if (section.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: section.items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = section.items[index];
          final product = productsById[item.data['product_id']];
          final badge = item.data.string('badge');
          if (product == null) return const SizedBox.shrink();

          return InkWell(
            onTap: () =>
                context.push('/productDetailsScreen?productId=${product.id}'),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
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
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AppRadius.card),
                            topRight: Radius.circular(AppRadius.card),
                          ),
                        ),
                        child: Text(
                          badge,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.overline.copyWith(
                            color: context.colors.surface,
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
