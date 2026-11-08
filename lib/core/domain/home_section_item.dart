import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_section_item.freezed.dart';
part 'home_section_item.g.dart';

/// One item within a [HomeSection]. [data]'s shape is section-type
/// specific and intentionally free-form JSON (not its own freezed class)
/// — see docs/PLAN.md's note on the typed-section/flexible-item model
/// this backs: admin isn't locked into a fixed field set per type.
@freezed
abstract class HomeSectionItem with _$HomeSectionItem {
  factory HomeSectionItem({
    required String id,
    required Map<String, dynamic> data,
  }) = _HomeSectionItem;

  factory HomeSectionItem.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionItemFromJson(json);
}
