import 'package:zippy/core/domain/coupon.dart';

abstract class CouponRepository {
  /// Returns the active coupon matching [code] (case-insensitive), or null.
  Future<Coupon?> findByCode(String code);
}
