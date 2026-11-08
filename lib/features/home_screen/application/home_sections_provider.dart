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
/// catalog. Only the products the sections reference are fetched.
typedef HomeSectionsData = ({
  List<HomeSection> sections,
  Map<String, Category> categoriesById,
  Map<String, Product> productsById,
});

final homeSectionsProvider = FutureProvider.autoDispose<HomeSectionsData>((
  ref,
) async {
  // Switching bottom-nav tabs shouldn't re-fetch home; retry still
  // invalidates it explicitly.
  ref.keepAlive();
  final catalog = ref.read(catalogRepositoryProvider);
  final (sections, categories) = await (
    ref.read(homeSectionRepositoryProvider).fetchHomeSections(),
    catalog.fetchCategories(),
  ).wait;

  final productIds = {
    for (final section in sections)
      for (final item in section.items)
        if (item.data['product_id'] case final String id) id,
  };
  final products = await catalog.fetchProductsByIds(productIds.toList());

  return (
    sections: sections,
    categoriesById: {for (final c in categories) c.id: c},
    productsById: {for (final p in products) p.id: p},
  );
});
