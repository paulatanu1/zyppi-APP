import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/features/HomeScreen/application/categoryState.dart';
import 'package:zippy/core/features/HomeScreen/domain/categories.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState.initial()) {
    _initializeChunks();
  }

  // This method performs the chunking
  void _initializeChunks() {
    final List<Category> categories = [
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
        image: 'assets/images/oil.png'
      ),
      Category(
        name: 'Meat & Fish',
        color: Color.fromRGBO(247, 165, 147, 0.25),
        borderColor: Color.fromRGBO(247, 165, 147, 1),
        image: 'assets/images/meat.png'
      ),
      Category(
        name: 'Bakery & Snacks',
        color: Color.fromRGBO(253, 229, 152, 0.25),
        borderColor: Color.fromRGBO(253, 229, 152, 1),
        image: 'assets/images/milk.png'
      ),
      Category(
        name: 'Beverages',
        color: Color.fromRGBO(183, 223, 245, 0.25),
        borderColor: Color.fromRGBO(183, 223, 245, 1),
        image: 'assets/images/beverages.png'
      )
    ];

    // Perform chunking: splitting the categories into chunks of 4
    final List<List<Category>> chunks = [];
    for (var i = 0; i < categories.length; i += 4) {
      chunks.add(categories.sublist(
          i, i + 4 > categories.length ? categories.length : i + 4));
    }

    // Update the state with chunked data
    state = state.copyWith(chunks: chunks);
  }
}

final categoryProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, CategoryState>(
  (ref) => CategoryNotifier(),
);
