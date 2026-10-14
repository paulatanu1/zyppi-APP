import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/category.dart';

part 'category_state.freezed.dart';

@freezed
abstract class CategoryState with _$CategoryState {
  factory CategoryState({
    required List<List<Category>> chunks,
    @Default(true) bool loading,
    String? error,
  }) = _CategoryState;

  factory CategoryState.initial() => CategoryState(chunks: [], loading: true);
}
