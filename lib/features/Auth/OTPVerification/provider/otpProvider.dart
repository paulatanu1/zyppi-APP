import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/otpState.dart';
import '../domain/otpLoginModel.dart';

class OtpLogin extends StateNotifier<OtpState> {
  OtpLogin() : super(OtpState());

  Future<void> generateOtp(String phoneNumber, BuildContext context) async {
    state = state.copyWith(loading: true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            log('Verification Failed: ${e.toString()}');
          },
          codeSent: (String verificationId, int? resendToken) {
            state =
                state.copyWith(loading: false, verificationId: verificationId);

            context.push('/otpVerificationScreen');
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            log('Auto Retrieval Timeout: $verificationId');
          });
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
      final cred = PhoneAuthProvider.credential(
          verificationId: state.verificationId ?? '', smsCode: otp);

      await FirebaseAuth.instance.signInWithCredential(cred);

      context.go('/navBar');

      state = state.copyWith(otpLoading: false);

    } catch (e) {
      state = state.copyWith(otpLoading: false);

      log('Error Verify: ${e.toString()}');
    }
  }
}

final otpProvider =
    StateNotifierProvider.autoDispose<OtpLogin, OtpState>((ref) => OtpLogin());
