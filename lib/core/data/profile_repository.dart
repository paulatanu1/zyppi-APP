import 'package:zippy/core/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> fetchProfile();

  /// Saves the edit-profile fields (name, email, dob, gender).
  Future<void> updateProfile(Profile profile);

  /// Saves the settings-screen fields (payment method, notifications).
  Future<void> updatePreferences(Profile profile);
}
