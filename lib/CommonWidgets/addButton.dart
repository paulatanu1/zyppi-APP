import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 80.w,
      width: 75.w,
      margin: EdgeInsets.only(top: 2.h, bottom: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor,
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Center(
        child: Icon(Icons.add, color: AppColors.white,)
      ),
    );
  }
}