import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/features/home_screen/domain/carousel.dart';

import '../application/carousel_state.dart';

class CarouselProvider extends StateNotifier<CarouselState> {
  CarouselProvider() : super(CarouselState.initial()) {
    carouselItems();
  }

  void carouselItems() {
    state = state.copyWith(
      carouselList: [
        Carousel(image: 'assets/images/veg.png', text: 'Slide 1'),
        Carousel(image: 'assets/images/veg.png', text: 'Slide 2'),
        Carousel(image: 'assets/images/veg.png', text: 'Slide 3'),
      ],
    );
  }

  void changeIndex(int index) {
    state = state.copyWith(index: index);
  }
}

final carouselProvider =
    StateNotifierProvider.autoDispose<CarouselProvider, CarouselState>(
      (ref) => CarouselProvider(),
    );
