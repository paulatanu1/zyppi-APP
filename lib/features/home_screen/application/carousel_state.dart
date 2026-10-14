import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/features/home_screen/domain/carousel.dart';

part 'carousel_state.freezed.dart';

@freezed
abstract class CarouselState with _$CarouselState {
  factory CarouselState({int? index, required List<Carousel> carouselList}) =
      _CarouselState;

  factory CarouselState.initial() => CarouselState(index: 0, carouselList: []);
}
