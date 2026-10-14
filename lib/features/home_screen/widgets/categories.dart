import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/application/categories_provider.dart';

/// docs/mockups/Main.dc.html's "Shop by category" 4-column grid.
class Categories extends ConsumerWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryProvider);
    final categories = categoryState.chunks.expand((c) => c).toList();

    if (categoryState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
            const SizedBox(height: 8),
            SizedBox(
              width: 140,
              child: PrimaryButton(
                buttonTitle: 'retry'.tr(),
                action: () => ref.read(categoryProvider.notifier).retry(),
              ),
            ),
          ],
        ),
      );
    }

    final items = categoryState.loading
        ? List.generate(
            8,
            (_) => Category(
              id: '',
              name: 'Category',
              image: 'assets/images/category.png',
              colorHex: 'FFEDF7FD',
              borderColorHex: 'FF52BAF4',
            ),
          )
        : categories;

    return AppSkeleton(
      enabled: categoryState.loading,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final category = items[index];

          return CategoryCard(
            categoryText: category.name,
            imageUrl: category.image,
            backgroundColor: AppColors.fromHex(category.colorHex),
            onTap: categoryState.loading
                ? null
                : () => context.push(
                    '/categoryDetailsScreen?categoryId=${category.id}',
                  ),
          );
        },
      ),
    );
  }
}
