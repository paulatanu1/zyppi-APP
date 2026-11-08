// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_section_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeSectionItem {

 String get id; Map<String, dynamic> get data;
/// Create a copy of HomeSectionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSectionItemCopyWith<HomeSectionItem> get copyWith => _$HomeSectionItemCopyWithImpl<HomeSectionItem>(this as HomeSectionItem, _$identity);

  /// Serializes this HomeSectionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as HomeSectionItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSectionItem&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as HomeSectionItem;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as HomeSectionItem;
  return 'HomeSectionItem(id: ${_this.id}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $HomeSectionItemCopyWith<$Res>  {
  factory $HomeSectionItemCopyWith(HomeSectionItem value, $Res Function(HomeSectionItem) _then) = _$HomeSectionItemCopyWithImpl;
@useResult
$Res call({
 String id, Map<String, dynamic> data
});




}
/// @nodoc
class _$HomeSectionItemCopyWithImpl<$Res>
    implements $HomeSectionItemCopyWith<$Res> {
  _$HomeSectionItemCopyWithImpl(this._self, this._then);

  final HomeSectionItem _self;
  final $Res Function(HomeSectionItem) _then;

/// Create a copy of HomeSectionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? data = null,}) {
  return _then(HomeSectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSectionItem].
extension HomeSectionItemPatterns on HomeSectionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSectionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSectionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSectionItem value)  $default,){
final _that = this;
switch (_that) {
case _HomeSectionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSectionItem value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSectionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSectionItem() when $default != null:
return $default(_that.id,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _HomeSectionItem():
return $default(_that.id,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _HomeSectionItem() when $default != null:
return $default(_that.id,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSectionItem implements HomeSectionItem {
   _HomeSectionItem({required this.id, required  Map<String, dynamic> data}): _data = data;
  factory _HomeSectionItem.fromJson(Map<String, dynamic> json) => _$HomeSectionItemFromJson(json);

@override final  String id;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of HomeSectionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSectionItemCopyWith<_HomeSectionItem> get copyWith => __$HomeSectionItemCopyWithImpl<_HomeSectionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSectionItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSectionItem&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'HomeSectionItem(id: $id, data: $data)';
}


}

/// @nodoc
abstract mixin class _$HomeSectionItemCopyWith<$Res> implements $HomeSectionItemCopyWith<$Res> {
  factory _$HomeSectionItemCopyWith(_HomeSectionItem value, $Res Function(_HomeSectionItem) _then) = __$HomeSectionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, Map<String, dynamic> data
});




}
/// @nodoc
class __$HomeSectionItemCopyWithImpl<$Res>
    implements _$HomeSectionItemCopyWith<$Res> {
  __$HomeSectionItemCopyWithImpl(this._self, this._then);

  final _HomeSectionItem _self;
  final $Res Function(_HomeSectionItem) _then;

/// Create a copy of HomeSectionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? data = null,}) {
  return _then(_HomeSectionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
