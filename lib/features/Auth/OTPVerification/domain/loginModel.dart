import 'package:freezed_annotation/freezed_annotation.dart';

part 'loginModel.freezed.dart';
part 'loginModel.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    required int? statusCode,
    required Response? response,
    required String? message,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}

@freezed
class Response with _$Response {
  const factory Response({
    required User? user,
    required String? token,
  }) = _Response;

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required dynamic phone,
    dynamic lastLogin,
    dynamic name,
    dynamic email,
    dynamic password,
    dynamic picture,
    dynamic deletedAt,
    required int? id,
    required bool? isVerified,
    required bool? isActive,
    required dynamic createdAt,
    required dynamic updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}














