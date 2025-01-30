import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/features/Account/widgets/profileContainer.dart';
import 'package:zippy/core/features/Account/widgets/profileContainerItem.dart';

import '../../../../Utils/colors.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final List yourInfoList= [
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
                padding:  EdgeInsets.all(height*0.025),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Supriya Singh",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: AppColors.darkBlue,
                              fontSize: 22),
                        ),
                        Row(
                          children: [
                            Image.asset("assets/icons/coin.png", height: height*0.025,width: height*0.025,fit: BoxFit.cover,),
                            SizedBox(width: width*0.01,),
                            Text("300",
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
                    SizedBox(height: height*0.01,),
                    Text("9800072183",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                          fontSize: 13),
                    ),

                    Row(
                      children: [
                        InkWell(
                          onTap: ()
                          {
                            context.push('/editProfileScreen');
                          },
                          child: Text('editProfile'.tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: AppColors.deepBlue1,
                                fontSize: 12),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color:AppColors.deepBlue1,size: 12,)
                      ],
                    ),
                    SizedBox(height: height*0.03,),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                            height: height * 0.32,
                            width: width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.lightBlue1,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Padding(
                              padding:  EdgeInsets.only(top: height*0.02),
                              child: ListView.builder(
                                  itemCount: yourInfoList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ProfileContainerItem(
                                      onClicked: (){
                                        index == 0?context.push('/yourOrderScreen'):
                                         index == 1? context.push('/myAddressScreen'):
                                         context.push('/myAddressScreen');
                                      },
                                      itemName: yourInfoList[index].toString(),);
                                  }),
                            )),
                        // Positioned text on the border
                        Positioned(
                          top: -10,
                          left: width * 0.1,
                          child: Container(
                            padding: EdgeInsets.only(
                                left: height * 0.025,
                                right: height * 0.025,
                                top: height * 0.003,
                                bottom: height * 0.003),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.lightBlue1,
                                width: 1.0,
                              ),
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              'yourInfo'.tr(),
                              style: TextStyle(
                                color: AppColors.lightBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height*0.025,),
                    ProfileContainer(ContainerName: 'otherInfo'.tr(), containerList: otherInfoList,),
                  ],
                ),
              ),

              Image.asset('assets/images/prof_logo.png', height: height*0.05,width: width*0.3,),
              Text(
                'v1.0.0'.tr(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.grey7,
                    fontSize: 12),
              ),

              SizedBox(height: height*0.05,)



          
            ],
          ),
        ),
      )
    );
  }
}