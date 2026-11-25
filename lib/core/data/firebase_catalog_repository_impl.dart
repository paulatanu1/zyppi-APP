import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_store.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// Live Firestore catalog (`categories`, `products`), selected by
/// `catalogRepositoryProvider` when Env.dataSource == 'firebase'. Product
/// variants are embedded in each product document; images are stored as
/// ready-to-load download URLs (`imageUrl`).
class FirebaseCatalogRepository implements CatalogRepository {
  /// A full resync at least this often, as a backstop for any change
  /// that didn't bump products.updatedAt.
  static const fullSyncEvery = Duration(days: 7);

  /// Delta queries look back this far before the cursor, so a write whose
  /// server timestamp is slightly older than one already seen isn't
  /// missed. Re-applying a product is harmless.
  static const cursorOverlap = Duration(minutes: 2);

  final FirebaseFirestore firestore;

  /// Local catalog for delta sync; null = fetch the whole catalog each
  /// time (the old behaviour).
  final CatalogStore? store;
  final DateTime Function() _now;

  /// Last synced catalog, so a session doesn't re-decode the store.
  Map<String, Product>? _memory;

  FirebaseCatalogRepository(
    this.firestore, {
    this.store,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  CollectionReference<Map<String, dynamic>> get _products =>
      firestore.collection('products');

  Query<Map<String, dynamic>> get _activeProducts =>
      _products.where('isActive', isEqualTo: true);

  @override
  Future<List<Category>> fetchCategories() async {
    final snap = await firestore
        .collection('categories')
        .orderBy('sortOrder')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return Category.fromJson({
        'id': doc.id,
        'name': data['name'],
        'image': data['imageUrl'],
        'colorHex': data['colorHex'],
        'borderColorHex': data['borderColorHex'],
        'parentId': data['parentId'],
      });
    }).toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final store = this.store;
    if (store == null) {
      final snap = await _activeProducts.get();
      return snap.docs.map(productFromDoc).toList();
    }
    return _sorted(await _sync(store));
  }

  /// Brings [store] up to date: the whole active catalog the first time
  /// (or when forced), afterwards only products whose updatedAt moved.
  Future<Map<String, Product>> _sync(CatalogStore store) async {
    final cached = _memory ?? store.readProducts();
    final meta = store.readMeta();
    try {
      final config = await firestore.doc('config/catalogSync').get();
      final epoch = (config.data()?['epoch'] as num?)?.toInt() ?? 0;
      final now = _now();

      final needsFull =
          meta == null ||
          cached.isEmpty ||
          meta.schema != CatalogSyncMeta.currentSchema ||
          meta.epoch != epoch ||
          now.difference(
                DateTime.fromMillisecondsSinceEpoch(meta.fullSyncAtMillis),
              ) >=
              fullSyncEvery;

      final Map<String, Product> products;
      final int cursor;
      final int fullSyncAt;
      if (needsFull) {
        final snap = await _activeProducts.get();
        products = {for (final doc in snap.docs) doc.id: productFromDoc(doc)};
        cursor = _maxUpdatedAt(snap.docs, 0);
        fullSyncAt = now.millisecondsSinceEpoch;
      } else {
        final since = Timestamp.fromMillisecondsSinceEpoch(
          meta.cursorMillis - cursorOverlap.inMilliseconds,
        );
        // No isActive filter: deactivations must arrive too.
        final snap = await _products
            .where('updatedAt', isGreaterThan: since)
            .get();
        products = Map.of(cached);
        for (final doc in snap.docs) {
          if (doc.data()['isActive'] == true) {
            products[doc.id] = productFromDoc(doc);
          } else {
            products.remove(doc.id);
          }
        }
        cursor = _maxUpdatedAt(snap.docs, meta.cursorMillis);
        fullSyncAt = meta.fullSyncAtMillis;
      }

      await store.write(
        products,
        CatalogSyncMeta(
          cursorMillis: cursor,
          epoch: epoch,
          fullSyncAtMillis: fullSyncAt,
        ),
      );
      return _memory = products;
    } catch (_) {
      // Offline or a failed read: browse the last synced catalog.
      if (cached.isNotEmpty) return _memory = cached;
      rethrow;
    }
  }

  static int _maxUpdatedAt(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    int floor,
  ) {
    var max = floor;
    for (final doc in docs) {
      final at = doc.data()['updatedAt'];
      if (at is Timestamp && at.millisecondsSinceEpoch > max) {
        max = at.millisecondsSinceEpoch;
      }
    }
    return max;
  }

  /// Same order as the full query (document id).
  static List<Product> _sorted(Map<String, Product> products) {
    final ids = products.keys.toList()..sort();
    return [for (final id in ids) products[id]!];
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final snap = await _activeProducts
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .get();
    return snap.docs.map(productFromDoc).toList();
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    final doc = await _products.doc(id).get();
    // Inactive products can't be opened (old links, favourites) or added
    // to the cart.
    if (!doc.exists || doc.data()?['isActive'] != true) return null;
    return productFromDoc(doc);
  }

  @override
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final unique = ids.toSet().toList();
    final products = <Product>[];
    // `whereIn` takes at most 30 values per query.
    for (var i = 0; i < unique.length; i += 30) {
      final chunk = unique.sublist(
        i,
        i + 30 > unique.length ? unique.length : i + 30,
      );
      final snap = await _products
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      products.addAll(
        snap.docs
            .where((d) => d.data()['isActive'] == true)
            .map(productFromDoc),
      );
    }
    return products;
  }

  /// Prefix search over each product's `keywords` (lower-cased prefixes of
  /// the name and its words, written by the seed script and admin panel).
  @override
  Future<List<Product>> searchProducts(String query) async {
    final words = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return [];

    // Whole query as typed ("toned m") matches the name prefix.
    final phrase = words.join(' ');
    if (phrase.length >= 2) {
      final hits = await _search(phrase.substring(0, _clamp(phrase.length)));
      if (hits.isNotEmpty) return hits;
    }

    // Otherwise any word order ("milk toned"): search the longest word and
    // keep products whose name contains every word.
    final longest = words.reduce((a, b) => a.length >= b.length ? a : b);
    if (longest.length < 2) return [];
    final hits = await _search(longest.substring(0, _clamp(longest.length)));
    return hits.where((p) {
      final name = p.name.toLowerCase();
      return words.every(name.contains);
    }).toList();
  }

  int _clamp(int length) => length > 30 ? 30 : length;

  Future<List<Product>> _search(String keyword) async {
    final snap = await _activeProducts
        .where('keywords', arrayContains: keyword)
        .limit(50)
        .get();
    return snap.docs.map(productFromDoc).toList();
  }
}

/// A Firestore product document → [Product].
Product productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? const {};
  return Product.fromJson({
    'id': doc.id,
    'name': data['name'],
    'image': data['imageUrl'],
    'description': data['description'],
    'categoryId': data['categoryId'],
    'subcategoryId': data['subcategoryId'],
    'variants': (data['variants'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(
          (v) => {
            'id': v['id'],
            'label': v['label'],
            'pricePaise': v['pricePaise'],
            'mrpPaise': v['mrpPaise'],
          },
        )
        .toList(),
    'areaBest': _areaBest(data['areaBest']),
  });
}

/// products/{id}.areaBest → JSON for [Product.areaBest]; malformed
/// entries are dropped (the variant price is shown instead).
Map<String, dynamic> _areaBest(Object? raw) {
  if (raw is! Map) return const {};
  final out = <String, dynamic>{};
  raw.forEach((area, variants) {
    if (variants is! Map) return;
    final byVariant = <String, dynamic>{};
    variants.forEach((variant, best) {
      if (best is Map &&
          best['offerId'] is String &&
          best['pricePaise'] is num) {
        byVariant['$variant'] = {
          'offerId': best['offerId'],
          'sellerId': best['sellerId'] ?? 'zyppi',
          'sellerName': best['sellerName'] ?? '',
          'pricePaise': (best['pricePaise'] as num).toInt(),
          'mrpPaise': ((best['mrpPaise'] ?? best['pricePaise']) as num).toInt(),
          'inStock': best['inStock'] != false,
          'offerCount': ((best['offerCount'] ?? 1) as num).toInt(),
        };
      }
    });
    if (byVariant.isNotEmpty) out['$area'] = byVariant;
  });
  return out;
}
