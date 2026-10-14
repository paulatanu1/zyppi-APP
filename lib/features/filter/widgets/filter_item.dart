import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';

class FilterItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onCheckBoxChanged;

  const FilterItem({
    super.key,
    required this.label,
    required this.value,
    this.onCheckBoxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onCheckBoxChanged,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.grey3),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: AppTypography.bodyMedium),
      ],
    );
  }
}
