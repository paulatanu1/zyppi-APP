import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/core/data/provider/shared_preference_provider.dart';
import 'package:zippy/core/push/data/push_token_repository_impl.dart';
import 'package:zippy/core/push/push_notification_service.dart';
import 'package:zippy/core/utils/snack_bar.dart';
import 'package:zippy/features/auth/otp_verification/data/otp_auth_repository_impl.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

import 'otp_state.dart';

class OtpLogin extends StateNotifier<OtpState> {
  final OtpAuthRepository repository;
  final Ref ref;

  OtpLogin(this.repository, this.ref) : super(OtpState());

  Future<void> generateOtp(String phoneNumber, BuildContext context) async {
    // A new number starts with a blank code, never the previous attempt's.
    state = state.copyWith(loading: true, error: null, otp: null);

    try {
      await repository.sendOtp(phoneNumber);

      state = state.copyWith(loading: false);

      if (!context.mounted) return;
      context.push(
        '/otpVerificationScreen?phoneNumber=${Uri.encodeComponent(phoneNumber)}',
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: error.toString());

      showError(error);
    }
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  /// Sends a fresh code to the same number without navigating. Returns
  /// whether it was sent, so the screen can restart its countdown.
  Future<bool> resendOtp(String phoneNumber) async {
    try {
      await repository.sendOtp(phoneNumber);
      if (mounted) state = state.copyWith(otp: null);
      return true;
    } catch (error) {
      showError(error);
      return false;
    }
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

      // Read before logging in: the redirect that follows disposes this
      // provider, and its ref with it.
      final pushTokens = ref.read(pushTokenRepositoryProvider);
      await ref
          .read(sharedPreferenceProvider.notifier)
          .setLocalStorage(authToken: accessToken);
      PushNotificationService.registerTokenAfterLogin(pushTokens);

      if (!context.mounted) return;
      context.goNamed('NavigationBar');
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(otpLoading: false, error: error.toString());

      showError(error);
    }
  }
}

final otpProvider = StateNotifierProvider.autoDispose<OtpLogin, OtpState>(
  (ref) => OtpLogin(ref.read(otpAuthRepositoryProvider), ref),
);
