// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderTrackingState {

 Order? get order; bool get loading; String? get error;
/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingStateCopyWith<OrderTrackingState> get copyWith => _$OrderTrackingStateCopyWithImpl<OrderTrackingState>(this as OrderTrackingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderTrackingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackingState&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as OrderTrackingState;
  return Object.hash(runtimeType,_this.order,_this.loading,_this.error);
}

@override
String toString() {
  final _this = this as OrderTrackingState;
  return 'OrderTrackingState(order: ${_this.order}, loading: ${_this.loading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $OrderTrackingStateCopyWith<$Res>  {
  factory $OrderTrackingStateCopyWith(OrderTrackingState value, $Res Function(OrderTrackingState) _then) = _$OrderTrackingStateCopyWithImpl;
@useResult
$Res call({
 Order? order, bool loading, String? error
});


$OrderCopyWith<$Res>? get order;

}
/// @nodoc
class _$OrderTrackingStateCopyWithImpl<$Res>
    implements $OrderTrackingStateCopyWith<$Res> {
  _$OrderTrackingStateCopyWithImpl(this._self, this._then);

  final OrderTrackingState _self;
  final $Res Function(OrderTrackingState) _then;

/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = freezed,Object? loading = null,Object? error = freezed,}) {
  return _then(OrderTrackingState(
order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $OrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderTrackingState].
extension OrderTrackingStatePatterns on OrderTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTrackingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Order? order,  bool loading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTrackingState() when $default != null:
return $default(_that.order,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Order? order,  bool loading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingState():
return $default(_that.order,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Order? order,  bool loading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingState() when $default != null:
return $default(_that.order,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _OrderTrackingState implements OrderTrackingState {
   _OrderTrackingState({this.order, this.loading = true, this.error});
  

@override final  Order? order;
@override@JsonKey() final  bool loading;
@override final  String? error;

/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingStateCopyWith<_OrderTrackingState> get copyWith => __$OrderTrackingStateCopyWithImpl<_OrderTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTrackingState&&(identical(other.order, order) || other.order == order)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,order,loading,error);
}

@override
String toString() {
    return 'OrderTrackingState(order: $order, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingStateCopyWith<$Res> implements $OrderTrackingStateCopyWith<$Res> {
  factory _$OrderTrackingStateCopyWith(_OrderTrackingState value, $Res Function(_OrderTrackingState) _then) = __$OrderTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 Order? order, bool loading, String? error
});


@override $OrderCopyWith<$Res>? get order;

}
/// @nodoc
class __$OrderTrackingStateCopyWithImpl<$Res>
    implements _$OrderTrackingStateCopyWith<$Res> {
  __$OrderTrackingStateCopyWithImpl(this._self, this._then);

  final _OrderTrackingState _self;
  final $Res Function(_OrderTrackingState) _then;

/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = freezed,Object? loading = null,Object? error = freezed,}) {
  return _then(_OrderTrackingState(
order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OrderTrackingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $OrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}

// dart format on
