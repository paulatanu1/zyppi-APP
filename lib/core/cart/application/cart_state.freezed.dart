// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartState {

 List<CartLine> get lines; int get tipPaise; Coupon? get appliedCoupon; String? get couponError; BillBreakdown get bill;/// Delivery fee / free-delivery threshold / minimum order in force.
 DeliveryConfig get delivery; bool get loading; String? get error;
/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartStateCopyWith<CartState> get copyWith => _$CartStateCopyWithImpl<CartState>(this as CartState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartState&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.tipPaise, _this.tipPaise) || other.tipPaise == _this.tipPaise)&&(identical(other.appliedCoupon, _this.appliedCoupon) || other.appliedCoupon == _this.appliedCoupon)&&(identical(other.couponError, _this.couponError) || other.couponError == _this.couponError)&&(identical(other.bill, _this.bill) || other.bill == _this.bill)&&(identical(other.delivery, _this.delivery) || other.delivery == _this.delivery)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CartState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.tipPaise,_this.appliedCoupon,_this.couponError,_this.bill,_this.delivery,_this.loading,_this.error);
}

@override
String toString() {
  final _this = this as CartState;
  return 'CartState(lines: ${_this.lines}, tipPaise: ${_this.tipPaise}, appliedCoupon: ${_this.appliedCoupon}, couponError: ${_this.couponError}, bill: ${_this.bill}, delivery: ${_this.delivery}, loading: ${_this.loading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CartStateCopyWith<$Res>  {
  factory $CartStateCopyWith(CartState value, $Res Function(CartState) _then) = _$CartStateCopyWithImpl;
@useResult
$Res call({
 List<CartLine> lines, int tipPaise, Coupon? appliedCoupon, String? couponError, BillBreakdown bill, DeliveryConfig delivery, bool loading, String? error
});


$CouponCopyWith<$Res>? get appliedCoupon;$BillBreakdownCopyWith<$Res> get bill;$DeliveryConfigCopyWith<$Res> get delivery;

}
/// @nodoc
class _$CartStateCopyWithImpl<$Res>
    implements $CartStateCopyWith<$Res> {
  _$CartStateCopyWithImpl(this._self, this._then);

  final CartState _self;
  final $Res Function(CartState) _then;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? tipPaise = null,Object? appliedCoupon = freezed,Object? couponError = freezed,Object? bill = null,Object? delivery = null,Object? loading = null,Object? error = freezed,}) {
  return _then(CartState(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,appliedCoupon: freezed == appliedCoupon ? _self.appliedCoupon : appliedCoupon // ignore: cast_nullable_to_non_nullable
as Coupon?,couponError: freezed == couponError ? _self.couponError : couponError // ignore: cast_nullable_to_non_nullable
as String?,bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as BillBreakdown,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryConfig,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponCopyWith<$Res>? get appliedCoupon {
    if (_self.appliedCoupon == null) {
    return null;
  }

  return $CouponCopyWith<$Res>(_self.appliedCoupon!, (value) {
    return _then(_self.copyWith(appliedCoupon: value));
  });
}/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillBreakdownCopyWith<$Res> get bill {
  
  return $BillBreakdownCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryConfigCopyWith<$Res> get delivery {
  
  return $DeliveryConfigCopyWith<$Res>(_self.delivery, (value) {
    return _then(_self.copyWith(delivery: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartState].
extension CartStatePatterns on CartState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartState value)  $default,){
final _that = this;
switch (_that) {
case _CartState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartState value)?  $default,){
final _that = this;
switch (_that) {
case _CartState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CartLine> lines,  int tipPaise,  Coupon? appliedCoupon,  String? couponError,  BillBreakdown bill,  DeliveryConfig delivery,  bool loading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that.lines,_that.tipPaise,_that.appliedCoupon,_that.couponError,_that.bill,_that.delivery,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CartLine> lines,  int tipPaise,  Coupon? appliedCoupon,  String? couponError,  BillBreakdown bill,  DeliveryConfig delivery,  bool loading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CartState():
return $default(_that.lines,_that.tipPaise,_that.appliedCoupon,_that.couponError,_that.bill,_that.delivery,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CartLine> lines,  int tipPaise,  Coupon? appliedCoupon,  String? couponError,  BillBreakdown bill,  DeliveryConfig delivery,  bool loading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CartState() when $default != null:
return $default(_that.lines,_that.tipPaise,_that.appliedCoupon,_that.couponError,_that.bill,_that.delivery,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CartState implements CartState {
   _CartState({ List<CartLine> lines = const [], this.tipPaise = 0, this.appliedCoupon, this.couponError, this.bill = BillBreakdown.zero, this.delivery = DeliveryConfig.free, this.loading = true, this.error}): _lines = lines;
  

 final  List<CartLine> _lines;
@override@JsonKey() List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  int tipPaise;
@override final  Coupon? appliedCoupon;
@override final  String? couponError;
@override@JsonKey() final  BillBreakdown bill;
/// Delivery fee / free-delivery threshold / minimum order in force.
@override@JsonKey() final  DeliveryConfig delivery;
@override@JsonKey() final  bool loading;
@override final  String? error;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartStateCopyWith<_CartState> get copyWith => __$CartStateCopyWithImpl<_CartState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartState&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.tipPaise, tipPaise) || other.tipPaise == tipPaise)&&(identical(other.appliedCoupon, appliedCoupon) || other.appliedCoupon == appliedCoupon)&&(identical(other.couponError, couponError) || other.couponError == couponError)&&(identical(other.bill, bill) || other.bill == bill)&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),tipPaise,appliedCoupon,couponError,bill,delivery,loading,error);
}

@override
String toString() {
    return 'CartState(lines: $lines, tipPaise: $tipPaise, appliedCoupon: $appliedCoupon, couponError: $couponError, bill: $bill, delivery: $delivery, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CartStateCopyWith<$Res> implements $CartStateCopyWith<$Res> {
  factory _$CartStateCopyWith(_CartState value, $Res Function(_CartState) _then) = __$CartStateCopyWithImpl;
@override @useResult
$Res call({
 List<CartLine> lines, int tipPaise, Coupon? appliedCoupon, String? couponError, BillBreakdown bill, DeliveryConfig delivery, bool loading, String? error
});


@override $CouponCopyWith<$Res>? get appliedCoupon;@override $BillBreakdownCopyWith<$Res> get bill;@override $DeliveryConfigCopyWith<$Res> get delivery;

}
/// @nodoc
class __$CartStateCopyWithImpl<$Res>
    implements _$CartStateCopyWith<$Res> {
  __$CartStateCopyWithImpl(this._self, this._then);

  final _CartState _self;
  final $Res Function(_CartState) _then;

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? tipPaise = null,Object? appliedCoupon = freezed,Object? couponError = freezed,Object? bill = null,Object? delivery = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_CartState(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,appliedCoupon: freezed == appliedCoupon ? _self.appliedCoupon : appliedCoupon // ignore: cast_nullable_to_non_nullable
as Coupon?,couponError: freezed == couponError ? _self.couponError : couponError // ignore: cast_nullable_to_non_nullable
as String?,bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as BillBreakdown,delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryConfig,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CouponCopyWith<$Res>? get appliedCoupon {
    if (_self.appliedCoupon == null) {
    return null;
  }

  return $CouponCopyWith<$Res>(_self.appliedCoupon!, (value) {
    return _then(_self.copyWith(appliedCoupon: value));
  });
}/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillBreakdownCopyWith<$Res> get bill {
  
  return $BillBreakdownCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}/// Create a copy of CartState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryConfigCopyWith<$Res> get delivery {
  
  return $DeliveryConfigCopyWith<$Res>(_self.delivery, (value) {
    return _then(_self.copyWith(delivery: value));
  });
}
}

// dart format on
