// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String? get phone; String? get fullName; String? get email; DateTime? get dob; String? get gender;/// 'UPI', 'Credit or debit card' or 'Cash on delivery'; checkout
/// starts with this method selected.
 String? get preferredPaymentMethod; bool get notifyOrderUpdates; bool get notifyOffers;/// Signed in anonymously ("Continue as guest").
 bool get isGuest;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.dob, _this.dob) || other.dob == _this.dob)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.preferredPaymentMethod, _this.preferredPaymentMethod) || other.preferredPaymentMethod == _this.preferredPaymentMethod)&&(identical(other.notifyOrderUpdates, _this.notifyOrderUpdates) || other.notifyOrderUpdates == _this.notifyOrderUpdates)&&(identical(other.notifyOffers, _this.notifyOffers) || other.notifyOffers == _this.notifyOffers)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.phone,_this.fullName,_this.email,_this.dob,_this.gender,_this.preferredPaymentMethod,_this.notifyOrderUpdates,_this.notifyOffers,_this.isGuest);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, phone: ${_this.phone}, fullName: ${_this.fullName}, email: ${_this.email}, dob: ${_this.dob}, gender: ${_this.gender}, preferredPaymentMethod: ${_this.preferredPaymentMethod}, notifyOrderUpdates: ${_this.notifyOrderUpdates}, notifyOffers: ${_this.notifyOffers}, isGuest: ${_this.isGuest})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String? fullName, String? email, DateTime? dob, String? gender, String? preferredPaymentMethod, bool notifyOrderUpdates, bool notifyOffers, bool isGuest
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,Object? email = freezed,Object? dob = freezed,Object? gender = freezed,Object? preferredPaymentMethod = freezed,Object? notifyOrderUpdates = null,Object? notifyOffers = null,Object? isGuest = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,preferredPaymentMethod: freezed == preferredPaymentMethod ? _self.preferredPaymentMethod : preferredPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,notifyOrderUpdates: null == notifyOrderUpdates ? _self.notifyOrderUpdates : notifyOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,notifyOffers: null == notifyOffers ? _self.notifyOffers : notifyOffers // ignore: cast_nullable_to_non_nullable
as bool,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName,  String? email,  DateTime? dob,  String? gender,  String? preferredPaymentMethod,  bool notifyOrderUpdates,  bool notifyOffers,  bool isGuest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.phone,_that.fullName,_that.email,_that.dob,_that.gender,_that.preferredPaymentMethod,_that.notifyOrderUpdates,_that.notifyOffers,_that.isGuest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String? fullName,  String? email,  DateTime? dob,  String? gender,  String? preferredPaymentMethod,  bool notifyOrderUpdates,  bool notifyOffers,  bool isGuest)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.phone,_that.fullName,_that.email,_that.dob,_that.gender,_that.preferredPaymentMethod,_that.notifyOrderUpdates,_that.notifyOffers,_that.isGuest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String? fullName,  String? email,  DateTime? dob,  String? gender,  String? preferredPaymentMethod,  bool notifyOrderUpdates,  bool notifyOffers,  bool isGuest)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.phone,_that.fullName,_that.email,_that.dob,_that.gender,_that.preferredPaymentMethod,_that.notifyOrderUpdates,_that.notifyOffers,_that.isGuest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
   _Profile({required this.id, this.phone, this.fullName, this.email, this.dob, this.gender, this.preferredPaymentMethod, this.notifyOrderUpdates = true, this.notifyOffers = false, this.isGuest = false});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String? fullName;
@override final  String? email;
@override final  DateTime? dob;
@override final  String? gender;
/// 'UPI', 'Credit or debit card' or 'Cash on delivery'; checkout
/// starts with this method selected.
@override final  String? preferredPaymentMethod;
@override@JsonKey() final  bool notifyOrderUpdates;
@override@JsonKey() final  bool notifyOffers;
/// Signed in anonymously ("Continue as guest").
@override@JsonKey() final  bool isGuest;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.preferredPaymentMethod, preferredPaymentMethod) || other.preferredPaymentMethod == preferredPaymentMethod)&&(identical(other.notifyOrderUpdates, notifyOrderUpdates) || other.notifyOrderUpdates == notifyOrderUpdates)&&(identical(other.notifyOffers, notifyOffers) || other.notifyOffers == notifyOffers)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,phone,fullName,email,dob,gender,preferredPaymentMethod,notifyOrderUpdates,notifyOffers,isGuest);
}

@override
String toString() {
    return 'Profile(id: $id, phone: $phone, fullName: $fullName, email: $email, dob: $dob, gender: $gender, preferredPaymentMethod: $preferredPaymentMethod, notifyOrderUpdates: $notifyOrderUpdates, notifyOffers: $notifyOffers, isGuest: $isGuest)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String? fullName, String? email, DateTime? dob, String? gender, String? preferredPaymentMethod, bool notifyOrderUpdates, bool notifyOffers, bool isGuest
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? fullName = freezed,Object? email = freezed,Object? dob = freezed,Object? gender = freezed,Object? preferredPaymentMethod = freezed,Object? notifyOrderUpdates = null,Object? notifyOffers = null,Object? isGuest = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,preferredPaymentMethod: freezed == preferredPaymentMethod ? _self.preferredPaymentMethod : preferredPaymentMethod // ignore: cast_nullable_to_non_nullable
as String?,notifyOrderUpdates: null == notifyOrderUpdates ? _self.notifyOrderUpdates : notifyOrderUpdates // ignore: cast_nullable_to_non_nullable
as bool,notifyOffers: null == notifyOffers ? _self.notifyOffers : notifyOffers // ignore: cast_nullable_to_non_nullable
as bool,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
