import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/domain/address.dart';

class MockAddressRepository implements AddressRepository {
  @override
  Future<List<Address>> fetchAddresses() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/addresses.json',
    );

    return json
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => MockAddressRepository(),
);
