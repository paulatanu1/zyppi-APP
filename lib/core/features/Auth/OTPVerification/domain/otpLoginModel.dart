import 'package:freezed_annotation/freezed_annotation.dart';

part 'otpLoginModel.freezed.dart';
part 'otpLoginModel.g.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required int statusCode,
    required LoginResponseBody response,
    required String message,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class LoginResponseBody with _$LoginResponseBody {
  const factory LoginResponseBody({
    required User user,
    required String token,
  }) = _LoginResponseBody;

  factory LoginResponseBody.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseBodyFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required String phone,
    required String lastLogin,
    String? name,
    String? email,
    String? password,
    String? picture,
    String? deletedAt,
    required int id,
    required bool isVerified,
    required bool isActive,
    required String createdAt,
    required String updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
