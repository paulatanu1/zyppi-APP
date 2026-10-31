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
    final row = await client
        .from('profiles')
        .select('id, phone, fullName:full_name, email, dob, gender')
        .single();

    return Profile.fromJson(row);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await client
        .from('profiles')
        .update({
          'full_name': profile.fullName,
          'email': profile.email,
          'dob': profile.dob?.toIso8601String().split('T').first,
          'gender': profile.gender,
        })
        .eq('id', profile.id);
  }
}
