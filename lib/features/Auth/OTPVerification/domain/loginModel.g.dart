// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loginModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserResponseImpl _$$UserResponseImplFromJson(Map<String, dynamic> json) =>
    _$UserResponseImpl(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      response: json['response'] == null
          ? null
          : Response.fromJson(json['response'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$UserResponseImplToJson(_$UserResponseImpl instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'response': instance.response,
      'message': instance.message,
    };

_$ResponseImpl _$$ResponseImplFromJson(Map<String, dynamic> json) =>
    _$ResponseImpl(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );

Map<String, dynamic> _$$ResponseImplToJson(_$ResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      phone: json['phone'],
      lastLogin: json['lastLogin'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      picture: json['picture'],
      deletedAt: json['deletedAt'],
      id: (json['id'] as num?)?.toInt(),
      isVerified: json['isVerified'] as bool?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
