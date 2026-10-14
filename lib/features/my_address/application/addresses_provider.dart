import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/address_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';

final addressesProvider = FutureProvider.autoDispose<List<Address>>((ref) {
  return ref.read(addressRepositoryProvider).fetchAddresses();
});
