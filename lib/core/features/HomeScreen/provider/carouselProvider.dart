import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/features/HomeScreen/domain/carousel.dart';
import '../application/carouselState.dart';

class CarouselProvider extends StateNotifier<CarouselState> {
  CarouselProvider() : super(CarouselState.initial()) {
    carouselItems();
  }

  void carouselItems() {
    state = state.copyWith(carouselList: [
      Carousel(image: 'assets/images/veg.png', text: 'Slide 1'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 2'),
      Carousel(image: 'assets/images/veg.png', text: 'Slide 3'),
    ]);
  }

  void changeIndex(int index) {
    state = state.copyWith(index: index);
  }
}

final carouselProvider =
    StateNotifierProvider.autoDispose<CarouselProvider, CarouselState>(
        (ref) => CarouselProvider());
