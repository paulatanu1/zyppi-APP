import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/mock/mock_data_source.dart';
import 'package:zippy/core/data/profile_repository.dart';
import 'package:zippy/core/data/supabase_profile_repository_impl.dart';
import 'package:zippy/core/domain/profile.dart';

class MockProfileRepository implements ProfileRepository {
  Profile? _override;

  @override
  Future<Profile> fetchProfile() async {
    await MockDataSource.simulateLatency();

    if (_override != null) return _override!;

    final json = await MockDataSource.loadJsonMap('assets/mock/profile.json');
    return Profile.fromJson(json);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await MockDataSource.simulateLatency();
    _override = profile;
  }

  @override
  Future<void> updatePreferences(Profile profile) async {
    await MockDataSource.simulateLatency();
    _override = profile;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => Env.isMockDataSource
      ? MockProfileRepository()
      : SupabaseProfileRepository(Supabase.instance.client),
);
