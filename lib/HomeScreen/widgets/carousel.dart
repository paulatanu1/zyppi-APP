import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class CategoryCarousel extends StatefulWidget {
  CategoryCarouselState createState() => CategoryCarouselState();
}

class CategoryCarouselState extends State<CategoryCarousel> {
  int _currentIndex = 0;
  final List<Map<String, String>> _sliderItems = [
    {'image': 'assets/images/veg.png', 'text': 'Slide 1'},
    {'image': 'assets/images/veg.png', 'text': 'Slide 2'},
    {'image': 'assets/images/veg.png', 'text': 'Slide 3'},
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CarouselSlider(
      items: _sliderItems.map((item) {
        return Stack(
          children: [
            // Slider container
            Container(
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
                        item['image']!,
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
            ),
            // Positioned indicator
            Positioned(
              bottom: 10, // Position slightly above the bottom of the container
              left: 0,
              right: 0, // Center-align using left and right
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _sliderItems.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = entry.key),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      width: _currentIndex == entry.key ? 40.w : 15.w,
                      height: _currentIndex == entry.key ? 4.h : 3.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _currentIndex == entry.key
                            ? AppColors.green
                            : AppColors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
      options: CarouselOptions(
        height: 70.h,
        enlargeCenterPage: false,
        autoPlay: false,
        viewportFraction: 1.0, // Ensures full width is taken
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
