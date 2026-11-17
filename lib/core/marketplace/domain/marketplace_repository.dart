import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';

/// Marketplace offers and seller pages (functions/src/marketplace).
abstract class MarketplaceRepository {
  /// Every offer for [productId] in [areaId], best ranked first.
  Future<List<Offer>> fetchOffers(String productId, String areaId);

  /// Offers by id (cart rows); missing ones are skipped.
  Future<List<Offer>> fetchOffersByIds(List<String> ids);

  /// Null when the seller isn't selling any more.
  Future<SellerProfile?> fetchSellerProfile(String sellerId);
}
