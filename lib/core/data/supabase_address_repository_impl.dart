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
  Future<void> addAddress(Address address) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot add an address while signed out');
    }

    // place_order() rejects an address with no service_area_id. There's
    // no real serviceability check yet (Phase 4: point-in-polygon/
    // nearest-store against lat/lng) — picking any active area is a
    // stand-in so checkout isn't permanently blocked until then.
    final serviceArea = await client
        .from('service_areas')
        .select('id')
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    await client.from('addresses').insert({
      'user_id': userId,
      'service_area_id': serviceArea?['id'],
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
}
