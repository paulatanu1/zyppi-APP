import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/infrastructure/network_api_services.dart';
import 'package:zippy/core/infrastructure/url.dart';
import 'package:zippy/core/shared_providers/network_provider.dart';
import 'package:zippy/core/utils/log.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/otp_verification/domain/login_model.dart';

import '../application/login_state.dart';

class LoginProvider extends StateNotifier<LoginState> {
  final NetworkApiServices networkApiServices;
  final Ref ref;

  LoginProvider(this.networkApiServices, this.ref) : super(LoginState());

  Future<void> login({
    String? phoneNumber,
    String? otp,
    required BuildContext context,
  }) async {
    state = state.copyWith(loading: true);

    try {
      var (response, dioException) = await networkApiServices.postApiRequest(
        url: Url.login,
        payload: {'phone': phoneNumber, 'otp': otp},
      );

      state = state.copyWith(loading: false);

      if (response == null && dioException == null) {
        showConnectionInterrupted();
      } else if (dioException != null) {
        AppLog.showLog(error: dioException.toString());
        showDioError(dioException);
      } else {
        AppLog.showLog(
          tag: 'Login Response',
          message: json.encode(response.data),
        );

        final user = UserResponse.fromJson(response.data);

        if (user.statusCode == 200) {
          state = state.copyWith(userResponse: user);

          ref
              .read(sharedPreferenceProvider.notifier)
              .setLocalStorage(
                authToken: state.userResponse?.response?.token ?? '',
              );

          context.goNamed('NavigationBar');

          AppLog.showLog(message: json.encode(user));

          showSuccessToast(message: user.message);
        } else {
          AppLog.showLog(message: json.encode(user));

          showSuccessToast(message: user.message);
        }
      }
    } catch (error, stackTrace) {
      state = state.copyWith(loading: false);

      AppLog.showLog(error: error, stackTrace: stackTrace);

      showDioError(error);
    }
  }
}

final loginProvider =
    StateNotifierProvider.autoDispose<LoginProvider, LoginState>(
      (ref) => LoginProvider(ref.read(networkProvider), ref),
    );
