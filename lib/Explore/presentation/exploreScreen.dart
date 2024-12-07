import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/Auth/Login/presentation/loginScreen.dart';
import 'package:zippy/CommonWidgets/categoryCard.dart';
import 'package:zippy/CommonWidgets/commonHeader.dart';
import 'package:zippy/CommonWidgets/textFormField.dart';
import 'package:zippy/Utils/colors.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(8.h),
          child: Column(
            children: [
              CommonHeader(),
              SizedBox(height: 13.h),
              TextformField(
                prefixIcon: true,
                textFormFieldController: searchController,
                labelText: 'searchStore'.tr(),),
              SizedBox(height: 10.h),
              Expanded(
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.h,
                    mainAxisSpacing: 5.h,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                        categoryText: "Frash Fruits & Vegetable", index: index);
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
