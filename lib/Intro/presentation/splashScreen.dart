import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/CommonWidgets/googleSignInButton.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';

class SplashScreen extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 30.sp, right: 30.sp),
          child: Column(
            children: [
              GoogleSignInButton(action: () => log('Google Sign In')),
              SizedBox(height: 20.h),
              PrimaryButton(
                  buttonTitle: 'login'.tr(), action: () => log('Clicked')),
                  SizedBox(height: 20),
              TextformField(textFormFieldController: controller, labelText: 'phoneNumber'.tr()),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}
