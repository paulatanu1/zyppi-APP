import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class CategoryCard extends StatelessWidget {
  final String categoryText;
  final String imageUrl;
  final Color backgroundColor;
  final Color borderColor;

  CategoryCard(
      {required this.categoryText,
      required this.imageUrl,
      required this.backgroundColor,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      // height: 180.h,
      width: 350.w,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(50.sp),
          // color: color, borderRadius: BorderRadius.circular(20.sp)
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.1),
                backgroundColor.withOpacity(0.1)
              ])),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imageUrl, height: 180.w, width: 180.w),
          // SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.all(5.h),
            child: Text(categoryText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
          )
        ],
      ),
    );
  }
}
