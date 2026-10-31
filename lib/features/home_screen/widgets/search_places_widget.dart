import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/app_spacing.dart';
import 'package:zippy/core/theme/app_typography.dart';
import 'package:zippy/core/theme/app_colors_ext.dart';

/// Opens the full map-pin picker (search_address_screen.dart) to change the
/// home screen's delivery location.
class SearchPlacesWidget extends ConsumerWidget {
  const SearchPlacesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocation);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: () => context.pushNamed('SearchAddressScreen', extra: false),
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
            Icon(Icons.search, size: 20, color: context.colors.muted),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                location.line1.isNotEmpty
                    ? location.line1
                    : 'searchAreaPlaceholder'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
