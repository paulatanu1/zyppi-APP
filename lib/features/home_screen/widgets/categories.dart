import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zippy/core/common_widgets/app_skeleton.dart';
import 'package:zippy/core/common_widgets/category_card.dart';
import 'package:zippy/core/common_widgets/primary_button.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/application/categories_provider.dart';

class Categories extends ConsumerWidget {
  Categories({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final categoryState = ref.watch(categoryProvider);

    if (categoryState.error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.04),
        child: Column(
          children: [
            Text('somethingWentWrong'.tr(), style: AppTypography.bodyMedium),
            SizedBox(height: height * 0.01),
            SizedBox(
              width: width * 0.4,
              child: PrimaryButton(
                buttonTitle: 'retry'.tr(),
                action: () => ref.read(categoryProvider.notifier).retry(),
              ),
            ),
          ],
        ),
      );
    }

    final chunks = categoryState.loading
        ? [
            List.generate(
              4,
              (_) => Category(
                id: '',
                name: 'Category name',
                image: 'assets/images/category.png',
                colorHex: 'FFEDF7FD',
                borderColorHex: 'FF52BAF4',
              ),
            ),
          ]
        : categoryState.chunks;

    return AppSkeleton(
      enabled: categoryState.loading,
      child: Column(
        children: [
          SizedBox(
            height: height * 0.45,
            child: PageView.builder(
              itemCount: chunks.length,
              controller: _pageController,
              itemBuilder: (context, index) {
                final chunk = chunks[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : width * 0.04),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: width * 0.04,
                      mainAxisSpacing: height * 0.02,
                    ),
                    itemCount: chunk.length,
                    itemBuilder: (context, subIndex) {
                      final item = chunk[subIndex];
                      return CategoryCard(
                        categoryText: item.name,
                        imageUrl: item.image,
                        backgroundColor: AppColors.fromHex(item.colorHex),
                        borderColor: AppColors.fromHex(item.borderColorHex),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: height * 0.015),
          SmoothPageIndicator(
            controller: _pageController,
            count: chunks.length,
            effect: ExpandingDotsEffect(
              dotHeight: height * 0.01,
              dotWidth: width * 0.02,
              activeDotColor: AppColors.green,
              dotColor: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
