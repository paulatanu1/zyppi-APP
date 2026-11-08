import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

enum ProductSort { relevance, priceLowToHigh, priceHighToLow, discount }

/// Price bands offered by the filter screen, in paise. `null` = no bound.
enum PriceBand {
  under50(null, 5000),
  from50To100(5000, 10000),
  from100To200(10000, 20000),
  over200(20000, null);

  const PriceBand(this.minPaise, this.maxPaise);

  final int? minPaise;
  final int? maxPaise;

  bool contains(int pricePaise) =>
      (minPaise == null || pricePaise >= minPaise!) &&
      (maxPaise == null || pricePaise < maxPaise!);
}

/// What a category listing is narrowed and ordered by (filter screen).
class ProductFilter {
  final ProductSort sort;
  final Set<PriceBand> priceBands;
  final bool onlyDiscounted;

  const ProductFilter({
    this.sort = ProductSort.relevance,
    this.priceBands = const {},
    this.onlyDiscounted = false,
  });

  static const none = ProductFilter();

  bool get isActive =>
      sort != ProductSort.relevance || priceBands.isNotEmpty || onlyDiscounted;

  /// Number of narrowing choices (for the "Filters (2)" badge).
  int get activeCount =>
      (sort != ProductSort.relevance ? 1 : 0) +
      priceBands.length +
      (onlyDiscounted ? 1 : 0);

  ProductFilter copyWith({
    ProductSort? sort,
    Set<PriceBand>? priceBands,
    bool? onlyDiscounted,
  }) => ProductFilter(
    sort: sort ?? this.sort,
    priceBands: priceBands ?? this.priceBands,
    onlyDiscounted: onlyDiscounted ?? this.onlyDiscounted,
  );

  /// Applies this filter to [products], judged by each product's first
  /// (displayed) variant — the one its card shows and adds to the cart.
  List<Product> apply(List<Product> products) {
    ProductVariant? shown(Product p) =>
        p.variants.isEmpty ? null : p.variants.first;
    int price(Product p) => shown(p)?.pricePaise ?? 0;
    int discount(Product p) {
      final v = shown(p);
      if (v == null || v.mrpPaise == null) return 0;
      return v.mrpPaise! - v.pricePaise;
    }

    final result = products.where((p) {
      if (shown(p) == null) return false;
      if (onlyDiscounted && discount(p) <= 0) return false;
      if (priceBands.isNotEmpty &&
          !priceBands.any((band) => band.contains(price(p)))) {
        return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case ProductSort.relevance:
        break;
      case ProductSort.priceLowToHigh:
        result.sort((a, b) => price(a).compareTo(price(b)));
      case ProductSort.priceHighToLow:
        result.sort((a, b) => price(b).compareTo(price(a)));
      case ProductSort.discount:
        result.sort((a, b) => discount(b).compareTo(discount(a)));
    }
    return result;
  }
}

/// The filter chosen for each category listing (by category id); shared by
/// the category screen (applies it) and the filter screen (edits it).
final productFilterProvider = StateProvider.autoDispose
    .family<ProductFilter, String>((ref, categoryId) => ProductFilter.none);
