import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/CommonWidgets/homeScreenHeader.dart';
import 'package:zippy/CommonWidgets/itemCard.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';
import 'package:zippy/HomeScreen/widgets/carousel.dart';
import 'package:zippy/HomeScreen/widgets/categories.dart';
import 'package:zippy/HomeScreen/widgets/homePageProducts.dart';
import 'package:zippy/Utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.gradientHomeBackGround),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(7.h),
                child: Column(
                  children: [
                    HomeScreenHeader(),
                    SizedBox(height: 10.h),
                    TextformField(
                      textFormFieldController: searchController,
                      labelText: 'searchBar'.tr(),
                      prefixIcon: true,
                      borderRadius: 10.0.sp,
                    ),
                    SizedBox(height: 5.h),
                    CategoryCarousel(),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'category'.tr(),
                          style: TextStyle(
                              fontSize: 50.sp,
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins'),
                        ),
                        Bounce(
                          duration: Duration(milliseconds: 200),
                          onPressed: () {
                            context.go('/exploreScreen');
                          },
                          child: Text(
                            'seeAll'.tr(),
                            style: TextStyle(
                                fontSize: 30.sp,
                                color: AppColors.primaryButtonColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins'),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 13.h),
                    Categories(),
                    SizedBox(height: 18.h),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(45.sp)),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16.h, right: 16.h, top: 8.h, bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              "assets/images/Zyppi_logo_white.png",
                              height: 20.h,
                              width: 50.h,
                            ),
                            Column(
                              children: [
                                Text(
                                  "Free delivery \norder above ₹ 199",
                                  style: TextStyle(
                                      fontSize: 30.sp,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      fontStyle: FontStyle.italic),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Stack(
                      children: [
                        SizedBox(
                          height: 35.h,
                          width: 95.h,
                          child: Image.asset(
                            "assets/images/zyppi_underline.png",
                            height: 10.h,
                            width: 80.h,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset('assets/images/underline.png'))
                      ],
                    ),
                    SizedBox(height: 10.h),
                    HomePageProducts()
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
