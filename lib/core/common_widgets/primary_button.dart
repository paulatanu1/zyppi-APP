import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        height: ZSize.button.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonColor ?? context.z.brand,
          borderRadius: BorderRadius.circular(borderRadius ?? ZRadius.input.r),
        ),
        child: Center(
          child: Text(
            buttonTitle,
            style: AppTypography.labelLarge.copyWith(
              color: context.z.onBrand,
              fontSize: fontSize ?? AppTypography.labelLarge.fontSize?.sp,
            ),
          ),
        ),
      ),
    );
  }
}
