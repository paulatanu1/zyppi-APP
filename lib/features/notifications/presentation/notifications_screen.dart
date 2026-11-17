import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/push/push_destination.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/core/utils/launch.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/core/widgets/z_motion.dart';
import 'package:zippy/features/account/widgets/settings_scaffold.dart';
import 'package:zippy/features/notifications/application/notifications_providers.dart';
import 'package:zippy/features/notifications/domain/app_notification.dart';

/// Account → Notifications: order updates, offers and messages from
/// Zyppi, newest first. Tap opens what it's about; swipe removes it.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final unread = (async.value ?? const <AppNotification>[])
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();

    return Stack(
      children: [
        SettingsScaffold<List<AppNotification>>(
          title: 'notifications'.tr(),
          async: async,
          onRetry: () => ref.invalidate(notificationsProvider),
          builder: (items) =>
              items.isEmpty ? const _Empty() : _List(items: items),
        ),
        if (unread.isNotEmpty)
          Positioned(
            top: MediaQuery.paddingOf(context).top,
            right: ZSpace.x2,
            child: SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: TextButton(
                  onPressed: () => ref
                      .read(notificationsRepositoryProvider)
                      .markAllRead(unread)
                      .catchError(showError),
                  child: Text('markAllRead'.tr()),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.items});

  final List<AppNotification> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = context.z;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(notificationsProvider),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: ZSpace.x2),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: z.line),
        itemBuilder: (context, i) {
          final n = items[i];
          return ZEntrance(
            index: i < 10 ? i : 10,
            child: Dismissible(
              key: ValueKey(n.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: z.dangerSoft,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: ZSpace.x5),
                child: Icon(Icons.delete_outline_rounded, color: z.danger),
              ),
              onDismissed: (_) => ref
                  .read(notificationsRepositoryProvider)
                  .remove(n.id)
                  .catchError(showError),
              child: _Tile(n: n, onTap: () => _open(context, ref, n)),
            ),
          );
        },
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref, AppNotification n) {
    if (!n.read) {
      unawaited(
        ref
            .read(notificationsRepositoryProvider)
            .markRead(n.id)
            .catchError((Object _) {}),
      );
    }
    switch (pushDestination(n.data)) {
      case OpenRoute(:final location):
        context.push(location);
      case OpenUrl(:final url):
        unawaited(openExternal(url));
      case ApplyCoupon(:final code):
        context.push('/myCartScreen');
        unawaited(ref.read(cartProvider.notifier).applyCoupon(code));
      case null:
        break;
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.n, required this.onTap});

  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    final (icon, bg, fg) = switch (n.kind) {
      AppNotificationKind.order => (
        Icons.shopping_bag_outlined,
        z.brandSoft,
        z.brandText,
      ),
      AppNotificationKind.offer => (Icons.local_offer_outlined, z.okSoft, z.ok),
      AppNotificationKind.support => (
        Icons.support_agent_rounded,
        z.blueSoft,
        z.blue,
      ),
      AppNotificationKind.account => (
        Icons.notifications_none_rounded,
        z.surface2,
        z.ink2,
      ),
    };
    final when = n.at == null
        ? ''
        : notificationTime(n.at!, DateTime.now(), context.locale);

    return Semantics(
      button: true,
      label: n.read ? null : 'unread'.tr(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: n.read ? null : z.brandSoft.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(
            horizontal: ZSpace.screen,
            vertical: ZSpace.x3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: ZSize.touch - 4,
                height: ZSize.touch - 4,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: ZRadius.all(ZRadius.control),
                ),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: ZSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelLarge!.copyWith(
                              color: z.ink,
                              fontWeight: n.read
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: ZSpace.x2),
                        Text(when, style: t.bodySmall),
                      ],
                    ),
                    const SizedBox(height: ZSpace.x1),
                    Text(
                      n.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium!.copyWith(color: z.ink2),
                    ),
                  ],
                ),
              ),
              if (!n.read) ...[
                const SizedBox(width: ZSpace.x2),
                Padding(
                  padding: const EdgeInsets.only(top: ZSpace.x2),
                  child: Container(
                    width: ZSpace.x2,
                    height: ZSpace.x2,
                    decoration: BoxDecoration(
                      color: z.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final z = context.z;
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ZSize.touch * 2,
              height: ZSize.touch * 2,
              decoration: BoxDecoration(
                color: z.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: ZSize.touch,
                color: z.ink3,
              ),
            ),
            const SizedBox(height: ZSpace.x4),
            Text('noNotifications'.tr(), style: t.titleMedium),
            const SizedBox(height: ZSpace.x2),
            Text(
              'noNotificationsHint'.tr(),
              textAlign: TextAlign.center,
              style: t.bodyMedium!.copyWith(color: z.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Just now", "5 min ago", "3 h ago", "Yesterday", or the date.
String notificationTime(DateTime at, DateTime now, Locale locale) {
  final diff = now.difference(at);
  if (diff.inMinutes < 1) return 'justNow'.tr();
  if (diff.inHours < 1) {
    return 'minutesAgo'.tr(args: ['${diff.inMinutes}']);
  }
  if (diff.inHours < 24 && now.day == at.day) {
    return 'hoursAgo'.tr(args: ['${diff.inHours}']);
  }
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (at.year == yesterday.year &&
      at.month == yesterday.month &&
      at.day == yesterday.day) {
    return 'yesterday'.tr();
  }
  return DateFormat.MMMd(locale.toLanguageTag()).format(at);
}
