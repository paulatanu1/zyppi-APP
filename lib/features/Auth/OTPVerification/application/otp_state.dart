import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/otp_login_model.dart';

part 'otp_state.freezed.dart';
part 'otp_state.g.dart';

@freezed
abstract class OtpState with _$OtpState {
  factory OtpState({
    @Default(false) bool loading,
    @Default(false) bool otpLoading,
    String? otp,
    String? verificationId,
    LoginResponse? loginResponse,
  }) = _OtpState;

  factory OtpState.fromJson(Map<String, dynamic> json) =>
      _$OtpStateFromJson(json);
}
