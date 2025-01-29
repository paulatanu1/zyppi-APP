import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';

class CategoryDetailsHeader extends StatelessWidget {
  final Function()? onBackIconClicked;
  final Function()? onFilterIconClicked;
  const CategoryDetailsHeader({super.key,  this.onBackIconClicked,  this.onFilterIconClicked});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
            onTap: onBackIconClicked,
            child: Icon(Icons.arrow_back_ios, size: 20,weight: 4,color: AppColors.black,)),
        Text("Beverages",style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.darkBlue,
            fontStyle: FontStyle.italic,
            fontSize: 20),
        ),
        InkWell(
            onTap: onFilterIconClicked,
            child: Image.asset("assets/icons/filter.png", height:height*0.025,width: height*0.025,fit: BoxFit.cover,)),


      ],
    );
  }
}
