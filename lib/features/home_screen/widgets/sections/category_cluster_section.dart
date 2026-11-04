import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

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

    // IntrinsicHeight + stretch: every tile matches the tallest one, even
    // when one label wraps to two lines and another doesn't.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ZSpace.x3,
        children: section.items.map((item) {
          final category = categoriesById[item.data['category_id']];
          final label = item.data.string('label') ?? category?.name ?? '';
          final count = item.data.integer('count');

          return Expanded(
            child: InkWell(
              onTap: category == null
                  ? null
                  : () => context.push(
                      '/categoryDetailsScreen?categoryId=${category.id}',
                    ),
              borderRadius: BorderRadius.circular(ZRadius.card),
              child: Container(
                padding: const EdgeInsets.all(ZSpace.x3),
                decoration: BoxDecoration(
                  color: context.z.surface2,
                  borderRadius: BorderRadius.circular(ZRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ZRadius.chip),
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
                                color: context.z.ink,
                                borderRadius: BorderRadius.circular(
                                  ZRadius.badge,
                                ),
                              ),
                              child: Text(
                                '+$count',
                                style: AppTypography.caption.copyWith(
                                  color: context.z.surface,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: ZSpace.x1),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(color: context.z.ink),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
