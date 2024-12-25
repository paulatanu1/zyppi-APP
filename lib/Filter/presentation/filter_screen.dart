import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/Filter/widgets/filter_header.dart';
import 'package:zippy/Filter/widgets/filter_item.dart';
import 'package:zippy/Utils/colors.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: height * 0.025, right: height * 0.025),
              child: FilterHeader(),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            Expanded(
              child: Container(
                width: width,
                decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(height * 0.03),
                        topLeft: Radius.circular(height * 0.03))),
                child: Padding(
                  padding:  EdgeInsets.all(height*0.025),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'categories'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: height*0.025,),
                      Expanded(
                        child: ListView.builder(
                            itemCount: 5,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return FilterItem(
                                value: false,
                              );
                            }),
                      ),
                      Text(
                        'brand'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: height*0.025,),

                      Expanded(
                        child: ListView.builder(
                            itemCount: 5,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return FilterItem(
                                value: false,
                              );
                            }),
                      ),
                      PrimaryButton(
                          buttonTitle: 'applyFilter'.tr(), action: () {}),
                      SizedBox(
                        height: height * 0.025,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
