import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/domain/cart_item.dart';

/// Server copy of the cart, selected by `cartRepositoryProvider`
/// (cart_repository_impl.dart) when Env.dataSource != 'mock'. CartNotifier
/// pushes local changes here in the background. RLS scopes every
/// read/write to the caller's own cart, so reads need no user filter.
class SupabaseCartRepository implements CartRepository {
  final SupabaseClient client;

  SupabaseCartRepository(this.client);

  @override
  Future<List<CartItem>> getItems() async {
    final rows = await client.from('cart_items').select('''
          variantId:product_variant_id, quantity,
          variant:product_variants(productId:product_id)
        ''');

    return rows.map((row) {
      final variant = row['variant'] as Map<String, dynamic>?;

      return CartItem(
        productId: variant?['productId'] as String? ?? '',
        variantId: row['variantId'] as String,
        quantity: row['quantity'] as int,
      );
    }).toList();
  }

  @override
  Future<void> setQuantity(CartItem item) async {
    final cartId = await _cartId();

    if (item.quantity <= 0) {
      await client
          .from('cart_items')
          .delete()
          .eq('cart_id', cartId)
          .eq('product_variant_id', item.variantId);
      return;
    }

    await client.from('cart_items').upsert({
      'cart_id': cartId,
      'product_variant_id': item.variantId,
      'quantity': item.quantity,
    }, onConflict: 'cart_id,product_variant_id');
  }

  // Cached per signed-in user: saves a round trip on every cart write,
  // and a different login never reuses another account's cart id.
  String? _cachedCartId;
  String? _cachedForUserId;

  Future<String> _cartId() async {
    final userId = client.auth.currentUser?.id;
    if (_cachedCartId != null && _cachedForUserId == userId) {
      return _cachedCartId!;
    }

    final row = await client.from('carts').select('id').single();
    _cachedForUserId = userId;
    return _cachedCartId = row['id'] as String;
  }
}
