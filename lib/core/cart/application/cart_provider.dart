import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/cart/application/cart_state.dart';
import 'package:zippy/core/cart/data/cart_repository_impl.dart';
import 'package:zippy/core/cart/domain/bill_calculator.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/domain/cart_item.dart';
import 'package:zippy/core/domain/coupon.dart';

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository cartRepository;
  final CatalogRepository catalogRepository;

  CartNotifier(this.cartRepository, this.catalogRepository)
    : super(CartState(loading: true)) {
    _load();
    cartRepository.watch().listen((_) => _load());
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final items = cartRepository.getItems();
      final products = await catalogRepository.fetchProducts();

      final lines = <CartLine>[];
      for (final item in items) {
        final product = products.where((p) => p.id == item.productId);
        if (product.isEmpty) continue;

        final variant = product.first.variants.where(
          (v) => v.id == item.variantId,
        );
        if (variant.isEmpty) continue;

        lines.add(
          CartLine(
            product: product.first,
            variant: variant.first,
            quantity: item.quantity,
          ),
        );
      }

      state = state.copyWith(
        lines: lines,
        loading: false,
        bill: BillCalculator.calculate(
          lines: lines,
          tipPaise: state.tipPaise,
          coupon: state.appliedCoupon,
        ),
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> setQuantity({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    final items = cartRepository.getItems();
    final withoutLine = items
        .where((i) => !(i.productId == productId && i.variantId == variantId))
        .toList();

    final nextItems = quantity <= 0
        ? withoutLine
        : [
            ...withoutLine,
            CartItem(
              productId: productId,
              variantId: variantId,
              quantity: quantity,
            ),
          ];

    await cartRepository.saveItems(nextItems);
  }

  Future<void> addItem({
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    final items = cartRepository.getItems();
    final existing = items.where(
      (i) => i.productId == productId && i.variantId == variantId,
    );

    final currentQuantity = existing.isEmpty ? 0 : existing.first.quantity;

    await setQuantity(
      productId: productId,
      variantId: variantId,
      quantity: currentQuantity + quantity,
    );
  }

  void setTip(int tipPaise) {
    state = state.copyWith(
      tipPaise: tipPaise,
      bill: BillCalculator.calculate(
        lines: state.lines,
        tipPaise: tipPaise,
        coupon: state.appliedCoupon,
      ),
    );
  }

  Future<void> applyCoupon(String code) async {
    state = state.copyWith(couponError: null);

    try {
      final json = await MockDataSource.loadJsonList(
        'assets/mock/coupons.json',
      );
      final coupons = json
          .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
          .toList();

      final match = coupons.where(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );

      if (match.isEmpty) {
        state = state.copyWith(couponError: 'invalidCoupon');
        return;
      }

      state = state.copyWith(
        appliedCoupon: match.first,
        bill: BillCalculator.calculate(
          lines: state.lines,
          tipPaise: state.tipPaise,
          coupon: match.first,
        ),
      );
    } catch (error) {
      state = state.copyWith(couponError: error.toString());
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      appliedCoupon: null,
      bill: BillCalculator.calculate(
        lines: state.lines,
        tipPaise: state.tipPaise,
      ),
    );
  }

  Future<void> clear() => cartRepository.saveItems(const []);

  Future<void> retry() => _load();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(
    ref.read(cartRepositoryProvider),
    ref.read(catalogRepositoryProvider),
  ),
);
