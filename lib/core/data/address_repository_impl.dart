import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/supabase_address_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';

class MockAddressRepository implements AddressRepository {
  final List<Address> _added = [];

  @override
  Future<List<Address>> fetchAddresses() async {
    await MockDataSource.simulateLatency();

    final json = await MockDataSource.loadJsonList(
      'assets/mock/addresses.json',
    );

    final addresses = json
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();

    return [..._added, ...addresses];
  }

  @override
  Future<void> addAddress(Address address) async {
    await MockDataSource.simulateLatency();

    _added.add(address);
  }
}

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => Env.isMockDataSource
      ? MockAddressRepository()
      : SupabaseAddressRepository(Supabase.instance.client),
);
