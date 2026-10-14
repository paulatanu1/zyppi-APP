import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_state.freezed.dart';

@freezed
abstract class OtpState with _$OtpState {
  factory OtpState({
    @Default(false) bool loading,
    @Default(false) bool otpLoading,
    String? otp,
    String? error,
  }) = _OtpState;
}
