import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/domain/delivery_slot.dart';

part 'checkout_state.freezed.dart';

@freezed
abstract class CheckoutState with _$CheckoutState {
  factory CheckoutState({
    @Default([]) List<Address> addresses,
    Address? selectedAddress,
    @Default([]) List<DeliverySlot> slots,
    DeliverySlot? selectedSlot,
    @Default('UPI') String paymentMethod,
    @Default(true) bool loading,
    @Default(false) bool placingOrder,
    String? placedOrderId,
    String? error,
    String? paymentError,
  }) = _CheckoutState;
}
