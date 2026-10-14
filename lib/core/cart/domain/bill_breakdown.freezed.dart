// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillBreakdown {

 int get itemTotalPaise; int get savingsPaise; int get deliveryFeePaise; int get handlingFeePaise; int get tipPaise; int get discountPaise; int get totalPaise;
/// Create a copy of BillBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillBreakdownCopyWith<BillBreakdown> get copyWith => _$BillBreakdownCopyWithImpl<BillBreakdown>(this as BillBreakdown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BillBreakdown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillBreakdown&&(identical(other.itemTotalPaise, _this.itemTotalPaise) || other.itemTotalPaise == _this.itemTotalPaise)&&(identical(other.savingsPaise, _this.savingsPaise) || other.savingsPaise == _this.savingsPaise)&&(identical(other.deliveryFeePaise, _this.deliveryFeePaise) || other.deliveryFeePaise == _this.deliveryFeePaise)&&(identical(other.handlingFeePaise, _this.handlingFeePaise) || other.handlingFeePaise == _this.handlingFeePaise)&&(identical(other.tipPaise, _this.tipPaise) || other.tipPaise == _this.tipPaise)&&(identical(other.discountPaise, _this.discountPaise) || other.discountPaise == _this.discountPaise)&&(identical(other.totalPaise, _this.totalPaise) || other.totalPaise == _this.totalPaise));
}


@override
int get hashCode {
  final _this = this as BillBreakdown;
  return Object.hash(runtimeType,_this.itemTotalPaise,_this.savingsPaise,_this.deliveryFeePaise,_this.handlingFeePaise,_this.tipPaise,_this.discountPaise,_this.totalPaise);
}

@override
String toString() {
  final _this = this as BillBreakdown;
  return 'BillBreakdown(itemTotalPaise: ${_this.itemTotalPaise}, savingsPaise: ${_this.savingsPaise}, deliveryFeePaise: ${_this.deliveryFeePaise}, handlingFeePaise: ${_this.handlingFeePaise}, tipPaise: ${_this.tipPaise}, discountPaise: ${_this.discountPaise}, totalPaise: ${_this.totalPaise})';
}


}

/// @nodoc
abstract mixin class $BillBreakdownCopyWith<$Res>  {
  factory $BillBreakdownCopyWith(BillBreakdown value, $Res Function(BillBreakdown) _then) = _$BillBreakdownCopyWithImpl;
@useResult
$Res call({
 int itemTotalPaise, int savingsPaise, int deliveryFeePaise, int handlingFeePaise, int tipPaise, int discountPaise, int totalPaise
});




}
/// @nodoc
class _$BillBreakdownCopyWithImpl<$Res>
    implements $BillBreakdownCopyWith<$Res> {
  _$BillBreakdownCopyWithImpl(this._self, this._then);

  final BillBreakdown _self;
  final $Res Function(BillBreakdown) _then;

/// Create a copy of BillBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemTotalPaise = null,Object? savingsPaise = null,Object? deliveryFeePaise = null,Object? handlingFeePaise = null,Object? tipPaise = null,Object? discountPaise = null,Object? totalPaise = null,}) {
  return _then(BillBreakdown(
itemTotalPaise: null == itemTotalPaise ? _self.itemTotalPaise : itemTotalPaise // ignore: cast_nullable_to_non_nullable
as int,savingsPaise: null == savingsPaise ? _self.savingsPaise : savingsPaise // ignore: cast_nullable_to_non_nullable
as int,deliveryFeePaise: null == deliveryFeePaise ? _self.deliveryFeePaise : deliveryFeePaise // ignore: cast_nullable_to_non_nullable
as int,handlingFeePaise: null == handlingFeePaise ? _self.handlingFeePaise : handlingFeePaise // ignore: cast_nullable_to_non_nullable
as int,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,discountPaise: null == discountPaise ? _self.discountPaise : discountPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BillBreakdown].
extension BillBreakdownPatterns on BillBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _BillBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _BillBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int itemTotalPaise,  int savingsPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillBreakdown() when $default != null:
return $default(_that.itemTotalPaise,_that.savingsPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int itemTotalPaise,  int savingsPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise)  $default,) {final _that = this;
switch (_that) {
case _BillBreakdown():
return $default(_that.itemTotalPaise,_that.savingsPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int itemTotalPaise,  int savingsPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise)?  $default,) {final _that = this;
switch (_that) {
case _BillBreakdown() when $default != null:
return $default(_that.itemTotalPaise,_that.savingsPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise);case _:
  return null;

}
}

}

/// @nodoc


class _BillBreakdown extends BillBreakdown {
  const _BillBreakdown({required this.itemTotalPaise, required this.savingsPaise, required this.deliveryFeePaise, required this.handlingFeePaise, required this.tipPaise, required this.discountPaise, required this.totalPaise}): super._();
  

@override final  int itemTotalPaise;
@override final  int savingsPaise;
@override final  int deliveryFeePaise;
@override final  int handlingFeePaise;
@override final  int tipPaise;
@override final  int discountPaise;
@override final  int totalPaise;

/// Create a copy of BillBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillBreakdownCopyWith<_BillBreakdown> get copyWith => __$BillBreakdownCopyWithImpl<_BillBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillBreakdown&&(identical(other.itemTotalPaise, itemTotalPaise) || other.itemTotalPaise == itemTotalPaise)&&(identical(other.savingsPaise, savingsPaise) || other.savingsPaise == savingsPaise)&&(identical(other.deliveryFeePaise, deliveryFeePaise) || other.deliveryFeePaise == deliveryFeePaise)&&(identical(other.handlingFeePaise, handlingFeePaise) || other.handlingFeePaise == handlingFeePaise)&&(identical(other.tipPaise, tipPaise) || other.tipPaise == tipPaise)&&(identical(other.discountPaise, discountPaise) || other.discountPaise == discountPaise)&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemTotalPaise,savingsPaise,deliveryFeePaise,handlingFeePaise,tipPaise,discountPaise,totalPaise);
}

@override
String toString() {
    return 'BillBreakdown(itemTotalPaise: $itemTotalPaise, savingsPaise: $savingsPaise, deliveryFeePaise: $deliveryFeePaise, handlingFeePaise: $handlingFeePaise, tipPaise: $tipPaise, discountPaise: $discountPaise, totalPaise: $totalPaise)';
}


}

/// @nodoc
abstract mixin class _$BillBreakdownCopyWith<$Res> implements $BillBreakdownCopyWith<$Res> {
  factory _$BillBreakdownCopyWith(_BillBreakdown value, $Res Function(_BillBreakdown) _then) = __$BillBreakdownCopyWithImpl;
@override @useResult
$Res call({
 int itemTotalPaise, int savingsPaise, int deliveryFeePaise, int handlingFeePaise, int tipPaise, int discountPaise, int totalPaise
});




}
/// @nodoc
class __$BillBreakdownCopyWithImpl<$Res>
    implements _$BillBreakdownCopyWith<$Res> {
  __$BillBreakdownCopyWithImpl(this._self, this._then);

  final _BillBreakdown _self;
  final $Res Function(_BillBreakdown) _then;

/// Create a copy of BillBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemTotalPaise = null,Object? savingsPaise = null,Object? deliveryFeePaise = null,Object? handlingFeePaise = null,Object? tipPaise = null,Object? discountPaise = null,Object? totalPaise = null,}) {
  return _then(_BillBreakdown(
itemTotalPaise: null == itemTotalPaise ? _self.itemTotalPaise : itemTotalPaise // ignore: cast_nullable_to_non_nullable
as int,savingsPaise: null == savingsPaise ? _self.savingsPaise : savingsPaise // ignore: cast_nullable_to_non_nullable
as int,deliveryFeePaise: null == deliveryFeePaise ? _self.deliveryFeePaise : deliveryFeePaise // ignore: cast_nullable_to_non_nullable
as int,handlingFeePaise: null == handlingFeePaise ? _self.handlingFeePaise : handlingFeePaise // ignore: cast_nullable_to_non_nullable
as int,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,discountPaise: null == discountPaise ? _self.discountPaise : discountPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
