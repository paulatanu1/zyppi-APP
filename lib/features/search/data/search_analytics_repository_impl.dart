import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';
import 'package:zippy/features/search/domain/search_analytics_repository.dart';

/// The `logSearch` callable (functions/src/search/search_stats.ts) keeps
/// daily totals per term for the admin; Firebase Analytics also gets the
/// standard `search` event.
class FirebaseSearchAnalyticsRepository implements SearchAnalyticsRepository {
  /// Looked up on first use, inside the try: never throws where Firebase
  /// isn't set up (tests).
  FirebaseSearchAnalyticsRepository([FirebaseFunctions Function()? functions])
    : _functions = functions ?? zyppiFunctions;

  final FirebaseFunctions Function() _functions;

  @override
  Future<void> logSearch(String term, {required int results}) async {
    try {
      await _functions().httpsCallable('logSearch').call<void>({
        'term': term,
        'results': results,
      });
    } catch (_) {}
    try {
      await FirebaseAnalytics.instance.logSearch(
        searchTerm: term,
        parameters: {'results': results},
      );
    } catch (_) {}
  }
}

class NoopSearchAnalyticsRepository implements SearchAnalyticsRepository {
  @override
  Future<void> logSearch(String term, {required int results}) async {}
}

final searchAnalyticsRepositoryProvider = Provider<SearchAnalyticsRepository>(
  (ref) => Env.isMockDataSource
      ? NoopSearchAnalyticsRepository()
      : FirebaseSearchAnalyticsRepository(),
);
