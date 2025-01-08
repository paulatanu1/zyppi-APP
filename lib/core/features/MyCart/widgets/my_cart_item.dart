import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:zippy/core/features/MyCart/widgets/item_count_container.dart';
import 'package:zippy/Utils/colors.dart';

class MyCartItem extends StatelessWidget {
  final Function() crossIconClicked;
  const MyCartItem({super.key, required this.crossIconClicked});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.only(left:height*0.02, right: height*0.02),
      child: Column(
        children: [
          Padding(
            padding:  EdgeInsets.only(top:height*0.02, bottom: height*0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/milk.png',
                  height: height * 0.08,
                  width: width * 0.15,
                  fit: BoxFit.contain,
                ),

                SizedBox(width: height*0.025,),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bell Pepper Red",
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        "1kg, Price",
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey3,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: height*0.02,),
                      Row(
                        children: [
                          ItemCountContainer(icon: Icons.remove, colors: AppColors.grey3,),
                          SizedBox(width: height*0.02,),
                          Text(
                            "1",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: height*0.02,),


                          ItemCountContainer(icon: Icons.add, colors: AppColors.primaryButtonColor,),


                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Bounce(

                        duration: Duration(milliseconds: 300),
                        onPressed: crossIconClicked,
                        child: Icon(Icons.close, size: 30,color: AppColors.grey3,)),
                    SizedBox(height: height*0.04,),
                    Text(
                      "\$4.99",
                      style: TextStyle(
                          fontSize: 18,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(
              height: 1,
              color: AppColors.grey5,
            ),
          ),
        ],
      ),
    );
  }
}
