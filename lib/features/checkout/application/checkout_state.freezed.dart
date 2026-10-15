// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckoutState {

 List<Address> get addresses; Address? get selectedAddress; List<DeliverySlot> get slots; DeliverySlot? get selectedSlot; String get paymentMethod; bool get loading; bool get placingOrder; String? get placedOrderId; String? get error; String? get paymentError;
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutStateCopyWith<CheckoutState> get copyWith => _$CheckoutStateCopyWithImpl<CheckoutState>(this as CheckoutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CheckoutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutState&&const DeepCollectionEquality().equals(other.addresses, _this.addresses)&&(identical(other.selectedAddress, _this.selectedAddress) || other.selectedAddress == _this.selectedAddress)&&const DeepCollectionEquality().equals(other.slots, _this.slots)&&(identical(other.selectedSlot, _this.selectedSlot) || other.selectedSlot == _this.selectedSlot)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.placingOrder, _this.placingOrder) || other.placingOrder == _this.placingOrder)&&(identical(other.placedOrderId, _this.placedOrderId) || other.placedOrderId == _this.placedOrderId)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.paymentError, _this.paymentError) || other.paymentError == _this.paymentError));
}


@override
int get hashCode {
  final _this = this as CheckoutState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.addresses),_this.selectedAddress,const DeepCollectionEquality().hash(_this.slots),_this.selectedSlot,_this.paymentMethod,_this.loading,_this.placingOrder,_this.placedOrderId,_this.error,_this.paymentError);
}

@override
String toString() {
  final _this = this as CheckoutState;
  return 'CheckoutState(addresses: ${_this.addresses}, selectedAddress: ${_this.selectedAddress}, slots: ${_this.slots}, selectedSlot: ${_this.selectedSlot}, paymentMethod: ${_this.paymentMethod}, loading: ${_this.loading}, placingOrder: ${_this.placingOrder}, placedOrderId: ${_this.placedOrderId}, error: ${_this.error}, paymentError: ${_this.paymentError})';
}


}

/// @nodoc
abstract mixin class $CheckoutStateCopyWith<$Res>  {
  factory $CheckoutStateCopyWith(CheckoutState value, $Res Function(CheckoutState) _then) = _$CheckoutStateCopyWithImpl;
@useResult
$Res call({
 List<Address> addresses, Address? selectedAddress, List<DeliverySlot> slots, DeliverySlot? selectedSlot, String paymentMethod, bool loading, bool placingOrder, String? placedOrderId, String? error, String? paymentError
});


$AddressCopyWith<$Res>? get selectedAddress;$DeliverySlotCopyWith<$Res>? get selectedSlot;

}
/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._self, this._then);

  final CheckoutState _self;
  final $Res Function(CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addresses = null,Object? selectedAddress = freezed,Object? slots = null,Object? selectedSlot = freezed,Object? paymentMethod = null,Object? loading = null,Object? placingOrder = null,Object? placedOrderId = freezed,Object? error = freezed,Object? paymentError = freezed,}) {
  return _then(CheckoutState(
addresses: null == addresses ? _self.addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<Address>,selectedAddress: freezed == selectedAddress ? _self.selectedAddress : selectedAddress // ignore: cast_nullable_to_non_nullable
as Address?,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<DeliverySlot>,selectedSlot: freezed == selectedSlot ? _self.selectedSlot : selectedSlot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,placingOrder: null == placingOrder ? _self.placingOrder : placingOrder // ignore: cast_nullable_to_non_nullable
as bool,placedOrderId: freezed == placedOrderId ? _self.placedOrderId : placedOrderId // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,paymentError: freezed == paymentError ? _self.paymentError : paymentError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get selectedAddress {
    if (_self.selectedAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.selectedAddress!, (value) {
    return _then(_self.copyWith(selectedAddress: value));
  });
}/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliverySlotCopyWith<$Res>? get selectedSlot {
    if (_self.selectedSlot == null) {
    return null;
  }

  return $DeliverySlotCopyWith<$Res>(_self.selectedSlot!, (value) {
    return _then(_self.copyWith(selectedSlot: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutState value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Address> addresses,  Address? selectedAddress,  List<DeliverySlot> slots,  DeliverySlot? selectedSlot,  String paymentMethod,  bool loading,  bool placingOrder,  String? placedOrderId,  String? error,  String? paymentError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.addresses,_that.selectedAddress,_that.slots,_that.selectedSlot,_that.paymentMethod,_that.loading,_that.placingOrder,_that.placedOrderId,_that.error,_that.paymentError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Address> addresses,  Address? selectedAddress,  List<DeliverySlot> slots,  DeliverySlot? selectedSlot,  String paymentMethod,  bool loading,  bool placingOrder,  String? placedOrderId,  String? error,  String? paymentError)  $default,) {final _that = this;
switch (_that) {
case _CheckoutState():
return $default(_that.addresses,_that.selectedAddress,_that.slots,_that.selectedSlot,_that.paymentMethod,_that.loading,_that.placingOrder,_that.placedOrderId,_that.error,_that.paymentError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Address> addresses,  Address? selectedAddress,  List<DeliverySlot> slots,  DeliverySlot? selectedSlot,  String paymentMethod,  bool loading,  bool placingOrder,  String? placedOrderId,  String? error,  String? paymentError)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutState() when $default != null:
return $default(_that.addresses,_that.selectedAddress,_that.slots,_that.selectedSlot,_that.paymentMethod,_that.loading,_that.placingOrder,_that.placedOrderId,_that.error,_that.paymentError);case _:
  return null;

}
}

}

/// @nodoc


class _CheckoutState implements CheckoutState {
   _CheckoutState({ List<Address> addresses = const [], this.selectedAddress,  List<DeliverySlot> slots = const [], this.selectedSlot, this.paymentMethod = 'UPI', this.loading = true, this.placingOrder = false, this.placedOrderId, this.error, this.paymentError}): _addresses = addresses,_slots = slots;
  

 final  List<Address> _addresses;
@override@JsonKey() List<Address> get addresses {
  if (_addresses is EqualUnmodifiableListView) return _addresses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addresses);
}

@override final  Address? selectedAddress;
 final  List<DeliverySlot> _slots;
@override@JsonKey() List<DeliverySlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}

@override final  DeliverySlot? selectedSlot;
@override@JsonKey() final  String paymentMethod;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool placingOrder;
@override final  String? placedOrderId;
@override final  String? error;
@override final  String? paymentError;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutStateCopyWith<_CheckoutState> get copyWith => __$CheckoutStateCopyWithImpl<_CheckoutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutState&&const DeepCollectionEquality().equals(other.addresses, _addresses)&&(identical(other.selectedAddress, selectedAddress) || other.selectedAddress == selectedAddress)&&const DeepCollectionEquality().equals(other.slots, _slots)&&(identical(other.selectedSlot, selectedSlot) || other.selectedSlot == selectedSlot)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.placingOrder, placingOrder) || other.placingOrder == placingOrder)&&(identical(other.placedOrderId, placedOrderId) || other.placedOrderId == placedOrderId)&&(identical(other.error, error) || other.error == error)&&(identical(other.paymentError, paymentError) || other.paymentError == paymentError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_addresses),selectedAddress,const DeepCollectionEquality().hash(_slots),selectedSlot,paymentMethod,loading,placingOrder,placedOrderId,error,paymentError);
}

@override
String toString() {
    return 'CheckoutState(addresses: $addresses, selectedAddress: $selectedAddress, slots: $slots, selectedSlot: $selectedSlot, paymentMethod: $paymentMethod, loading: $loading, placingOrder: $placingOrder, placedOrderId: $placedOrderId, error: $error, paymentError: $paymentError)';
}


}

/// @nodoc
abstract mixin class _$CheckoutStateCopyWith<$Res> implements $CheckoutStateCopyWith<$Res> {
  factory _$CheckoutStateCopyWith(_CheckoutState value, $Res Function(_CheckoutState) _then) = __$CheckoutStateCopyWithImpl;
@override @useResult
$Res call({
 List<Address> addresses, Address? selectedAddress, List<DeliverySlot> slots, DeliverySlot? selectedSlot, String paymentMethod, bool loading, bool placingOrder, String? placedOrderId, String? error, String? paymentError
});


@override $AddressCopyWith<$Res>? get selectedAddress;@override $DeliverySlotCopyWith<$Res>? get selectedSlot;

}
/// @nodoc
class __$CheckoutStateCopyWithImpl<$Res>
    implements _$CheckoutStateCopyWith<$Res> {
  __$CheckoutStateCopyWithImpl(this._self, this._then);

  final _CheckoutState _self;
  final $Res Function(_CheckoutState) _then;

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addresses = null,Object? selectedAddress = freezed,Object? slots = null,Object? selectedSlot = freezed,Object? paymentMethod = null,Object? loading = null,Object? placingOrder = null,Object? placedOrderId = freezed,Object? error = freezed,Object? paymentError = freezed,}) {
  return _then(_CheckoutState(
addresses: null == addresses ? _self._addresses : addresses // ignore: cast_nullable_to_non_nullable
as List<Address>,selectedAddress: freezed == selectedAddress ? _self.selectedAddress : selectedAddress // ignore: cast_nullable_to_non_nullable
as Address?,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<DeliverySlot>,selectedSlot: freezed == selectedSlot ? _self.selectedSlot : selectedSlot // ignore: cast_nullable_to_non_nullable
as DeliverySlot?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,placingOrder: null == placingOrder ? _self.placingOrder : placingOrder // ignore: cast_nullable_to_non_nullable
as bool,placedOrderId: freezed == placedOrderId ? _self.placedOrderId : placedOrderId // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,paymentError: freezed == paymentError ? _self.paymentError : paymentError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressCopyWith<$Res>? get selectedAddress {
    if (_self.selectedAddress == null) {
    return null;
  }

  return $AddressCopyWith<$Res>(_self.selectedAddress!, (value) {
    return _then(_self.copyWith(selectedAddress: value));
  });
}/// Create a copy of CheckoutState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliverySlotCopyWith<$Res>? get selectedSlot {
    if (_self.selectedSlot == null) {
    return null;
  }

  return $DeliverySlotCopyWith<$Res>(_self.selectedSlot!, (value) {
    return _then(_self.copyWith(selectedSlot: value));
  });
}
}

// dart format on
