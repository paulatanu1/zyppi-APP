import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/home_section_item.dart';

part 'home_section.freezed.dart';
part 'home_section.g.dart';

/// Backend/admin-driven Home screen section — [type] picks which widget
/// under lib/features/home_screen/widgets/sections/ renders it.
@freezed
abstract class HomeSection with _$HomeSection {
  factory HomeSection({
    required String id,
    required String type,
    String? title,
    String? subtitle,
    @Default({}) Map<String, dynamic> config,
    @Default([]) List<HomeSectionItem> items,
  }) = _HomeSection;

  factory HomeSection.fromJson(Map<String, dynamic> json) =>
      _$HomeSectionFromJson(json);
}
