import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/features/auth/otp_verification/data/otp_auth_repository_impl.dart';
import 'package:zippy/features/auth/otp_verification/domain/otp_auth_repository.dart';

import 'otp_state.dart';

class OtpLogin extends StateNotifier<OtpState> {
  final OtpAuthRepository repository;

  OtpLogin(this.repository) : super(OtpState());

  Future<void> generateOtp(String phoneNumber, BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      await repository.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await repository.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification Failed: ${e.toString()}');
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            loading: false,
            verificationId: verificationId,
          );

          context.push('/otpVerificationScreen');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto Retrieval Timeout: $verificationId');
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false);

      log('Error Generate: ${e.toString()}');
    }
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp);
  }

  Future<void> verifyOtp(String otp, BuildContext context) async {
    state = state.copyWith(otpLoading: true);

    try {
      final cred = repository.credentialFromSmsCode(
        verificationId: state.verificationId ?? '',
        smsCode: otp,
      );

      await repository.signInWithCredential(cred);

      if (!context.mounted) return;
      context.go('/navBar');

      state = state.copyWith(otpLoading: false);
    } catch (e) {
      state = state.copyWith(otpLoading: false);

      log('Error Verify: ${e.toString()}');
    }
  }
}

final otpProvider = StateNotifierProvider.autoDispose<OtpLogin, OtpState>(
  (ref) => OtpLogin(ref.read(otpAuthRepositoryProvider)),
);
