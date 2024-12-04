import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class CategoryCard extends StatelessWidget {
  final String categoryText;
  // final String imageUrl;
  final int index;

  CategoryCard({required this.categoryText, required this.index});

  int calculateColorIndex(int index, int colorListLength) {
    return index % colorListLength;
  }

  Color getCardColor(int index) {
    final baseColor = AppColors.categoryColors[
            calculateColorIndex(index, AppColors.categoryColors.length)]
        ['categoryCard'];

    // Extract RGBA values from the base color
    final red = baseColor.red;
    final green = baseColor.green;
    final blue = baseColor.blue;

    // Create a new color with desired opacity
    return Color.fromRGBO(red, green, blue, 0.7); // Adjust opacity as needed
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 92.h,
      width: 350.w,
      decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.categoryColors[calculateColorIndex(
                      index, AppColors.categoryColors.length)]
                  ['categoryCardBorder']),
          borderRadius: BorderRadius.circular(50.sp),
          // color: color, borderRadius: BorderRadius.circular(20.sp)
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                getCardColor(index),
                getCardColor(index).withOpacity(0.5),
                getCardColor(index).withOpacity(0.2),
              ])),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/category.png'),
          SizedBox(height: 10.h),
          Text(categoryText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30.sp,
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'))
        ],
      ),
    );
  }
}
