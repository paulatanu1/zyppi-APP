import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zippy/core/data/provider/sharedPreferenceProvider.dart';
import 'package:zippy/core/infrastructure/baseApiServices.dart';
import 'package:zippy/core/infrastructure/dioExceptions.dart';
import 'package:zippy/core/infrastructure/header.dart';
import 'package:zippy/core/utils/log.dart';

class NetworkApiServices implements BaseApiServices {
  final Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json));

  final Header header = Header();

  @override
  Future<(dynamic, DioException?)> getApiRequest(
      {required String url, String? parameters}) async {
    // TODO: implement getApiRequest
    try {
      dio.options.headers.addAll(header.header());

      AppLog.showLog(
          tag: 'Get URL',
          message: parameters == null ? url : '$url$parameters');

      final response =
          await dio.get(parameters == null ? url : '$url$parameters');

      return (response, null);
    } on DioException catch (e) {
      return (null, e);
    } catch (error) {
      return (null, null);
    }
  }

  @override
  Future<(dynamic, DioException?)> postApiRequest(
      {required String url, required Map<String, dynamic> payload}) async {
    // TODO: implement postApiRequest
    try {
      dio.options.headers.addAll(header.header());
      AppLog.showLog(tag: 'Get URL', message: url);

      final response = await dio.post(url, data: payload);

      return (response, null);
    } on DioException catch (e) {
      return (null, e);
    } catch (error) {
      return (null, null);
    }
  }

  @override
  Future<(dynamic, DioException?)> postAuthenticatedApiRequest(
      {required String url, required Map<String, dynamic> payload}) async {
    // TODO: implement postApiRequest
    try {
      dio.options.headers
          .addAll(header.authenticatedHeader());
      AppLog.showLog(tag: 'POST URL', message: url);

      final response = await dio.post(url, data: payload);

      return (response, null);
    } on DioException catch (e) {
      return (null, e);
    } catch (error) {
      return (null, null);
    }
  }
}
