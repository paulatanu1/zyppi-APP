import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../Utils/colors.dart';

class YourOrderWidget extends StatelessWidget {
  final Function() onClicked;
  const YourOrderWidget({super.key, required this.onClicked});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
      child: Container(
        width: width,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.lightBlue1
            ),
            borderRadius: BorderRadius.circular(height*0.02),
          ),
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: height*0.03,
                          width: height*0.03,
                          color: AppColors.green1,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Apple grapes & juice",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: AppColors.darkBlue,
                                  fontSize: 16),
                            ),
                            SizedBox(height: height*0.005,),
                            Row(
                              children: [
                                Text(
                                  "80.00",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins',
                                      color: AppColors.black,
                                      fontSize: 10),
                                ),
                                Text(
                                  "24th dec, 9:13pm ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins',
                                      color: AppColors.black,
                                      fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                        onTap: onClicked,
                        child: Icon(Icons.more_vert, size: 20,color: AppColors.darkBlue,))
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.lightBlue1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
                    child: Text(
                      'reOrder'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: AppColors.darkBlue,
                          fontSize: 10),
                    ),
                  ),
                  Container(
                    height: height*0.025,
                    width: width*0.004,
                    color: AppColors.darkBlue,
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
                    child: Text(
                      'rateOrder'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: AppColors.darkBlue,
                          fontSize: 10),
                    ),
                  ),
                ],

              )
            ],
          ),
        ),

      ),
    );
  }
}
