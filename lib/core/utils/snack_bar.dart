import 'package:flutter/material.dart';

/// Attached to [MaterialApp.scaffoldMessengerKey] in lib/app/app.dart so
/// these helpers can show a SnackBar without needing a BuildContext at
/// every call site (several callers are Riverpod notifiers, not widgets).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void _showSnackBar(String message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    // Colours come from ZyppiTheme's snackBarTheme so it flips with dark mode.
    SnackBar(content: Text(message)),
  );
}

void showSuccessToast({String? message}) {
  _showSnackBar(message ?? '');
}

void showError(dynamic error) {
  _showSnackBar(error.toString());
}

void showConnectionInterrupted() {
  _showSnackBar('Connection Was Interrupted');
}
