import 'package:flutter/foundation.dart';

/// Typed reads of a section's admin-edited `config` / item `data` JSON.
/// A value of the wrong type reads as missing rather than throwing, so one
/// mistyped field can't take down the whole Home screen.
extension SectionData on Map<String, dynamic> {
  String? string(String key) {
    final value = this[key];
    if (value == null || value is String) return value as String?;
    _logMismatch(key, 'String', value);
    return null;
  }

  int? integer(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toInt();
    _logMismatch(key, 'int', value);
    return null;
  }

  void _logMismatch(String key, String expected, Object value) {
    if (kDebugMode) {
      debugPrint(
        'SectionData: "$key" should be $expected, got ${value.runtimeType}',
      );
    }
  }
}
