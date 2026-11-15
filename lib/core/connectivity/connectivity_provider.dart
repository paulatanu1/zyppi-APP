import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the phone has any network (Wi-Fi, mobile, ethernet, VPN…).
/// connectivity_plus reports the link, not real internet reachability, so
/// this only drives the "You're offline" banner — never business logic.
abstract class ConnectivityMonitor {
  Future<bool> isOnline();
  Stream<bool> watch();
}

class PluginConnectivityMonitor implements ConnectivityMonitor {
  PluginConnectivityMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async =>
      _online(await _connectivity.checkConnectivity());

  @override
  Stream<bool> watch() => _connectivity.onConnectivityChanged.map(_online);
}

final connectivityMonitorProvider = Provider<ConnectivityMonitor>(
  (ref) => PluginConnectivityMonitor(),
);

/// Current online state: the first check, then every change (de-duped).
/// Errors from the plugin count as online, so a platform hiccup never
/// shows a false "offline" banner.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final monitor = ref.watch(connectivityMonitorProvider);
  bool? last;
  bool initial;
  try {
    initial = await monitor.isOnline();
  } catch (_) {
    initial = true;
  }
  last = initial;
  yield initial;
  await for (final online in monitor.watch().handleError((_) {})) {
    if (online == last) continue;
    last = online;
    yield online;
  }
});
