import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/favourites/domain/favourites_repository.dart';

/// Live Supabase-backed favourites, selected by `favouritesRepositoryProvider`
/// (favourites_repository_impl.dart) instead of `HiveFavouritesRepository`
/// when Env.dataSource != 'mock'. RLS scopes reads to the caller's own rows.
class SupabaseFavouritesRepository implements FavouritesRepository {
  final SupabaseClient client;

  SupabaseFavouritesRepository(this.client);

  @override
  Future<Set<String>> getIds() async {
    final rows = await client.from('favourites').select('product_id');

    return rows.map((row) => row['product_id'] as String).toSet();
  }

  @override
  Future<void> add(String productId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');

    await client.from('favourites').upsert({
      'user_id': userId,
      'product_id': productId,
    }, ignoreDuplicates: true);
  }

  @override
  Future<void> remove(String productId) async {
    // RLS limits the delete to the caller's own row.
    await client.from('favourites').delete().eq('product_id', productId);
  }

  // Only this session writes favourites; the notifier updates its own state.
  @override
  Stream<void> watch() => const Stream.empty();
}
