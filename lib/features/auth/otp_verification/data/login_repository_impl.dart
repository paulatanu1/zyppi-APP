import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/infrastructure/network_api_services.dart';
import 'package:zippy/core/infrastructure/url.dart';
import 'package:zippy/core/shared_providers/network_provider.dart';
import 'package:zippy/features/auth/otp_verification/domain/login_repository.dart';

// Phase 1 keeps the existing REST call behind this interface;
// Phase 3 swaps the implementation to Supabase Auth.
class LoginRepositoryImpl implements LoginRepository {
  final NetworkApiServices networkApiServices;

  LoginRepositoryImpl(this.networkApiServices);

  @override
  Future<(dynamic, DioException?)> login({String? phoneNumber, String? otp}) {
    return networkApiServices.postApiRequest(
      url: Url.login,
      payload: {'phone': phoneNumber, 'otp': otp},
    );
  }
}

final loginRepositoryProvider = Provider<LoginRepository>(
  (ref) => LoginRepositoryImpl(ref.read(networkProvider)),
);
