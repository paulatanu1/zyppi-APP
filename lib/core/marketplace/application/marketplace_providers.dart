import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';
import 'package:zippy/core/marketplace/data/marketplace_repository_impl.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';

/// The service area the customer is shopping in (set when the location
/// check finds one; null until then). Prices and sellers follow it.
class ShoppingAreaId extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) {
    if (id != state) state = id;
  }
}

final shoppingAreaIdProvider = NotifierProvider<ShoppingAreaId, String?>(
  ShoppingAreaId.new,
);

/// Every offer for a product in the shopping area, best first. Empty when
/// the area isn't known yet (the product's own price is shown then).
final productOffersProvider = FutureProvider.autoDispose
    .family<List<Offer>, String>((ref, productId) async {
      final area = ref.watch(shoppingAreaIdProvider);
      if (area == null) return const [];
      return ref
          .watch(marketplaceRepositoryProvider)
          .fetchOffers(productId, area);
    });

final sellerProfileProvider = FutureProvider.autoDispose
    .family<SellerProfile?, String>(
      (ref, sellerId) =>
          ref.watch(marketplaceRepositoryProvider).fetchSellerProfile(sellerId),
    );

/// What a product card shows and adds for [variant]: the area's top offer
/// (another seller may be cheaper or have stock), else Zyppi's own price.
({int price, int? mrp, OfferPick? pick}) cardPrice(
  Product product,
  ProductVariant variant,
  String? areaId,
) {
  final best = product.bestOfferFor(areaId, variant.id);
  if (best == null) {
    return (price: variant.pricePaise, mrp: variant.mrpPaise, pick: null);
  }
  return (
    price: best.pricePaise,
    mrp: best.mrpPaise,
    // Zyppi's lines stay keyed by variant (the server reads them as Zyppi's).
    pick: best.sellerId == zyppiSellerId ? null : best.pick,
  );
}
