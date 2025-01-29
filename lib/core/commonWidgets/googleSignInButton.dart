import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/constants/colors.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback action;

  GoogleSignInButton({required this.action}); 

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 20.h,
        width: 350.w,
        padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
        decoration: BoxDecoration(
          color: AppColors.googleSignInButtonColor,
          borderRadius: BorderRadius.circular(40.sp),
          border: Border.all(color: AppColors.googleSignInShadowColor)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/icons/googleIcon.png'),
            Text('signInWithGoogle'.tr(), style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
