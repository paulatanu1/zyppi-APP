import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';

class ProfileContainerItem extends StatelessWidget {
  final String itemName;
  final Function()? onClicked;
  const ProfileContainerItem({super.key, required this.itemName, this.onClicked});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.only(left: height*0.03, right:height*0.025, top: height*0.02 ),
      child: InkWell(
        onTap: onClicked,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.lightBlue1),
                  child: Padding(
                    padding:  EdgeInsets.all(height*0.006),
                    child: Icon(Icons.account_box_outlined,size: 20,color: AppColors.black.withOpacity(0.8),),
                  ),
                ),
                SizedBox(
                  width: width * 0.025,
                ),
                Text(
                  itemName,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                      fontSize: 15),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 20,)
          ],
        ),
      ),
    );
  }
}
