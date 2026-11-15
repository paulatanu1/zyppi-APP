import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/app_settings/data/app_settings_repository.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';

/// Play Store page of this app (Android-only release; see the
/// android-only-release decision).
final _storeUri = Uri.https('play.google.com', '/store/apps/details', {
  'id': 'com.zyppi.one',
});

/// Wraps the navigator (MaterialApp.builder): shows a full-screen notice
/// instead of the app while Settings → Services has maintenance on, or
/// when this app is older than the minimum version.
class AppGate extends ConsumerWidget {
  const AppGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    if (ref.watch(updateRequiredProvider)) {
      return _Notice(
        icon: Icons.system_update_rounded,
        title: 'updateRequiredTitle'.tr(),
        message: 'updateRequiredMessage'.tr(),
        action: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, ZSize.button),
          ),
          onPressed: () => openExternal(_storeUri),
          child: Text('updateNow'.tr()),
        ),
      );
    }
    if (flags.maintenance) {
      return _Notice(
        icon: Icons.construction_rounded,
        title: 'maintenanceTitle'.tr(),
        message: flags.maintenanceMessage.trim().isNotEmpty
            ? flags.maintenanceMessage.trim()
            : 'maintenanceMessage'.tr(),
      );
    }
    return child;
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: z.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ZSpace.x6),
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: z.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 44, color: z.brandText),
                  ),
                  const SizedBox(height: ZSpace.x5),
                  Text(
                    title,
                    style: t.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ZSpace.x3),
                  Text(
                    message,
                    style: t.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (action != null) ...[
                    const SizedBox(height: ZSpace.x6),
                    SizedBox(width: double.infinity, child: action),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
