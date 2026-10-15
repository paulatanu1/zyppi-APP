import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/cart/data/supabase_cart_repository_impl.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/domain/cart_item.dart';

/// Opened once in bootstrap() and provided via [cartBoxProvider]'s
/// override — a Hive box open is async, so it can't happen inside a
/// synchronous Provider factory.
final cartBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'cartBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

class HiveCartRepository implements CartRepository {
  static const _itemsKey = 'items';

  final Box box;

  HiveCartRepository(this.box);

  @override
  Future<List<CartItem>> getItems() async {
    final raw = box.get(_itemsKey) as List<dynamic>? ?? const [];

    return raw
        .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveItems(List<CartItem> items) {
    return box.put(_itemsKey, items.map((i) => i.toJson()).toList());
  }

  @override
  Stream<void> watch() => box.watch(key: _itemsKey).map((_) {});
}

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => Env.isMockDataSource
      ? HiveCartRepository(ref.read(cartBoxProvider))
      : SupabaseCartRepository(Supabase.instance.client),
);
