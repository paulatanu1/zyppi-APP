import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/CommonWidgets/googleSignInButton.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';
import 'package:zippy/Utils/colors.dart';
import 'package:zippy/Utils/routes/backButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
                top: 20.h, left: 40.w, right: 40.w, bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'getYour'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black),
                ),
                Text(
                  'delivery'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 70.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.selectedOTP),
                ),
                SizedBox(height: 25.h),
                Center(
                  child: GoogleSignInButton(
                    action: () {},
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Center(
                  child: Text('continueWith'.tr(),
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey1,
                      )),
                ),
                SizedBox(height: 35.h),
                TextformField(
                  labelText: 'phoneNumber'.tr(),
                  textFormFieldController: phoneController,
                ),
                SizedBox(
                  height: 40.h,
                ),
                PrimaryButton(
                    buttonTitle: 'login'.tr(),
                    action: () {
                      context.go('/otpVerificationScreen');
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
