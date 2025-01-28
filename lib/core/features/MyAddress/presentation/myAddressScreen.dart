import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';

class MyAddressScreen extends StatefulWidget {
  const MyAddressScreen({super.key});

  @override
  State<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new, size: 20,)),
                SizedBox(width: width*0.02,),
                Text(
                  'myAddress'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.darkBlue,
                      fontStyle: FontStyle.italic,
                      fontSize: 18),
                ),
        
              ],
            ),

            SizedBox(
              height: height * 0.025,
            ),
            Divider(
              height: 1,
              color: AppColors.grey5,
            ),
            SizedBox(
              height: height * 0.025,
            ),

            Padding(
              padding:  EdgeInsets.only(left: height*0.02, right: height*0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.grey8,
                      borderRadius: BorderRadius.circular(height*0.02),
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add, color: AppColors.deepBlue2,size: 20,),
                              SizedBox(
                                width: width * 0.02,
                              ),
                              Text(
                                'addNewAddress'.tr(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: AppColors.deepBlue2,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20,color: AppColors.deepBlue2,)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  Text(
                    'yourSavedAddress'.tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color: AppColors.black,
                        fontSize: 14),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),

                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.grey8,
                      borderRadius: BorderRadius.circular(height*0.015)
                    ),
                    child: Padding(
                      padding:  EdgeInsets.only(left:height*0.02, right: height*0.02, top: height*0.01, bottom: height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: height*0.035,
                                width: height*0.03,
                                color: AppColors.lightBlue1,
                              ),
                               SizedBox(width: width*0.02,),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     'Home',
                                     style: TextStyle(
                                         fontWeight: FontWeight.w600,
                                         fontFamily: 'Poppins',
                                         color: AppColors.black,
                                         fontSize: 15),
                                   ),
                                   Text(
                                     'Chelyama, Raghunathpur, Purulia, 723146',
                                     style: TextStyle(
                                         fontWeight: FontWeight.w300,
                                         fontFamily: 'Poppins',
                                         color: AppColors.black,
                                         fontSize: 12),
                                   ),
                                   Text(
                                     'Phone: 8637003404',
                                     style: TextStyle(
                                         fontWeight: FontWeight.w500,
                                         fontFamily: 'Poppins',
                                         color: AppColors.black,
                                         fontSize: 12),
                                   ),

                                 ],
                               ),
                            ],
                          ),
                           Icon(Icons.more_vert),

                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Spacer(),
            Column(
              children: [
                Image.asset('assets/images/prof_logo.png', height: height*0.05,width: width*0.3,),
                Text(
                  'v1.0.0'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.grey7,
                      fontSize: 12),
                ),
              ],
            )

            

           


          ],
        ),
      ),
    );
  }
}
