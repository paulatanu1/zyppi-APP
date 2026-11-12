import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// Remembers which splash revision this device has played, so the full
/// animation shows once and later launches get the short one.
class SplashSeenStore {
  /// Bump in a release to show everyone the full splash again (e.g. after
  /// the animation changes).
  static const revision = 1;

  static const _key = 'splashSeenRevision';

  final SharedPreferences prefs;

  SplashSeenStore(this.prefs);

  bool get hasSeenCurrent => prefs.getInt(_key) == revision;

  Future<void> markSeen() => prefs.setInt(_key, revision);
}

final splashSeenStoreProvider = Provider<SplashSeenStore>(
  (ref) => SplashSeenStore(ref.read(sharedPreferencesProvider)),
);
