import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';
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

      final subcategories = categories.childrenOf(categoryId);
      final selected = state.selectedSubcategoryId;
      state = state.copyWith(
        category: category.isEmpty ? null : category.first,
        subcategories: subcategories,
        // Keep the rail selection across a retry if it still exists.
        selectedSubcategoryId: subcategories.any((c) => c.id == selected)
            ? selected
            : null,
        products: products,
        loading: false,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();

  /// Rail tap; null selects "All".
  void selectSubcategory(String? id) =>
      state = state.copyWith(selectedSubcategoryId: id);
}

final categoryDetailsProvider = StateNotifierProvider.autoDispose
    .family<CategoryDetailsProvider, CategoryDetailsState, String>(
      (ref, categoryId) => CategoryDetailsProvider(
        ref.read(catalogRepositoryProvider),
        categoryId,
      ),
    );
