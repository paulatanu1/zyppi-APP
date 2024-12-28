import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/Utils/colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20.h, left: 40.w, right: 40.w, bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'otpVerification'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 70.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'phoneVerification'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  'enterOtp'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey1),
                ),
                SizedBox(
                  height: 20.h,
                ),
                OtpTextField(
                  numberOfFields: 4,
                  fieldWidth: 110.w,
                  // fieldWidth: 95.w,
                  // fieldHeight: 180.w,
                  margin: EdgeInsets.all(10.sp),
                  focusedBorderColor: AppColors.selectedOTP,
                  enabledBorderColor: AppColors.selectedOTP1,
                  borderRadius: BorderRadius.circular(18.sp),
                  borderWidth: 1,
                  showFieldAsBox: true,
                  onCodeChanged: (String code) {},
                  onSubmit: (String verificationCode) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Verification Code"),
                            content:
                                Text('Code entered is $verificationCode'),
                          );
                        });
                  }, // end onSubmit
                ),
                SizedBox(
                  height: 25.h,
                ),
                Text(
                  'resendCode'.tr(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightBlue),
                ),
                SizedBox(
                  height: 50.h,
                ),
                PrimaryButton(
                    buttonTitle: 'submit'.tr(),
                    action: () {
                      context.push('/navBar');
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
