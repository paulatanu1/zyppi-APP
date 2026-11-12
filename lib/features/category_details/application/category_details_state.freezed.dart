// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryDetailsState {

 List<Category> get categories; String? get parentId; String? get subId; List<Product> get products; bool get loading; String? get error;
/// Create a copy of CategoryDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryDetailsStateCopyWith<CategoryDetailsState> get copyWith => _$CategoryDetailsStateCopyWithImpl<CategoryDetailsState>(this as CategoryDetailsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryDetailsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryDetailsState&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.subId, _this.subId) || other.subId == _this.subId)&&const DeepCollectionEquality().equals(other.products, _this.products)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CategoryDetailsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),_this.parentId,_this.subId,const DeepCollectionEquality().hash(_this.products),_this.loading,_this.error);
}

@override
String toString() {
  final _this = this as CategoryDetailsState;
  return 'CategoryDetailsState(categories: ${_this.categories}, parentId: ${_this.parentId}, subId: ${_this.subId}, products: ${_this.products}, loading: ${_this.loading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CategoryDetailsStateCopyWith<$Res>  {
  factory $CategoryDetailsStateCopyWith(CategoryDetailsState value, $Res Function(CategoryDetailsState) _then) = _$CategoryDetailsStateCopyWithImpl;
@useResult
$Res call({
 List<Category> categories, String? parentId, String? subId, List<Product> products, bool loading, String? error
});




}
/// @nodoc
class _$CategoryDetailsStateCopyWithImpl<$Res>
    implements $CategoryDetailsStateCopyWith<$Res> {
  _$CategoryDetailsStateCopyWithImpl(this._self, this._then);

  final CategoryDetailsState _self;
  final $Res Function(CategoryDetailsState) _then;

/// Create a copy of CategoryDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? parentId = freezed,Object? subId = freezed,Object? products = null,Object? loading = null,Object? error = freezed,}) {
  return _then(CategoryDetailsState(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,subId: freezed == subId ? _self.subId : subId // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryDetailsState].
extension CategoryDetailsStatePatterns on CategoryDetailsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryDetailsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryDetailsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryDetailsState value)  $default,){
final _that = this;
switch (_that) {
case _CategoryDetailsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryDetailsState value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryDetailsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Category> categories,  String? parentId,  String? subId,  List<Product> products,  bool loading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryDetailsState() when $default != null:
return $default(_that.categories,_that.parentId,_that.subId,_that.products,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Category> categories,  String? parentId,  String? subId,  List<Product> products,  bool loading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CategoryDetailsState():
return $default(_that.categories,_that.parentId,_that.subId,_that.products,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Category> categories,  String? parentId,  String? subId,  List<Product> products,  bool loading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CategoryDetailsState() when $default != null:
return $default(_that.categories,_that.parentId,_that.subId,_that.products,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryDetailsState extends CategoryDetailsState {
   _CategoryDetailsState({ List<Category> categories = const [], this.parentId, this.subId,  List<Product> products = const [], this.loading = true, this.error}): _categories = categories,_products = products,super._();
  

 final  List<Category> _categories;
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  String? parentId;
@override final  String? subId;
 final  List<Product> _products;
@override@JsonKey() List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  bool loading;
@override final  String? error;

/// Create a copy of CategoryDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryDetailsStateCopyWith<_CategoryDetailsState> get copyWith => __$CategoryDetailsStateCopyWithImpl<_CategoryDetailsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryDetailsState&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.subId, subId) || other.subId == subId)&&const DeepCollectionEquality().equals(other.products, _products)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),parentId,subId,const DeepCollectionEquality().hash(_products),loading,error);
}

@override
String toString() {
    return 'CategoryDetailsState(categories: $categories, parentId: $parentId, subId: $subId, products: $products, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CategoryDetailsStateCopyWith<$Res> implements $CategoryDetailsStateCopyWith<$Res> {
  factory _$CategoryDetailsStateCopyWith(_CategoryDetailsState value, $Res Function(_CategoryDetailsState) _then) = __$CategoryDetailsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Category> categories, String? parentId, String? subId, List<Product> products, bool loading, String? error
});




}
/// @nodoc
class __$CategoryDetailsStateCopyWithImpl<$Res>
    implements _$CategoryDetailsStateCopyWith<$Res> {
  __$CategoryDetailsStateCopyWithImpl(this._self, this._then);

  final _CategoryDetailsState _self;
  final $Res Function(_CategoryDetailsState) _then;

/// Create a copy of CategoryDetailsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? parentId = freezed,Object? subId = freezed,Object? products = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_CategoryDetailsState(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,subId: freezed == subId ? _self.subId : subId // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
