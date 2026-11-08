import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every key in the English file must exist in every other language, with
/// the same placeholders — otherwise users see raw keys or broken text.
void main() {
  const dir = 'assets/translations';
  const others = ['bn-BN', 'hi-IN', 'pa-Guru'];

  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('$dir/$locale.json').readAsStringSync())
          as Map<String, dynamic>;

  // Plural entries are maps; compare their forms' placeholders too.
  Iterable<String> texts(dynamic value) => value is Map
      ? value.values.map((v) => '$v')
      : [if (value is String) value];

  Set<String> placeholders(dynamic value) => {
    for (final text in texts(value))
      for (final m in RegExp(r'\{[a-zA-Z]*\}').allMatches(text)) m.group(0)!,
  };

  final english = load('en-UK');

  for (final locale in others) {
    test('$locale has every English key', () {
      final translated = load(locale);
      final missing = english.keys.where((k) => !translated.containsKey(k));
      expect(missing, isEmpty, reason: 'missing in $locale');
    });

    test('$locale uses the same placeholders as English', () {
      final translated = load(locale);
      final mismatched = [
        for (final key in english.keys)
          if (translated.containsKey(key) &&
              !_sameSet(
                placeholders(english[key]),
                placeholders(translated[key]),
              ))
            key,
      ];
      expect(mismatched, isEmpty, reason: 'placeholder mismatch in $locale');
    });
  }
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);
