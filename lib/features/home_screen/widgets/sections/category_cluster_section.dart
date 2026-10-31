import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// Blinkit-referenced "Frequently bought" cluster cards: a thumbnail,
/// "+N more" badge and category label.
class CategoryClusterSection extends StatelessWidget {
  final HomeSection section;
  final Map<String, Category> categoriesById;

  const CategoryClusterSection({
    super.key,
    required this.section,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: section.items.map((item) {
        final category = categoriesById[item.data['category_id']];
        final label = item.data['label'] as String? ?? category?.name ?? '';
        final count = item.data['count'] as int?;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: InkWell(
              onTap: category == null
                  ? null
                  : () => context.push(
                      '/categoryDetailsScreen?categoryId=${category.id}',
                    ),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: CatalogImage(image: category?.image),
                          ),
                        ),
                        if (count != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.ink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+$count',
                                style: AppTypography.caption.copyWith(
                                  color: context.colors.surface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        color: context.colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
