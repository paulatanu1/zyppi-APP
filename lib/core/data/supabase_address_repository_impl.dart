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
}
