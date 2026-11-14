import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/home_section_item.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/features/home_screen/application/home_schedule.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';

final _now = DateTime(2026, 11, 14, 12);

HomeSection _carousel(List<HomeSectionItem> items) =>
    HomeSection(id: 's1', type: 'banner_carousel', items: items);

HomeSectionItem _banner(
  String id, {
  DateTime? startAt,
  DateTime? endAt,
  List<String> areas = const [],
  bool isActive = true,
}) => HomeSectionItem(
  id: id,
  data: {'title': id},
  startAt: startAt,
  endAt: endAt,
  serviceAreaIds: areas,
  isActive: isActive,
);

void main() {
  group('HomeSectionItem.isVisibleAt', () {
    test('respects the start (inclusive) and end (exclusive)', () {
      final b = _banner('b', startAt: _now, endAt: _now.add(_hour));
      expect(b.isVisibleAt(_now.subtract(_second)), isFalse);
      expect(b.isVisibleAt(_now), isTrue);
      expect(b.isVisibleAt(_now.add(_hour).subtract(_second)), isTrue);
      expect(b.isVisibleAt(_now.add(_hour)), isFalse);
    });

    test('area-only items need a matching, known area', () {
      final b = _banner('b', areas: ['a1']);
      expect(b.isVisibleAt(_now, serviceAreaId: 'a1'), isTrue);
      expect(b.isVisibleAt(_now, serviceAreaId: 'a2'), isFalse);
      expect(b.isVisibleAt(_now), isFalse);
      expect(_banner('everywhere').isVisibleAt(_now), isTrue);
    });

    test('a switched-off item never shows', () {
      expect(_banner('b', isActive: false).isVisibleAt(_now), isFalse);
    });

    test('old items without schedule fields still show', () {
      final legacy = HomeSectionItem.fromJson({
        'id': 'x',
        'data': {'title': 'Free delivery'},
      });
      expect(legacy.isVisibleAt(_now), isTrue);
    });
  });

  group('visibleSections', () {
    test('drops hidden items, and a carousel left empty', () {
      final sections = [
        _carousel([
          _banner('live'),
          _banner('later', startAt: _now.add(_hour)),
        ]),
        HomeSection(
          id: 's2',
          type: 'banner_carousel',
          items: [_banner('ended', endAt: _now)],
        ),
        HomeSection(id: 's3', type: 'category_tabs'),
      ];
      final visible = visibleSections(sections, _now);
      expect(visible.map((s) => s.id), ['s1', 's3']);
      expect(visible.first.items.map((i) => i.id), ['live']);
    });
  });

  test('nextScheduleChange finds the nearest future start or end', () {
    final sections = [
      _carousel([
        _banner('a', startAt: _now.subtract(_hour), endAt: _now.add(_hour * 3)),
        _banner('b', startAt: _now.add(_hour * 2)),
      ]),
    ];
    expect(nextScheduleChange(sections, _now), _now.add(_hour * 2));
    expect(nextScheduleChange(sections, _now.add(_hour * 4)), isNull);
  });

  testWidgets('a scheduled banner appears and then expires without a refetch', (
    tester,
  ) async {
    // Timers run on the test's fake clock; "now" moves with them.
    var now = _now;
    final start = _now.add(const Duration(minutes: 2));
    final end = start.add(const Duration(minutes: 2));
    var fetches = 0;
    final container = ProviderContainer(
      overrides: [
        homeNowProvider.overrideWithValue(() => now),
        homeServiceAreaIdProvider.overrideWithValue(null),
        homeSectionsProvider.overrideWith((ref) async {
          fetches++;
          return (
            sections: [
              _carousel([_banner('promo', startAt: start, endAt: end)]),
            ],
            categoriesById: const <String, Category>{},
            productsById: const <String, Product>{},
          );
        }),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(visibleHomeSectionsProvider, (_, _) {});
    addTearDown(sub.close);

    List<String> shown() =>
        container
            .read(visibleHomeSectionsProvider)
            .value
            ?.sections
            .expand((s) => s.items)
            .map((i) => i.id)
            .toList() ??
        const [];

    Future<void> advance(Duration d) async {
      now = now.add(d);
      await tester.pump(d);
    }

    await tester.pump();
    expect(container.read(visibleHomeSectionsProvider).hasValue, isTrue);
    expect(shown(), isEmpty);

    await advance(const Duration(minutes: 2, seconds: 1));
    expect(shown(), ['promo']);

    await advance(const Duration(minutes: 2));
    expect(shown(), isEmpty);
    expect(fetches, 1);
  });
}

const _second = Duration(seconds: 1);
const _hour = Duration(hours: 1);
