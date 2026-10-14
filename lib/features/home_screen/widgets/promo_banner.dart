import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';

/// docs/mockups/Main.dc.html's promo banner, linking to the category
/// grid (Explore).
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/exploreScreen'),
      borderRadius: BorderRadius.circular(AppRadius.banner),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxxl,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadius.banner),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('promoTitle'.tr(), style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'shopNow'.tr(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: Color(0xFFC2410C),
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
