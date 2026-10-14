import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_area.freezed.dart';
part 'service_area.g.dart';

/// Launch areas: Purulia, Raghunathpur, Chelyama (PLAN.md §3).
@freezed
abstract class ServiceArea with _$ServiceArea {
  factory ServiceArea({
    required String id,
    required String name,
    @Default(true) bool isActive,
  }) = _ServiceArea;

  factory ServiceArea.fromJson(Map<String, dynamic> json) =>
      _$ServiceAreaFromJson(json);
}
