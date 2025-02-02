import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkLocationState.freezed.dart';

@freezed
class CheckLocationState with _$CheckLocationState {
  factory CheckLocationState({
    bool? isEnabled
  }) = _CheckLocationState;

   CheckLocationState._();
}