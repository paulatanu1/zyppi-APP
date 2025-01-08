import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/explore.dart';

part 'exploreState.freezed.dart';

@freezed
class ExploreState with _$ExploreState {
  factory ExploreState({required List<Explore> explore}) = _ExploreState;

  factory ExploreState.initial() => ExploreState(explore: []);
}
