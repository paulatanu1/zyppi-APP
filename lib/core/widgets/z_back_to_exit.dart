import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Root-screen Back handling (button or gesture): when [atHome] is false,
/// Back calls [onGoHome]; on Home the first Back shows "Press back again
/// to exit" and only a second Back within [window] closes the app, so a
/// stray press or gesture doesn't.
class ZBackToExit extends StatefulWidget {
  const ZBackToExit({
    super.key,
    required this.child,
    required this.atHome,
    required this.onGoHome,
    this.onExit = SystemNavigator.pop,
    this.window = const Duration(seconds: 2),
  });

  final Widget child;
  final bool atHome;
  final VoidCallback onGoHome;
  final Future<void> Function() onExit;
  final Duration window;

  @override
  State<ZBackToExit> createState() => _ZBackToExitState();
}

class _ZBackToExitState extends State<ZBackToExit> {
  /// Running while the first Back's message is up.
  Timer? _armed;

  @override
  void dispose() {
    _armed?.cancel();
    super.dispose();
  }

  void _onBack() {
    if (!widget.atHome) {
      widget.onGoHome();
      return;
    }
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (_armed?.isActive ?? false) {
      _armed!.cancel();
      widget.onExit();
      return;
    }
    _armed = Timer(widget.window, () {});
    messenger.showSnackBar(
      SnackBar(
        content: Text('pressBackAgainToExit'.tr()),
        duration: widget.window,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _onBack();
    },
    child: widget.child,
  );
}
