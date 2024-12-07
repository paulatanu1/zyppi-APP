import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/Auth/Login/presentation/loginScreen.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/CommonWidgets/homeScreenHeader.dart';
import 'package:zippy/CommonWidgets/itemCard.dart';
import 'package:zippy/CommonWidgets/searchBar.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';
import 'package:zippy/Utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  final List<Map<String, String>> _sliderItems = [
    {'image': 'assets/images/veg.png', 'text': 'Slide 1'},
    {'image': 'assets/images/veg.png', 'text': 'Slide 2'},
    {'image': 'assets/images/veg.png', 'text': 'Slide 3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.gradientHomeBackGround
        ),
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
                    textFormFieldController:searchController ,
                    labelText: 'searchBar'.tr(),
                    prefixIcon: true,
                  ),
              
                  SizedBox(height: 5.h),
              
                  CarouselSlider(
                    items: _sliderItems.map((item) {
                      return Stack(
                        children: [
                          // Slider container
                          Container(
                            width: double.infinity, // Full width of the screen
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.h),
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(5.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Image
                                  ClipRRect(
                                    child: Image.asset(
                                      item['image']!,
                                      height: 60.h,
                                      width: 70.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Text content
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Fresh Vegetables",
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontFamily: 'Aclonica',
                                          fontSize: 40.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        "Get Up To 40% OFF",
                                        style: TextStyle(
                                          color: AppColors.green,
                                          fontFamily: "Poppins",
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Positioned indicator
                          Positioned(
                            bottom: 10, // Position slightly above the bottom of the container
                            left: 0,
                            right: 0, // Center-align using left and right
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _sliderItems.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () => setState(() => _currentIndex = entry.key),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    margin:  EdgeInsets.symmetric(horizontal: 8.w),
                                    width: _currentIndex == entry.key ? 40.w : 15.w,
                                    height: _currentIndex == entry.key ? 4.h : 3.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: _currentIndex == entry.key
                                          ? AppColors.green
                                          : AppColors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 70.h,
                      enlargeCenterPage: false,
                      autoPlay: false,
                      viewportFraction: 1.0, // Ensures full width is taken
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
              
                  SizedBox(height: 15.h),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('category'.tr(), style: TextStyle(
                          fontSize: 50.sp,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'
                      ),),
                      Bounce(
                        duration: Duration(milliseconds: 200),
                        onPressed: () {
                          context.go('/exploreScreen');
                        },
                        child: Text('seeAll'.tr(), style: TextStyle(
                            fontSize: 30.sp,
                            color: AppColors.primaryButtonColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'
                        ),),
                      )
              
                    ],
                  ),
              
                  SizedBox(height: 13.h),
              
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.h,
                      mainAxisSpacing: 5.h,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return CategoryCard(
                          categoryText: "Frash Fruits & Vegetable", index: index);
                    },
                  ),
              
                  SizedBox(height: 18.h),
              
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:AppColors.blue,
                      borderRadius: BorderRadius.circular(30.sp)
                    ),
              
                    child:Padding(
                      padding: EdgeInsets.only(left: 16.h, right: 16.h, top: 8.h, bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/Zyppi_logo_white.png", height: 25.h,width: 60.h,),
              
                          Column(children: [
              
                            Text("Free delivery \norder above ₹ 199", style:
                                TextStyle(
                                    fontSize: 35.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  fontStyle: FontStyle.italic
                            ),)
              
                          ],)
                        ],
                      ),
                    ) ,
                  ),
              
                  SizedBox(height: 20.h),
              
                  RichText(
                    text: TextSpan(
                      text: 'lowestIn'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 40.sp,
                          color: AppColors.grey1,
                          fontFamily: "Montserrat"
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Zyppi'.tr(), style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Righteous',
                            color: AppColors.deepBlue1,
                            fontSize: 50.sp
                        )),
                      ],
                    ),
                  ),
              
                  SizedBox(height: 20.h),
              
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.h,
                      mainAxisSpacing: 8.h,
                      childAspectRatio: 0.8
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return ItemCard(productName: 'Fresh Apple Juice', quantity: '2L', price: '80');
                    },
                  ),
                ],
              
              ),
            ),
          ),
        )
      ),
    );
  }
}
