import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/domain/cart_item.dart';

/// Phase 3: live Supabase-backed cart, selected by `cartRepositoryProvider`
/// (cart_repository_impl.dart) instead of `HiveCartRepository` when
/// Env.dataSource != 'mock'. RLS scopes every read/write to the caller's
/// own cart, so there's no explicit user filter needed for reads.
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
  Future<void> saveItems(List<CartItem> items) async {
    final cartId = await _cartId();

    if (items.isEmpty) {
      await client.from('cart_items').delete().eq('cart_id', cartId);
      return;
    }

    await client.from('cart_items').upsert([
      for (final item in items)
        {
          'cart_id': cartId,
          'product_variant_id': item.variantId,
          'quantity': item.quantity,
        },
    ], onConflict: 'cart_id,product_variant_id');

    await client
        .from('cart_items')
        .delete()
        .eq('cart_id', cartId)
        .not(
          'product_variant_id',
          'in',
          items.map((i) => i.variantId).toList(),
        );
  }

  Future<String> _cartId() async {
    final row = await client.from('carts').select('id').single();
    return row['id'] as String;
  }

  // No Realtime subscription yet (Phase 4): this flavor relies on each
  // screen's own fresh fetch rather than a live cross-device refresh.
  @override
  Stream<void> watch() => const Stream.empty();
}
