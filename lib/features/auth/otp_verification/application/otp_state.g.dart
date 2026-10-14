// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OtpState _$OtpStateFromJson(Map<String, dynamic> json) => _OtpState(
  loading: json['loading'] as bool? ?? false,
  otpLoading: json['otpLoading'] as bool? ?? false,
  otp: json['otp'] as String?,
  verificationId: json['verificationId'] as String?,
  loginResponse: json['loginResponse'] == null
      ? null
      : LoginResponse.fromJson(json['loginResponse'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OtpStateToJson(_OtpState instance) => <String, dynamic>{
  'loading': instance.loading,
  'otpLoading': instance.otpLoading,
  'otp': instance.otp,
  'verificationId': instance.verificationId,
  'loginResponse': instance.loginResponse,
};
