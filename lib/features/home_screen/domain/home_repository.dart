import 'package:zippy/features/home_screen/domain/carousel.dart';
import 'package:zippy/features/home_screen/domain/categories.dart';

abstract class HomeRepository {
  Future<List<Carousel>> fetchCarousel();

  Future<List<Category>> fetchCategories();
}
