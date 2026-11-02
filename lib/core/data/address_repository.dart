import 'package:zippy/core/domain/address.dart';

abstract class AddressRepository {
  Future<List<Address>> fetchAddresses();

  /// [serviceAreaId] is the area the serviceability check matched for this
  /// location (place_order rejects addresses without one). Mock: kept
  /// in-memory for the session. Supabase: [address.id] is ignored — the
  /// server generates it.
  Future<void> addAddress(Address address, {required String serviceAreaId});

  /// Edits the label / line1 / landmark of an existing address (its
  /// location doesn't change, so neither does its service area).
  Future<void> updateAddress(Address address);

  /// Past orders keep their own copy of the address, so deleting is safe.
  Future<void> deleteAddress(String id);

  /// Makes [id] the only default address.
  Future<void> setDefault(String id);
}
