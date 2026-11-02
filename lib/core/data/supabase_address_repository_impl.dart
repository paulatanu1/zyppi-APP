import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/address_repository.dart';
import 'package:zippy/core/domain/address.dart';

/// Phase 3: live Supabase-backed addresses, selected by
/// `addressRepositoryProvider` (address_repository_impl.dart) instead of
/// `MockAddressRepository` when Env.dataSource != 'mock'. RLS restricts
/// every row to its owner, so this is implicitly scoped to the signed-in
/// user.
class SupabaseAddressRepository implements AddressRepository {
  final SupabaseClient client;

  SupabaseAddressRepository(this.client);

  @override
  Future<List<Address>> fetchAddresses() async {
    final rows = await client
        .from('addresses')
        .select('''
          id, label, line1, area, city, state, postalCode:postal_code,
          landmark, lat, lng, isDefault:is_default
        ''')
        .order('created_at');

    return rows.map((row) => Address.fromJson(row)).toList();
  }

  @override
  Future<void> addAddress(
    Address address, {
    required String serviceAreaId,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot add an address while signed out');
    }

    await client.from('addresses').insert({
      'user_id': userId,
      'service_area_id': serviceAreaId,
      'label': address.label,
      'line1': address.line1,
      'area': address.area,
      'city': address.city,
      'state': address.state,
      'postal_code': address.postalCode,
      'landmark': address.landmark,
      'lat': address.lat,
      'lng': address.lng,
      'is_default': address.isDefault,
    });
  }

  @override
  Future<void> updateAddress(Address address) async {
    await client
        .from('addresses')
        .update({
          'label': address.label,
          'line1': address.line1,
          'landmark': address.landmark,
        })
        .eq('id', address.id);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await client.from('addresses').delete().eq('id', id);
  }

  @override
  Future<void> setDefault(String id) async {
    await client.rpc('set_default_address', params: {'p_address_id': id});
  }
}
