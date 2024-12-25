import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/CommonWidgets/primaryButton.dart';
import 'package:zippy/ProductDetails/widgets/dropdown_expentiantile.dart';
import 'package:zippy/ProductDetails/widgets/product_slider.dart';
import 'package:zippy/Utils/colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSlider(),
            Padding(
              padding: EdgeInsets.only(left:height*0.02, right:height*0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Naturel Red Apple",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppColors.darkBlue,
                            fontStyle: FontStyle.italic,
                            fontSize: 24),
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 30,
                        color: AppColors.grey,
                        weight: 4,
                      )
                    ],
                  ),
                  SizedBox(height: height*0.015,),
                  Text(
                    "1kg, Price",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: AppColors.grey3,
                        fontSize: 16),
                  ),
                  SizedBox(height: height*0.025,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.remove,
                            size: 30,
                            weight: 4,
                            color: AppColors.grey4,
                          ),
                           SizedBox(width: width*0.03,),
                          Container(
                            height: height * 0.05,
                            width: width * 0.1,
                            decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text("1",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: AppColors.darkBlue,
                                      fontSize: 18)),
                            ),
                          ),
                          SizedBox(width: width*0.03,),
                          Icon(
                            Icons.add,
                            size: 30,
                            weight: 4,
                            color: AppColors.green,
                          ),
                        ],
                      ),
                      Text(
                        "₹ 90",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: AppColors.darkBlue,
                            fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: height*0.03,),
                  Divider(
                    height: 1,
                    color: AppColors.grey5,
                  ),
                  DropdownExpansionTile(
                    dropDownTitle: 'Product Detail',
                    dropDownContent: 'Apples are nutritious. Apples may be good for weight loss. apples may be good for your heart. As part of a healtful and varied diet.',),
                  Divider(
                    height: 1,
                    color: AppColors.grey5,
                  ),
                  DropdownExpansionTile(
                    dropDownTitle: 'Nutritions',
                    dropDownContent: 'Apples are nutritious. Apples may be good for weight loss. apples may be good for your heart. As part of a healtful and varied diet.',
                    dynamicWidget: Container(
                      // height: height*0.028,
                      // width: width*0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.grey6
                      ),
                      child: Padding(
                        padding:  EdgeInsets.only(left: width*0.02,right: width*0.02, top: width*0.02, bottom: width*0.02),
                        child: Text(
                          "100 gm",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: AppColors.grey3,
                              fontSize: 9),
                        ),
                      ),
                    ),
                  ),
        
                  Divider(
                    height: 1,
                    color: AppColors.grey5,
                  ),
        
                  DropdownExpansionTile(
                    dropDownTitle: 'Review',
                    dropDownContent: 'Apples are nutritious. Apples may be good for weight loss. apples may be good for your heart. As part of a healtful and varied diet.',
                    dynamicWidget: Padding(
                      padding:  EdgeInsets.only(left: width*0.02,right: width*0.02, top: width*0.02, bottom: width*0.02),
                      child: Row(
                      children: List.generate(5, (index) {
                        return const Icon(Icons.star, color: AppColors.darkBlue,size: 20,);
        
                        }))
                    ),
                  ),
                  SizedBox(height: height*0.015,),
                  PrimaryButton(
                      buttonTitle: 'addToBasket'.tr(), action: (){}),

                  SizedBox(height: height*0.025,),
        
        
        
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
