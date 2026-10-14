import 'package:flutter/material.dart';
import 'package:zippy/core/infrastructure/dio_exceptions.dart';
import 'package:zippy/core/theme/app_colors.dart';

/// Attached to [MaterialApp.scaffoldMessengerKey] in lib/app/app.dart so
/// these helpers can show a SnackBar without needing a BuildContext at
/// every call site (several callers are Riverpod notifiers, not widgets).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void _showSnackBar(String message) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: AppColors.white)),
      backgroundColor: AppColors.black,
    ),
  );
}

void showSuccessToast({String? message}) {
  _showSnackBar(message ?? '');
}

void showDioError(dynamic e) {
  final errorResponse = DioExceptions.fromDioError(dioException: e);

  _showSnackBar(errorResponse.toString());
}

void showConnectionInterrupted() {
  _showSnackBar('Connection Was Interrupted');
}
