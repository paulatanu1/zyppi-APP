import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';

final favouriteProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final favouriteIds = ref.watch(favouritesProvider);
  final products = await ref.read(catalogRepositoryProvider).fetchProducts();

  return products.where((p) => favouriteIds.contains(p.id)).toList();
});
