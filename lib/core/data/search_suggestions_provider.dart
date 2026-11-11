import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';

/// "Try searching" chips and the Home search bar's rotating placeholder:
/// a few product names from the (cached) catalog. Empty on failure.
final searchSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final products = await ref.read(catalogRepositoryProvider).fetchProducts();
    final seen = <String>{};
    return [
      for (final p in products)
        if (p.variants.isNotEmpty && seen.add(p.name.toLowerCase())) p.name,
    ].take(6).toList();
  } catch (_) {
    return const [];
  }
});
