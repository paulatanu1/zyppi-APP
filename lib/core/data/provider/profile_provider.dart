import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/data/profile_repository_impl.dart';
import 'package:zippy/core/domain/profile.dart';

/// Shared between account_screen.dart (display) and
/// edit_profile_screen.dart (edit) — both features import this from
/// core/ per CLAUDE.md. Invalidate after a successful
/// `updateProfile()` so both screens pick up the change.
final profileProvider = FutureProvider.autoDispose<Profile>(
  (ref) => ref.read(profileRepositoryProvider).fetchProfile(),
);
