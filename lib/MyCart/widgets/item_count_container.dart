import 'package:flutter/material.dart';
import 'package:zippy/Utils/colors.dart';

class ItemCountContainer extends StatelessWidget {
  final IconData icon;
  final Color colors;
  const ItemCountContainer({super.key, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;


    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.grey4,
              width: 1
          )
      ),
      child: Padding(
        padding:  EdgeInsets.all(height*0.01),
        child: Icon(icon, size: 20,color:colors, ),
      ),

    );
  }
}
