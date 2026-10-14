import 'package:zippy/features/home_screen/domain/carousel.dart';

/// Categories now come from the shared [CatalogRepository]
/// (core/data/catalog_repository.dart) since they're used by
/// home_screen, explore and category_details alike. This repository is
/// left with just the carousel, which is home_screen-specific.
abstract class HomeRepository {
  Future<List<Carousel>> fetchCarousel();
}
