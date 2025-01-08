import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/features/HomeScreen/domain/carousel.dart';

part 'carouselState.freezed.dart';

@freezed
class CarouselState with _$CarouselState {
  factory CarouselState({
    int? index,
    required List<Carousel> carouselList
  }) = _CarouselState;

  factory CarouselState.initial() => CarouselState(index: 0, carouselList: []);
}