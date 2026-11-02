import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/favourites/application/favourites_provider.dart';

final favouriteProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final favouriteIds = ref.watch(favouritesProvider);
  if (favouriteIds.isEmpty) return const [];

  // Only the favourited products, not the whole catalog (which the
  // backend would cap at its row limit as it grows).
  return ref
      .read(catalogRepositoryProvider)
      .fetchProductsByIds(favouriteIds.toList());
});
