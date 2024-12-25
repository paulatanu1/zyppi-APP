import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';

class FavouriteItem extends StatelessWidget {
  const FavouriteItem({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.only(left:height*0.02, right: height*0.02,),
      child: Column(
        children: [

          Padding(
            padding:  EdgeInsets.only(top:height*0.02, bottom: height*0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/milk.png',
                      height: height * 0.08,
                      width: width * 0.15,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: height*0.025,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sprite Can",
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontStyle: FontStyle.italic),
                        ),
                        Text(
                          "325ml, Price",
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey3,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "\$1.50",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',

                      ),
                    ),

                    SizedBox(width: height*0.015,),

                    Icon(Icons.arrow_forward_ios, size: 20,),
                  ],
                )


              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.grey5,
          ),
        ],
      ),
    );
  }
}
