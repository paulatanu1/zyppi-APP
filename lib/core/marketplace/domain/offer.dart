import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';
part 'offer.g.dart';

/// Zyppi's own stock is the marketplace seller `zyppi`
/// (functions/src/marketplace/model.ts).
const zyppiSellerId = 'zyppi';

/// One seller's offer of a variant in an area (offers/{id}, public).
/// Payout and margin never reach the app.
@freezed
abstract class Offer with _$Offer {
  const Offer._();

  const factory Offer({
    required String id,
    required String productId,
    required String variantId,
    required String serviceAreaId,
    required String sellerId,
    required String sellerName,
    @Default(0) double sellerRating,
    @Default(0) int ratingCount,
    required int pricePaise,
    required int mrpPaise,

    /// Without the seller's special discount (struck through beside it).
    required int regularPricePaise,
    @Default(false) bool discountActive,
    @Default(true) bool inStock,
    @Default(0) double rankScore,
  }) = _Offer;

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  bool get isZyppi => sellerId == zyppiSellerId;

  OfferPick get pick => OfferPick(
    offerId: id,
    sellerId: sellerId,
    sellerName: sellerName,
    pricePaise: pricePaise,
    mrpPaise: mrpPaise,
  );
}

/// The top offer for a variant in an area, kept on the product
/// (products/{id}.areaBest) so lists need no extra reads.
@freezed
abstract class BestOffer with _$BestOffer {
  const BestOffer._();

  const factory BestOffer({
    required String offerId,
    required String sellerId,
    @Default('') String sellerName,
    required int pricePaise,
    required int mrpPaise,
    @Default(true) bool inStock,
    @Default(1) int offerCount,
  }) = _BestOffer;

  factory BestOffer.fromJson(Map<String, dynamic> json) =>
      _$BestOfferFromJson(json);

  OfferPick get pick => OfferPick(
    offerId: offerId,
    sellerId: sellerId,
    sellerName: sellerName,
    pricePaise: pricePaise,
    mrpPaise: mrpPaise,
  );
}

/// The seller a cart line buys from, as the line remembers it. Lines from
/// Zyppi's own stock carry none (the server reads them as Zyppi's).
@freezed
abstract class OfferPick with _$OfferPick {
  const OfferPick._();

  const factory OfferPick({
    required String offerId,
    required String sellerId,
    required String sellerName,
    required int pricePaise,
    required int mrpPaise,
  }) = _OfferPick;

  factory OfferPick.fromJson(Map<String, dynamic> json) =>
      _$OfferPickFromJson(json);

  bool get isZyppi => sellerId == zyppiSellerId;
}
