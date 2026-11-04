import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

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
          icon: Icon(Icons.close, color: context.z.ink),
          tooltip: 'close'.tr(),
        ),
      ],
    );
  }
}
