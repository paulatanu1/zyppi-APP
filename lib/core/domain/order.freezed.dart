// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id; List<OrderItem> get items; OrderStatus get status; DateTime get placedAt; int get itemTotalPaise; int get deliveryFeePaise; int get handlingFeePaise; int get tipPaise; int get discountPaise; int get totalPaise; String? get addressId; String get paymentMethod;/// Address snapshot taken when the order was placed.
 String? get addressLabel; String? get addressText;/// Set by the store once a rider is assigned (tracking screen).
 String? get riderName; String? get riderPhone;/// The chosen delivery slot's promise, for the tracking ETA.
 int? get etaMinutes;/// Wallet (docs/WALLET.md): what the wallet paid; the rest
/// ([payablePaise]) was paid online or is cash at the door.
 int get walletPaise; int? get payablePaise;/// When it was delivered ("Report a problem" is open for 2 hours).
 DateTime? get deliveredAt;/// The claim under review on this order, if any.
 String? get openIssueId;/// Units already claimed per line (item index → units).
 Map<String, int> get claimedQty;/// Set on a free replacement: the order it replaces.
 String? get replacementOf;/// Online refund to the customer's bank or UPI, mirrored by the server
/// (functions/src/payments/refunds.ts): requesting → requested →
/// succeeded, or failed. Null when nothing was refunded online.
 String? get refundStatus;/// Paise refunded online so far.
 int? get refundedPaise;/// Items a shop couldn't supply, dropped from the order after it was
/// placed (functions/src/orders/partial_cancel.ts). Empty usually.
 List<String> get removedItemNames;/// What came back for [removedItemNames] (refund, wallet or less cash).
 int get removedValuePaise;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&(identical(other.itemTotalPaise, _this.itemTotalPaise) || other.itemTotalPaise == _this.itemTotalPaise)&&(identical(other.deliveryFeePaise, _this.deliveryFeePaise) || other.deliveryFeePaise == _this.deliveryFeePaise)&&(identical(other.handlingFeePaise, _this.handlingFeePaise) || other.handlingFeePaise == _this.handlingFeePaise)&&(identical(other.tipPaise, _this.tipPaise) || other.tipPaise == _this.tipPaise)&&(identical(other.discountPaise, _this.discountPaise) || other.discountPaise == _this.discountPaise)&&(identical(other.totalPaise, _this.totalPaise) || other.totalPaise == _this.totalPaise)&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.addressLabel, _this.addressLabel) || other.addressLabel == _this.addressLabel)&&(identical(other.addressText, _this.addressText) || other.addressText == _this.addressText)&&(identical(other.riderName, _this.riderName) || other.riderName == _this.riderName)&&(identical(other.riderPhone, _this.riderPhone) || other.riderPhone == _this.riderPhone)&&(identical(other.etaMinutes, _this.etaMinutes) || other.etaMinutes == _this.etaMinutes)&&(identical(other.walletPaise, _this.walletPaise) || other.walletPaise == _this.walletPaise)&&(identical(other.payablePaise, _this.payablePaise) || other.payablePaise == _this.payablePaise)&&(identical(other.deliveredAt, _this.deliveredAt) || other.deliveredAt == _this.deliveredAt)&&(identical(other.openIssueId, _this.openIssueId) || other.openIssueId == _this.openIssueId)&&const DeepCollectionEquality().equals(other.claimedQty, _this.claimedQty)&&(identical(other.replacementOf, _this.replacementOf) || other.replacementOf == _this.replacementOf)&&(identical(other.refundStatus, _this.refundStatus) || other.refundStatus == _this.refundStatus)&&(identical(other.refundedPaise, _this.refundedPaise) || other.refundedPaise == _this.refundedPaise)&&const DeepCollectionEquality().equals(other.removedItemNames, _this.removedItemNames)&&(identical(other.removedValuePaise, _this.removedValuePaise) || other.removedValuePaise == _this.removedValuePaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Order;
  return Object.hashAll([runtimeType,_this.id,const DeepCollectionEquality().hash(_this.items),_this.status,_this.placedAt,_this.itemTotalPaise,_this.deliveryFeePaise,_this.handlingFeePaise,_this.tipPaise,_this.discountPaise,_this.totalPaise,_this.addressId,_this.paymentMethod,_this.addressLabel,_this.addressText,_this.riderName,_this.riderPhone,_this.etaMinutes,_this.walletPaise,_this.payablePaise,_this.deliveredAt,_this.openIssueId,const DeepCollectionEquality().hash(_this.claimedQty),_this.replacementOf,_this.refundStatus,_this.refundedPaise,const DeepCollectionEquality().hash(_this.removedItemNames),_this.removedValuePaise]);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, items: ${_this.items}, status: ${_this.status}, placedAt: ${_this.placedAt}, itemTotalPaise: ${_this.itemTotalPaise}, deliveryFeePaise: ${_this.deliveryFeePaise}, handlingFeePaise: ${_this.handlingFeePaise}, tipPaise: ${_this.tipPaise}, discountPaise: ${_this.discountPaise}, totalPaise: ${_this.totalPaise}, addressId: ${_this.addressId}, paymentMethod: ${_this.paymentMethod}, addressLabel: ${_this.addressLabel}, addressText: ${_this.addressText}, riderName: ${_this.riderName}, riderPhone: ${_this.riderPhone}, etaMinutes: ${_this.etaMinutes}, walletPaise: ${_this.walletPaise}, payablePaise: ${_this.payablePaise}, deliveredAt: ${_this.deliveredAt}, openIssueId: ${_this.openIssueId}, claimedQty: ${_this.claimedQty}, replacementOf: ${_this.replacementOf}, refundStatus: ${_this.refundStatus}, refundedPaise: ${_this.refundedPaise}, removedItemNames: ${_this.removedItemNames}, removedValuePaise: ${_this.removedValuePaise})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, List<OrderItem> items, OrderStatus status, DateTime placedAt, int itemTotalPaise, int deliveryFeePaise, int handlingFeePaise, int tipPaise, int discountPaise, int totalPaise, String? addressId, String paymentMethod, String? addressLabel, String? addressText, String? riderName, String? riderPhone, int? etaMinutes, int walletPaise, int? payablePaise, DateTime? deliveredAt, String? openIssueId, Map<String, int> claimedQty, String? replacementOf, String? refundStatus, int? refundedPaise, List<String> removedItemNames, int removedValuePaise
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? status = null,Object? placedAt = null,Object? itemTotalPaise = null,Object? deliveryFeePaise = null,Object? handlingFeePaise = null,Object? tipPaise = null,Object? discountPaise = null,Object? totalPaise = null,Object? addressId = freezed,Object? paymentMethod = null,Object? addressLabel = freezed,Object? addressText = freezed,Object? riderName = freezed,Object? riderPhone = freezed,Object? etaMinutes = freezed,Object? walletPaise = null,Object? payablePaise = freezed,Object? deliveredAt = freezed,Object? openIssueId = freezed,Object? claimedQty = null,Object? replacementOf = freezed,Object? refundStatus = freezed,Object? refundedPaise = freezed,Object? removedItemNames = null,Object? removedValuePaise = null,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,itemTotalPaise: null == itemTotalPaise ? _self.itemTotalPaise : itemTotalPaise // ignore: cast_nullable_to_non_nullable
as int,deliveryFeePaise: null == deliveryFeePaise ? _self.deliveryFeePaise : deliveryFeePaise // ignore: cast_nullable_to_non_nullable
as int,handlingFeePaise: null == handlingFeePaise ? _self.handlingFeePaise : handlingFeePaise // ignore: cast_nullable_to_non_nullable
as int,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,discountPaise: null == discountPaise ? _self.discountPaise : discountPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,addressLabel: freezed == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,riderName: freezed == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String?,riderPhone: freezed == riderPhone ? _self.riderPhone : riderPhone // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,walletPaise: null == walletPaise ? _self.walletPaise : walletPaise // ignore: cast_nullable_to_non_nullable
as int,payablePaise: freezed == payablePaise ? _self.payablePaise : payablePaise // ignore: cast_nullable_to_non_nullable
as int?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openIssueId: freezed == openIssueId ? _self.openIssueId : openIssueId // ignore: cast_nullable_to_non_nullable
as String?,claimedQty: null == claimedQty ? _self.claimedQty : claimedQty // ignore: cast_nullable_to_non_nullable
as Map<String, int>,replacementOf: freezed == replacementOf ? _self.replacementOf : replacementOf // ignore: cast_nullable_to_non_nullable
as String?,refundStatus: freezed == refundStatus ? _self.refundStatus : refundStatus // ignore: cast_nullable_to_non_nullable
as String?,refundedPaise: freezed == refundedPaise ? _self.refundedPaise : refundedPaise // ignore: cast_nullable_to_non_nullable
as int?,removedItemNames: null == removedItemNames ? _self.removedItemNames : removedItemNames // ignore: cast_nullable_to_non_nullable
as List<String>,removedValuePaise: null == removedValuePaise ? _self.removedValuePaise : removedValuePaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<OrderItem> items,  OrderStatus status,  DateTime placedAt,  int itemTotalPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise,  String? addressId,  String paymentMethod,  String? addressLabel,  String? addressText,  String? riderName,  String? riderPhone,  int? etaMinutes,  int walletPaise,  int? payablePaise,  DateTime? deliveredAt,  String? openIssueId,  Map<String, int> claimedQty,  String? replacementOf,  String? refundStatus,  int? refundedPaise,  List<String> removedItemNames,  int removedValuePaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.items,_that.status,_that.placedAt,_that.itemTotalPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise,_that.addressId,_that.paymentMethod,_that.addressLabel,_that.addressText,_that.riderName,_that.riderPhone,_that.etaMinutes,_that.walletPaise,_that.payablePaise,_that.deliveredAt,_that.openIssueId,_that.claimedQty,_that.replacementOf,_that.refundStatus,_that.refundedPaise,_that.removedItemNames,_that.removedValuePaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<OrderItem> items,  OrderStatus status,  DateTime placedAt,  int itemTotalPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise,  String? addressId,  String paymentMethod,  String? addressLabel,  String? addressText,  String? riderName,  String? riderPhone,  int? etaMinutes,  int walletPaise,  int? payablePaise,  DateTime? deliveredAt,  String? openIssueId,  Map<String, int> claimedQty,  String? replacementOf,  String? refundStatus,  int? refundedPaise,  List<String> removedItemNames,  int removedValuePaise)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.items,_that.status,_that.placedAt,_that.itemTotalPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise,_that.addressId,_that.paymentMethod,_that.addressLabel,_that.addressText,_that.riderName,_that.riderPhone,_that.etaMinutes,_that.walletPaise,_that.payablePaise,_that.deliveredAt,_that.openIssueId,_that.claimedQty,_that.replacementOf,_that.refundStatus,_that.refundedPaise,_that.removedItemNames,_that.removedValuePaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<OrderItem> items,  OrderStatus status,  DateTime placedAt,  int itemTotalPaise,  int deliveryFeePaise,  int handlingFeePaise,  int tipPaise,  int discountPaise,  int totalPaise,  String? addressId,  String paymentMethod,  String? addressLabel,  String? addressText,  String? riderName,  String? riderPhone,  int? etaMinutes,  int walletPaise,  int? payablePaise,  DateTime? deliveredAt,  String? openIssueId,  Map<String, int> claimedQty,  String? replacementOf,  String? refundStatus,  int? refundedPaise,  List<String> removedItemNames,  int removedValuePaise)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.items,_that.status,_that.placedAt,_that.itemTotalPaise,_that.deliveryFeePaise,_that.handlingFeePaise,_that.tipPaise,_that.discountPaise,_that.totalPaise,_that.addressId,_that.paymentMethod,_that.addressLabel,_that.addressText,_that.riderName,_that.riderPhone,_that.etaMinutes,_that.walletPaise,_that.payablePaise,_that.deliveredAt,_that.openIssueId,_that.claimedQty,_that.replacementOf,_that.refundStatus,_that.refundedPaise,_that.removedItemNames,_that.removedValuePaise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
   _Order({required this.id, required  List<OrderItem> items, required this.status, required this.placedAt, required this.itemTotalPaise, required this.deliveryFeePaise, required this.handlingFeePaise, required this.tipPaise, required this.discountPaise, required this.totalPaise, this.addressId, required this.paymentMethod, this.addressLabel, this.addressText, this.riderName, this.riderPhone, this.etaMinutes, this.walletPaise = 0, this.payablePaise, this.deliveredAt, this.openIssueId,  Map<String, int> claimedQty = const <String, int>{}, this.replacementOf, this.refundStatus, this.refundedPaise,  List<String> removedItemNames = const <String>[], this.removedValuePaise = 0}): _items = items,_claimedQty = claimedQty,_removedItemNames = removedItemNames;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  OrderStatus status;
@override final  DateTime placedAt;
@override final  int itemTotalPaise;
@override final  int deliveryFeePaise;
@override final  int handlingFeePaise;
@override final  int tipPaise;
@override final  int discountPaise;
@override final  int totalPaise;
@override final  String? addressId;
@override final  String paymentMethod;
/// Address snapshot taken when the order was placed.
@override final  String? addressLabel;
@override final  String? addressText;
/// Set by the store once a rider is assigned (tracking screen).
@override final  String? riderName;
@override final  String? riderPhone;
/// The chosen delivery slot's promise, for the tracking ETA.
@override final  int? etaMinutes;
/// Wallet (docs/WALLET.md): what the wallet paid; the rest
/// ([payablePaise]) was paid online or is cash at the door.
@override@JsonKey() final  int walletPaise;
@override final  int? payablePaise;
/// When it was delivered ("Report a problem" is open for 2 hours).
@override final  DateTime? deliveredAt;
/// The claim under review on this order, if any.
@override final  String? openIssueId;
/// Units already claimed per line (item index → units).
 final  Map<String, int> _claimedQty;
/// Units already claimed per line (item index → units).
@override@JsonKey() Map<String, int> get claimedQty {
  if (_claimedQty is EqualUnmodifiableMapView) return _claimedQty;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_claimedQty);
}

/// Set on a free replacement: the order it replaces.
@override final  String? replacementOf;
/// Online refund to the customer's bank or UPI, mirrored by the server
/// (functions/src/payments/refunds.ts): requesting → requested →
/// succeeded, or failed. Null when nothing was refunded online.
@override final  String? refundStatus;
/// Paise refunded online so far.
@override final  int? refundedPaise;
/// Items a shop couldn't supply, dropped from the order after it was
/// placed (functions/src/orders/partial_cancel.ts). Empty usually.
 final  List<String> _removedItemNames;
/// Items a shop couldn't supply, dropped from the order after it was
/// placed (functions/src/orders/partial_cancel.ts). Empty usually.
@override@JsonKey() List<String> get removedItemNames {
  if (_removedItemNames is EqualUnmodifiableListView) return _removedItemNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_removedItemNames);
}

/// What came back for [removedItemNames] (refund, wallet or less cash).
@override@JsonKey() final  int removedValuePaise;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.itemTotalPaise, itemTotalPaise) || other.itemTotalPaise == itemTotalPaise)&&(identical(other.deliveryFeePaise, deliveryFeePaise) || other.deliveryFeePaise == deliveryFeePaise)&&(identical(other.handlingFeePaise, handlingFeePaise) || other.handlingFeePaise == handlingFeePaise)&&(identical(other.tipPaise, tipPaise) || other.tipPaise == tipPaise)&&(identical(other.discountPaise, discountPaise) || other.discountPaise == discountPaise)&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.addressLabel, addressLabel) || other.addressLabel == addressLabel)&&(identical(other.addressText, addressText) || other.addressText == addressText)&&(identical(other.riderName, riderName) || other.riderName == riderName)&&(identical(other.riderPhone, riderPhone) || other.riderPhone == riderPhone)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.walletPaise, walletPaise) || other.walletPaise == walletPaise)&&(identical(other.payablePaise, payablePaise) || other.payablePaise == payablePaise)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.openIssueId, openIssueId) || other.openIssueId == openIssueId)&&const DeepCollectionEquality().equals(other.claimedQty, _claimedQty)&&(identical(other.replacementOf, replacementOf) || other.replacementOf == replacementOf)&&(identical(other.refundStatus, refundStatus) || other.refundStatus == refundStatus)&&(identical(other.refundedPaise, refundedPaise) || other.refundedPaise == refundedPaise)&&const DeepCollectionEquality().equals(other.removedItemNames, _removedItemNames)&&(identical(other.removedValuePaise, removedValuePaise) || other.removedValuePaise == removedValuePaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,const DeepCollectionEquality().hash(_items),status,placedAt,itemTotalPaise,deliveryFeePaise,handlingFeePaise,tipPaise,discountPaise,totalPaise,addressId,paymentMethod,addressLabel,addressText,riderName,riderPhone,etaMinutes,walletPaise,payablePaise,deliveredAt,openIssueId,const DeepCollectionEquality().hash(_claimedQty),replacementOf,refundStatus,refundedPaise,const DeepCollectionEquality().hash(_removedItemNames),removedValuePaise]);
}

@override
String toString() {
    return 'Order(id: $id, items: $items, status: $status, placedAt: $placedAt, itemTotalPaise: $itemTotalPaise, deliveryFeePaise: $deliveryFeePaise, handlingFeePaise: $handlingFeePaise, tipPaise: $tipPaise, discountPaise: $discountPaise, totalPaise: $totalPaise, addressId: $addressId, paymentMethod: $paymentMethod, addressLabel: $addressLabel, addressText: $addressText, riderName: $riderName, riderPhone: $riderPhone, etaMinutes: $etaMinutes, walletPaise: $walletPaise, payablePaise: $payablePaise, deliveredAt: $deliveredAt, openIssueId: $openIssueId, claimedQty: $claimedQty, replacementOf: $replacementOf, refundStatus: $refundStatus, refundedPaise: $refundedPaise, removedItemNames: $removedItemNames, removedValuePaise: $removedValuePaise)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, List<OrderItem> items, OrderStatus status, DateTime placedAt, int itemTotalPaise, int deliveryFeePaise, int handlingFeePaise, int tipPaise, int discountPaise, int totalPaise, String? addressId, String paymentMethod, String? addressLabel, String? addressText, String? riderName, String? riderPhone, int? etaMinutes, int walletPaise, int? payablePaise, DateTime? deliveredAt, String? openIssueId, Map<String, int> claimedQty, String? replacementOf, String? refundStatus, int? refundedPaise, List<String> removedItemNames, int removedValuePaise
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? status = null,Object? placedAt = null,Object? itemTotalPaise = null,Object? deliveryFeePaise = null,Object? handlingFeePaise = null,Object? tipPaise = null,Object? discountPaise = null,Object? totalPaise = null,Object? addressId = freezed,Object? paymentMethod = null,Object? addressLabel = freezed,Object? addressText = freezed,Object? riderName = freezed,Object? riderPhone = freezed,Object? etaMinutes = freezed,Object? walletPaise = null,Object? payablePaise = freezed,Object? deliveredAt = freezed,Object? openIssueId = freezed,Object? claimedQty = null,Object? replacementOf = freezed,Object? refundStatus = freezed,Object? refundedPaise = freezed,Object? removedItemNames = null,Object? removedValuePaise = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,itemTotalPaise: null == itemTotalPaise ? _self.itemTotalPaise : itemTotalPaise // ignore: cast_nullable_to_non_nullable
as int,deliveryFeePaise: null == deliveryFeePaise ? _self.deliveryFeePaise : deliveryFeePaise // ignore: cast_nullable_to_non_nullable
as int,handlingFeePaise: null == handlingFeePaise ? _self.handlingFeePaise : handlingFeePaise // ignore: cast_nullable_to_non_nullable
as int,tipPaise: null == tipPaise ? _self.tipPaise : tipPaise // ignore: cast_nullable_to_non_nullable
as int,discountPaise: null == discountPaise ? _self.discountPaise : discountPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,addressLabel: freezed == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String?,addressText: freezed == addressText ? _self.addressText : addressText // ignore: cast_nullable_to_non_nullable
as String?,riderName: freezed == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String?,riderPhone: freezed == riderPhone ? _self.riderPhone : riderPhone // ignore: cast_nullable_to_non_nullable
as String?,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,walletPaise: null == walletPaise ? _self.walletPaise : walletPaise // ignore: cast_nullable_to_non_nullable
as int,payablePaise: freezed == payablePaise ? _self.payablePaise : payablePaise // ignore: cast_nullable_to_non_nullable
as int?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openIssueId: freezed == openIssueId ? _self.openIssueId : openIssueId // ignore: cast_nullable_to_non_nullable
as String?,claimedQty: null == claimedQty ? _self._claimedQty : claimedQty // ignore: cast_nullable_to_non_nullable
as Map<String, int>,replacementOf: freezed == replacementOf ? _self.replacementOf : replacementOf // ignore: cast_nullable_to_non_nullable
as String?,refundStatus: freezed == refundStatus ? _self.refundStatus : refundStatus // ignore: cast_nullable_to_non_nullable
as String?,refundedPaise: freezed == refundedPaise ? _self.refundedPaise : refundedPaise // ignore: cast_nullable_to_non_nullable
as int?,removedItemNames: null == removedItemNames ? _self._removedItemNames : removedItemNames // ignore: cast_nullable_to_non_nullable
as List<String>,removedValuePaise: null == removedValuePaise ? _self.removedValuePaise : removedValuePaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
