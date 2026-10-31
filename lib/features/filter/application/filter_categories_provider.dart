import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/domain/category.dart';

/// Categories listed on the Filters screen. Declared top-level (not inline
/// in `build`) so the same provider instance survives rebuilds.
final filterCategoriesProvider = FutureProvider.autoDispose<List<Category>>(
  (ref) => ref.read(catalogRepositoryProvider).fetchCategories(),
);
