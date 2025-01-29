import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';

class FilterHeader extends StatelessWidget {
  final Function()? onCrossIconClicked;
  const FilterHeader({super.key, this.onCrossIconClicked});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
            onTap: onCrossIconClicked,
            child: Icon(Icons.close, weight: 4, size: 30,)),
        SizedBox(width:width*0.3 ,),
        Text(
          'filters'.tr(),
          style: TextStyle(
              fontSize: 20,
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontStyle: FontStyle.italic),
        )
      ],
    );
  }
}
