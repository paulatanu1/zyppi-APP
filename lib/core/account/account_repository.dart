import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';

abstract class AccountRepository {
  /// Permanently deletes the signed-in user's account and personal data
  /// (orders are kept anonymised for accounting). Server side: the
  /// deleteAccount Cloud Function (functions/src/account.ts).
  Future<void> deleteAccount();
}

class FirebaseAccountRepository implements AccountRepository {
  final FirebaseFunctions functions;

  FirebaseAccountRepository(this.functions);

  @override
  Future<void> deleteAccount() async {
    await functions.httpsCallable('deleteAccount').call({'confirm': 'DELETE'});
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
      : FirebaseAccountRepository(zyppiFunctions()),
);
