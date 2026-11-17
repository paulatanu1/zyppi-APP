import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

/// Snapshot of a product/variant at order time — orders must not change
/// retroactively if the catalog price changes later.
@freezed
abstract class OrderItem with _$OrderItem {
  factory OrderItem({
    required String productId,
    required String variantId,
    required String name,
    required String unit,
    required int quantity,
    required int pricePaise,

    /// Product image (current catalog image; display only).
    String? image,

    /// Marketplace: who sold it (order time). Null on older orders and
    /// for Zyppi's own stock before the marketplace.
    String? sellerId,
    String? sellerName,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
