import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppLog {
  static void showLog(
      {String? tag,
      String? message,
      DioException? dioError,
      Object? error,
      StackTrace? stackTrace}) {
    if (kDebugMode) {
      log('Tag: $tag,\n Message: $message,\n DioError: $dioError,\n Error: $error,\n StackTrace: $stackTrace');
    }
  }
}
