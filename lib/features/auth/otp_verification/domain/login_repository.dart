import 'package:dio/dio.dart';

abstract class LoginRepository {
  Future<(dynamic, DioException?)> login({String? phoneNumber, String? otp});
}
