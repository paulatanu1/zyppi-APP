import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_section_item.freezed.dart';
part 'home_section_item.g.dart';

/// One item within a [HomeSection]. [data]'s shape is section-type
/// specific and intentionally free-form JSON (not its own freezed class)
/// — see docs/PLAN.md's note on the typed-section/flexible-item model
/// this backs: admin isn't locked into a fixed field set per type.
///
/// The admin panel can schedule an item ([startAt]–[endAt]), limit it to
/// some service areas (empty = everywhere) or switch it off.
@freezed
abstract class HomeSectionItem with _$HomeSectionItem {
  const HomeSectionItem._();

  factory HomeSectionItem({
    required String id,
    required Map<String, dynamic> data,
    DateTime? startAt,
    DateTime? endAt,
    @Default([]) List<String> serviceAreaIds,
    @Default(true) bool isActive,
  }) = _HomeSectionItem;

  factory HomeSectionItem.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionItemFromJson(json);

  /// Shown at [now] to a customer in [serviceAreaId] (null = not known
  /// yet, which only sees items meant for everywhere).
  bool isVisibleAt(DateTime now, {String? serviceAreaId}) {
    if (!isActive) return false;
    if (startAt case final start? when now.isBefore(start)) return false;
    if (endAt case final end? when !now.isBefore(end)) return false;
    if (serviceAreaIds.isEmpty) return true;
    return serviceAreaId != null && serviceAreaIds.contains(serviceAreaId);
  }
}
