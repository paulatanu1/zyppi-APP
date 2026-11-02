import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/firebase_address_repository_impl.dart';
import 'package:zippy/core/domain/address.dart';

/// Loads the bundled sample addresses once, then keeps every change
/// in-memory for the session (the mock flavor has no backend).
class MockAddressRepository implements AddressRepository {
  List<Address>? _addresses;

  Future<List<Address>> _all() async {
    if (_addresses != null) return _addresses!;
    final json = await MockDataSource.loadJsonList(
      'assets/mock/addresses.json',
    );
    return _addresses = json
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Address>> fetchAddresses() async {
    await MockDataSource.simulateLatency();
    return List.of(await _all());
  }

  @override
  Future<void> addAddress(
    Address address, {
    required String serviceAreaId,
  }) async {
    await MockDataSource.simulateLatency();
    (await _all()).insert(0, address);
  }

  @override
  Future<void> updateAddress(Address address) async {
    await MockDataSource.simulateLatency();
    final all = await _all();
    final index = all.indexWhere((a) => a.id == address.id);
    if (index >= 0) all[index] = address;
  }

  @override
  Future<void> deleteAddress(String id) async {
    await MockDataSource.simulateLatency();
    (await _all()).removeWhere((a) => a.id == id);
  }

  @override
  Future<void> setDefault(String id) async {
    await MockDataSource.simulateLatency();
    final all = await _all();
    for (var i = 0; i < all.length; i++) {
      all[i] = all[i].copyWith(isDefault: all[i].id == id);
    }
  }
}

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => Env.isMockDataSource
      ? MockAddressRepository()
      : FirebaseAddressRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
);
