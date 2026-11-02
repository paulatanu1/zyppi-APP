import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/features/auth/guest/domain/guest_auth_repository.dart';

/// Supabase anonymous sign-in. The guest still gets an `authenticated` JWT,
/// so cart/address/order RLS and the payment Edge Functions work unchanged.
/// Needs "Anonymous sign-ins" enabled under Auth → Providers per project.
class SupabaseGuestAuthRepository implements GuestAuthRepository {
  final SupabaseClient client;

  SupabaseGuestAuthRepository(this.client);

  @override
  Future<String?> signIn() async {
    final response = await client.auth.signInAnonymously();

    return response.session?.accessToken;
  }
}

final guestAuthRepositoryProvider = Provider<GuestAuthRepository>(
  (ref) => SupabaseGuestAuthRepository(Supabase.instance.client),
);
