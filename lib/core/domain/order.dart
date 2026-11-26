import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/order_item.dart';
import 'package:zippy/core/domain/order_status.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  factory Order({
    required String id,
    required List<OrderItem> items,
    required OrderStatus status,
    required DateTime placedAt,
    required int itemTotalPaise,
    required int deliveryFeePaise,
    required int handlingFeePaise,
    required int tipPaise,
    required int discountPaise,
    required int totalPaise,
    // Null once the address (or account) is deleted; the snapshot below
    // keeps what was delivered to.
    String? addressId,
    required String paymentMethod,

    /// Address snapshot taken when the order was placed.
    String? addressLabel,
    String? addressText,

    /// Set by the store once a rider is assigned (tracking screen).
    String? riderName,
    String? riderPhone,

    /// The chosen delivery slot's promise, for the tracking ETA.
    int? etaMinutes,

    /// Wallet (docs/WALLET.md): what the wallet paid; the rest
    /// ([payablePaise]) was paid online or is cash at the door.
    @Default(0) int walletPaise,
    int? payablePaise,

    /// When it was delivered ("Report a problem" is open for 2 hours).
    DateTime? deliveredAt,

    /// The claim under review on this order, if any.
    String? openIssueId,

    /// Units already claimed per line (item index → units).
    @Default(<String, int>{}) Map<String, int> claimedQty,

    /// Set on a free replacement: the order it replaces.
    String? replacementOf,

    /// Online refund to the customer's bank or UPI, mirrored by the server
    /// (functions/src/payments/refunds.ts): requesting → requested →
    /// succeeded, or failed. Null when nothing was refunded online.
    String? refundStatus,

    /// Paise refunded online so far.
    int? refundedPaise,

    /// Items a shop couldn't supply, dropped from the order after it was
    /// placed (functions/src/orders/partial_cancel.ts). Empty usually.
    @Default(<String>[]) List<String> removedItemNames,

    /// What came back for [removedItemNames] (refund, wallet or less cash).
    @Default(0) int removedValuePaise,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
