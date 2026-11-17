import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/features/notifications/data/firebase_notifications_repository.dart';
import 'package:zippy/features/notifications/data/mock_notifications_repository.dart';
import 'package:zippy/features/notifications/domain/app_notification.dart';
import 'package:zippy/features/notifications/domain/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => Env.isMockDataSource
      ? MockNotificationsRepository()
      : FirebaseNotificationsRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
);

/// Newest first. No automatic retry: the screen shows Retry.
final notificationsProvider = StreamProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(notificationsRepositoryProvider).watch(),
  retry: (_, _) => null,
);

/// Unread count for the Account row (0 while loading or on error).
final unreadNotificationsProvider = Provider.autoDispose<int>(
  (ref) =>
      ref.watch(notificationsProvider).value?.where((n) => !n.read).length ?? 0,
);
