import 'package:freezed_annotation/freezed_annotation.dart';

part 'addressState.freezed.dart';

@freezed
class AddressState with _$AddressState {
  factory AddressState({
    bool? isSearchBoxClicked,
    bool? boxClick,
    dynamic sheetHeight,
  }) = _AddressState;

  factory AddressState.initial() => AddressState(isSearchBoxClicked: false, boxClick: true, sheetHeight: 0.6);
}