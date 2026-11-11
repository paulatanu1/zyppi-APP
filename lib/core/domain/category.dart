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

    /// Set on a sub-category (the left rail on the category page); null
    /// for a top-level category (Home grid, Explore).
    String? parentId,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

extension CategoryTree on Iterable<Category> {
  /// Top-level categories only (Home grid, Explore).
  List<Category> get topLevel => where((c) => c.parentId == null).toList();

  /// Sub-categories of [parentId], in catalog order.
  List<Category> childrenOf(String parentId) =>
      where((c) => c.parentId == parentId).toList();
}
