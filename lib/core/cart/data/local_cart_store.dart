import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';

/// Opened once in bootstrap() and provided via [cartBoxProvider]'s
/// override — a Hive box open is async, so it can't happen inside a
/// synchronous Provider factory.
final cartBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'cartBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

/// The cart's source of truth on the device, in every flavor. Reads and
/// writes are synchronous so a tap updates the UI on the same frame;
/// CartNotifier syncs the server behind it (supabase flavor).
class LocalCartStore {
  static const _linesKey = 'lines';
  static const _dirtyKey = 'dirty';

  /// Pre-local-first format (bare CartItems); dropped on first read.
  static const _legacyItemsKey = 'items';

  final Box box;

  LocalCartStore(this.box);

  List<CartLine> readLines() {
    if (box.containsKey(_legacyItemsKey)) box.delete(_legacyItemsKey);

    final raw = box.get(_linesKey) as String?;
    if (raw == null) return const [];

    try {
      return (jsonDecode(raw) as List)
          .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // A corrupt or outdated snapshot shouldn't break the app; the
      // server pull refills it.
      return const [];
    }
  }

  // jsonEncode walks the nested freezed toJson()s; Hive can't store them raw.
  void writeLines(List<CartLine> lines) =>
      box.put(_linesKey, jsonEncode(lines.map((l) => l.toJson()).toList()));

  /// Variants changed locally that the server hasn't confirmed yet.
  /// Persisted so taps made offline survive an app restart.
  Set<String> dirtyVariantIds() =>
      (box.get(_dirtyKey) as List<dynamic>? ?? const []).cast<String>().toSet();

  void markDirty(String variantId) =>
      box.put(_dirtyKey, {...dirtyVariantIds(), variantId}.toList());

  void markClean(String variantId) =>
      box.put(_dirtyKey, (dirtyVariantIds()..remove(variantId)).toList());

  Future<void> clear() => box.clear();
}

final localCartStoreProvider = Provider<LocalCartStore>(
  (ref) => LocalCartStore(ref.read(cartBoxProvider)),
);
