import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/core/domain/category.dart';

part 'explore_state.freezed.dart';

@freezed
abstract class ExploreState with _$ExploreState {
  factory ExploreState({
    required List<Category> categories,
    @Default(true) bool loading,
    String? error,
  }) = _ExploreState;

  factory ExploreState.initial() => ExploreState(categories: [], loading: true);
}
