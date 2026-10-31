import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// Opens the map-pin picker in "save a new address" mode.
class AddNewAddressRow extends StatelessWidget {
  const AddNewAddressRow({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: () => context.pushNamed('SearchAddressScreen', extra: true),
      child: Container(
        height: AppSizes.inputMin,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: context.colors.line),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: context.colors.primary),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                'addNewAddress'.tr(),
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
