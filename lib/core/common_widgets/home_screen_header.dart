import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/common_widgets/nav_bar/provider/nav_bar_provider.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/address_label.dart';
import 'package:zippy/core/widgets/z_chrome.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/home_screen/widgets/address_sheet.dart';

/// docs/screens/light/05-home.png's magenta header: "ZYPPI EXPRESS",
/// ⚡ ETA, address row (opens the address sheet), avatar (Account tab) and
/// the search bar (search screen). HomeScreen paints the status-bar strip
/// above it in the same colour.
class HomeScreenHeader extends ConsumerWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: z.header,
      padding: EdgeInsets.fromLTRB(
        ZSpace.screen,
        MediaQuery.paddingOf(context).top + ZSpace.x4,
        ZSpace.screen,
        ZSpace.x5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'zyppiExpress'.tr(),
                      style: t.labelSmall!.copyWith(
                        color: z.headerInk2,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: ZSpace.x1),
                    Row(
                      children: [
                        ZLoop(
                          child: Icon(
                            Icons.bolt_rounded,
                            color: z.deal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: ZSpace.x1),
                        Flexible(
                          child: Text(
                            'etaHeadline'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.headlineSmall!.copyWith(
                              color: z.headerInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZSpace.x1),
                    const _AddressRow(),
                  ],
                ),
              ),
              const SizedBox(width: ZSpace.x3),
              const _Avatar(),
            ],
          ),
          const SizedBox(height: ZSpace.x3),
          ZSearchBar(onTap: () => context.push('/searchScreen')),
        ],
      ),
    );
  }
}

/// "Home · Ranchi Road, Purulia ⌄" — or a small spinner while the location
/// is being detected / checked.
class _AddressRow extends ConsumerWidget {
  const _AddressRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final location = ref.watch(currentLocation);
    final label = location.label == null
        ? 'currentLocation'.tr()
        : addressLabelText(location.label!);
    final busy = location.isDetecting || location.checkingServiceability;
    final secondary = t.labelMedium!.copyWith(
      color: z.headerInk2,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: () => bottomSheet(context, ref),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ZSize.touch),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.labelMedium!.copyWith(
                  color: z.headerInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(' · ', style: secondary),
            if (busy) ...[
              if (!MediaQuery.disableAnimationsOf(context)) ...[
                SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: z.headerInk2,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  'detectingLocation'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: secondary,
                ),
              ),
            ] else
              Flexible(
                child: Text(
                  location.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: secondary,
                ),
              ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: z.headerInk2,
            ),
          ],
        ),
      ),
    );
  }
}

/// The user's initial (person icon until the profile loads, or for
/// guests); opens the Account tab.
class _Avatar extends ConsumerWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final profile = ref.watch(profileProvider).value;
    final name = profile?.fullName?.trim() ?? '';
    final initial = profile == null || profile.isGuest || name.isEmpty
        ? null
        : name.characters.first.toUpperCase();

    return Semantics(
      button: true,
      label: 'navAccount'.tr(),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => ref.read(navBarProvider.notifier).updateIndex(4),
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: ZSize.touch / 2,
          backgroundColor: z.onBrand.withValues(alpha: .16),
          child: initial == null
              ? Icon(Icons.person_outline_rounded, color: z.onBrand)
              : Text(
                  initial,
                  style: Theme.of(context).textTheme.titleMedium!
                      .copyWith(color: z.onBrand, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }
}
