import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/features/home_screen/application/category_state.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CatalogRepository repository;

  CategoryNotifier(this.repository) : super(CategoryState.initial()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final categories = await repository.fetchCategories();

      // Perform chunking: splitting the categories into chunks of 4
      final List<List<Category>> chunks = [];
      for (var i = 0; i < categories.length; i += 4) {
        chunks.add(
          categories.sublist(
            i,
            i + 4 > categories.length ? categories.length : i + 4,
          ),
        );
      }

      state = state.copyWith(chunks: chunks, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();
}

final categoryProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, CategoryState>(
      (ref) => CategoryNotifier(ref.read(catalogRepositoryProvider)),
    );
