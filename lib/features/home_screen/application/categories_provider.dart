import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/features/home_screen/application/category_state.dart';
import 'package:zippy/features/home_screen/data/home_repository_impl.dart';
import 'package:zippy/features/home_screen/domain/categories.dart';
import 'package:zippy/features/home_screen/domain/home_repository.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  final HomeRepository repository;

  CategoryNotifier(this.repository) : super(CategoryState.initial()) {
    _initializeChunks();
  }

  Future<void> _initializeChunks() async {
    final List<Category> categories = await repository.fetchCategories();

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

    // Update the state with chunked data
    state = state.copyWith(chunks: chunks);
  }
}

final categoryProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, CategoryState>(
      (ref) => CategoryNotifier(ref.read(homeRepositoryProvider)),
    );
