import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/product.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  factory SearchState({
    @Default('') String query,
    @Default([]) List<Product> results,
    @Default(false) bool loading,
    String? error,
  }) = _SearchState;
}
