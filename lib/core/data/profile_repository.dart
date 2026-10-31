import 'package:zippy/core/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> fetchProfile();

  Future<void> updateProfile(Profile profile);
}
