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
    'assets/icons/Splash-1.png',
    'assets/icons/Splash-2.png',
    'assets/icons/Splash-3.png',
    'assets/icons/Splash-4.png',
  ];
  final List<String> text2 = [
    'slider1-t'.tr(),
    'slider2-t'.tr(),
    'slider3-t'.tr(),
    'slider4-t'.tr(),
  ];
  final List<String> text1 = [
    'slider1-h'.tr(),
    'slider2-h'.tr(),
    'slider3-h'.tr(),
    'slider4-h'.tr(),
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
        padding: EdgeInsets.only(left: 20.0, right: 20, top: 30, bottom: 30),
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
                        color: Colors.black, // Default color for the number
                      ),
                    ),
                    TextSpan(
                      text: '/4', // The "/4" part
                      style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontFamily: "Montserrat"),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 200.h,
                width: double.infinity,
                child: Image.asset(
                  images[currentStep],
                ),
              ),

              Text(
                text1[currentStep],
                style: TextStyle(
                    fontSize: 55.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(
                height: 5.h,
              ),
              Text(
                text2[currentStep],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 35.sp,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Montserrat"),
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
                            fontSize: 40.sp,
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
                        width: isSelected ? 70.w : 15.w,
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
                            context.go('/signupScreen');
                          },
                          duration: Duration(milliseconds: 200),
                          child: Text(
                            'getStart'.tr(),
                            style: TextStyle(
                                fontSize: 40.sp,
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
                                fontSize: 40.sp,
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
