import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/analytics/analytics_service.dart';
import 'package:zippy/core/cart/application/cart_state.dart';
import 'package:zippy/core/cart/data/cart_repository_impl.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/cart/domain/bill_calculator.dart';
import 'package:zippy/core/cart/domain/cart_line.dart';
import 'package:zippy/core/cart/domain/cart_repository.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/core/data/coupon_repository.dart';
import 'package:zippy/core/data/coupon_repository_impl.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/domain/cart_item.dart';
import 'package:zippy/core/domain/product.dart';
import 'package:zippy/core/domain/product_variant.dart';

/// Local-first cart. A tap changes [state] and [store] synchronously, so
/// the UI updates on the same frame; the server ([remote], supabase flavor
/// only) is synced in the background:
/// - push: [pushDebounce] after the last tap, each changed ("dirty")
///   variant is written once with its latest quantity. Failures keep the
///   local cart and retry with backoff, and again on app resume.
/// - pull: on start, resume and [retry], the server's cart is merged in;
///   the server wins for variants with no unsynced local change.
class CartNotifier extends StateNotifier<CartState> {
  static const pushDebounce = Duration(milliseconds: 400);
  static const _minRetry = Duration(seconds: 2);
  static const _maxRetry = Duration(seconds: 30);

  final LocalCartStore store;
  final CartRepository? remote;
  final CatalogRepository catalogRepository;
  final CouponRepository couponRepository;

  Timer? _pushTimer;
  Duration _retryDelay = _minRetry;
  Future<bool>? _pushInFlight;
  late final AppLifecycleListener _lifecycle;

  /// Bumped on every local change to a variant, so a push that raced a
  /// newer tap doesn't mark that newer value as synced.
  final Map<String, int> _versions = {};

  CartNotifier(
    this.store,
    this.remote,
    this.catalogRepository,
    this.couponRepository,
  ) : super(CartState(loading: false)) {
    final lines = store.readLines();
    _setLines(lines, persist: false);
    // Only a first-ever launch (nothing on the device yet) waits on the
    // server; otherwise the saved cart shows straight away.
    state = state.copyWith(loading: remote != null && lines.isEmpty);

    _lifecycle = AppLifecycleListener(onResume: _sync);
    _sync();
  }

  // ---- Reads -------------------------------------------------------------

  int quantityOf(String productId, String variantId) {
    final line = state.lines.where(
      (l) => l.product.id == productId && l.variant.id == variantId,
    );
    return line.isEmpty ? 0 : line.first.quantity;
  }

  // ---- Local writes (synchronous) ---------------------------------------

  void setQuantity({
    required Product product,
    required ProductVariant variant,
    required int quantity,
  }) {
    final next = max(0, quantity);
    final lines = [...state.lines];
    final index = lines.indexWhere(
      (l) => l.product.id == product.id && l.variant.id == variant.id,
    );

    if (next == 0) {
      if (index < 0) return;
      lines.removeAt(index);
    } else if (index < 0) {
      lines.add(CartLine(product: product, variant: variant, quantity: next));
    } else {
      lines[index] = lines[index].copyWith(quantity: next);
    }

    _setLines(lines);

    if (remote == null) return;
    _versions[variant.id] = (_versions[variant.id] ?? 0) + 1;
    store.markDirty(variant.id);
    _schedulePush(pushDebounce);
  }

  void addItem({
    required Product product,
    required ProductVariant variant,
    int quantity = 1,
  }) {
    setQuantity(
      product: product,
      variant: variant,
      quantity: quantityOf(product.id, variant.id) + quantity,
    );

    unawaited(
      AnalyticsService.logAddToCart(
        itemId: variant.id,
        itemName: product.name,
        pricePaise: variant.pricePaise,
        quantity: quantity,
      ).catchError((_) {}),
    );
  }

  void _setLines(List<CartLine> lines, {bool persist = true}) {
    if (persist) store.writeLines(lines);
    state = state.copyWith(
      lines: lines,
      loading: false,
      error: null,
      bill: BillCalculator.calculate(
        lines: lines,
        tipPaise: state.tipPaise,
        coupon: state.appliedCoupon,
      ),
    );
  }

  // ---- Background sync ---------------------------------------------------

  Future<void> _sync() async {
    if (remote == null) return;
    await _push();
    await _pull();
  }

  void _schedulePush(Duration delay) {
    _pushTimer?.cancel();
    _pushTimer = Timer(delay, _push);
  }

  /// Pushes every dirty variant once. Returns false if any write failed
  /// (a retry is then scheduled). Concurrent callers share one run.
  Future<bool> _push() {
    _pushTimer?.cancel();
    return _pushInFlight ??= _pushDirty().whenComplete(
      () => _pushInFlight = null,
    );
  }

  Future<bool> _pushDirty() async {
    final repo = remote;
    if (repo == null) return true;

    for (final variantId in store.dirtyVariantIds()) {
      final version = _versions[variantId];
      final line = state.lines.where((l) => l.variant.id == variantId);
      final item = CartItem(
        productId: line.isEmpty ? '' : line.first.product.id,
        variantId: variantId,
        quantity: line.isEmpty ? 0 : line.first.quantity,
      );

      try {
        await repo.setQuantity(item);
      } catch (_) {
        if (mounted) {
          _schedulePush(_retryDelay);
          _retryDelay = Duration(
            milliseconds: min(
              _retryDelay.inMilliseconds * 2,
              _maxRetry.inMilliseconds,
            ),
          );
        }
        return false;
      }

      if (!mounted) return true;
      // A newer tap on this variant is already queued; leave it dirty.
      if (_versions[variantId] == version) store.markClean(variantId);
    }

    _retryDelay = _minRetry;
    if (mounted && store.dirtyVariantIds().isNotEmpty) {
      _schedulePush(pushDebounce);
    }
    return true;
  }

  Future<void> _pull() async {
    final repo = remote;
    if (repo == null) return;

    try {
      final serverItems = await repo.getItems();

      // Re-read every product in the cart, not just new ones: a line saved
      // on the device keeps whatever price it had when it was added.
      final ids = {
        ...state.lines.map((l) => l.product.id),
        ...serverItems.map((i) => i.productId),
      }..remove('');
      final known = {for (final l in state.lines) l.product.id: l.product};
      if (ids.isNotEmpty) {
        for (final p in await catalogRepository.fetchProductsByIds(
          ids.toList(),
        )) {
          known[p.id] = p;
        }
      }
      if (!mounted) return;

      // Read after the awaits so taps made meanwhile are respected.
      final dirty = store.dirtyVariantIds();
      final serverByVariant = {for (final i in serverItems) i.variantId: i};
      final merged = <CartLine>[];

      // The line with current catalog data (price, name, image).
      CartLine fresh(CartLine line, int quantity) {
        final product = known[line.product.id];
        final variant = product?.variants
            .where((v) => v.id == line.variant.id)
            .firstOrNull;
        return variant == null
            ? line.copyWith(quantity: quantity)
            : CartLine(product: product!, variant: variant, quantity: quantity);
      }

      for (final line in state.lines) {
        if (dirty.contains(line.variant.id)) {
          merged.add(fresh(line, line.quantity));
        } else if (serverByVariant.remove(line.variant.id) case final item?) {
          merged.add(fresh(line, item.quantity));
        }
        // Clean and gone from the server: removed elsewhere, drop it.
      }
      for (final item in serverByVariant.values) {
        if (dirty.contains(item.variantId)) continue;
        final product = known[item.productId];
        final variant = product?.variants.where((v) => v.id == item.variantId);
        if (variant == null || variant.isEmpty) continue;
        merged.add(
          CartLine(
            product: product!,
            variant: variant.first,
            quantity: item.quantity,
          ),
        );
      }

      _setLines(merged);
    } catch (error) {
      // Offline etc.: keep showing the local cart; only surface an error
      // when there's nothing local to show.
      if (mounted) {
        state = state.copyWith(
          loading: false,
          error: state.lines.isEmpty ? error.toString() : null,
        );
      }
    }
  }

  /// Pushes pending changes now. Checkout calls this first because
  /// place_order() reads the *server's* cart. Throws if anything is still
  /// unsynced afterwards.
  Future<void> flush() async {
    if (remote == null) return;
    await _pushInFlight;
    final ok = await _push();
    if (!ok || store.dirtyVariantIds().isNotEmpty) {
      throw StateError('Cart not synced yet');
    }
  }

  // ---- Bill extras -------------------------------------------------------

  /// The server rejects tips above this (orders_tip_cap in
  /// 20261101120000_secure_payments.sql).
  static const maxTipPaise = 50000;

  void setTip(int tipPaise) {
    final tip = tipPaise.clamp(0, maxTipPaise);
    state = state.copyWith(
      tipPaise: tip,
      bill: BillCalculator.calculate(
        lines: state.lines,
        tipPaise: tip,
        coupon: state.appliedCoupon,
      ),
    );
  }

  Future<void> applyCoupon(String code) async {
    state = state.copyWith(couponError: null);

    try {
      final coupon = await couponRepository.findByCode(code);

      if (coupon == null) {
        state = state.copyWith(couponError: 'invalidCoupon');
        return;
      }

      state = state.copyWith(
        appliedCoupon: coupon,
        bill: BillCalculator.calculate(
          lines: state.lines,
          tipPaise: state.tipPaise,
          coupon: coupon,
        ),
      );
    } catch (_) {
      // A translation key, like 'invalidCoupon' — never a raw exception.
      state = state.copyWith(couponError: 'couponCheckFailed');
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

  /// After an order: place_order() already emptied the server cart, so
  /// only the device copy (and its pending changes) needs clearing.
  Future<void> clear() async {
    _pushTimer?.cancel();
    _versions.clear();
    await store.clear();
    // Tip and coupon belong to the order just placed, not the next one.
    state = state.copyWith(appliedCoupon: null, tipPaise: 0, couponError: null);
    _setLines(const []);
  }

  Future<void> retry() {
    state = state.copyWith(loading: state.lines.isEmpty, error: null);
    return _sync();
  }

  @override
  void dispose() {
    _pushTimer?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  // Rebuild on login/logout so a new account pulls its own cart.
  ref.watch(sharedPreferenceProvider);

  return CartNotifier(
    ref.read(localCartStoreProvider),
    ref.read(cartRepositoryProvider),
    ref.read(catalogRepositoryProvider),
    ref.read(couponRepositoryProvider),
  );
});
