import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/home_screen/domain/carousel.dart';
import 'package:zippy/features/home_screen/domain/categories.dart';
import 'package:zippy/features/home_screen/domain/home_repository.dart';

// Phase 1 keeps the existing literal data; Phase 2 replaces this with a
// mock-JSON repository, then Phase 3 with a Supabase-backed one.
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<Carousel>> fetchCarousel() async {
    return [
      Carousel(image: 'assets/images/veg.png', text: 'Slide 1'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 2'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 3'),
    ];
  }

  @override
  Future<List<Category>> fetchCategories() async {
    return [
      Category(
        name: 'Fresh Fruits & Vegetables',
        color: const Color(0x1A53B175),
        borderColor: const Color(0xFF53B175),
        image: 'assets/images/category.png',
      ),
      Category(
        name: 'Bread & Eggs',
        color: const Color(0xFFFFECF7),
        borderColor: const Color(0xFFFB54B6),
        image: 'assets/images/bread.png',
      ),
      Category(
        name: 'Atta, Rice & Dals',
        color: const Color(0x1AF8A44C),
        borderColor: const Color(0xFFFABD7C),
        image: 'assets/images/rice.png',
      ),
      Category(
        name: 'Masala & Dry Fruits',
        color: const Color(0xFFEDF7FD),
        borderColor: const Color(0xFF52BAF4),
        image: 'assets/images/category.png',
      ),
      Category(
        name: 'Cooking Oil & Ghee',
        color: Color.fromRGBO(248, 164, 76, 0.1),
        borderColor: Color.fromRGBO(248, 164, 76, 0.7),
        image: 'assets/images/oil.png',
      ),
      Category(
        name: 'Meat & Fish',
        color: Color.fromRGBO(247, 165, 147, 0.25),
        borderColor: Color.fromRGBO(247, 165, 147, 1),
        image: 'assets/images/meat.png',
      ),
      Category(
        name: 'Bakery & Snacks',
        color: Color.fromRGBO(253, 229, 152, 0.25),
        borderColor: Color.fromRGBO(253, 229, 152, 1),
        image: 'assets/images/milk.png',
      ),
      Category(
        name: 'Beverages',
        color: Color.fromRGBO(183, 223, 245, 0.25),
        borderColor: Color.fromRGBO(183, 223, 245, 1),
        image: 'assets/images/beverages.png',
      ),
    ];
  }
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(),
);
