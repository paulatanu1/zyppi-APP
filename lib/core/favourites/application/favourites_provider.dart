import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/favourites/data/favourites_repository_impl.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';
import 'package:zippy/core/utils/snack_bar.dart';

class FavouritesNotifier extends StateNotifier<Set<String>> {
  final FavouritesRepository repository;
  StreamSubscription<void>? _subscription;

  FavouritesNotifier(this.repository) : super(const {}) {
    _load();
    _subscription = repository.watch().listen((_) => _load());
  }

  Future<void> _load() async {
    try {
      final ids = await repository.getIds();
      if (mounted) state = ids;
    } catch (_) {
      // Keep whatever is shown; a failed read shouldn't clear hearts.
    }
  }

  Future<void> toggle(String productId) async {
    final adding = !state.contains(productId);

    // Optimistic: the Firebase repo has no change stream to echo it back.
    state = adding ? {...state, productId} : ({...state}..remove(productId));
    try {
      adding
          ? await repository.add(productId)
          : await repository.remove(productId);
    } catch (error) {
      // Undo just this product, not every change since.
      if (mounted) {
        state = adding
            ? ({...state}..remove(productId))
            : {...state, productId};
      }
      showError(error);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>((ref) {
      // Rebuild on login/logout so one account never sees another's hearts.
      // (Its state is just the auth token.)
      ref.watch(sharedPreferenceProvider);

      return FavouritesNotifier(ref.read(favouritesRepositoryProvider));
    });
