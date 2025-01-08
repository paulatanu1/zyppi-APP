import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zippy/core/infrastructure/Network/baseApiServices.dart';
import 'package:zippy/core/infrastructure/Network/dioExceptions.dart';
import 'package:zippy/core/infrastructure/Network/header.dart';

class NetworkApiServices implements BaseApiServices {
  final Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json));

  final Header header = Header();

  @override
  Future getApiRequest({required String url}) {
    // TODO: implement getApiRequest
    throw UnimplementedError();
  }

  @override
  Future postApiRequest(
      {required String url, required Map<String, dynamic> payload}) async {
    // TODO: implement postApiRequest
    try {
      dio.options.headers.addAll(header.header());
      final response = await dio.post(url, data: payload);

      if (kDebugMode) {
        log('Response ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      var error = DioExceptions.fromDioError(e);
      throw error.toString();
    }
  }
}
