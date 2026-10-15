import 'package:zippy/core/domain/address.dart';

abstract class AddressRepository {
  Future<List<Address>> fetchAddresses();

  /// Mock: appended in-memory for the rest of the session (not persisted
  /// across restarts). Supabase: inserted into `addresses`; [address.id]
  /// is ignored — the server generates it.
  Future<void> addAddress(Address address);
}
