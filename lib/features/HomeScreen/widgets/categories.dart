import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zippy/core/commonWidgets/categoryCard.dart';
import 'package:zippy/features/HomeScreen/provider/categoriesProvider.dart';
import 'package:zippy/core/constants/colors.dart';

class Categories extends ConsumerWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final categoryItem = ref.watch(categoryProvider);

    // TODO: implement build
    return Column(
      children: [
        Container(
          height: height * 0.45,
          child: PageView.builder(
            itemCount: categoryItem.chunks.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              final chunk = categoryItem.chunks[index];
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
                        categoryText: item.name ?? '',
                        imageUrl: item.image ?? '',
                        backgroundColor: item.color ?? AppColors.grey,
                        borderColor: item.borderColor ?? AppColors.grey);
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: height * 0.015),
        SmoothPageIndicator(
          controller: _pageController,
          count: categoryItem.chunks.length,
          effect: ExpandingDotsEffect(
            dotHeight: height * 0.01,
            dotWidth: width * 0.02,
            activeDotColor: AppColors.green,
            dotColor: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
