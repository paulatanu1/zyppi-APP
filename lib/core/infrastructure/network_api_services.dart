import 'package:dio/dio.dart';
import 'package:zippy/core/infrastructure/base_api_services.dart';
import 'package:zippy/core/infrastructure/header.dart';
import 'package:zippy/core/utils/log.dart';

class NetworkApiServices implements BaseApiServices {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
    ),
  );

  final Header header = Header();

  @override
  Future<(dynamic, DioException?)> getApiRequest({
    required String url,
    String? parameters,
  }) async {
    // TODO: implement getApiRequest
    try {
      dio.options.headers.addAll(header.header());

      AppLog.showLog(
        tag: 'Get URL',
        message: parameters == null ? url : '$url$parameters',
      );

      final response = await dio.get(
        parameters == null ? url : '$url$parameters',
      );

      return (response, null);
    } on DioException catch (e) {
      return (null, e);
    } catch (error) {
      return (null, null);
    }
  }
}
