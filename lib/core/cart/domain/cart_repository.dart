import 'package:zippy/core/domain/cart_item.dart';

/// The server copy of the cart (supabase flavor). The device copy lives in
/// LocalCartStore; CartNotifier syncs the two. Lives in core/ — "Add to
/// basket" needs to be reachable from product_details, home_screen,
/// explore, etc, and CLAUDE.md's "features import only core/ and
/// themselves" rule means a cross-feature capability like this can't live
/// in one feature's (e.g. my_cart's) domain/.
abstract class CartRepository {
  Future<List<CartItem>> getItems();

  /// Sets one line's quantity; 0 removes it. One write, not a full resave.
  Future<void> setQuantity(CartItem item);
}
