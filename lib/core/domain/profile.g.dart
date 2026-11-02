// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  phone: json['phone'] as String?,
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
  gender: json['gender'] as String?,
  preferredPaymentMethod: json['preferredPaymentMethod'] as String?,
  notifyOrderUpdates: json['notifyOrderUpdates'] as bool? ?? true,
  notifyOffers: json['notifyOffers'] as bool? ?? false,
  isGuest: json['isGuest'] as bool? ?? false,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'fullName': instance.fullName,
  'email': instance.email,
  'dob': instance.dob?.toIso8601String(),
  'gender': instance.gender,
  'preferredPaymentMethod': instance.preferredPaymentMethod,
  'notifyOrderUpdates': instance.notifyOrderUpdates,
  'notifyOffers': instance.notifyOffers,
  'isGuest': instance.isGuest,
};
