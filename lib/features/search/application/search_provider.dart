import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/search/application/search_state.dart';
import 'package:zippy/features/search/data/search_analytics_repository_impl.dart';
import 'package:zippy/features/search/domain/search_analytics_repository.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final CatalogRepository repository;
  final SearchAnalyticsRepository analytics;

  static const _debounceDuration = Duration(milliseconds: 300);

  /// A search counts for Search insights once its results stayed on
  /// screen this long before the next keystroke, or when the screen is
  /// left with them showing. So "m", "mi", "mil" on the way to "milk"
  /// aren't counted. (No timer: decided at the next search or on close.)
  static const logAfter = Duration(milliseconds: 1500);

  Timer? _debounce;
  int _requestId = 0;
  ({String term, int results, DateTime shownAt})? _pendingLog;
  String? _lastLogged;
  final DateTime Function() _now;

  SearchNotifier(
    this.repository, {
    SearchAnalyticsRepository? analytics,
    DateTime Function()? now,
  }) : analytics = analytics ?? NoopSearchAnalyticsRepository(),
       _now = now ?? DateTime.now,
       super(SearchState());

  void search(String query) {
    state = state.copyWith(query: query);

    _debounce?.cancel();
    _settleLog();

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
      _scheduleLog(normalized, results.length);
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

  void _scheduleLog(String term, int results) {
    _pendingLog = (term: term, results: results, shownAt: _now());
  }

  /// Typing again: count the shown results only if they stayed up long
  /// enough to be read.
  void _settleLog() {
    final pending = _pendingLog;
    if (pending == null) return;
    if (_now().difference(pending.shownAt) >= logAfter) {
      _flushLog();
    } else {
      _pendingLog = null;
    }
  }

  void _flushLog() {
    final pending = _pendingLog;
    _pendingLog = null;
    if (pending == null) return;
    final key = pending.term.toLowerCase();
    if (key == _lastLogged) return;
    _lastLogged = key;
    analytics.logSearch(pending.term, results: pending.results).ignore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Left the screen with results showing: that search still counts.
    _flushLog();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(
        ref.read(catalogRepositoryProvider),
        analytics: ref.read(searchAnalyticsRepositoryProvider),
      ),
    );
