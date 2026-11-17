import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/app_settings/data/app_settings_repository.dart';
import 'package:zippy/core/app_settings/domain/app_settings.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Notices at the top of Home: ordering paused in the customer's area
/// (Settings → Services) and the admin's announcement (Store settings).
/// Takes no space when there's nothing to say.
class HomeNotices extends ConsumerWidget {
  const HomeNotices({super.key, required this.serviceAreaId});

  /// The delivery address's service area, if known.
  final String? serviceAreaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    final closed = ref.watch(featureFlagsProvider).isAreaClosed(serviceAreaId);
    final config = ref.watch(appConfigProvider);
    final announcement = config.announcement;
    if (!closed && announcement == null) return const SizedBox.shrink();

    final (bg, fg, icon) = switch (config.announcementTone) {
      AnnouncementTone.warning => (
        z.warnSoft,
        z.warn,
        Icons.info_outline_rounded,
      ),
      AnnouncementTone.offer => (
        z.brandSoft,
        z.brandText,
        Icons.local_offer_outlined,
      ),
      AnnouncementTone.info => (
        z.blueSoft,
        z.blueText,
        Icons.campaign_outlined,
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZSpace.screen,
        ZSpace.x3,
        ZSpace.screen,
        0,
      ),
      child: Column(
        children: [
          if (closed)
            _Strip(
              background: z.dangerSoft,
              foreground: z.danger,
              icon: Icons.storefront_outlined,
              text: 'orderingPausedInArea'.tr(),
            ),
          if (closed && announcement != null) const SizedBox(height: ZSpace.x2),
          if (announcement != null)
            _Strip(
              background: bg,
              foreground: fg,
              icon: icon,
              text: announcement,
            ),
        ],
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.text,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: ZSpace.x4,
          vertical: ZSpace.x3,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: ZRadius.all(ZRadius.control),
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: ZSpace.x3),
            Expanded(
              child: Text(
                text,
                style: t.bodyMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
