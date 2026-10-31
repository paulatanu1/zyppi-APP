import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Backs both account_screen.dart (display) and edit_profile_screen.dart
/// (edit) — previously both screens showed hardcoded placeholder text
/// with no data source at all.
@freezed
abstract class Profile with _$Profile {
  factory Profile({
    required String id,
    String? phone,
    String? fullName,
    String? email,
    DateTime? dob,
    String? gender,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
