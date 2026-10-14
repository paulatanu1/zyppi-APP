import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/utils/log.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/otp_verification/data/login_repository_impl.dart';
import 'package:zippy/features/auth/otp_verification/domain/login_model.dart';
import 'package:zippy/features/auth/otp_verification/domain/login_repository.dart';

import 'login_state.dart';

class LoginProvider extends StateNotifier<LoginState> {
  final LoginRepository repository;
  final Ref ref;

  LoginProvider(this.repository, this.ref) : super(LoginState());

  Future<void> login({
    String? phoneNumber,
    String? otp,
    required BuildContext context,
  }) async {
    state = state.copyWith(loading: true);

    try {
      var (response, dioException) = await repository.login(
        phoneNumber: phoneNumber,
        otp: otp,
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
      (ref) => LoginProvider(ref.read(loginRepositoryProvider), ref),
    );
