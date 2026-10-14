import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/favourites/data/favourites_repository_impl.dart';

class FavouritesNotifier extends StateNotifier<Set<String>> {
  final FavouritesRepository repository;

  FavouritesNotifier(this.repository) : super(const {}) {
    state = repository.getIds();
    repository.watch().listen((_) => state = repository.getIds());
  }

  Future<void> toggle(String productId) async {
    final next = {...state};

    if (!next.remove(productId)) next.add(productId);

    await repository.saveIds(next);
  }
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>(
      (ref) => FavouritesNotifier(ref.read(favouritesRepositoryProvider)),
    );
