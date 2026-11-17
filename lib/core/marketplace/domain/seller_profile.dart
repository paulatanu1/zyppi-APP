import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_profile.freezed.dart';

/// What customers can see about a seller (sellerProfiles/{id}), as the
/// Consumer Protection (E-Commerce) Rules require: name, address, contact.
@freezed
abstract class SellerProfile with _$SellerProfile {
  const factory SellerProfile({
    required String id,
    required String shopName,
    String? address,
    String? phone,
    String? gstin,
    String? fssaiNo,
    @Default(0) double ratingAvg,
    @Default(0) int ratingCount,
  }) = _SellerProfile;
}
