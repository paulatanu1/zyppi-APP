import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Opens the map-pin picker in "save a new address" mode.
class AddNewAddressRow extends StatelessWidget {
  const AddNewAddressRow({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ZRadius.input),
      onTap: () => context.pushNamed('SearchAddressScreen', extra: true),
      child: Container(
        height: ZSize.input,
        padding: const EdgeInsets.symmetric(horizontal: ZSpace.x3),
        decoration: BoxDecoration(
          color: context.z.surface,
          borderRadius: BorderRadius.circular(ZRadius.input),
          border: Border.all(color: context.z.line),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: context.z.brand),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Text(
                'addNewAddress'.tr(),
                style: AppTypography.bodyMedium.copyWith(
                  color: context.z.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.z.brand),
          ],
        ),
      ),
    );
  }
}
