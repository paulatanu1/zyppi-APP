import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/domain/product.dart';

/// Opened once in bootstrap() and provided via its override (see
/// cartBoxProvider for why).
final catalogBoxProvider = Provider<Box>(
  (ref) => throw UnimplementedError(
    'catalogBoxProvider must be overridden with an opened Hive box in bootstrap()',
  ),
);

/// Sync state kept next to the products.
class CatalogSyncMeta {
  /// Bump when the stored product format changes: old stores resync fully.
  static const currentSchema = 1;

  /// Largest products.updatedAt seen (server clock), epoch millis.
  final int cursorMillis;

  /// config/catalogSync.epoch at the last full sync.
  final int epoch;

  /// Device time of the last full sync, epoch millis.
  final int fullSyncAtMillis;
  final int schema;

  const CatalogSyncMeta({
    required this.cursorMillis,
    required this.epoch,
    required this.fullSyncAtMillis,
    this.schema = currentSchema,
  });

  Map<String, dynamic> toJson() => {
    'cursorMillis': cursorMillis,
    'epoch': epoch,
    'fullSyncAtMillis': fullSyncAtMillis,
    'schema': schema,
  };

  static CatalogSyncMeta? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final cursor = raw['cursorMillis'];
    final epoch = raw['epoch'];
    final fullSyncAt = raw['fullSyncAtMillis'];
    final schema = raw['schema'];
    if (cursor is! int || epoch is! int || fullSyncAt is! int) return null;
    return CatalogSyncMeta(
      cursorMillis: cursor,
      epoch: epoch,
      fullSyncAtMillis: fullSyncAt,
      schema: schema is int ? schema : 0,
    );
  }
}

/// The active catalog on the device, so a session downloads only the
/// products that changed since the last one instead of all of them
/// (audit COST-01). Products are stored as JSON strings keyed by id.
class CatalogStore {
  static const _productsKey = 'products';
  static const _metaKey = 'meta';

  final Box box;

  CatalogStore(this.box);

  CatalogSyncMeta? readMeta() {
    final raw = box.get(_metaKey);
    if (raw is! String) return null;
    try {
      return CatalogSyncMeta.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  /// Stored products by id; an unreadable store reads as empty (and so
  /// triggers a full sync).
  Map<String, Product> readProducts() {
    final raw = box.get(_productsKey);
    if (raw is! Map) return {};
    try {
      return {
        for (final entry in raw.entries)
          '${entry.key}': Product.fromJson(
            jsonDecode(entry.value as String) as Map<String, dynamic>,
          ),
      };
    } on Object {
      return {};
    }
  }

  Future<void> write(Map<String, Product> products, CatalogSyncMeta meta) =>
      box.putAll({
        _productsKey: {
          for (final entry in products.entries)
            entry.key: jsonEncode(entry.value.toJson()),
        },
        _metaKey: jsonEncode(meta.toJson()),
      });

  Future<void> clear() => box.clear();
}
