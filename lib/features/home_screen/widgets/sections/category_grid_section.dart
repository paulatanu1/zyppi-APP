import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/catalog_image.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/zyppi_colors.dart';
import 'package:zippy/core/theme/zyppi_tokens.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/features/home_screen/widgets/sections/section_data.dart';

/// Blinkit-referenced "Shop by category" grid — looser spacing than the
/// old fixed `Categories` widget per the user's "need more gaps between
/// the row" feedback. `config.columns` picks the grid's column count.
class CategoryGridSection extends StatelessWidget {
  final HomeSection section;
  final Map<String, Category> categoriesById;

  const CategoryGridSection({
    super.key,
    required this.section,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    // Clamped: an admin-entered 0 or huge value would break the grid.
    final columns = (section.config.integer('columns') ?? 4).clamp(1, 6);
    final categories = section.items
        .map((item) => categoriesById[item.data['category_id']])
        .whereType<Category>()
        .toList();

    if (categories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ZSpace.x3,
        mainAxisSpacing: ZSpace.x4,
        // Two-line labels at any text size.
        mainAxisExtent: ZCategoryTile.height(context),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return ZCategoryTile(
          label: category.name,
          image: CatalogImage(image: category.image, fit: BoxFit.contain),
          color: ZColors.fromHex(category.colorHex),
          onTap: () =>
              context.push('/categoryDetailsScreen?categoryId=${category.id}'),
        );
      },
    );
  }
}
