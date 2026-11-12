import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/cart/data/local_cart_store.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/payments/data/payment_repository_impl.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/utils/log.dart';

import '../application/shared_preference_state.dart';

/// Opened once in bootstrap() and provided via this override, same
/// pattern as core/cart's cartBoxProvider.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with an awaited '
    'SharedPreferences.getInstance() in bootstrap()',
  ),
);

class SharedPreferenceProvider extends StateNotifier<SharedPreferenceState> {
  final Ref ref;

  SharedPreferenceProvider(this.ref) : super(SharedPreferenceState.initial()) {
    getLocalStorage();
  }

  Future<void> getLocalStorage() async {
    state = state.copyWith(
      authToken: ref.read(sharedPreferencesProvider).getString(KeyNames.token),
    );

    // Never log the token itself — it's a live bearer credential.
    AppLog.showLog(
      tag: 'Stored Token',
      message: state.authToken == null ? 'none' : 'present',
    );
  }

  Future<void> setLocalStorage({required String authToken}) async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(KeyNames.token, authToken);

    state = state.copyWith(authToken: authToken);

    AppLog.showLog(tag: 'Saved Token', message: 'present');
  }

  bool _loggingOut = false;

  /// Ends the session everywhere. Safe to call when Firebase has already
  /// signed the user out (expired/revoked session): the auth listener in
  /// bootstrap.dart calls this too.
  Future<void> logOut() async {
    if (_loggingOut) return;
    _loggingOut = true;

    try {
      // A payment still being confirmed: while the session is valid, ask
      // the server once — it creates the order from a completed payment.
      // (Afterwards nobody on this phone could check it any more.)
      final pending = ref
          .read(sharedPreferencesProvider)
          .getString(_pendingPaymentKey);
      if (pending != null) {
        try {
          await ref
              .read(paymentRepositoryProvider)
              .verifyPayment(pending)
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          // Offline: the payment stays on the server for support to settle.
        }
      }

      // While still signed in: stop this device getting the account's
      // order notifications.
      try {
        await ref.read(pushTokenRepositoryProvider).clearToken();
      } catch (_) {}

      // Ends the Firebase session too, so a guest (anonymous) session
      // doesn't linger. Local logout must still succeed if this fails.
      try {
        await FirebaseAuth.instance.signOut();
      } catch (error) {
        AppLog.showLog(tag: 'Sign out', message: error.toString());
      }

      // The cart is stored on the device; the next account mustn't
      // inherit it, nor a half-finished payment.
      await ref.read(localCartStoreProvider).clear();
      await ref.read(sharedPreferencesProvider).remove(KeyNames.token);
      await ref.read(sharedPreferencesProvider).remove(_pendingPaymentKey);
      await ref
          .read(sharedPreferencesProvider)
          .remove(_pendingPaymentSavedAtKey);

      if (mounted) state = state.copyWith(authToken: null);
    } finally {
      _loggingOut = false;
    }
  }
}

// Mirror PendingPaymentStore's keys (core/payments) without importing it
// here, which would create an import cycle through the payments layer.
const _pendingPaymentKey = 'pendingPayUTxnId';
const _pendingPaymentSavedAtKey = 'pendingPayUSavedAt';

final sharedPreferenceProvider =
    StateNotifierProvider.autoDispose<
      SharedPreferenceProvider,
      SharedPreferenceState
    >((ref) => SharedPreferenceProvider(ref));
