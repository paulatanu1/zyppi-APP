import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/features/home_screen/application/home_sections_provider.dart';

/// The items of [sections] shown at [now] in [serviceAreaId]. A section
/// whose every item is hidden (say, a carousel of banners that all ended)
/// is dropped, so it leaves no gap.
List<HomeSection> visibleSections(
  List<HomeSection> sections,
  DateTime now, {
  String? serviceAreaId,
}) => [
  for (final section in sections)
    if (section.items.isEmpty)
      section
    else if (section.items
            .where((i) => i.isVisibleAt(now, serviceAreaId: serviceAreaId))
            .toList()
        case final items when items.isNotEmpty)
      section.copyWith(items: items),
];

/// The first start or end after [now], when what Home shows changes.
DateTime? nextScheduleChange(List<HomeSection> sections, DateTime now) {
  DateTime? next;
  for (final section in sections) {
    for (final item in section.items) {
      for (final at in [item.startAt, item.endAt]) {
        if (at != null &&
            at.isAfter(now) &&
            (next == null || at.isBefore(next))) {
          next = at;
        }
      }
    }
  }
  return next;
}

/// The current service area for Home's area-only items (overridable in
/// tests, which have no location).
final homeServiceAreaIdProvider = Provider.autoDispose<String?>(
  (ref) => ref.watch(currentLocation.select((s) => s.serviceArea?.id)),
);

/// The wall clock (overridden in tests).
final homeNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// "Now" for Home, moved forward exactly when a banner starts or ends, so
/// a scheduled banner appears and disappears without a refetch.
class HomeClock extends Notifier<DateTime> {
  Timer? _timer;

  /// Dart timers are fine for hours, but re-check at least this often.
  static const maxWait = Duration(hours: 6);

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final sections =
        ref.watch(homeSectionsProvider).value?.sections ?? const [];
    final now = ref.read(homeNowProvider)();
    _schedule(sections, now);
    return now;
  }

  void _schedule(List<HomeSection> sections, DateTime now) {
    _timer?.cancel();
    final next = nextScheduleChange(sections, now);
    if (next == null) return;
    var wait = next.difference(now) + const Duration(milliseconds: 500);
    if (wait > maxWait) wait = maxWait;
    _timer = Timer(wait, () {
      final at = ref.read(homeNowProvider)();
      state = at;
      _schedule(sections, at);
    });
  }
}

final homeClockProvider = NotifierProvider.autoDispose<HomeClock, DateTime>(
  HomeClock.new,
);

/// What the Home screen renders: [homeSectionsProvider] with scheduled,
/// switched-off and other-area items removed.
final visibleHomeSectionsProvider =
    Provider.autoDispose<AsyncValue<HomeSectionsData>>((ref) {
      final now = ref.watch(homeClockProvider);
      final areaId = ref.watch(homeServiceAreaIdProvider);
      return ref
          .watch(homeSectionsProvider)
          .whenData(
            (d) => (
              sections: visibleSections(d.sections, now, serviceAreaId: areaId),
              categoriesById: d.categoriesById,
              productsById: d.productsById,
            ),
          );
    });
