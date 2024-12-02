import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback action;

  PrimaryButton({required this.buttonTitle, required this.action});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 30.h,
        width: double.infinity,
        margin: EdgeInsets.only(left: 30.sp, right: 30.sp),
        decoration: BoxDecoration(
            color: AppColors.primaryButtonColor,
            borderRadius: BorderRadius.circular(45.sp)),
        child: Center(
          child: Text(buttonTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 45.sp)),
        ),
      ),
    );
  }
}
