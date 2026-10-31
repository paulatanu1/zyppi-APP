import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/theme/app_colors.dart';
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.68,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return CategoryCard(
          categoryText: category.name,
          imageUrl: category.image,
          backgroundColor: AppColors.fromHex(category.colorHex),
          onTap: () =>
              context.push('/categoryDetailsScreen?categoryId=${category.id}'),
        );
      },
    );
  }
}
