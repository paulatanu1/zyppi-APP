// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Offer {

 String get id; String get productId; String get variantId; String get serviceAreaId; String get sellerId; String get sellerName; double get sellerRating; int get ratingCount; int get pricePaise; int get mrpPaise;/// Without the seller's special discount (struck through beside it).
 int get regularPricePaise; bool get discountActive; bool get inStock; double get rankScore;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);

  /// Serializes this Offer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Offer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.variantId, _this.variantId) || other.variantId == _this.variantId)&&(identical(other.serviceAreaId, _this.serviceAreaId) || other.serviceAreaId == _this.serviceAreaId)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.sellerName, _this.sellerName) || other.sellerName == _this.sellerName)&&(identical(other.sellerRating, _this.sellerRating) || other.sellerRating == _this.sellerRating)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.pricePaise, _this.pricePaise) || other.pricePaise == _this.pricePaise)&&(identical(other.mrpPaise, _this.mrpPaise) || other.mrpPaise == _this.mrpPaise)&&(identical(other.regularPricePaise, _this.regularPricePaise) || other.regularPricePaise == _this.regularPricePaise)&&(identical(other.discountActive, _this.discountActive) || other.discountActive == _this.discountActive)&&(identical(other.inStock, _this.inStock) || other.inStock == _this.inStock)&&(identical(other.rankScore, _this.rankScore) || other.rankScore == _this.rankScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Offer;
  return Object.hash(runtimeType,_this.id,_this.productId,_this.variantId,_this.serviceAreaId,_this.sellerId,_this.sellerName,_this.sellerRating,_this.ratingCount,_this.pricePaise,_this.mrpPaise,_this.regularPricePaise,_this.discountActive,_this.inStock,_this.rankScore);
}

@override
String toString() {
  final _this = this as Offer;
  return 'Offer(id: ${_this.id}, productId: ${_this.productId}, variantId: ${_this.variantId}, serviceAreaId: ${_this.serviceAreaId}, sellerId: ${_this.sellerId}, sellerName: ${_this.sellerName}, sellerRating: ${_this.sellerRating}, ratingCount: ${_this.ratingCount}, pricePaise: ${_this.pricePaise}, mrpPaise: ${_this.mrpPaise}, regularPricePaise: ${_this.regularPricePaise}, discountActive: ${_this.discountActive}, inStock: ${_this.inStock}, rankScore: ${_this.rankScore})';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String variantId, String serviceAreaId, String sellerId, String sellerName, double sellerRating, int ratingCount, int pricePaise, int mrpPaise, int regularPricePaise, bool discountActive, bool inStock, double rankScore
});




}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? variantId = null,Object? serviceAreaId = null,Object? sellerId = null,Object? sellerName = null,Object? sellerRating = null,Object? ratingCount = null,Object? pricePaise = null,Object? mrpPaise = null,Object? regularPricePaise = null,Object? discountActive = null,Object? inStock = null,Object? rankScore = null,}) {
  return _then(Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String,serviceAreaId: null == serviceAreaId ? _self.serviceAreaId : serviceAreaId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,sellerRating: null == sellerRating ? _self.sellerRating : sellerRating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,regularPricePaise: null == regularPricePaise ? _self.regularPricePaise : regularPricePaise // ignore: cast_nullable_to_non_nullable
as int,discountActive: null == discountActive ? _self.discountActive : discountActive // ignore: cast_nullable_to_non_nullable
as bool,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,rankScore: null == rankScore ? _self.rankScore : rankScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String variantId,  String serviceAreaId,  String sellerId,  String sellerName,  double sellerRating,  int ratingCount,  int pricePaise,  int mrpPaise,  int regularPricePaise,  bool discountActive,  bool inStock,  double rankScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.serviceAreaId,_that.sellerId,_that.sellerName,_that.sellerRating,_that.ratingCount,_that.pricePaise,_that.mrpPaise,_that.regularPricePaise,_that.discountActive,_that.inStock,_that.rankScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String variantId,  String serviceAreaId,  String sellerId,  String sellerName,  double sellerRating,  int ratingCount,  int pricePaise,  int mrpPaise,  int regularPricePaise,  bool discountActive,  bool inStock,  double rankScore)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.id,_that.productId,_that.variantId,_that.serviceAreaId,_that.sellerId,_that.sellerName,_that.sellerRating,_that.ratingCount,_that.pricePaise,_that.mrpPaise,_that.regularPricePaise,_that.discountActive,_that.inStock,_that.rankScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String variantId,  String serviceAreaId,  String sellerId,  String sellerName,  double sellerRating,  int ratingCount,  int pricePaise,  int mrpPaise,  int regularPricePaise,  bool discountActive,  bool inStock,  double rankScore)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.serviceAreaId,_that.sellerId,_that.sellerName,_that.sellerRating,_that.ratingCount,_that.pricePaise,_that.mrpPaise,_that.regularPricePaise,_that.discountActive,_that.inStock,_that.rankScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Offer extends Offer {
  const _Offer({required this.id, required this.productId, required this.variantId, required this.serviceAreaId, required this.sellerId, required this.sellerName, this.sellerRating = 0, this.ratingCount = 0, required this.pricePaise, required this.mrpPaise, required this.regularPricePaise, this.discountActive = false, this.inStock = true, this.rankScore = 0}): super._();
  factory _Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

@override final  String id;
@override final  String productId;
@override final  String variantId;
@override final  String serviceAreaId;
@override final  String sellerId;
@override final  String sellerName;
@override@JsonKey() final  double sellerRating;
@override@JsonKey() final  int ratingCount;
@override final  int pricePaise;
@override final  int mrpPaise;
/// Without the seller's special discount (struck through beside it).
@override final  int regularPricePaise;
@override@JsonKey() final  bool discountActive;
@override@JsonKey() final  bool inStock;
@override@JsonKey() final  double rankScore;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.serviceAreaId, serviceAreaId) || other.serviceAreaId == serviceAreaId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.sellerRating, sellerRating) || other.sellerRating == sellerRating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.pricePaise, pricePaise) || other.pricePaise == pricePaise)&&(identical(other.mrpPaise, mrpPaise) || other.mrpPaise == mrpPaise)&&(identical(other.regularPricePaise, regularPricePaise) || other.regularPricePaise == regularPricePaise)&&(identical(other.discountActive, discountActive) || other.discountActive == discountActive)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.rankScore, rankScore) || other.rankScore == rankScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productId,variantId,serviceAreaId,sellerId,sellerName,sellerRating,ratingCount,pricePaise,mrpPaise,regularPricePaise,discountActive,inStock,rankScore);
}

@override
String toString() {
    return 'Offer(id: $id, productId: $productId, variantId: $variantId, serviceAreaId: $serviceAreaId, sellerId: $sellerId, sellerName: $sellerName, sellerRating: $sellerRating, ratingCount: $ratingCount, pricePaise: $pricePaise, mrpPaise: $mrpPaise, regularPricePaise: $regularPricePaise, discountActive: $discountActive, inStock: $inStock, rankScore: $rankScore)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String variantId, String serviceAreaId, String sellerId, String sellerName, double sellerRating, int ratingCount, int pricePaise, int mrpPaise, int regularPricePaise, bool discountActive, bool inStock, double rankScore
});




}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? variantId = null,Object? serviceAreaId = null,Object? sellerId = null,Object? sellerName = null,Object? sellerRating = null,Object? ratingCount = null,Object? pricePaise = null,Object? mrpPaise = null,Object? regularPricePaise = null,Object? discountActive = null,Object? inStock = null,Object? rankScore = null,}) {
  return _then(_Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: null == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String,serviceAreaId: null == serviceAreaId ? _self.serviceAreaId : serviceAreaId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,sellerRating: null == sellerRating ? _self.sellerRating : sellerRating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,regularPricePaise: null == regularPricePaise ? _self.regularPricePaise : regularPricePaise // ignore: cast_nullable_to_non_nullable
as int,discountActive: null == discountActive ? _self.discountActive : discountActive // ignore: cast_nullable_to_non_nullable
as bool,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,rankScore: null == rankScore ? _self.rankScore : rankScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BestOffer {

 String get offerId; String get sellerId; String get sellerName; int get pricePaise; int get mrpPaise; bool get inStock; int get offerCount;
/// Create a copy of BestOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BestOfferCopyWith<BestOffer> get copyWith => _$BestOfferCopyWithImpl<BestOffer>(this as BestOffer, _$identity);

  /// Serializes this BestOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BestOffer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BestOffer&&(identical(other.offerId, _this.offerId) || other.offerId == _this.offerId)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.sellerName, _this.sellerName) || other.sellerName == _this.sellerName)&&(identical(other.pricePaise, _this.pricePaise) || other.pricePaise == _this.pricePaise)&&(identical(other.mrpPaise, _this.mrpPaise) || other.mrpPaise == _this.mrpPaise)&&(identical(other.inStock, _this.inStock) || other.inStock == _this.inStock)&&(identical(other.offerCount, _this.offerCount) || other.offerCount == _this.offerCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BestOffer;
  return Object.hash(runtimeType,_this.offerId,_this.sellerId,_this.sellerName,_this.pricePaise,_this.mrpPaise,_this.inStock,_this.offerCount);
}

@override
String toString() {
  final _this = this as BestOffer;
  return 'BestOffer(offerId: ${_this.offerId}, sellerId: ${_this.sellerId}, sellerName: ${_this.sellerName}, pricePaise: ${_this.pricePaise}, mrpPaise: ${_this.mrpPaise}, inStock: ${_this.inStock}, offerCount: ${_this.offerCount})';
}


}

/// @nodoc
abstract mixin class $BestOfferCopyWith<$Res>  {
  factory $BestOfferCopyWith(BestOffer value, $Res Function(BestOffer) _then) = _$BestOfferCopyWithImpl;
@useResult
$Res call({
 String offerId, String sellerId, String sellerName, int pricePaise, int mrpPaise, bool inStock, int offerCount
});




}
/// @nodoc
class _$BestOfferCopyWithImpl<$Res>
    implements $BestOfferCopyWith<$Res> {
  _$BestOfferCopyWithImpl(this._self, this._then);

  final BestOffer _self;
  final $Res Function(BestOffer) _then;

/// Create a copy of BestOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offerId = null,Object? sellerId = null,Object? sellerName = null,Object? pricePaise = null,Object? mrpPaise = null,Object? inStock = null,Object? offerCount = null,}) {
  return _then(BestOffer(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BestOffer].
extension BestOfferPatterns on BestOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BestOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BestOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BestOffer value)  $default,){
final _that = this;
switch (_that) {
case _BestOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BestOffer value)?  $default,){
final _that = this;
switch (_that) {
case _BestOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise,  bool inStock,  int offerCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BestOffer() when $default != null:
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise,_that.inStock,_that.offerCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise,  bool inStock,  int offerCount)  $default,) {final _that = this;
switch (_that) {
case _BestOffer():
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise,_that.inStock,_that.offerCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise,  bool inStock,  int offerCount)?  $default,) {final _that = this;
switch (_that) {
case _BestOffer() when $default != null:
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise,_that.inStock,_that.offerCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BestOffer extends BestOffer {
  const _BestOffer({required this.offerId, required this.sellerId, this.sellerName = '', required this.pricePaise, required this.mrpPaise, this.inStock = true, this.offerCount = 1}): super._();
  factory _BestOffer.fromJson(Map<String, dynamic> json) => _$BestOfferFromJson(json);

@override final  String offerId;
@override final  String sellerId;
@override@JsonKey() final  String sellerName;
@override final  int pricePaise;
@override final  int mrpPaise;
@override@JsonKey() final  bool inStock;
@override@JsonKey() final  int offerCount;

/// Create a copy of BestOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BestOfferCopyWith<_BestOffer> get copyWith => __$BestOfferCopyWithImpl<_BestOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BestOfferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BestOffer&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.pricePaise, pricePaise) || other.pricePaise == pricePaise)&&(identical(other.mrpPaise, mrpPaise) || other.mrpPaise == mrpPaise)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,offerId,sellerId,sellerName,pricePaise,mrpPaise,inStock,offerCount);
}

@override
String toString() {
    return 'BestOffer(offerId: $offerId, sellerId: $sellerId, sellerName: $sellerName, pricePaise: $pricePaise, mrpPaise: $mrpPaise, inStock: $inStock, offerCount: $offerCount)';
}


}

/// @nodoc
abstract mixin class _$BestOfferCopyWith<$Res> implements $BestOfferCopyWith<$Res> {
  factory _$BestOfferCopyWith(_BestOffer value, $Res Function(_BestOffer) _then) = __$BestOfferCopyWithImpl;
@override @useResult
$Res call({
 String offerId, String sellerId, String sellerName, int pricePaise, int mrpPaise, bool inStock, int offerCount
});




}
/// @nodoc
class __$BestOfferCopyWithImpl<$Res>
    implements _$BestOfferCopyWith<$Res> {
  __$BestOfferCopyWithImpl(this._self, this._then);

  final _BestOffer _self;
  final $Res Function(_BestOffer) _then;

/// Create a copy of BestOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offerId = null,Object? sellerId = null,Object? sellerName = null,Object? pricePaise = null,Object? mrpPaise = null,Object? inStock = null,Object? offerCount = null,}) {
  return _then(_BestOffer(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as bool,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OfferPick {

 String get offerId; String get sellerId; String get sellerName; int get pricePaise; int get mrpPaise;
/// Create a copy of OfferPick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferPickCopyWith<OfferPick> get copyWith => _$OfferPickCopyWithImpl<OfferPick>(this as OfferPick, _$identity);

  /// Serializes this OfferPick to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfferPick;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferPick&&(identical(other.offerId, _this.offerId) || other.offerId == _this.offerId)&&(identical(other.sellerId, _this.sellerId) || other.sellerId == _this.sellerId)&&(identical(other.sellerName, _this.sellerName) || other.sellerName == _this.sellerName)&&(identical(other.pricePaise, _this.pricePaise) || other.pricePaise == _this.pricePaise)&&(identical(other.mrpPaise, _this.mrpPaise) || other.mrpPaise == _this.mrpPaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfferPick;
  return Object.hash(runtimeType,_this.offerId,_this.sellerId,_this.sellerName,_this.pricePaise,_this.mrpPaise);
}

@override
String toString() {
  final _this = this as OfferPick;
  return 'OfferPick(offerId: ${_this.offerId}, sellerId: ${_this.sellerId}, sellerName: ${_this.sellerName}, pricePaise: ${_this.pricePaise}, mrpPaise: ${_this.mrpPaise})';
}


}

/// @nodoc
abstract mixin class $OfferPickCopyWith<$Res>  {
  factory $OfferPickCopyWith(OfferPick value, $Res Function(OfferPick) _then) = _$OfferPickCopyWithImpl;
@useResult
$Res call({
 String offerId, String sellerId, String sellerName, int pricePaise, int mrpPaise
});




}
/// @nodoc
class _$OfferPickCopyWithImpl<$Res>
    implements $OfferPickCopyWith<$Res> {
  _$OfferPickCopyWithImpl(this._self, this._then);

  final OfferPick _self;
  final $Res Function(OfferPick) _then;

/// Create a copy of OfferPick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offerId = null,Object? sellerId = null,Object? sellerName = null,Object? pricePaise = null,Object? mrpPaise = null,}) {
  return _then(OfferPick(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferPick].
extension OfferPickPatterns on OfferPick {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferPick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferPick() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferPick value)  $default,){
final _that = this;
switch (_that) {
case _OfferPick():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferPick value)?  $default,){
final _that = this;
switch (_that) {
case _OfferPick() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferPick() when $default != null:
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise)  $default,) {final _that = this;
switch (_that) {
case _OfferPick():
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offerId,  String sellerId,  String sellerName,  int pricePaise,  int mrpPaise)?  $default,) {final _that = this;
switch (_that) {
case _OfferPick() when $default != null:
return $default(_that.offerId,_that.sellerId,_that.sellerName,_that.pricePaise,_that.mrpPaise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferPick extends OfferPick {
  const _OfferPick({required this.offerId, required this.sellerId, required this.sellerName, required this.pricePaise, required this.mrpPaise}): super._();
  factory _OfferPick.fromJson(Map<String, dynamic> json) => _$OfferPickFromJson(json);

@override final  String offerId;
@override final  String sellerId;
@override final  String sellerName;
@override final  int pricePaise;
@override final  int mrpPaise;

/// Create a copy of OfferPick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferPickCopyWith<_OfferPick> get copyWith => __$OfferPickCopyWithImpl<_OfferPick>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferPickToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferPick&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.sellerName, sellerName) || other.sellerName == sellerName)&&(identical(other.pricePaise, pricePaise) || other.pricePaise == pricePaise)&&(identical(other.mrpPaise, mrpPaise) || other.mrpPaise == mrpPaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,offerId,sellerId,sellerName,pricePaise,mrpPaise);
}

@override
String toString() {
    return 'OfferPick(offerId: $offerId, sellerId: $sellerId, sellerName: $sellerName, pricePaise: $pricePaise, mrpPaise: $mrpPaise)';
}


}

/// @nodoc
abstract mixin class _$OfferPickCopyWith<$Res> implements $OfferPickCopyWith<$Res> {
  factory _$OfferPickCopyWith(_OfferPick value, $Res Function(_OfferPick) _then) = __$OfferPickCopyWithImpl;
@override @useResult
$Res call({
 String offerId, String sellerId, String sellerName, int pricePaise, int mrpPaise
});




}
/// @nodoc
class __$OfferPickCopyWithImpl<$Res>
    implements _$OfferPickCopyWith<$Res> {
  __$OfferPickCopyWithImpl(this._self, this._then);

  final _OfferPick _self;
  final $Res Function(_OfferPick) _then;

/// Create a copy of OfferPick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offerId = null,Object? sellerId = null,Object? sellerName = null,Object? pricePaise = null,Object? mrpPaise = null,}) {
  return _then(_OfferPick(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,sellerName: null == sellerName ? _self.sellerName : sellerName // ignore: cast_nullable_to_non_nullable
as String,pricePaise: null == pricePaise ? _self.pricePaise : pricePaise // ignore: cast_nullable_to_non_nullable
as int,mrpPaise: null == mrpPaise ? _self.mrpPaise : mrpPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
