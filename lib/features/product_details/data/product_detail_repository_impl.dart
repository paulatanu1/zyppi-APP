import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/product_details/domain/product_detail.dart';
import 'package:zippy/features/product_details/domain/product_detail_repository.dart';

// Phase 1 keeps the existing literal data; Phase 2 replaces this with a
// mock-JSON repository, then Phase 3 with a Supabase-backed one.
class ProductDetailRepositoryImpl implements ProductDetailRepository {
  @override
  Future<List<Product>> fetchProductImages() async {
    return [
      Product(image: 'assets/images/apple.png'),
      Product(image: 'assets/images/apple.png'),
      Product(image: 'assets/images/apple.png'),
    ];
  }
}

final productDetailRepositoryProvider = Provider<ProductDetailRepository>(
  (ref) => ProductDetailRepositoryImpl(),
);
