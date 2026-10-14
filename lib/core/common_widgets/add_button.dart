import 'package:flutter/material.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.stepper,
      width: AppSizes.stepper,
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor,
        borderRadius: BorderRadius.circular(AppRadius.stepper),
      ),
      child: const Center(
        child: Icon(Icons.add, color: AppColors.white, size: 20),
      ),
    );
  }
}
