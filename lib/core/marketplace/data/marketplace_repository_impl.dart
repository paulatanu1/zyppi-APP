import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/marketplace/domain/marketplace_repository.dart';
import 'package:zippy/core/marketplace/domain/offer.dart';
import 'package:zippy/core/marketplace/domain/seller_profile.dart';

/// offers/{id} and sellerProfiles/{id} are public; the offers trigger
/// (functions/src/marketplace/offers_sync.ts) keeps them current.
class FirebaseMarketplaceRepository implements MarketplaceRepository {
  FirebaseMarketplaceRepository(this.db);

  final FirebaseFirestore db;

  @override
  Future<List<Offer>> fetchOffers(String productId, String areaId) async {
    final snap = await db
        .collection('offers')
        .where('productId', isEqualTo: productId)
        .where('serviceAreaId', isEqualTo: areaId)
        .orderBy('rankScore', descending: true)
        .get();
    return snap.docs.map(offerFromDoc).nonNulls.toList();
  }

  @override
  Future<List<Offer>> fetchOffersByIds(List<String> ids) async {
    final unique = ids.toSet().toList();
    final out = <Offer>[];
    for (var i = 0; i < unique.length; i += 30) {
      final chunk = unique.sublist(i, (i + 30).clamp(0, unique.length));
      final snap = await db
          .collection('offers')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      out.addAll(snap.docs.map(offerFromDoc).nonNulls);
    }
    return out;
  }

  @override
  Future<SellerProfile?> fetchSellerProfile(String sellerId) async {
    final doc = await db.collection('sellerProfiles').doc(sellerId).get();
    final d = doc.data();
    if (d == null) return null;
    final rating = (d['rating'] as Map?) ?? const {};
    return SellerProfile(
      id: doc.id,
      shopName: (d['shopName'] as String?) ?? '',
      address: d['address'] as String?,
      phone: d['phone'] as String?,
      gstin: d['gstin'] as String?,
      fssaiNo: d['fssaiNo'] as String?,
      ratingAvg: (rating['avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (rating['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// An offers/{id} document → [Offer]; null when it's malformed.
Offer? offerFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data();
  if (d == null || d['pricePaise'] is! num) return null;
  return Offer(
    id: doc.id,
    productId: d['productId'] as String,
    variantId: d['variantId'] as String,
    serviceAreaId: d['serviceAreaId'] as String,
    sellerId: d['sellerId'] as String,
    sellerName: (d['sellerName'] as String?) ?? '',
    sellerRating: (d['sellerRating'] as num?)?.toDouble() ?? 0,
    ratingCount: (d['ratingCount'] as num?)?.toInt() ?? 0,
    pricePaise: (d['pricePaise'] as num).toInt(),
    mrpPaise:
        (d['mrpPaise'] as num?)?.toInt() ?? (d['pricePaise'] as num).toInt(),
    regularPricePaise:
        (d['regularPricePaise'] as num?)?.toInt() ??
        (d['pricePaise'] as num).toInt(),
    discountActive: d['discountActive'] == true,
    inStock: d['inStock'] != false,
    rankScore: (d['rankScore'] as num?)?.toDouble() ?? 0,
  );
}

/// Mock flavor: Zyppi is the only seller, so there are no other offers.
class MockMarketplaceRepository implements MarketplaceRepository {
  @override
  Future<List<Offer>> fetchOffers(String productId, String areaId) async =>
      const [];

  @override
  Future<List<Offer>> fetchOffersByIds(List<String> ids) async => const [];

  @override
  Future<SellerProfile?> fetchSellerProfile(String sellerId) async => null;
}

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>(
  (ref) => Env.isMockDataSource
      ? MockMarketplaceRepository()
      : FirebaseMarketplaceRepository(FirebaseFirestore.instance),
);
