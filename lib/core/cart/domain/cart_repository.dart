import 'package:zippy/core/domain/cart_item.dart';

/// Persists the cart (hive_ce). Lives in core/ — "Add to basket" needs
/// to be reachable from product_details, home_screen, explore, etc,
/// and CLAUDE.md's "features import only core/ and themselves" rule
/// means a cross-feature capability like this can't live in one
/// feature's (e.g. my_cart's) domain/.
abstract class CartRepository {
  Future<List<CartItem>> getItems();

  Future<void> saveItems(List<CartItem> items);

  /// Fires on every persisted change, so UIs can re-read [getItems].
  Stream<void> watch();
}
