import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/category_details/application/category_details_state.dart';

/// Drives the product page. Opened on a category id ('' = All); the left
/// menu then switches the parent ([selectParent]) or the sub-category
/// ([selectSub]) in place.
class CategoryDetailsProvider extends StateNotifier<CategoryDetailsState> {
  final CatalogRepository repository;

  /// The id the page was opened with: a top-level category, a
  /// sub-category, or '' for All.
  final String initialId;

  CategoryDetailsProvider(this.repository, this.initialId)
    : super(CategoryDetailsState()) {
    _start();
  }

  /// Bumped per products load, so a slow earlier load can't overwrite a
  /// newer selection.
  int _generation = 0;

  Future<void> _start() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final categories = await repository.fetchCategories();
      if (!mounted) return;
      // A sub-category id opens its parent with that sub selected.
      String? parentId = initialId.isEmpty ? null : initialId;
      String? subId;
      for (final c in categories) {
        if (c.id == initialId && c.parentId != null) {
          parentId = c.parentId;
          subId = c.id;
        }
      }
      state = state.copyWith(
        categories: categories,
        parentId: parentId,
        subId: subId,
      );
      await _loadProducts();
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> _loadProducts() async {
    final generation = ++_generation;
    state = state.copyWith(loading: true, error: null);
    try {
      final parentId = state.parentId;
      final products = parentId == null
          ? await repository.fetchProducts()
          : await repository.fetchProductsByCategory(parentId);
      if (!mounted || generation != _generation) return;
      state = state.copyWith(products: products, loading: false);
    } catch (error) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  /// Switch to another top-level category (null = All).
  Future<void> selectParent(String? parentId) async {
    if (parentId == state.parentId && state.subId == null) return;
    state = state.copyWith(parentId: parentId, subId: null, products: []);
    await _loadProducts();
  }

  /// Show one sub-category of the current parent (null = all of it).
  void selectSub(String? subId) => state = state.copyWith(subId: subId);

  Future<void> retry() => state.categories.isEmpty ? _start() : _loadProducts();
}

final categoryDetailsProvider = StateNotifierProvider.autoDispose
    .family<CategoryDetailsProvider, CategoryDetailsState, String>(
      (ref, categoryId) => CategoryDetailsProvider(
        ref.read(catalogRepositoryProvider),
        categoryId,
      ),
    );
