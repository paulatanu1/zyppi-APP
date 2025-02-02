import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/constants/colors.dart';

class PrimaryButton extends ConsumerWidget {
  final String buttonTitle;
  final VoidCallback action;
  final Color? buttonColor;
  final double? fontSize;
  final double? borderRadius;

  PrimaryButton(
      {required this.buttonTitle,
      required this.action,
      this.buttonColor,
      this.fontSize,
      this.borderRadius
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 25.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: buttonColor ?? AppColors.primaryButtonColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 30.sp)),
        child: Center(
          child: Text(buttonTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontSize: fontSize ?? 37.sp)),
        ),
      ),
    );
  }
}
