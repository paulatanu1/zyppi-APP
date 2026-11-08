import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/category_details/application/category_details_state.dart';

class CategoryDetailsProvider extends StateNotifier<CategoryDetailsState> {
  final CatalogRepository repository;
  final String categoryId;

  CategoryDetailsProvider(this.repository, this.categoryId)
    : super(CategoryDetailsState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final (categories, products) = await (
        repository.fetchCategories(),
        repository.fetchProductsByCategory(categoryId),
      ).wait;
      if (!mounted) return;

      final category = categories.where((c) => c.id == categoryId);

      state = state.copyWith(
        category: category.isEmpty ? null : category.first,
        products: products,
        loading: false,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();
}

final categoryDetailsProvider = StateNotifierProvider.autoDispose
    .family<CategoryDetailsProvider, CategoryDetailsState, String>(
      (ref, categoryId) => CategoryDetailsProvider(
        ref.read(catalogRepositoryProvider),
        categoryId,
      ),
    );
