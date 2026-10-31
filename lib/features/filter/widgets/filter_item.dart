import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

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
          activeColor: context.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            side: BorderSide(color: context.colors.line),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: AppTypography.bodyMedium),
      ],
    );
  }
}
