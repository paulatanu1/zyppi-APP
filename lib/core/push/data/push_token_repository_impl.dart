import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/push/domain/push_token_repository.dart';

/// The mock flavor has no profiles table to write a token to, and no
/// Edge Function will ever read it.
class MockPushTokenRepository implements PushTokenRepository {
  @override
  Future<void> registerToken(String token) async {}

  @override
  Future<void> clearToken() async {}
}

class SupabasePushTokenRepository implements PushTokenRepository {
  final SupabaseClient client;

  SupabasePushTokenRepository(this.client);

  @override
  Future<void> registerToken(String token) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('profiles').update({'fcm_token': token}).eq('id', userId);
  }

  @override
  Future<void> clearToken() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('profiles').update({'fcm_token': null}).eq('id', userId);
  }
}

final pushTokenRepositoryProvider = Provider<PushTokenRepository>(
  (ref) => Env.isMockDataSource
      ? MockPushTokenRepository()
      : SupabasePushTokenRepository(Supabase.instance.client),
);
