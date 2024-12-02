import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Utils/colors.dart';

class TextformField extends StatelessWidget {
  final TextEditingController textFormFieldController;
  final String labelText;

  TextformField(
      {required this.textFormFieldController, required this.labelText});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(left: 30.sp, right: 30.sp),
      decoration: BoxDecoration(
        color: AppColors.textFormFieldColor,
        borderRadius: BorderRadius.circular(30.sp)
        ),
      child: TextFormField(
        controller: textFormFieldController,
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: TextStyle(color: AppColors.hintTextColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 9.h),
        ),
      ),
    );
  }
}
