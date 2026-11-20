import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/features/search/application/search_provider.dart';
import 'package:zippy/features/search/domain/search_analytics_repository.dart';

class _Log implements SearchAnalyticsRepository {
  final calls = <(String, int)>[];

  @override
  Future<void> logSearch(String term, {required int results}) async =>
      calls.add((term, results));
}

class _Catalog extends MockCatalogRepository {
  @override
  Future<List<Product>> searchProducts(String query) async => const [];
}

void main() {
  late _Log log;
  late SearchNotifier notifier;
  late DateTime now;

  /// Types [text], lets the debounce fire and the results arrive, then
  /// waits [readFor] before the next action.
  Future<void> type(String text, {Duration readFor = Duration.zero}) async {
    notifier.search(text);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    now = now.add(readFor);
  }

  setUp(() {
    log = _Log();
    now = DateTime(2026, 11, 20, 18);
    notifier = SearchNotifier(_Catalog(), analytics: log, now: () => now);
  });

  test('only the search people stopped on is counted', () async {
    await type('m');
    await type('mi');
    await type('mil');
    await type('milk', readFor: const Duration(seconds: 3));
    await type('paneer');
    expect(log.calls, [('milk', 0)]);
    notifier.dispose();
  });

  test('the same term twice in a row is counted once', () async {
    await type('milk', readFor: const Duration(seconds: 3));
    await type('milk ', readFor: const Duration(seconds: 3));
    notifier.dispose();
    expect(log.calls, hasLength(1));
  });

  test('leaving the screen with results showing still counts', () async {
    await type('kurkure');
    notifier.dispose();
    expect(log.calls, [('kurkure', 0)]);
  });

  test('clearing the box straight away counts nothing', () async {
    await type('paneer');
    notifier.search('');
    notifier.dispose();
    expect(log.calls, isEmpty);
  });
}
