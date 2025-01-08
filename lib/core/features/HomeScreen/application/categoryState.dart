import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/features/HomeScreen/domain/categories.dart';

part 'categoryState.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  factory CategoryState({
    required List<List<Category>> chunks
  }) = _CategoryState;

  factory CategoryState.initial() => CategoryState(chunks: []);
}