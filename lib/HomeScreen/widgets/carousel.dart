import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/HomeScreen/provider/carouselProvider.dart';
import 'package:zippy/Utils/colors.dart';

class CategoryCarousel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carousel = ref.watch(carouselProvider);
    final carouselFunction = ref.read(carouselProvider.notifier);

    // TODO: implement build
    return Column(
      children: [
        CarouselSlider(
          items: carousel.carouselList.map((item) {
            return Container(
              width: double.infinity, // Full width of the screen
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image
                    ClipRRect(
                      child: Image.asset(
                        item.image ?? 'assets/images/veg.png',
                        height: 60.h,
                        width: 60.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Text content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fresh Vegetables",
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: 'Aclonica',
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "Get Up To 40% OFF",
                          style: TextStyle(
                            color: AppColors.green,
                            fontFamily: "AirbnbCereal",
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 70.h,
            enlargeCenterPage: false,
            autoPlay: false,
            viewportFraction: 1.0, // Ensures full width is taken
            onPageChanged: (index, reason) =>
                carouselFunction.changeIndex(index),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carousel.carouselList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => carouselFunction.changeIndex(entry.key),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                width: carousel.index == entry.key ? 40.w : 15.w,
                height: carousel.index == entry.key ? 4.h : 3.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: carousel.index == entry.key
                      ? AppColors.green
                      : AppColors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
