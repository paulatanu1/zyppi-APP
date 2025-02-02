import 'package:freezed_annotation/freezed_annotation.dart';

part 'carousel.freezed.dart';
part 'carousel.g.dart';

@freezed
class Carousel with _$Carousel {
  factory Carousel({
    required String? image,
    required String? text
  }) = _Carousel;

  factory Carousel.fromJson(Map<String, dynamic> json) => _$CarouselFromJson(json);
}