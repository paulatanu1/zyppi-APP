import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/features/Explore/application/exploreState.dart';
import 'package:zippy/features/Explore/domain/explore.dart';

class ExploreNotifier extends StateNotifier<ExploreState> {
  ExploreNotifier() : super(ExploreState.initial()) {
    exploreList();
  }

  void exploreList() {
    final List<Explore> categories = [
      Explore(
        name: 'Fresh Fruits & Vegetables',
        color: const Color(0x1A53B175),
        borderColor: const Color(0xFF53B175),
        image: 'assets/images/category.png',
      ),
      Explore(
        name: 'Bread & Eggs',
        color: const Color(0xFFFFECF7),
        borderColor: const Color(0xFFFB54B6),
        image: 'assets/images/bread.png',
      ),
      Explore(
        name: 'Atta, Rice & Dals',
        color: const Color(0x1AF8A44C),
        borderColor: const Color(0xFFFABD7C),
        image: 'assets/images/rice.png',
      ),
      Explore(
        name: 'Masala & Dry Fruits',
        color: const Color(0xFFEDF7FD),
        borderColor: const Color(0xFF52BAF4),
        image: 'assets/images/category.png',
      ),
      Explore(
          name: 'Cooking Oil & Ghee',
          color: Color.fromRGBO(248, 164, 76, 0.1),
          borderColor: Color.fromRGBO(248, 164, 76, 0.7),
          image: 'assets/images/oil.png'),
      Explore(
          name: 'Meat & Fish',
          color: Color.fromRGBO(247, 165, 147, 0.25),
          borderColor: Color.fromRGBO(247, 165, 147, 1),
          image: 'assets/images/meat.png'),
      Explore(
          name: 'Bakery & Snacks',
          color: Color.fromRGBO(253, 229, 152, 0.25),
          borderColor: Color.fromRGBO(253, 229, 152, 1),
          image: 'assets/images/milk.png'),
      Explore(
          name: 'Beverages',
          color: Color.fromRGBO(183, 223, 245, 0.25),
          borderColor: Color.fromRGBO(183, 223, 245, 1),
          image: 'assets/images/beverages.png')
    ];

    state = state.copyWith(explore: categories);
  }
}

final exploreNotifier =
    StateNotifierProvider.autoDispose<ExploreNotifier, ExploreState>(
        (ref) => ExploreNotifier());
