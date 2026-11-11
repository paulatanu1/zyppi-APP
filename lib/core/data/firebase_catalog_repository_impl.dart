import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/product.dart';

/// Live Firestore catalog (`categories`, `products`), selected by
/// `catalogRepositoryProvider` when Env.dataSource == 'firebase'. Product
/// variants are embedded in each product document; images are stored as
/// ready-to-load download URLs (`imageUrl`).
class FirebaseCatalogRepository implements CatalogRepository {
  final FirebaseFirestore firestore;

  FirebaseCatalogRepository(this.firestore);

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
    final snap = await _activeProducts.get();
    return snap.docs.map(productFromDoc).toList();
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
  });
}
