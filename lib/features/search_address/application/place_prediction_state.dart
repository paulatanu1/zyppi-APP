import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/features/search_address/domain/place_details.dart';

import '../domain/place_prediction.dart';

part 'place_prediction_state.freezed.dart';

@freezed
abstract class PlacePredictionState with _$PlacePredictionState {
  factory PlacePredictionState({
    PlacePrediction? placePrediction,
    PlaceDetails? placeDetails,
    String? selectedAddress,
  }) = _PlacePredictionState;

  const PlacePredictionState._();
}
