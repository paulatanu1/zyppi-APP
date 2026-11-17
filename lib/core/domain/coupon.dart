import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

/// A coupon's terms as the bill needs them (functions/src/coupons). Money
/// is int paise. Eligibility (limits, first order, area) is checked by the
/// server; the app only does the sum.
@freezed
abstract class Coupon with _$Coupon {
  const Coupon._();

  factory Coupon({
    required String code,
    required String description,

    /// Flat coupons: the amount off.
    @Default(0) int discountPaise,
    @Default(CouponType.flat) CouponType type,

    /// Percent coupons: 1–90, rounded down to the paisa.
    @Default(0) int percent,

    /// Percent coupons: the most they take off (null = no cap).
    int? maxDiscountPaise,
    int? minOrderPaise,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

  /// What it takes off [itemTotalPaise]: nothing below the minimum, never
  /// more than the items cost. Same sum as the server's discountFor.
  int discountFor(int itemTotalPaise) {
    if (itemTotalPaise <= 0 || itemTotalPaise < (minOrderPaise ?? 0)) return 0;
    var off = switch (type) {
      CouponType.flat => discountPaise,
      CouponType.percent => itemTotalPaise * percent ~/ 100,
    };
    final cap = maxDiscountPaise;
    if (type == CouponType.percent && cap != null && off > cap) off = cap;
    return off.clamp(0, itemTotalPaise);
  }
}

enum CouponType { flat, percent }

/// Why the server refused a code (`details.reason` of checkCoupon).
enum CouponProblem {
  invalid,
  expired,
  usedUp,
  userLimit,
  firstOrder,
  area;

  static CouponProblem fromWire(Object? reason) => switch (reason) {
    'expired' => expired,
    'used_up' => usedUp,
    'user_limit' => userLimit,
    'first_order' => firstOrder,
    'area' => area,
    _ => invalid,
  };

  /// Translation key shown under the coupon field.
  String get messageKey => switch (this) {
    invalid => 'invalidCoupon',
    expired => 'couponExpired',
    usedUp => 'couponUsedUp',
    userLimit => 'couponUserLimit',
    firstOrder => 'couponFirstOrderOnly',
    area => 'couponNotInArea',
  };
}

/// The code exists but can't be used now.
class CouponRejected implements Exception {
  final CouponProblem problem;

  const CouponRejected(this.problem);

  @override
  String toString() => 'CouponRejected($problem)';
}
