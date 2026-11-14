import 'package:zippy/core/domain/coupon.dart';

abstract class CouponRepository {
  /// The coupon matching [code] (case-insensitive) if this customer can use
  /// it, or null if there's no such coupon. Throws [CouponRejected] when it
  /// exists but can't be used (expired, used up, first order only, not in
  /// [serviceAreaId]…).
  Future<Coupon?> findByCode(String code, {String? serviceAreaId});
}
