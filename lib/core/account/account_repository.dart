import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';

abstract class AccountRepository {
  /// Permanently deletes the signed-in user's account and personal data
  /// (orders are kept anonymised for accounting). Server side:
  /// supabase/functions/delete-account.
  Future<void> deleteAccount();
}

class SupabaseAccountRepository implements AccountRepository {
  final SupabaseClient client;

  SupabaseAccountRepository(this.client);

  @override
  Future<void> deleteAccount() async {
    await client.functions.invoke(
      'delete-account',
      body: {'confirm': 'DELETE'},
    );
  }
}

/// No backend account in the mock flavor; logging out afterwards is the
/// whole effect.
class MockAccountRepository implements AccountRepository {
  @override
  Future<void> deleteAccount() async {}
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => Env.isMockDataSource
      ? MockAccountRepository()
      : SupabaseAccountRepository(Supabase.instance.client),
);
