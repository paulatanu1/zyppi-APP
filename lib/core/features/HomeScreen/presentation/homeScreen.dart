import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/features/CommonWidgets/homeScreenHeader.dart';
import 'package:zippy/core/features/CommonWidgets/navBar/provider/navBarProvider.dart';
import 'package:zippy/core/features/CommonWidgets/textFormField.dart';
import 'package:zippy/core/features/HomeScreen/widgets/carousel.dart';
import 'package:zippy/core/features/HomeScreen/widgets/categories.dart';
import 'package:zippy/core/features/HomeScreen/widgets/homePageProducts.dart';
import 'package:zippy/Utils/colors.dart';

class HomeScreen extends ConsumerWidget {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.gradientHomeBackGround),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(height * 0.02
                // 7.h
                ),
            child: Column(
              children: [
                HomeScreenHeader(),
                SizedBox(
                  height: height * 0.015,

                  // height: 10.h
                ),
                TextformField(
                  textFormFieldController: searchController,
                  labelText: 'searchBar'.tr(),
                  prefixIcon: true,
                  borderRadius: width * 0.03,

                  // borderRadius: 10.0.sp,
                ),
                SizedBox(height: height * 0.02

                    // height: 5.h
                    ),
                CategoryCarousel(),
                SizedBox(height: height * 0.015),
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
                        ref.read(navBarProvider.notifier).updateIndex(1);
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
                SizedBox(height: height * 0.025),
                Categories(),
                SizedBox(height: height * 0.025),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(width * 0.05)),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: height * 0.04,
                        right: height * 0.04,
                        top: height * 0.018,
                        bottom: height * 0.018),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Zyppi_logo_white.png",
                          height: height * 0.05,
                          width: width * 0.3,
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
                SizedBox(height: height * 0.02),
                Stack(
                  children: [
                    Image.asset(
                      "assets/images/zyppi_underline.png",
                      height: height * 0.08,
                      width: width * 0.5,
                    ),
                    Positioned(
                        right: 0,
                        bottom: height * 0.008,
                        child: Image.asset('assets/images/underline.png'))
                  ],
                ),
                SizedBox(height: height * 0.02),
                HomePageProducts(
                  onClicked: () {
                    context.push('/productDetailsScreen');
                    // context.go('/categoryDetailsScreen');
                    // context.go('/favouriteScreen');
                    // context.go('/myCartScreen');
                  },
                ),
                SizedBox(height: height * 0.08)
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
