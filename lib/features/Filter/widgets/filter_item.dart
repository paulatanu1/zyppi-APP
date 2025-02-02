import 'package:flutter/material.dart';
import 'package:zippy/core/constants/colors.dart';

class FilterItem extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onCheckBoxChanged;
  const FilterItem({super.key, this.onCheckBoxChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
              value: value,
              onChanged: onCheckBoxChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: AppColors.grey3,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        Text(
          "Noodles & Pasta",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontStyle: FontStyle.italic
          ),
        )
      ],
    );
  }
}
