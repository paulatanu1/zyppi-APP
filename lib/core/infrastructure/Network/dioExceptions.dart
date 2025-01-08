import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  String? message;

  DioExceptions.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = 'Request To Server Was Cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection Timed Out';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Received Time Out';
        break;
      case DioExceptionType.sendTimeout:
        message = "Request send timeout.";
        break;
      default:
        message = 'An Error Occured';
        break;
      // case DioExceptionType.badResponse:
      //   message = _handleError(
      //     dioException.response?.statusCode,
      //     dioException.response?.statusMessage,
      //   );
      //   break;
      // case DioExceptionType.badCertificate:
      //   if (dioException.message!.contains('SocketException')) {
      //     message = 'No Internet';
      //     break;
      //   }
      //   message = _handleError(
      //     dioException.response?.statusCode,
      //     dioException.response?.statusMessage,
      //   );
      // case DioExceptionType.connectionError:
      //   if (dioException.message!.contains('SocketException')) {
      //     message = 'No Internet';
      //     break;
      //   }
      //   message = _handleError(
      //     dioException.response?.statusCode,
      //     dioException.response?.statusMessage,
      //   );
      //   break;
      // case DioExceptionType.unknown:
      //   message = _handleError(
      //     dioException.response?.statusCode,
      //     dioException.response?.statusMessage,
      //   );
      //   break;
    }
  }
}

String _handleError(int statusCode) {
  switch (statusCode) {
    case 400:
      return 'Bad request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'The requested resource does not exist.';
    case 500:
      return 'Internal server error';
    case 502:
      return 'Bad gateway';
    default:
      return 'Oops something went wrong';
  }
}
