import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/features/explore/application/explore_state.dart';
import 'package:zippy/features/explore/data/explore_repository_impl.dart';
import 'package:zippy/features/explore/domain/explore_repository.dart';

class ExploreNotifier extends StateNotifier<ExploreState> {
  final ExploreRepository repository;

  ExploreNotifier(this.repository) : super(ExploreState.initial()) {
    exploreList();
  }

  Future<void> exploreList() async {
    final categories = await repository.fetchExploreCategories();

    state = state.copyWith(explore: categories);
  }
}

final exploreNotifier =
    StateNotifierProvider.autoDispose<ExploreNotifier, ExploreState>(
      (ref) => ExploreNotifier(ref.read(exploreRepositoryProvider)),
    );
