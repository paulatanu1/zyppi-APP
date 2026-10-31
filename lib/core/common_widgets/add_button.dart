import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Main.dc.html's `.add` pill button.
class AddButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AddButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.stepper),
      child: Container(
        height: AppSizes.stepper,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.stepper),
        ),
        child: Text(
          'add'.tr(),
          style: AppTypography.labelSmall.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
