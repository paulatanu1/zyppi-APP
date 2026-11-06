import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// Remembers a PayU payment that was started but not yet confirmed as
/// an order, so leaving checkout or killing the app after paying never
/// loses it: the next checkout visit (or app start) re-verifies it and the
/// server creates the order, instead of the customer paying again.
class PendingPaymentStore {
  static const _key = 'pendingPayUTxnId';

  final SharedPreferences prefs;

  PendingPaymentStore(this.prefs);

  String? read() => prefs.getString(_key);

  Future<void> save(String txnid) => prefs.setString(_key, txnid);

  Future<void> clear() => prefs.remove(_key);
}

final pendingPaymentStoreProvider = Provider<PendingPaymentStore>(
  (ref) => PendingPaymentStore(ref.read(sharedPreferencesProvider)),
);
