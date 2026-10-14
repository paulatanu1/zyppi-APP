import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Opened once in bootstrap() and provided via [favouritesBoxProvider]'s
/// override, same pattern as core/cart's cartBoxProvider.
final favouritesBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'favouritesBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

class FavouritesRepository {
  static const _idsKey = 'ids';

  final Box box;

  FavouritesRepository(this.box);

  Set<String> getIds() {
    final raw = box.get(_idsKey) as List<dynamic>? ?? const [];
    return raw.cast<String>().toSet();
  }

  Future<void> saveIds(Set<String> ids) => box.put(_idsKey, ids.toList());

  Stream<void> watch() => box.watch(key: _idsKey).map((_) {});
}

final favouritesRepositoryProvider = Provider<FavouritesRepository>(
  (ref) => FavouritesRepository(ref.read(favouritesBoxProvider)),
);
