import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/order.dart';

part 'order_tracking_state.freezed.dart';

@freezed
abstract class OrderTrackingState with _$OrderTrackingState {
  factory OrderTrackingState({
    Order? order,
    @Default(true) bool loading,
    String? error,
  }) = _OrderTrackingState;
}
