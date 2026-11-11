import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// The user's last few searches, newest first, kept on this device only
/// (shared preferences) — the search screen's "Recent searches" chips.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier(this._prefs)
    : super(_prefs.getStringList(_key) ?? const []);

  final SharedPreferences _prefs;

  static const _key = 'recentSearches';
  static const max = 8;

  /// Moves [query] to the front (case-insensitive de-dupe).
  void add(String query) {
    final q = query.trim();
    if (q.length < 2) return;
    final next = [
      q,
      ...state.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(max).toList();
    state = next;
    _prefs.setStringList(_key, next);
  }

  void clear() {
    state = const [];
    _prefs.remove(_key);
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>(
      (ref) => RecentSearchesNotifier(ref.read(sharedPreferencesProvider)),
    );
