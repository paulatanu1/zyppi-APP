import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/favourites/data/firebase_favourites_repository_impl.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';

/// Opened once in bootstrap() and provided via [favouritesBoxProvider]'s
/// override, same pattern as core/cart's cartBoxProvider.
final favouritesBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'favouritesBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

class HiveFavouritesRepository implements FavouritesRepository {
  static const _idsKey = 'ids';

  final Box box;

  HiveFavouritesRepository(this.box);

  @override
  Future<Set<String>> getIds() async {
    final raw = box.get(_idsKey) as List<dynamic>? ?? const [];
    return raw.cast<String>().toSet();
  }

  @override
  Future<void> add(String productId) async =>
      box.put(_idsKey, {...await getIds(), productId}.toList());

  @override
  Future<void> remove(String productId) async =>
      box.put(_idsKey, ((await getIds())..remove(productId)).toList());

  @override
  Stream<void> watch() => box.watch(key: _idsKey).map((_) {});
}

final favouritesRepositoryProvider = Provider<FavouritesRepository>(
  (ref) => Env.isMockDataSource
      ? HiveFavouritesRepository(ref.read(favouritesBoxProvider))
      : FirebaseFavouritesRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
);
