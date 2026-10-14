import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_location_state.freezed.dart';

@freezed
abstract class CheckLocationState with _$CheckLocationState {
  factory CheckLocationState({bool? isEnabled}) = _CheckLocationState;

  CheckLocationState._();
}
