import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class MockDataException implements Exception {
  final String message;

  MockDataException(this.message);

  @override
  String toString() => message;
}

/// Shared helper for Phase 2's mock repositories: loads `assets/mock/*.json`
/// and simulates network latency (300-800ms) and failures, per PLAN.md.
class MockDataSource {
  MockDataSource._();

  static final Random _random = Random();

  /// Flip to true (e.g. from a debug menu) to make every mock repository
  /// throw instead of returning data, to exercise error/retry states.
  static bool simulateErrors = false;

  static Future<void> simulateLatency() async {
    final delayMs = 300 + _random.nextInt(501); // 300-800ms
    await Future.delayed(Duration(milliseconds: delayMs));

    if (simulateErrors) {
      throw MockDataException('Simulated mock data error');
    }
  }

  static Future<List<dynamic>> loadJsonList(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return json.decode(raw) as List<dynamic>;
  }
}
