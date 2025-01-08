import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/otpLoginModel.dart';

part 'otpState.freezed.dart';
part 'otpState.g.dart';

@freezed
class OtpState with _$OtpState {
  factory OtpState({
    @Default(false) bool loading,
    @Default(false) bool otpLoading,
    String? otp,
    String? verificationId,
    LoginResponse? loginResponse
  }) = _OtpState;

  factory OtpState.fromJson(Map<String, dynamic> json) =>
      _$OtpStateFromJson(json);
}