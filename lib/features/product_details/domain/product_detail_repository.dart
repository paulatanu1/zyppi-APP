import 'package:zippy/features/product_details/domain/product_detail.dart';

abstract class ProductDetailRepository {
  Future<List<Product>> fetchProductImages();
}
