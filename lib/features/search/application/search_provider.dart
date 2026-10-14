import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/search/application/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final CatalogRepository repository;

  SearchNotifier(this.repository) : super(SearchState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final products = await repository.fetchProducts();

      state = state.copyWith(allProducts: products, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();

  void search(String query) {
    final normalized = query.trim().toLowerCase();

    state = state.copyWith(
      query: query,
      results: normalized.isEmpty
          ? []
          : state.allProducts
                .where((p) => p.name.toLowerCase().contains(normalized))
                .toList(),
    );
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(ref.read(catalogRepositoryProvider)),
    );
