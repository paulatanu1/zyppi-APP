import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Container(
        height: 20.h,
        width: 20.w,

        child: Center(
          child: Text('submit'.tr(), style: TextStyle(fontSize: 5.sp),),
        ),
      ),
    );
  }
}
