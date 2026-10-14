import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/features/SearchAddress/domain/place_details.dart';

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
