import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zippy/features/SearchAddress/domain/placeDetails.dart';
import '../domain/placePrediction.dart';

part 'placePredictionState.freezed.dart';

@freezed
class PlacePredictionState with _$PlacePredictionState {
  factory PlacePredictionState({
    PlacePrediction? placePrediction,
    PlaceDetails? placeDetails,
    String? selectedAddress
    }) =
      _PlacePredictionState;

  const PlacePredictionState._();
}
