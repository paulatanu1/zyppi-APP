import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zippy/core/data/data_source/key_names.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';

/// Profile screen's Appearance picker (Light/Dark/System), persisted via
/// shared_preferences — same storage this app already uses for the auth
/// token.
class ThemeModeProvider extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeProvider(this.ref) : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(KeyNames.themeMode);
    state = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(KeyNames.themeMode, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeProvider, ThemeMode>(
  (ref) => ThemeModeProvider(ref),
);
