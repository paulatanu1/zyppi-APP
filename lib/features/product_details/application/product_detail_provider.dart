import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/catalog_repository.dart';
import 'package:zippy/core/data/catalog_repository_impl.dart';
import 'package:zippy/features/product_details/application/product_detail_state.dart';

class ProductDetailProvider extends StateNotifier<ProductDetailState> {
  final CatalogRepository repository;
  final String productId;

  ProductDetailProvider(this.repository, this.productId)
    : super(ProductDetailState.initial()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final product = await repository.fetchProductById(productId);

      state = state.copyWith(product: product, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  Future<void> retry() => _load();

  void currentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void incrementQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decrementQuantity() {
    if (state.quantity <= 1) return;

    state = state.copyWith(quantity: state.quantity - 1);
  }
}

final productDetailProvider = StateNotifierProvider.autoDispose
    .family<ProductDetailProvider, ProductDetailState, String>(
      (ref, productId) =>
          ProductDetailProvider(ref.read(catalogRepositoryProvider), productId),
    );
