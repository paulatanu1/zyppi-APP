import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/features/Account/widgets/profileContainer.dart';

import '../../../../Utils/colors.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final List yourInfoList = [
      'yourOrder'.tr(),
      'addressBook'.tr(),
      'myDetails'.tr(),
      'myCoins'.tr(),
      'paymentSettings'.tr()
    ];

    final List otherInfoList = [
      'shareApp'.tr(),
      'aboutUs'.tr(),
      'accountPrivacy'.tr(),
      'notificationPref'.tr(),
      'logOut'.tr()
    ];

    return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text(
                    'profile'.tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: AppColors.darkBlue,
                        fontStyle: FontStyle.italic,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                Divider(
                  height: 1,
                  color: AppColors.grey5,
                ),
                Padding(
                  padding: EdgeInsets.all(height * 0.025),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Supriya Singh",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: AppColors.darkBlue,
                                fontSize: 22),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/coin.png",
                                height: height * 0.025,
                                width: height * 0.025,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                width: width * 0.01,
                              ),
                              Text(
                                "300",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: AppColors.brownBlue,
                                    fontSize: 15),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Text(
                        "9800072183",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                            color: AppColors.black,
                            fontSize: 13),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      ProfileContainer(
                        ContainerName: 'yourInfo'.tr(),
                        containerList: yourInfoList,
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      ProfileContainer(
                        ContainerName: 'otherInfo'.tr(),
                        containerList: otherInfoList,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/prof_logo.png',
                  height: height * 0.05,
                  width: width * 0.3,
                ),
                Text(
                  'v1.0.0'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.grey7,
                      fontSize: 12),
                ),
                SizedBox(
                  height: height * 0.05,
                )
              ],
            ),
          ),
        ));
  }
}
