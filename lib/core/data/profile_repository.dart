import 'package:zippy/core/domain/profile.dart';

abstract class ProfileRepository {
  Future<Profile> fetchProfile();

  /// Saves the edit-profile fields (name, email, dob, gender).
  Future<void> updateProfile(Profile profile);

  /// Saves the settings-screen fields (payment method, notifications).
  Future<void> updatePreferences(Profile profile);

  /// Sets the account's mobile number (`+91XXXXXXXXXX`), collected at
  /// sign-up or right after a first Google sign-in. Riders call it, so
  /// it's required to order; the app doesn't offer to change it later.
  Future<void> savePhone(String phone, {String? fullName});
}
