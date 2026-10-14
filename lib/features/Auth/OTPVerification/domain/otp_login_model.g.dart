// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      response: LoginResponseBody.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      message: json['message'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'response': instance.response,
      'message': instance.message,
    };

_LoginResponseBody _$LoginResponseBodyFromJson(Map<String, dynamic> json) =>
    _LoginResponseBody(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$LoginResponseBodyToJson(_LoginResponseBody instance) =>
    <String, dynamic>{'user': instance.user, 'token': instance.token};

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  phone: json['phone'] as String,
  lastLogin: json['lastLogin'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  picture: json['picture'] as String?,
  deletedAt: json['deletedAt'] as String?,
  id: (json['id'] as num).toInt(),
  isVerified: json['isVerified'] as bool,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'phone': instance.phone,
  'lastLogin': instance.lastLogin,
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
  'picture': instance.picture,
  'deletedAt': instance.deletedAt,
  'id': instance.id,
  'isVerified': instance.isVerified,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
