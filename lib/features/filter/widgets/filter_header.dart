import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';

class FilterHeader extends StatelessWidget {
  final VoidCallback? onCrossIconClicked;

  const FilterHeader({super.key, this.onCrossIconClicked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('filters'.tr(), style: AppTypography.titleMedium),
        IconButton(
          onPressed: onCrossIconClicked,
          icon: const Icon(Icons.close, color: AppColors.ink),
          tooltip: 'close'.tr(),
        ),
      ],
    );
  }
}
