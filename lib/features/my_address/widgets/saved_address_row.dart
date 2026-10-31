import 'package:flutter/material.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// docs/mockups/Location.dc.html's `.saved` row.
class SavedAddressRow extends StatelessWidget {
  final Address address;

  const SavedAddressRow({super.key, required this.address});

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
                Text(
                  address.label,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${address.line1}, ${address.area}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
