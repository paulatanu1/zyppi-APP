import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zippy/features/notifications/domain/app_notification.dart';
import 'package:zippy/features/notifications/domain/notifications_repository.dart';

/// Reads users/{uid}/notifications. The rules let the app only set
/// `read: true` or delete an entry; functions write everything else.
class FirebaseNotificationsRepository implements NotificationsRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  FirebaseNotificationsRepository(this.auth, this.firestore);

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('notifications');
  }

  @override
  Stream<List<AppNotification>> watch({int limit = 50}) {
    final col = _col();
    if (col == null) return Stream.value(const []);
    return col
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => fromDoc(d.id, d.data())).toList());
  }

  @override
  Future<void> markRead(String id) async {
    await _col()?.doc(id).update({'read': true});
  }

  @override
  Future<void> markAllRead(Iterable<String> ids) async {
    final col = _col();
    if (col == null) return;
    final batch = firestore.batch();
    for (final id in ids) {
      batch.update(col.doc(id), {'read': true});
    }
    await batch.commit();
  }

  @override
  Future<void> remove(String id) async {
    await _col()?.doc(id).delete();
  }

  /// Exposed for tests.
  static AppNotification fromDoc(String id, Map<String, dynamic> d) {
    final raw = d['data'];
    return AppNotification(
      id: id,
      kind: switch (d['kind']) {
        'order' => AppNotificationKind.order,
        'offer' => AppNotificationKind.offer,
        'support' => AppNotificationKind.support,
        _ => AppNotificationKind.account,
      },
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      at: (d['at'] as Timestamp?)?.toDate(),
      read: d['read'] == true,
      imageUrl: d['imageUrl'] as String?,
      data: raw is Map
          ? {
              for (final e in raw.entries)
                if (e.value is String) e.key.toString(): e.value as String,
            }
          : const {},
    );
  }
}
