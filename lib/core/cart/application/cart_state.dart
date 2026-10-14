import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/cart/domain/bill_breakdown.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/domain/coupon.dart';

part 'cart_state.freezed.dart';

@freezed
abstract class CartState with _$CartState {
  factory CartState({
    @Default([]) List<CartLine> lines,
    @Default(0) int tipPaise,
    Coupon? appliedCoupon,
    String? couponError,
    @Default(BillBreakdown.zero) BillBreakdown bill,
    @Default(true) bool loading,
    String? error,
  }) = _CartState;
}
