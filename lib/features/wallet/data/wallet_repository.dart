import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';

/// One line of the wallet history (users/{uid}/wallet, written only by
/// Cloud Functions: functions/src/wallet). [amountPaise] is signed: money
/// in is positive, money spent is negative.
class WalletEntry {
  const WalletEntry({
    required this.id,
    required this.type,
    required this.amountPaise,
    required this.reason,
    this.orderId,
    this.status,
    this.at,
  });

  final String id;

  /// spend · release · cancel · claim · credit
  final String type;
  final int amountPaise;
  final String reason;
  final String? orderId;

  /// For a PayU reservation: held · spent · released.
  final String? status;
  final DateTime? at;

  bool get isCredit => amountPaise > 0;

  /// Reserved for a payment that hasn't finished yet.
  bool get isHeld => status == 'held';

  factory WalletEntry.fromMap(String id, Map<String, dynamic> d) => WalletEntry(
    id: id,
    type: d['type'] as String? ?? '',
    amountPaise: (d['amountPaise'] as num?)?.round() ?? 0,
    reason: d['reason'] as String? ?? '',
    orderId: d['orderId'] as String?,
    status: d['status'] as String?,
    at: d['at'] is Timestamp ? (d['at'] as Timestamp).toDate() : null,
  );
}

/// The customer's Zyppi wallet: closed-loop store credit filled by
/// refunds and approved claims, spent at checkout (docs/WALLET.md).
abstract class WalletRepository {
  /// The spendable balance, live (0 when signed out or never used).
  Stream<int> watchBalance();

  /// The newest [limit] history entries, newest first, live.
  Stream<List<WalletEntry>> watchHistory({int limit = 50});
}

class FirebaseWalletRepository implements WalletRepository {
  FirebaseWalletRepository(this.auth, this.db);

  final FirebaseAuth auth;
  final FirebaseFirestore db;

  /// Follows sign-in / sign-out: a new account's wallet, never the last one's.
  Stream<T> _forUser<T>(
    T signedOut,
    Stream<T> Function(DocumentReference<Map<String, dynamic>> me) watch,
  ) {
    late final StreamController<T> out;
    StreamSubscription<User?>? authSub;
    StreamSubscription<T>? inner;
    out = StreamController<T>(
      onListen: () {
        authSub = auth.authStateChanges().listen((user) {
          inner?.cancel();
          if (user == null) {
            out.add(signedOut);
            return;
          }
          inner = watch(db.collection('users').doc(user.uid))
              .listen(out.add, onError: out.addError);
        }, onError: out.addError);
      },
      onCancel: () async {
        await inner?.cancel();
        await authSub?.cancel();
      },
    );
    return out.stream;
  }

  @override
  Stream<int> watchBalance() => _forUser(
    0,
    (me) => me.snapshots().map((s) {
      final v = s.data()?['walletPaise'];
      return v is num && v > 0 ? v.round() : 0;
    }),
  );

  @override
  Stream<List<WalletEntry>> watchHistory({int limit = 50}) => _forUser(
    const <WalletEntry>[],
    (me) => me
        .collection('wallet')
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => [
            for (final d in snap.docs) WalletEntry.fromMap(d.id, d.data()),
          ],
        ),
  );
}

/// The mock flavor has no backend: an empty wallet.
class MockWalletRepository implements WalletRepository {
  @override
  Stream<int> watchBalance() => Stream.value(0);

  @override
  Stream<List<WalletEntry>> watchHistory({int limit = 50}) =>
      Stream.value(const []);
}

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => Env.isMockDataSource
      ? MockWalletRepository()
      : FirebaseWalletRepository(
          FirebaseAuth.instance,
          FirebaseFirestore.instance,
        ),
);

/// Live wallet balance in paise.
final walletBalanceProvider = StreamProvider<int>(
  (ref) => ref.watch(walletRepositoryProvider).watchBalance(),
);

/// Live wallet history, newest first.
final walletHistoryProvider = StreamProvider.autoDispose<List<WalletEntry>>(
  (ref) => ref.watch(walletRepositoryProvider).watchHistory(),
);

/// How much of [balancePaise] an order of [totalPaise] uses: as much as it
/// can, up to the total. Same rule as the server (wallet/model.ts).
int walletToApply(int balancePaise, int totalPaise, {required bool use}) {
  if (!use || balancePaise <= 0 || totalPaise <= 0) return 0;
  return balancePaise < totalPaise ? balancePaise : totalPaise;
}
