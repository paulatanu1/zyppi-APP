import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Location.dc.html's `.saved` row.
class SavedAddressRow extends StatelessWidget {
  final Address address;

  /// e.g. My Address's edit/delete menu.
  final Widget? trailing;

  const SavedAddressRow({super.key, required this.address, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Icon(
              address.label.toLowerCase() == 'work'
                  ? Icons.work_outline
                  : Icons.home_outlined,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      addressLabelText(address.label),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Text(
                          'defaultAddress'.tr(),
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  [
                    address.line1,
                    address.area,
                  ].where((s) => s.isNotEmpty).join(', '),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.muted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
