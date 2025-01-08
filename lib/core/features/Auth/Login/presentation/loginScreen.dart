import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/features/Auth/GoogleSignIn/provider/googleProvider.dart';
import 'package:zippy/core/features/Auth/OTPVerification/provider/otpProvider.dart';
import 'package:zippy/core/features/CommonWidgets/googleSignInButton.dart';
import 'package:zippy/core/features/CommonWidgets/primaryButton.dart';
import 'package:zippy/core/features/CommonWidgets/textFormField.dart';
import 'package:zippy/Utils/colors.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController phoneController = TextEditingController();

    final googleToken = ref.watch(googleProvider);
    final otpLogin = ref.watch(otpProvider);

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
                  child: googleToken.loading == true
                      ? const CircularProgressIndicator()
                      : GoogleSignInButton(
                          action: () => ref
                              .read(googleProvider.notifier)
                              .generateGoogleToken(context),
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
                  //Here
                  isNumber: true,
                  labelText: 'phoneNumber'.tr(),
                  textFormFieldController: phoneController,
                ),
                SizedBox(
                  height: 40.h,
                ),
                otpLogin.loading == true
                    ? Center(child: const CircularProgressIndicator())
                    : PrimaryButton(
                        buttonTitle: 'login'.tr(),
                        action: () {
                          if (phoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please Enter Phone Number')),
                            );
                          } else if (phoneController.text.length < 10 ||
                              phoneController.text.length > 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid Phone Number')),
                            );
                          } else {
                            ref
                                .read(otpProvider.notifier)
                                .generateOtp(phoneController.text, context);
                          }
                        }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
