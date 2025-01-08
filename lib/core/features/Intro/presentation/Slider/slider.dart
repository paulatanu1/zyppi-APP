import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/Utils/colors.dart';

class Slider extends StatefulWidget {
  const Slider({super.key});

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  int currentStep = 0; // Step tracker (0-indexed)

  // Define data for each step
  final List<String> stepIndicators = ['1/4', '2/4', '3/4', '4/4'];
  final List<String> images = [
    'assets/images/Splash-1.png',
    'assets/images/Splash-2.png',
    'assets/images/Splash-3.png',
    'assets/images/Splash-4.png',
  ];
  final List<String> text2 = [
    'perfectPickDescription'.tr(),
    'pickupProductsDescription'.tr(),
    'doorstepDeliveryDescription'.tr(),
    'getYourOrderDescription'.tr(),
  ];
  final List<String> text1 = [
    'perfectPick'.tr(),
    'pickupProducts'.tr(),
    'doorstepDelivery'.tr(),
    'getYourOrder'.tr(),
  ];

  // Navigate to the next step
  void _nextStep() {
    if (currentStep < stepIndicators.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  // Navigate to the previous step
  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding:
            EdgeInsets.only(left: 30.0.w, right: 30.w, top: 10.h, bottom: 10.h),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step Indicator
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: stepIndicators[currentStep]
                          .split('/')[0], // The step number (e.g., "1")
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black, // Default color for the number
                      ),
                    ),
                    TextSpan(
                      text: '/4', // The "/4" part
                      style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                          fontFamily: "Montserrat"),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  images[currentStep],
                  key: ValueKey<int>(currentStep),
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              // For the main text (text1[currentStep])
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 0.5), // Start from below
                        end: Offset(0.0, 0.0),   // End at the original position
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  text1[currentStep],
                  key: ValueKey<int>(currentStep), // Unique key for each step
                  style: TextStyle(
                      fontSize: 45.sp,
                      color: AppColors.black,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w800),
                ),
              ),

              SizedBox(
                height: 5.h,
              ),


              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 0.5), // Start from below
                        end: Offset(0.0, 0.0),   // End at the original position
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  text2[currentStep],
                  key: ValueKey<int>(currentStep), // Unique key for each step
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30.sp,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat"),
                ),
              ),

              Spacer(),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: currentStep > 0,
                    child: Bounce(
                      onPressed: _previousStep,
                      duration: Duration(milliseconds: 200),
                      child: Text(
                        'previous'.tr(),
                        style: TextStyle(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                            fontFamily: "Montserrat"),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(stepIndicators.length, (index) {
                      bool isSelected = index == currentStep;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        width: isSelected ? 60.w : 15.w,
                        height: isSelected ? 5.h : 3.h,
                        decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.grey,
                            borderRadius: BorderRadius.circular(5)
                            //shape: BoxShape.circle,
                            ),
                      );
                    }),
                  ),
                  currentStep == 3
                      ? Bounce(
                          onPressed: () {
                            context.push('/loginScreen');
                          },
                          duration: Duration(milliseconds: 200),
                          child: Text(
                            'getStart'.tr(),
                            style: TextStyle(
                                fontSize: 35.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepBlue),
                          ),
                        )
                      : Bounce(
                          onPressed: _nextStep,
                          duration: Duration(milliseconds: 200),
                          child: Text(
                            'next'.tr(),
                            style: TextStyle(
                                fontSize: 35.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepBlue,
                                fontFamily: "Montserrat"),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
