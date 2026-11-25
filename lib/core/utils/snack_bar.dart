import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zippy/core/cart/application/cart_provider.dart';
import 'package:zippy/core/utils/auth_errors.dart';

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

/// Shows [error] to the user. A [String] is shown as-is (callers pass
/// already-translated text); anything else becomes a translated, friendly
/// message — never a raw exception dump.
void showError(Object error) {
  _showSnackBar(error is String ? error : friendlyAuthError(error));
}

/// "Max 5 per item" / "Order limit reached (50 items)". Replaces a message
/// already showing, so tapping + repeatedly doesn't queue copies.
void showCartLimit(CartLimit limit) {
  rootScaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(limit.messageKey.tr(args: ['${limit.value}']))),
    );
}

void showConnectionInterrupted() {
  _showSnackBar('connectionInterrupted'.tr());
}
