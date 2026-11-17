// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryConfig {

 int get feePaise; int get freeAbovePaise; int get minOrderPaise;
/// Create a copy of DeliveryConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryConfigCopyWith<DeliveryConfig> get copyWith => _$DeliveryConfigCopyWithImpl<DeliveryConfig>(this as DeliveryConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryConfig&&(identical(other.feePaise, _this.feePaise) || other.feePaise == _this.feePaise)&&(identical(other.freeAbovePaise, _this.freeAbovePaise) || other.freeAbovePaise == _this.freeAbovePaise)&&(identical(other.minOrderPaise, _this.minOrderPaise) || other.minOrderPaise == _this.minOrderPaise));
}


@override
int get hashCode {
  final _this = this as DeliveryConfig;
  return Object.hash(runtimeType,_this.feePaise,_this.freeAbovePaise,_this.minOrderPaise);
}

@override
String toString() {
  final _this = this as DeliveryConfig;
  return 'DeliveryConfig(feePaise: ${_this.feePaise}, freeAbovePaise: ${_this.freeAbovePaise}, minOrderPaise: ${_this.minOrderPaise})';
}


}

/// @nodoc
abstract mixin class $DeliveryConfigCopyWith<$Res>  {
  factory $DeliveryConfigCopyWith(DeliveryConfig value, $Res Function(DeliveryConfig) _then) = _$DeliveryConfigCopyWithImpl;
@useResult
$Res call({
 int feePaise, int freeAbovePaise, int minOrderPaise
});




}
/// @nodoc
class _$DeliveryConfigCopyWithImpl<$Res>
    implements $DeliveryConfigCopyWith<$Res> {
  _$DeliveryConfigCopyWithImpl(this._self, this._then);

  final DeliveryConfig _self;
  final $Res Function(DeliveryConfig) _then;

/// Create a copy of DeliveryConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feePaise = null,Object? freeAbovePaise = null,Object? minOrderPaise = null,}) {
  return _then(DeliveryConfig(
feePaise: null == feePaise ? _self.feePaise : feePaise // ignore: cast_nullable_to_non_nullable
as int,freeAbovePaise: null == freeAbovePaise ? _self.freeAbovePaise : freeAbovePaise // ignore: cast_nullable_to_non_nullable
as int,minOrderPaise: null == minOrderPaise ? _self.minOrderPaise : minOrderPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryConfig].
extension DeliveryConfigPatterns on DeliveryConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryConfig value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int feePaise,  int freeAbovePaise,  int minOrderPaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryConfig() when $default != null:
return $default(_that.feePaise,_that.freeAbovePaise,_that.minOrderPaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int feePaise,  int freeAbovePaise,  int minOrderPaise)  $default,) {final _that = this;
switch (_that) {
case _DeliveryConfig():
return $default(_that.feePaise,_that.freeAbovePaise,_that.minOrderPaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int feePaise,  int freeAbovePaise,  int minOrderPaise)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryConfig() when $default != null:
return $default(_that.feePaise,_that.freeAbovePaise,_that.minOrderPaise);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryConfig extends DeliveryConfig {
  const _DeliveryConfig({this.feePaise = 0, this.freeAbovePaise = 0, this.minOrderPaise = 0}): super._();
  

@override@JsonKey() final  int feePaise;
@override@JsonKey() final  int freeAbovePaise;
@override@JsonKey() final  int minOrderPaise;

/// Create a copy of DeliveryConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryConfigCopyWith<_DeliveryConfig> get copyWith => __$DeliveryConfigCopyWithImpl<_DeliveryConfig>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryConfig&&(identical(other.feePaise, feePaise) || other.feePaise == feePaise)&&(identical(other.freeAbovePaise, freeAbovePaise) || other.freeAbovePaise == freeAbovePaise)&&(identical(other.minOrderPaise, minOrderPaise) || other.minOrderPaise == minOrderPaise));
}


@override
int get hashCode {
    return Object.hash(runtimeType,feePaise,freeAbovePaise,minOrderPaise);
}

@override
String toString() {
    return 'DeliveryConfig(feePaise: $feePaise, freeAbovePaise: $freeAbovePaise, minOrderPaise: $minOrderPaise)';
}


}

/// @nodoc
abstract mixin class _$DeliveryConfigCopyWith<$Res> implements $DeliveryConfigCopyWith<$Res> {
  factory _$DeliveryConfigCopyWith(_DeliveryConfig value, $Res Function(_DeliveryConfig) _then) = __$DeliveryConfigCopyWithImpl;
@override @useResult
$Res call({
 int feePaise, int freeAbovePaise, int minOrderPaise
});




}
/// @nodoc
class __$DeliveryConfigCopyWithImpl<$Res>
    implements _$DeliveryConfigCopyWith<$Res> {
  __$DeliveryConfigCopyWithImpl(this._self, this._then);

  final _DeliveryConfig _self;
  final $Res Function(_DeliveryConfig) _then;

/// Create a copy of DeliveryConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feePaise = null,Object? freeAbovePaise = null,Object? minOrderPaise = null,}) {
  return _then(_DeliveryConfig(
feePaise: null == feePaise ? _self.feePaise : feePaise // ignore: cast_nullable_to_non_nullable
as int,freeAbovePaise: null == freeAbovePaise ? _self.freeAbovePaise : freeAbovePaise // ignore: cast_nullable_to_non_nullable
as int,minOrderPaise: null == minOrderPaise ? _self.minOrderPaise : minOrderPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
