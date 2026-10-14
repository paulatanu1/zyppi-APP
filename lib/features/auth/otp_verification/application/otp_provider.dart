import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/otp_verification/data/otp_auth_repository_impl.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

import 'otp_state.dart';

class OtpLogin extends StateNotifier<OtpState> {
  final OtpAuthRepository repository;
  final Ref ref;

  OtpLogin(this.repository, this.ref) : super(OtpState());

  Future<void> generateOtp(String phoneNumber, BuildContext context) async {
    state = state.copyWith(loading: true, error: null);

    try {
      await repository.sendOtp(phoneNumber);

      state = state.copyWith(loading: false);

      if (!context.mounted) return;
      context.push(
        '/otpVerificationScreen?phoneNumber=${Uri.encodeComponent(phoneNumber)}',
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());

      showError(error);
    }
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  Future<void> verifyOtp(
    String phoneNumber,
    String otp,
    BuildContext context,
  ) async {
    state = state.copyWith(otpLoading: true, error: null);

    try {
      final accessToken = await repository.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      state = state.copyWith(otpLoading: false);

      if (accessToken == null) {
        showConnectionInterrupted();
        return;
      }

      await ref
          .read(sharedPreferenceProvider.notifier)
          .setLocalStorage(authToken: accessToken);

      if (!context.mounted) return;
      context.goNamed('NavigationBar');
    } catch (error) {
      state = state.copyWith(otpLoading: false, error: error.toString());

      showError(error);
    }
  }
}

final otpProvider = StateNotifierProvider.autoDispose<OtpLogin, OtpState>(
  (ref) => OtpLogin(ref.read(otpAuthRepositoryProvider), ref),
);
