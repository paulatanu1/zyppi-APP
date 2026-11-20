import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Completes once the launch animation has handed off to Home or
/// Onboarding, or has left the screen some other way (e.g. a notification
/// tap). Bootstrap waits on it before asking for location and push
/// permission, so a system dialog never covers the animation.
final launchDoneProvider = Provider<Completer<void>>(
  (ref) => Completer<void>(),
);

extension LaunchDone on Completer<void> {
  /// Completes once; later calls do nothing.
  void markDone() {
    if (!isCompleted) complete();
  }
}
