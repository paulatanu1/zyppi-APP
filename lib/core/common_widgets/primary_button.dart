import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback action;
  final Color? buttonColor;
  final double? fontSize;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.buttonTitle,
    required this.action,
    this.buttonColor,
    this.fontSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        height: AppSizes.button.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.input.r,
          ),
        ),
        child: Center(
          child: Text(
            buttonTitle,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.white,
              fontSize: fontSize ?? AppTypography.labelLarge.fontSize?.sp,
            ),
          ),
        ),
      ),
    );
  }
}
