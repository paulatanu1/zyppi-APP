import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/features/home_screen/data/home_repository_impl.dart';
import 'package:zippy/features/home_screen/domain/home_repository.dart';

import 'carousel_state.dart';

class CarouselProvider extends StateNotifier<CarouselState> {
  final HomeRepository repository;

  CarouselProvider(this.repository) : super(CarouselState.initial()) {
    carouselItems();
  }

  Future<void> carouselItems() async {
    final carouselList = await repository.fetchCarousel();

    state = state.copyWith(carouselList: carouselList);
  }

  void changeIndex(int index) {
    state = state.copyWith(index: index);
  }
}

final carouselProvider =
    StateNotifierProvider.autoDispose<CarouselProvider, CarouselState>(
      (ref) => CarouselProvider(ref.read(homeRepositoryProvider)),
    );
