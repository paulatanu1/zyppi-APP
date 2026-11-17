import 'dart:async';

import 'package:zippy/features/notifications/domain/app_notification.dart';
import 'package:zippy/features/notifications/domain/notifications_repository.dart';

/// In-memory list for the mock flavor and tests.
class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository([List<AppNotification>? seed])
    : _items = [...?seed];

  final List<AppNotification> _items;
  final _changes = StreamController<List<AppNotification>>.broadcast();

  void _emit() => _changes.add(List.unmodifiable(_items));

  @override
  Stream<List<AppNotification>> watch({int limit = 50}) async* {
    yield List.unmodifiable(_items.take(limit));
    yield* _changes.stream.map((l) => l.take(limit).toList());
  }

  @override
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(read: true);
    _emit();
  }

  @override
  Future<void> markAllRead(Iterable<String> ids) async {
    final set = ids.toSet();
    for (var i = 0; i < _items.length; i++) {
      if (set.contains(_items[i].id)) {
        _items[i] = _items[i].copyWith(read: true);
      }
    }
    _emit();
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((n) => n.id == id);
    _emit();
  }
}
