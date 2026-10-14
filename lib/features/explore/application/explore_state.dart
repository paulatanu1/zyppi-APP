import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/explore.dart';

part 'explore_state.freezed.dart';

@freezed
abstract class ExploreState with _$ExploreState {
  factory ExploreState({required List<Explore> explore}) = _ExploreState;

  factory ExploreState.initial() => ExploreState(explore: []);
}
