import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Shared across home_screen, explore and category_details — lives in
/// core/domain (not a single feature's domain) per CLAUDE.md's "features
/// import only core/ and themselves" rule.
@freezed
abstract class Category with _$Category {
  factory Category({
    required String id,
    required String name,
    String? image,
    required String colorHex,
    required String borderColorHex,

    /// Set on a sub-category (the product page's left menu); null on a
    /// top-level category. Written by the admin panel (`parentId`).
    String? parentId,
    @Default(0) int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
