// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'legal_doc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PendingLegalDoc {

 String get type; int get version; String get title; String get sha256;
/// Create a copy of PendingLegalDoc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingLegalDocCopyWith<PendingLegalDoc> get copyWith => _$PendingLegalDocCopyWithImpl<PendingLegalDoc>(this as PendingLegalDoc, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PendingLegalDoc;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingLegalDoc&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.sha256, _this.sha256) || other.sha256 == _this.sha256));
}


@override
int get hashCode {
  final _this = this as PendingLegalDoc;
  return Object.hash(runtimeType,_this.type,_this.version,_this.title,_this.sha256);
}

@override
String toString() {
  final _this = this as PendingLegalDoc;
  return 'PendingLegalDoc(type: ${_this.type}, version: ${_this.version}, title: ${_this.title}, sha256: ${_this.sha256})';
}


}

/// @nodoc
abstract mixin class $PendingLegalDocCopyWith<$Res>  {
  factory $PendingLegalDocCopyWith(PendingLegalDoc value, $Res Function(PendingLegalDoc) _then) = _$PendingLegalDocCopyWithImpl;
@useResult
$Res call({
 String type, int version, String title, String sha256
});




}
/// @nodoc
class _$PendingLegalDocCopyWithImpl<$Res>
    implements $PendingLegalDocCopyWith<$Res> {
  _$PendingLegalDocCopyWithImpl(this._self, this._then);

  final PendingLegalDoc _self;
  final $Res Function(PendingLegalDoc) _then;

/// Create a copy of PendingLegalDoc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? version = null,Object? title = null,Object? sha256 = null,}) {
  return _then(PendingLegalDoc(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingLegalDoc].
extension PendingLegalDocPatterns on PendingLegalDoc {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingLegalDoc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingLegalDoc() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingLegalDoc value)  $default,){
final _that = this;
switch (_that) {
case _PendingLegalDoc():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingLegalDoc value)?  $default,){
final _that = this;
switch (_that) {
case _PendingLegalDoc() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  int version,  String title,  String sha256)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingLegalDoc() when $default != null:
return $default(_that.type,_that.version,_that.title,_that.sha256);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  int version,  String title,  String sha256)  $default,) {final _that = this;
switch (_that) {
case _PendingLegalDoc():
return $default(_that.type,_that.version,_that.title,_that.sha256);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  int version,  String title,  String sha256)?  $default,) {final _that = this;
switch (_that) {
case _PendingLegalDoc() when $default != null:
return $default(_that.type,_that.version,_that.title,_that.sha256);case _:
  return null;

}
}

}

/// @nodoc


class _PendingLegalDoc implements PendingLegalDoc {
  const _PendingLegalDoc({required this.type, required this.version, required this.title, required this.sha256});
  

@override final  String type;
@override final  int version;
@override final  String title;
@override final  String sha256;

/// Create a copy of PendingLegalDoc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingLegalDocCopyWith<_PendingLegalDoc> get copyWith => __$PendingLegalDocCopyWithImpl<_PendingLegalDoc>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingLegalDoc&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.title, title) || other.title == title)&&(identical(other.sha256, sha256) || other.sha256 == sha256));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,version,title,sha256);
}

@override
String toString() {
    return 'PendingLegalDoc(type: $type, version: $version, title: $title, sha256: $sha256)';
}


}

/// @nodoc
abstract mixin class _$PendingLegalDocCopyWith<$Res> implements $PendingLegalDocCopyWith<$Res> {
  factory _$PendingLegalDocCopyWith(_PendingLegalDoc value, $Res Function(_PendingLegalDoc) _then) = __$PendingLegalDocCopyWithImpl;
@override @useResult
$Res call({
 String type, int version, String title, String sha256
});




}
/// @nodoc
class __$PendingLegalDocCopyWithImpl<$Res>
    implements _$PendingLegalDocCopyWith<$Res> {
  __$PendingLegalDocCopyWithImpl(this._self, this._then);

  final _PendingLegalDoc _self;
  final $Res Function(_PendingLegalDoc) _then;

/// Create a copy of PendingLegalDoc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? version = null,Object? title = null,Object? sha256 = null,}) {
  return _then(_PendingLegalDoc(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LegalDocText {

 String get type; int get version; String get title;/// Markdown.
 String get body;
/// Create a copy of LegalDocText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalDocTextCopyWith<LegalDocText> get copyWith => _$LegalDocTextCopyWithImpl<LegalDocText>(this as LegalDocText, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LegalDocText;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalDocText&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body));
}


@override
int get hashCode {
  final _this = this as LegalDocText;
  return Object.hash(runtimeType,_this.type,_this.version,_this.title,_this.body);
}

@override
String toString() {
  final _this = this as LegalDocText;
  return 'LegalDocText(type: ${_this.type}, version: ${_this.version}, title: ${_this.title}, body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $LegalDocTextCopyWith<$Res>  {
  factory $LegalDocTextCopyWith(LegalDocText value, $Res Function(LegalDocText) _then) = _$LegalDocTextCopyWithImpl;
@useResult
$Res call({
 String type, int version, String title, String body
});




}
/// @nodoc
class _$LegalDocTextCopyWithImpl<$Res>
    implements $LegalDocTextCopyWith<$Res> {
  _$LegalDocTextCopyWithImpl(this._self, this._then);

  final LegalDocText _self;
  final $Res Function(LegalDocText) _then;

/// Create a copy of LegalDocText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? version = null,Object? title = null,Object? body = null,}) {
  return _then(LegalDocText(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LegalDocText].
extension LegalDocTextPatterns on LegalDocText {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalDocText value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalDocText() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalDocText value)  $default,){
final _that = this;
switch (_that) {
case _LegalDocText():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalDocText value)?  $default,){
final _that = this;
switch (_that) {
case _LegalDocText() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  int version,  String title,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalDocText() when $default != null:
return $default(_that.type,_that.version,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  int version,  String title,  String body)  $default,) {final _that = this;
switch (_that) {
case _LegalDocText():
return $default(_that.type,_that.version,_that.title,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  int version,  String title,  String body)?  $default,) {final _that = this;
switch (_that) {
case _LegalDocText() when $default != null:
return $default(_that.type,_that.version,_that.title,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _LegalDocText implements LegalDocText {
  const _LegalDocText({required this.type, required this.version, required this.title, required this.body});
  

@override final  String type;
@override final  int version;
@override final  String title;
/// Markdown.
@override final  String body;

/// Create a copy of LegalDocText
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalDocTextCopyWith<_LegalDocText> get copyWith => __$LegalDocTextCopyWithImpl<_LegalDocText>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalDocText&&(identical(other.type, type) || other.type == type)&&(identical(other.version, version) || other.version == version)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,version,title,body);
}

@override
String toString() {
    return 'LegalDocText(type: $type, version: $version, title: $title, body: $body)';
}


}

/// @nodoc
abstract mixin class _$LegalDocTextCopyWith<$Res> implements $LegalDocTextCopyWith<$Res> {
  factory _$LegalDocTextCopyWith(_LegalDocText value, $Res Function(_LegalDocText) _then) = __$LegalDocTextCopyWithImpl;
@override @useResult
$Res call({
 String type, int version, String title, String body
});




}
/// @nodoc
class __$LegalDocTextCopyWithImpl<$Res>
    implements _$LegalDocTextCopyWith<$Res> {
  __$LegalDocTextCopyWithImpl(this._self, this._then);

  final _LegalDocText _self;
  final $Res Function(_LegalDocText) _then;

/// Create a copy of LegalDocText
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? version = null,Object? title = null,Object? body = null,}) {
  return _then(_LegalDocText(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
