import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Opens the full map-pin picker (search_address_screen.dart) to change the
/// home screen's delivery location.
class SearchPlacesWidget extends ConsumerWidget {
  const SearchPlacesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(currentLocation);

    return InkWell(
      borderRadius: BorderRadius.circular(ZRadius.input),
      onTap: () => context.pushNamed('SearchAddressScreen', extra: false),
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
            Icon(Icons.search, size: 20, color: context.z.ink2),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Text(
                location.line1.isNotEmpty
                    ? location.line1
                    : 'searchAreaPlaceholder'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: context.z.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
