import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product.dart';

final homeProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.read(catalogRepositoryProvider).fetchProducts();
});
