// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => _Offer(
  id: json['id'] as String,
  productId: json['productId'] as String,
  variantId: json['variantId'] as String,
  serviceAreaId: json['serviceAreaId'] as String,
  sellerId: json['sellerId'] as String,
  sellerName: json['sellerName'] as String,
  sellerRating: (json['sellerRating'] as num?)?.toDouble() ?? 0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  pricePaise: (json['pricePaise'] as num).toInt(),
  mrpPaise: (json['mrpPaise'] as num).toInt(),
  regularPricePaise: (json['regularPricePaise'] as num).toInt(),
  discountActive: json['discountActive'] as bool? ?? false,
  inStock: json['inStock'] as bool? ?? true,
  rankScore: (json['rankScore'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'variantId': instance.variantId,
  'serviceAreaId': instance.serviceAreaId,
  'sellerId': instance.sellerId,
  'sellerName': instance.sellerName,
  'sellerRating': instance.sellerRating,
  'ratingCount': instance.ratingCount,
  'pricePaise': instance.pricePaise,
  'mrpPaise': instance.mrpPaise,
  'regularPricePaise': instance.regularPricePaise,
  'discountActive': instance.discountActive,
  'inStock': instance.inStock,
  'rankScore': instance.rankScore,
};

_BestOffer _$BestOfferFromJson(Map<String, dynamic> json) => _BestOffer(
  offerId: json['offerId'] as String,
  sellerId: json['sellerId'] as String,
  sellerName: json['sellerName'] as String? ?? '',
  pricePaise: (json['pricePaise'] as num).toInt(),
  mrpPaise: (json['mrpPaise'] as num).toInt(),
  inStock: json['inStock'] as bool? ?? true,
  offerCount: (json['offerCount'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$BestOfferToJson(_BestOffer instance) =>
    <String, dynamic>{
      'offerId': instance.offerId,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'pricePaise': instance.pricePaise,
      'mrpPaise': instance.mrpPaise,
      'inStock': instance.inStock,
      'offerCount': instance.offerCount,
    };

_OfferPick _$OfferPickFromJson(Map<String, dynamic> json) => _OfferPick(
  offerId: json['offerId'] as String,
  sellerId: json['sellerId'] as String,
  sellerName: json['sellerName'] as String,
  pricePaise: (json['pricePaise'] as num).toInt(),
  mrpPaise: (json['mrpPaise'] as num).toInt(),
);

Map<String, dynamic> _$OfferPickToJson(_OfferPick instance) =>
    <String, dynamic>{
      'offerId': instance.offerId,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'pricePaise': instance.pricePaise,
      'mrpPaise': instance.mrpPaise,
    };
