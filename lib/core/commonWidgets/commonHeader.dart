import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/constants/colors.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("findProducts".tr(), style: TextStyle(
            fontSize: 50.sp,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          fontStyle: FontStyle.italic
        ),)
      ],
    );
  }
}
