import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/features/HomeScreen/domain/categories.dart';

part 'category_state.freezed.dart';

@freezed
abstract class CategoryState with _$CategoryState {
  factory CategoryState({required List<List<Category>> chunks}) =
      _CategoryState;

  factory CategoryState.initial() => CategoryState(chunks: []);
}
