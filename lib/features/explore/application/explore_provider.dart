import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/explore/application/explore_state.dart';

class ExploreNotifier extends StateNotifier<ExploreState> {
  final CatalogRepository repository;

  ExploreNotifier(this.repository) : super(ExploreState.initial()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final categories = await repository.fetchCategories();

      state = state.copyWith(categories: categories, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();
}

final exploreNotifier =
    StateNotifierProvider.autoDispose<ExploreNotifier, ExploreState>(
      (ref) => ExploreNotifier(ref.read(catalogRepositoryProvider)),
    );
