import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback action;

  const GoogleSignInButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: AppSizes.button,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.googleSignInButtonColor,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/googleIcon.png', width: 20, height: 20),
            const SizedBox(width: AppSpacing.lg),
            Text('signInWithGoogle'.tr(), style: AppTypography.labelLarge),
          ],
        ),
      ),
    );
  }
}
