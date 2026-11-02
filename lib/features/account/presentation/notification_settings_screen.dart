import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/account/widgets/settings_scaffold.dart';
import 'package:zippy/core/common_widgets/section_card.dart';

/// Whether the OS lets this app show notifications at all. The in-app
/// switches below are pointless while this is off, so the screen says so.
final _osNotificationsAllowedProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  } catch (_) {
    return true; // can't tell (e.g. no Firebase) — don't nag
  }
});

/// Account → Notification preferences. "Order updates" is honoured by the
/// onOrderEventCreated Cloud Function; "Offers" is stored for future
/// marketing pushes.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from system settings: re-check the permission.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(_osNotificationsAllowedProvider);
    }
  }

  Future<void> _save(Profile profile) async {
    try {
      await ref.read(profileRepositoryProvider).updatePreferences(profile);
      ref.invalidate(profileProvider);
    } catch (error) {
      showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final allowed = ref.watch(_osNotificationsAllowedProvider).value ?? true;
    final z = context.z;
    final text = Theme.of(context).textTheme;

    return SettingsScaffold(
      title: 'notificationPref'.tr(),
      async: profileAsync,
      onRetry: () => ref.invalidate(profileProvider),
      builder: (profile) => ListView(
        padding: const EdgeInsets.all(ZSpace.screen),
        children: [
          if (!allowed) ...[
            Container(
              padding: const EdgeInsets.all(ZSpace.x4),
              decoration: BoxDecoration(
                color: z.warnSoft,
                borderRadius: ZRadius.all(ZRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'notificationsBlocked'.tr(),
                    style: text.labelLarge?.copyWith(color: z.warn),
                  ),
                  const SizedBox(height: ZSpace.x1),
                  Text('notificationsBlockedHint'.tr(), style: text.bodySmall),
                  const SizedBox(height: ZSpace.x2),
                  TextButton(
                    onPressed: Geolocator.openAppSettings,
                    child: Text('openSettings'.tr()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ZSpace.x3),
          ],
          SectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'notifyOrderUpdates'.tr(),
                    style: text.labelLarge,
                  ),
                  subtitle: Text(
                    'notifyOrderUpdatesHint'.tr(),
                    style: text.bodySmall,
                  ),
                  value: profile.notifyOrderUpdates,
                  onChanged: (value) =>
                      _save(profile.copyWith(notifyOrderUpdates: value)),
                ),
                Divider(height: 1, color: z.line),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('notifyOffers'.tr(), style: text.labelLarge),
                  subtitle: Text(
                    'notifyOffersHint'.tr(),
                    style: text.bodySmall,
                  ),
                  value: profile.notifyOffers,
                  onChanged: (value) =>
                      _save(profile.copyWith(notifyOffers: value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
