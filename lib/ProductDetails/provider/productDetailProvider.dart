import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/ProductDetails/application/productDetailState.dart';
import 'package:zippy/ProductDetails/domain/productDetail.dart';

class ProductDetailProvider extends StateNotifier<ProductDetailState> {
  ProductDetailProvider() : super(ProductDetailState.initial()) {
    initializeImage();
  }

  void initializeImage() {
    state = state.copyWith(product: [
      Product(image: 'assets/images/apple.png'),
      Product(image: 'assets/images/apple.png'),
      Product(image: 'assets/images/apple.png')
    ]);
  }

  void currentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final productDetailProvider = StateNotifierProvider.autoDispose<
    ProductDetailProvider,
    ProductDetailState>((ref) => ProductDetailProvider());
