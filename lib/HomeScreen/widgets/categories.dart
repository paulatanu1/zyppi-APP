import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/HomeScreen/provider/categoriesProvider.dart';
import 'package:zippy/Utils/colors.dart';

class Categories extends ConsumerWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryItem = ref.watch(categoryProvider);

    // TODO: implement build
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            itemCount: categoryItem.chunks.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              final chunk = categoryItem.chunks[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 40.w,
                    mainAxisSpacing: 12.h,
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
        SizedBox(height: 15.h),
        SmoothPageIndicator(
          controller: _pageController,
          count: categoryItem.chunks.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 12.w,
            activeDotColor: AppColors.green,
            dotColor: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
