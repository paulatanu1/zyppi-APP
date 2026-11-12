import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// A PayU payment started on this device but not yet settled.
class PendingPayment {
  /// After this, checkout stops waiting on the payment and lets the
  /// customer pay again; the server's reconciler still settles it.
  static const staleAfter = Duration(minutes: 15);

  final String txnid;

  /// When it was started; null for one saved by an older app version.
  final DateTime? savedAt;

  const PendingPayment(this.txnid, this.savedAt);

  bool isStale(DateTime now) {
    final saved = savedAt;
    return saved == null || now.difference(saved) >= staleAfter;
  }
}

/// Remembers a PayU payment that was started but not yet confirmed as
/// an order, so leaving checkout or killing the app after paying never
/// loses it: the next checkout visit (or app start) re-verifies it and the
/// server creates the order, instead of the customer paying again.
class PendingPaymentStore {
  static const _key = 'pendingPayUTxnId';
  static const _savedAtKey = 'pendingPayUSavedAt';

  final SharedPreferences prefs;
  final DateTime Function() _now;

  PendingPaymentStore(this.prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  PendingPayment? read() {
    final txnid = prefs.getString(_key);
    if (txnid == null) return null;
    final savedAt = prefs.getInt(_savedAtKey);
    return PendingPayment(
      txnid,
      savedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
  }

  Future<void> save(String txnid) async {
    await prefs.setInt(_savedAtKey, _now().millisecondsSinceEpoch);
    await prefs.setString(_key, txnid);
  }

  Future<void> clear() async {
    await prefs.remove(_key);
    await prefs.remove(_savedAtKey);
  }
}

final pendingPaymentStoreProvider = Provider<PendingPaymentStore>(
  (ref) => PendingPaymentStore(ref.read(sharedPreferencesProvider)),
);
