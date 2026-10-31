import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/data/home_section_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';
import 'package:zippy/core/domain/home_section.dart';
import 'package:zippy/core/domain/product.dart';

/// Section items only carry a `category_id`/`product_id` reference (see
/// docs/PLAN.md's typed-section/flexible-item note) — fetched once
/// alongside the sections themselves so every section widget can resolve
/// references via a plain map lookup instead of each re-fetching the
/// catalog.
typedef HomeSectionsData = ({
  List<HomeSection> sections,
  Map<String, Category> categoriesById,
  Map<String, Product> productsById,
});

final homeSectionsProvider = FutureProvider.autoDispose<HomeSectionsData>((
  ref,
) async {
  final results = await Future.wait([
    ref.read(homeSectionRepositoryProvider).fetchHomeSections(),
    ref.read(catalogRepositoryProvider).fetchCategories(),
    ref.read(catalogRepositoryProvider).fetchProducts(),
  ]);

  final sections = results[0] as List<HomeSection>;
  final categories = results[1] as List<Category>;
  final products = results[2] as List<Product>;

  return (
    sections: sections,
    categoriesById: {for (final c in categories) c.id: c},
    productsById: {for (final p in products) p.id: p},
  );
});
