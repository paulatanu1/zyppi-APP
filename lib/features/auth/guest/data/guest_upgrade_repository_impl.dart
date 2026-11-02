import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/auth/google_sign_in/data/google_auth_repository_impl.dart';
import 'package:zippy/features/auth/guest/domain/guest_upgrade_repository.dart';

/// Supabase identity linking: the anonymous user gains a phone (via a
/// phone-change OTP) or a Google identity and stops being anonymous; the
/// user id — and everything keyed to it — stays the same. Google linking
/// needs "Manual linking" enabled under Auth → Providers.
class SupabaseGuestUpgradeRepository implements GuestUpgradeRepository {
  final SupabaseClient client;

  SupabaseGuestUpgradeRepository(this.client);

  @override
  Future<void> sendPhoneCode(String phone) =>
      _guard(() => client.auth.updateUser(UserAttributes(phone: phone)));

  @override
  Future<void> verifyPhoneCode({
    required String phone,
    required String code,
  }) async {
    await _guard(
      () => client.auth.verifyOTP(
        type: OtpType.phoneChange,
        phone: phone,
        token: code,
      ),
    );

    // profiles.phone is filled by the sign-up trigger, which ran when the
    // guest had no phone; keep it in step for the account screen.
    final userId = client.auth.currentUser?.id;
    if (userId != null) {
      await client.from('profiles').update({'phone': phone}).eq('id', userId);
    }
  }

  @override
  Future<bool> linkGoogle() async {
    final String? idToken;
    try {
      idToken = await fetchGoogleIdToken();
    } on GoogleSignInCancelled {
      return false;
    }
    if (idToken == null) return false;

    await _guard(
      () => client.auth.linkIdentityWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
      ),
    );
    return true;
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException catch (error) {
      if (error.code == 'phone_exists' ||
          error.code == 'identity_already_exists') {
        throw const AccountAlreadyExists();
      }
      rethrow;
    }
  }
}

final guestUpgradeRepositoryProvider = Provider<GuestUpgradeRepository>(
  (ref) => SupabaseGuestUpgradeRepository(Supabase.instance.client),
);
