import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/addressState.dart';

class AddressProvider extends StateNotifier<AddressState> {
  AddressProvider() : super(AddressState());

  void searchBoxClick(bool isEmpty) {
    state = state.copyWith(isSearchBoxClicked: isEmpty);
  }

  void boxClick(bool click) {
    state = state.copyWith(boxClick: click);
  }
}

final addressProvider = StateNotifierProvider<AddressProvider, AddressState>(
    (ref) => AddressProvider());
