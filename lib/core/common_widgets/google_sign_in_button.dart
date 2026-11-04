import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback action;

  const GoogleSignInButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(ZRadius.input),
      child: Container(
        height: ZSize.button,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.x4),
        decoration: BoxDecoration(
          color: AppColors.googleSignInButtonColor,
          borderRadius: BorderRadius.circular(ZRadius.input),
          border: Border.all(color: context.z.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/googleIcon.png', width: 20, height: 20),
            const SizedBox(width: ZSpace.x3),
            Text('signInWithGoogle'.tr(), style: AppTypography.labelLarge),
          ],
        ),
      ),
    );
  }
}
