import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/firebase/firebase_setup.dart';

abstract class AccountRepository {
  /// Permanently deletes the signed-in user's account and personal data
  /// (orders are kept anonymised for accounting). Server side: the
  /// deleteAccount Cloud Function (functions/src/account.ts).
  ///
  /// With money in the wallet it throws [WalletNotEmpty] until called
  /// again with [forfeitWallet] (the customer has been warned). While an
  /// order, payment or claim is in progress it throws [AccountHasActiveOrders].
  Future<void> deleteAccount({bool forfeitWallet = false});
}

/// An order, online payment or claim is still in progress.
class AccountHasActiveOrders implements Exception {
  const AccountHasActiveOrders();
}

/// The account still has a wallet balance, which deletion would lose.
class WalletNotEmpty implements Exception {
  const WalletNotEmpty(this.walletPaise);

  final int walletPaise;
}

class FirebaseAccountRepository implements AccountRepository {
  final FirebaseFunctions functions;

  FirebaseAccountRepository(this.functions);

  @override
  Future<void> deleteAccount({bool forfeitWallet = false}) async {
    try {
      await functions.httpsCallable('deleteAccount').call({
        'confirm': 'DELETE',
        'forfeitWallet': forfeitWallet,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.message == 'WALLET_NOT_EMPTY') {
        final paise = (e.details as Map?)?['walletPaise'];
        throw WalletNotEmpty(paise is num ? paise.round() : 0);
      }
      if (e.message == 'ACTIVE_ORDERS') throw const AccountHasActiveOrders();
      rethrow;
    }
  }
}

/// No backend account in the mock flavor; logging out afterwards is the
/// whole effect.
class MockAccountRepository implements AccountRepository {
  @override
  Future<void> deleteAccount({bool forfeitWallet = false}) async {}
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => Env.isMockDataSource
      ? MockAccountRepository()
      : FirebaseAccountRepository(zyppiFunctions()),
);
