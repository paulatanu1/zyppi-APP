import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_colors.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/features/home_screen/widgets/address_sheet.dart';

/// Matches docs/mockups/Main.dc.html's header: delivery ETA + profile
/// avatar, address row, search bar.
class HomeScreenHeader extends ConsumerWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getCurrentLocation = ref.watch(currentLocation);

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'deliveryEta'.tr(),
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: () => ref.read(navBarProvider.notifier).updateIndex(4),
                borderRadius: BorderRadius.circular(22),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryDark,
                  child: Icon(Icons.person_outline, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () => bottomSheet(context, ref),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${'home'.tr()} · ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: getCurrentLocation.isDetecting == true
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          getCurrentLocation.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onPrimaryMuted,
                          ),
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.onPrimaryMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () => context.push('/searchScreen'),
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Container(
              height: AppSizes.inputMin,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.muted),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Text(
                      'homeSearchHint'.tr(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
