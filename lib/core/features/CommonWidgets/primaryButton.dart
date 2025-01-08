import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class PrimaryButton extends ConsumerWidget {
  final String buttonTitle;
  final VoidCallback action;

  PrimaryButton({required this.buttonTitle, required this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 25.h,
        width: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.primaryButtonColor,
            borderRadius: BorderRadius.circular(30.sp)),
        child: Center(
          child: Text(buttonTitle,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 37.sp)),
        ),
      ),
    );
  }
}
