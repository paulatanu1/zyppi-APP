import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/features/product_details/application/product_detail_state.dart';
import 'package:zippy/features/product_details/data/product_detail_repository_impl.dart';
import 'package:zippy/features/product_details/domain/product_detail_repository.dart';

class ProductDetailProvider extends StateNotifier<ProductDetailState> {
  final ProductDetailRepository repository;

  ProductDetailProvider(this.repository) : super(ProductDetailState.initial()) {
    initializeImage();
  }

  Future<void> initializeImage() async {
    final product = await repository.fetchProductImages();

    state = state.copyWith(product: product);
  }

  void currentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final productDetailProvider =
    StateNotifierProvider.autoDispose<
      ProductDetailProvider,
      ProductDetailState
    >(
      (ref) => ProductDetailProvider(ref.read(productDetailRepositoryProvider)),
    );
