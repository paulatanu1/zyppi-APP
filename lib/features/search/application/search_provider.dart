import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/search/application/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final CatalogRepository repository;

  static const _debounceDuration = Duration(milliseconds: 300);

  Timer? _debounce;
  int _requestId = 0;

  SearchNotifier(this.repository) : super(SearchState());

  void search(String query) {
    state = state.copyWith(query: query);

    _debounce?.cancel();

    final normalized = query.trim();
    if (normalized.isEmpty) {
      _requestId++; // a search still in flight must not refill the list
      state = state.copyWith(results: [], loading: false, error: null);
      return;
    }

    _debounce = Timer(_debounceDuration, () => _runSearch(normalized));
  }

  Future<void> _runSearch(String normalized) async {
    final requestId = ++_requestId;
    state = state.copyWith(loading: true, error: null);

    try {
      final results = await repository.searchProducts(normalized);
      // Superseded by a newer keystroke, or the screen closed.
      if (!mounted || requestId != _requestId) return;

      state = state.copyWith(results: results, loading: false);
    } catch (error) {
      if (!mounted || requestId != _requestId) return;

      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() {
    final normalized = state.query.trim();
    if (normalized.isEmpty) return Future.value();

    return _runSearch(normalized);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(ref.read(catalogRepositoryProvider)),
    );
