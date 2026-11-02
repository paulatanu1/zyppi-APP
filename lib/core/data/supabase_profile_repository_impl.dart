import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/data/profile_repository.dart';
import 'package:zippy/core/domain/profile.dart';

/// RLS restricts `profiles` to its owner (20261015120100_user_schema.sql),
/// so an unfiltered select/update implicitly targets the signed-in user.
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient client;

  SupabaseProfileRepository(this.client);

  @override
  Future<Profile> fetchProfile() async {
    final row = await client.from('profiles').select('''
          id, phone, fullName:full_name, email, dob, gender,
          preferredPaymentMethod:preferred_payment_method,
          notifyOrderUpdates:notify_order_updates, notifyOffers:notify_offers
        ''').single();

    return Profile.fromJson({
      ...row,
      'isGuest': client.auth.currentUser?.isAnonymous ?? false,
    });
  }

  @override
  Future<void> updateProfile(Profile profile) {
    final email = profile.email?.trim() ?? '';
    return _update(profile.id, {
      'full_name': profile.fullName?.trim(),
      'email': email.isEmpty ? null : email,
      'dob': profile.dob?.toIso8601String().split('T').first,
      'gender': profile.gender,
    });
  }

  @override
  Future<void> updatePreferences(Profile profile) => _update(profile.id, {
    'preferred_payment_method': profile.preferredPaymentMethod,
    'notify_order_updates': profile.notifyOrderUpdates,
    'notify_offers': profile.notifyOffers,
  });

  /// Throws if no row was written, instead of reporting a silent success.
  Future<void> _update(String id, Map<String, dynamic> values) async {
    final rows = await client
        .from('profiles')
        .update(values)
        .eq('id', id)
        .select('id');
    if (rows.isEmpty) throw StateError('Profile not saved');
  }
}
