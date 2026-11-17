// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SellerProfile {

 String get id; String get shopName; String? get address; String? get phone; String? get gstin; String? get fssaiNo; double get ratingAvg; int get ratingCount;
/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerProfileCopyWith<SellerProfile> get copyWith => _$SellerProfileCopyWithImpl<SellerProfile>(this as SellerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SellerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.shopName, _this.shopName) || other.shopName == _this.shopName)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.gstin, _this.gstin) || other.gstin == _this.gstin)&&(identical(other.fssaiNo, _this.fssaiNo) || other.fssaiNo == _this.fssaiNo)&&(identical(other.ratingAvg, _this.ratingAvg) || other.ratingAvg == _this.ratingAvg)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount));
}


@override
int get hashCode {
  final _this = this as SellerProfile;
  return Object.hash(runtimeType,_this.id,_this.shopName,_this.address,_this.phone,_this.gstin,_this.fssaiNo,_this.ratingAvg,_this.ratingCount);
}

@override
String toString() {
  final _this = this as SellerProfile;
  return 'SellerProfile(id: ${_this.id}, shopName: ${_this.shopName}, address: ${_this.address}, phone: ${_this.phone}, gstin: ${_this.gstin}, fssaiNo: ${_this.fssaiNo}, ratingAvg: ${_this.ratingAvg}, ratingCount: ${_this.ratingCount})';
}


}

/// @nodoc
abstract mixin class $SellerProfileCopyWith<$Res>  {
  factory $SellerProfileCopyWith(SellerProfile value, $Res Function(SellerProfile) _then) = _$SellerProfileCopyWithImpl;
@useResult
$Res call({
 String id, String shopName, String? address, String? phone, String? gstin, String? fssaiNo, double ratingAvg, int ratingCount
});




}
/// @nodoc
class _$SellerProfileCopyWithImpl<$Res>
    implements $SellerProfileCopyWith<$Res> {
  _$SellerProfileCopyWithImpl(this._self, this._then);

  final SellerProfile _self;
  final $Res Function(SellerProfile) _then;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopName = null,Object? address = freezed,Object? phone = freezed,Object? gstin = freezed,Object? fssaiNo = freezed,Object? ratingAvg = null,Object? ratingCount = null,}) {
  return _then(SellerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,fssaiNo: freezed == fssaiNo ? _self.fssaiNo : fssaiNo // ignore: cast_nullable_to_non_nullable
as String?,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerProfile].
extension SellerProfilePatterns on SellerProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerProfile value)  $default,){
final _that = this;
switch (_that) {
case _SellerProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopName,  String? address,  String? phone,  String? gstin,  String? fssaiNo,  double ratingAvg,  int ratingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that.id,_that.shopName,_that.address,_that.phone,_that.gstin,_that.fssaiNo,_that.ratingAvg,_that.ratingCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopName,  String? address,  String? phone,  String? gstin,  String? fssaiNo,  double ratingAvg,  int ratingCount)  $default,) {final _that = this;
switch (_that) {
case _SellerProfile():
return $default(_that.id,_that.shopName,_that.address,_that.phone,_that.gstin,_that.fssaiNo,_that.ratingAvg,_that.ratingCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopName,  String? address,  String? phone,  String? gstin,  String? fssaiNo,  double ratingAvg,  int ratingCount)?  $default,) {final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that.id,_that.shopName,_that.address,_that.phone,_that.gstin,_that.fssaiNo,_that.ratingAvg,_that.ratingCount);case _:
  return null;

}
}

}

/// @nodoc


class _SellerProfile implements SellerProfile {
  const _SellerProfile({required this.id, required this.shopName, this.address, this.phone, this.gstin, this.fssaiNo, this.ratingAvg = 0, this.ratingCount = 0});
  

@override final  String id;
@override final  String shopName;
@override final  String? address;
@override final  String? phone;
@override final  String? gstin;
@override final  String? fssaiNo;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerProfileCopyWith<_SellerProfile> get copyWith => __$SellerProfileCopyWithImpl<_SellerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.fssaiNo, fssaiNo) || other.fssaiNo == fssaiNo)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,shopName,address,phone,gstin,fssaiNo,ratingAvg,ratingCount);
}

@override
String toString() {
    return 'SellerProfile(id: $id, shopName: $shopName, address: $address, phone: $phone, gstin: $gstin, fssaiNo: $fssaiNo, ratingAvg: $ratingAvg, ratingCount: $ratingCount)';
}


}

/// @nodoc
abstract mixin class _$SellerProfileCopyWith<$Res> implements $SellerProfileCopyWith<$Res> {
  factory _$SellerProfileCopyWith(_SellerProfile value, $Res Function(_SellerProfile) _then) = __$SellerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopName, String? address, String? phone, String? gstin, String? fssaiNo, double ratingAvg, int ratingCount
});




}
/// @nodoc
class __$SellerProfileCopyWithImpl<$Res>
    implements _$SellerProfileCopyWith<$Res> {
  __$SellerProfileCopyWithImpl(this._self, this._then);

  final _SellerProfile _self;
  final $Res Function(_SellerProfile) _then;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopName = null,Object? address = freezed,Object? phone = freezed,Object? gstin = freezed,Object? fssaiNo = freezed,Object? ratingAvg = null,Object? ratingCount = null,}) {
  return _then(_SellerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,fssaiNo: freezed == fssaiNo ? _self.fssaiNo : fssaiNo // ignore: cast_nullable_to_non_nullable
as String?,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
