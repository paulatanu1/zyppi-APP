// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otpLoginModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      statusCode: (json['statusCode'] as num).toInt(),
      response:
          LoginResponseBody.fromJson(json['response'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'response': instance.response,
      'message': instance.message,
    };

_$LoginResponseBodyImpl _$$LoginResponseBodyImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginResponseBodyImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$$LoginResponseBodyImplToJson(
        _$LoginResponseBodyImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
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

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
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
