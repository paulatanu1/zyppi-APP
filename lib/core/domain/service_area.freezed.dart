// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_area.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceArea {

 String get id; String get name; bool get isActive; double? get centerLat; double? get centerLng; int? get radiusMeters;
/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceAreaCopyWith<ServiceArea> get copyWith => _$ServiceAreaCopyWithImpl<ServiceArea>(this as ServiceArea, _$identity);

  /// Serializes this ServiceArea to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceArea;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceArea&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.centerLat, _this.centerLat) || other.centerLat == _this.centerLat)&&(identical(other.centerLng, _this.centerLng) || other.centerLng == _this.centerLng)&&(identical(other.radiusMeters, _this.radiusMeters) || other.radiusMeters == _this.radiusMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceArea;
  return Object.hash(runtimeType,_this.id,_this.name,_this.isActive,_this.centerLat,_this.centerLng,_this.radiusMeters);
}

@override
String toString() {
  final _this = this as ServiceArea;
  return 'ServiceArea(id: ${_this.id}, name: ${_this.name}, isActive: ${_this.isActive}, centerLat: ${_this.centerLat}, centerLng: ${_this.centerLng}, radiusMeters: ${_this.radiusMeters})';
}


}

/// @nodoc
abstract mixin class $ServiceAreaCopyWith<$Res>  {
  factory $ServiceAreaCopyWith(ServiceArea value, $Res Function(ServiceArea) _then) = _$ServiceAreaCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isActive, double? centerLat, double? centerLng, int? radiusMeters
});




}
/// @nodoc
class _$ServiceAreaCopyWithImpl<$Res>
    implements $ServiceAreaCopyWith<$Res> {
  _$ServiceAreaCopyWithImpl(this._self, this._then);

  final ServiceArea _self;
  final $Res Function(ServiceArea) _then;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isActive = null,Object? centerLat = freezed,Object? centerLng = freezed,Object? radiusMeters = freezed,}) {
  return _then(ServiceArea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,centerLat: freezed == centerLat ? _self.centerLat : centerLat // ignore: cast_nullable_to_non_nullable
as double?,centerLng: freezed == centerLng ? _self.centerLng : centerLng // ignore: cast_nullable_to_non_nullable
as double?,radiusMeters: freezed == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceArea].
extension ServiceAreaPatterns on ServiceArea {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceArea value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceArea value)  $default,){
final _that = this;
switch (_that) {
case _ServiceArea():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceArea value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isActive,  double? centerLat,  double? centerLng,  int? radiusMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
return $default(_that.id,_that.name,_that.isActive,_that.centerLat,_that.centerLng,_that.radiusMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isActive,  double? centerLat,  double? centerLng,  int? radiusMeters)  $default,) {final _that = this;
switch (_that) {
case _ServiceArea():
return $default(_that.id,_that.name,_that.isActive,_that.centerLat,_that.centerLng,_that.radiusMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isActive,  double? centerLat,  double? centerLng,  int? radiusMeters)?  $default,) {final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
return $default(_that.id,_that.name,_that.isActive,_that.centerLat,_that.centerLng,_that.radiusMeters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceArea implements ServiceArea {
   _ServiceArea({required this.id, required this.name, this.isActive = true, this.centerLat, this.centerLng, this.radiusMeters});
  factory _ServiceArea.fromJson(Map<String, dynamic> json) => _$ServiceAreaFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool isActive;
@override final  double? centerLat;
@override final  double? centerLng;
@override final  int? radiusMeters;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceAreaCopyWith<_ServiceArea> get copyWith => __$ServiceAreaCopyWithImpl<_ServiceArea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceAreaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceArea&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.centerLat, centerLat) || other.centerLat == centerLat)&&(identical(other.centerLng, centerLng) || other.centerLng == centerLng)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,isActive,centerLat,centerLng,radiusMeters);
}

@override
String toString() {
    return 'ServiceArea(id: $id, name: $name, isActive: $isActive, centerLat: $centerLat, centerLng: $centerLng, radiusMeters: $radiusMeters)';
}


}

/// @nodoc
abstract mixin class _$ServiceAreaCopyWith<$Res> implements $ServiceAreaCopyWith<$Res> {
  factory _$ServiceAreaCopyWith(_ServiceArea value, $Res Function(_ServiceArea) _then) = __$ServiceAreaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isActive, double? centerLat, double? centerLng, int? radiusMeters
});




}
/// @nodoc
class __$ServiceAreaCopyWithImpl<$Res>
    implements _$ServiceAreaCopyWith<$Res> {
  __$ServiceAreaCopyWithImpl(this._self, this._then);

  final _ServiceArea _self;
  final $Res Function(_ServiceArea) _then;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isActive = null,Object? centerLat = freezed,Object? centerLng = freezed,Object? radiusMeters = freezed,}) {
  return _then(_ServiceArea(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,centerLat: freezed == centerLat ? _self.centerLat : centerLat // ignore: cast_nullable_to_non_nullable
as double?,centerLng: freezed == centerLng ? _self.centerLng : centerLng // ignore: cast_nullable_to_non_nullable
as double?,radiusMeters: freezed == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
