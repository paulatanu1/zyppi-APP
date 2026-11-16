import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  factory CartItem({
    required String productId,
    required String variantId,
    required int quantity,

    /// Marketplace seller's offer (offers/{id}); null = Zyppi's own stock.
    /// The server cart doc id is this, or [variantId] for Zyppi's.
    String? offerId,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}
