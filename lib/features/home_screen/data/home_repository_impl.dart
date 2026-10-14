import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/home_screen/domain/carousel.dart';
import 'package:zippy/features/home_screen/domain/home_repository.dart';

// Hero banners are home_screen-specific and still literal placeholder
// data; they aren't part of PLAN.md's mock-JSON entity list.
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<Carousel>> fetchCarousel() async {
    return [
      Carousel(image: 'assets/images/veg.png', text: 'Slide 1'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 2'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 3'),
    ];
  }
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(),
);
