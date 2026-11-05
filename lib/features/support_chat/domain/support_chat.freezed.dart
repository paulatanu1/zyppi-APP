// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupportChat {

 String get id; SupportChatStatus get status; String? get orderId; int get unreadByUser;
/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportChatCopyWith<SupportChat> get copyWith => _$SupportChatCopyWithImpl<SupportChat>(this as SupportChat, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupportChat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportChat&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.unreadByUser, _this.unreadByUser) || other.unreadByUser == _this.unreadByUser));
}


@override
int get hashCode {
  final _this = this as SupportChat;
  return Object.hash(runtimeType,_this.id,_this.status,_this.orderId,_this.unreadByUser);
}

@override
String toString() {
  final _this = this as SupportChat;
  return 'SupportChat(id: ${_this.id}, status: ${_this.status}, orderId: ${_this.orderId}, unreadByUser: ${_this.unreadByUser})';
}


}

/// @nodoc
abstract mixin class $SupportChatCopyWith<$Res>  {
  factory $SupportChatCopyWith(SupportChat value, $Res Function(SupportChat) _then) = _$SupportChatCopyWithImpl;
@useResult
$Res call({
 String id, SupportChatStatus status, String? orderId, int unreadByUser
});




}
/// @nodoc
class _$SupportChatCopyWithImpl<$Res>
    implements $SupportChatCopyWith<$Res> {
  _$SupportChatCopyWithImpl(this._self, this._then);

  final SupportChat _self;
  final $Res Function(SupportChat) _then;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? orderId = freezed,Object? unreadByUser = null,}) {
  return _then(SupportChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportChatStatus,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,unreadByUser: null == unreadByUser ? _self.unreadByUser : unreadByUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportChat].
extension SupportChatPatterns on SupportChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportChat value)  $default,){
final _that = this;
switch (_that) {
case _SupportChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportChat value)?  $default,){
final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SupportChatStatus status,  String? orderId,  int unreadByUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
return $default(_that.id,_that.status,_that.orderId,_that.unreadByUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SupportChatStatus status,  String? orderId,  int unreadByUser)  $default,) {final _that = this;
switch (_that) {
case _SupportChat():
return $default(_that.id,_that.status,_that.orderId,_that.unreadByUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SupportChatStatus status,  String? orderId,  int unreadByUser)?  $default,) {final _that = this;
switch (_that) {
case _SupportChat() when $default != null:
return $default(_that.id,_that.status,_that.orderId,_that.unreadByUser);case _:
  return null;

}
}

}

/// @nodoc


class _SupportChat implements SupportChat {
  const _SupportChat({required this.id, required this.status, this.orderId, this.unreadByUser = 0});
  

@override final  String id;
@override final  SupportChatStatus status;
@override final  String? orderId;
@override@JsonKey() final  int unreadByUser;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportChatCopyWith<_SupportChat> get copyWith => __$SupportChatCopyWithImpl<_SupportChat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportChat&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.unreadByUser, unreadByUser) || other.unreadByUser == unreadByUser));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,status,orderId,unreadByUser);
}

@override
String toString() {
    return 'SupportChat(id: $id, status: $status, orderId: $orderId, unreadByUser: $unreadByUser)';
}


}

/// @nodoc
abstract mixin class _$SupportChatCopyWith<$Res> implements $SupportChatCopyWith<$Res> {
  factory _$SupportChatCopyWith(_SupportChat value, $Res Function(_SupportChat) _then) = __$SupportChatCopyWithImpl;
@override @useResult
$Res call({
 String id, SupportChatStatus status, String? orderId, int unreadByUser
});




}
/// @nodoc
class __$SupportChatCopyWithImpl<$Res>
    implements _$SupportChatCopyWith<$Res> {
  __$SupportChatCopyWithImpl(this._self, this._then);

  final _SupportChat _self;
  final $Res Function(_SupportChat) _then;

/// Create a copy of SupportChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? orderId = freezed,Object? unreadByUser = null,}) {
  return _then(_SupportChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportChatStatus,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,unreadByUser: null == unreadByUser ? _self.unreadByUser : unreadByUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SupportQuickReply {

 String get id; String get label;
/// Create a copy of SupportQuickReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportQuickReplyCopyWith<SupportQuickReply> get copyWith => _$SupportQuickReplyCopyWithImpl<SupportQuickReply>(this as SupportQuickReply, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupportQuickReply;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportQuickReply&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as SupportQuickReply;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as SupportQuickReply;
  return 'SupportQuickReply(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $SupportQuickReplyCopyWith<$Res>  {
  factory $SupportQuickReplyCopyWith(SupportQuickReply value, $Res Function(SupportQuickReply) _then) = _$SupportQuickReplyCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$SupportQuickReplyCopyWithImpl<$Res>
    implements $SupportQuickReplyCopyWith<$Res> {
  _$SupportQuickReplyCopyWithImpl(this._self, this._then);

  final SupportQuickReply _self;
  final $Res Function(SupportQuickReply) _then;

/// Create a copy of SupportQuickReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(SupportQuickReply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportQuickReply].
extension SupportQuickReplyPatterns on SupportQuickReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportQuickReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportQuickReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportQuickReply value)  $default,){
final _that = this;
switch (_that) {
case _SupportQuickReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportQuickReply value)?  $default,){
final _that = this;
switch (_that) {
case _SupportQuickReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportQuickReply() when $default != null:
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label)  $default,) {final _that = this;
switch (_that) {
case _SupportQuickReply():
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label)?  $default,) {final _that = this;
switch (_that) {
case _SupportQuickReply() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _SupportQuickReply extends SupportQuickReply {
  const _SupportQuickReply({required this.id, required this.label}): super._();
  

@override final  String id;
@override final  String label;

/// Create a copy of SupportQuickReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportQuickReplyCopyWith<_SupportQuickReply> get copyWith => __$SupportQuickReplyCopyWithImpl<_SupportQuickReply>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportQuickReply&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'SupportQuickReply(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SupportQuickReplyCopyWith<$Res> implements $SupportQuickReplyCopyWith<$Res> {
  factory _$SupportQuickReplyCopyWith(_SupportQuickReply value, $Res Function(_SupportQuickReply) _then) = __$SupportQuickReplyCopyWithImpl;
@override @useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class __$SupportQuickReplyCopyWithImpl<$Res>
    implements _$SupportQuickReplyCopyWith<$Res> {
  __$SupportQuickReplyCopyWithImpl(this._self, this._then);

  final _SupportQuickReply _self;
  final $Res Function(_SupportQuickReply) _then;

/// Create a copy of SupportQuickReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_SupportQuickReply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SupportMessage {

 String get id; SupportSender get from; String get text;/// Null while the customer's own message is still pending the server.
 DateTime? get createdAt; List<SupportQuickReply> get quickReplies;/// The hand-off message: show WhatsApp / Call buttons under it.
 bool get showContactOptions;
/// Create a copy of SupportMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportMessageCopyWith<SupportMessage> get copyWith => _$SupportMessageCopyWithImpl<SupportMessage>(this as SupportMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupportMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.quickReplies, _this.quickReplies)&&(identical(other.showContactOptions, _this.showContactOptions) || other.showContactOptions == _this.showContactOptions));
}


@override
int get hashCode {
  final _this = this as SupportMessage;
  return Object.hash(runtimeType,_this.id,_this.from,_this.text,_this.createdAt,const DeepCollectionEquality().hash(_this.quickReplies),_this.showContactOptions);
}

@override
String toString() {
  final _this = this as SupportMessage;
  return 'SupportMessage(id: ${_this.id}, from: ${_this.from}, text: ${_this.text}, createdAt: ${_this.createdAt}, quickReplies: ${_this.quickReplies}, showContactOptions: ${_this.showContactOptions})';
}


}

/// @nodoc
abstract mixin class $SupportMessageCopyWith<$Res>  {
  factory $SupportMessageCopyWith(SupportMessage value, $Res Function(SupportMessage) _then) = _$SupportMessageCopyWithImpl;
@useResult
$Res call({
 String id, SupportSender from, String text, DateTime? createdAt, List<SupportQuickReply> quickReplies, bool showContactOptions
});




}
/// @nodoc
class _$SupportMessageCopyWithImpl<$Res>
    implements $SupportMessageCopyWith<$Res> {
  _$SupportMessageCopyWithImpl(this._self, this._then);

  final SupportMessage _self;
  final $Res Function(SupportMessage) _then;

/// Create a copy of SupportMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? from = null,Object? text = null,Object? createdAt = freezed,Object? quickReplies = null,Object? showContactOptions = null,}) {
  return _then(SupportMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as SupportSender,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quickReplies: null == quickReplies ? _self.quickReplies : quickReplies // ignore: cast_nullable_to_non_nullable
as List<SupportQuickReply>,showContactOptions: null == showContactOptions ? _self.showContactOptions : showContactOptions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportMessage].
extension SupportMessagePatterns on SupportMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportMessage value)  $default,){
final _that = this;
switch (_that) {
case _SupportMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SupportMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SupportSender from,  String text,  DateTime? createdAt,  List<SupportQuickReply> quickReplies,  bool showContactOptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportMessage() when $default != null:
return $default(_that.id,_that.from,_that.text,_that.createdAt,_that.quickReplies,_that.showContactOptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SupportSender from,  String text,  DateTime? createdAt,  List<SupportQuickReply> quickReplies,  bool showContactOptions)  $default,) {final _that = this;
switch (_that) {
case _SupportMessage():
return $default(_that.id,_that.from,_that.text,_that.createdAt,_that.quickReplies,_that.showContactOptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SupportSender from,  String text,  DateTime? createdAt,  List<SupportQuickReply> quickReplies,  bool showContactOptions)?  $default,) {final _that = this;
switch (_that) {
case _SupportMessage() when $default != null:
return $default(_that.id,_that.from,_that.text,_that.createdAt,_that.quickReplies,_that.showContactOptions);case _:
  return null;

}
}

}

/// @nodoc


class _SupportMessage implements SupportMessage {
  const _SupportMessage({required this.id, required this.from, required this.text, this.createdAt,  List<SupportQuickReply> quickReplies = const [], this.showContactOptions = false}): _quickReplies = quickReplies;
  

@override final  String id;
@override final  SupportSender from;
@override final  String text;
/// Null while the customer's own message is still pending the server.
@override final  DateTime? createdAt;
 final  List<SupportQuickReply> _quickReplies;
@override@JsonKey() List<SupportQuickReply> get quickReplies {
  if (_quickReplies is EqualUnmodifiableListView) return _quickReplies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickReplies);
}

/// The hand-off message: show WhatsApp / Call buttons under it.
@override@JsonKey() final  bool showContactOptions;

/// Create a copy of SupportMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportMessageCopyWith<_SupportMessage> get copyWith => __$SupportMessageCopyWithImpl<_SupportMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.quickReplies, _quickReplies)&&(identical(other.showContactOptions, showContactOptions) || other.showContactOptions == showContactOptions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,from,text,createdAt,const DeepCollectionEquality().hash(_quickReplies),showContactOptions);
}

@override
String toString() {
    return 'SupportMessage(id: $id, from: $from, text: $text, createdAt: $createdAt, quickReplies: $quickReplies, showContactOptions: $showContactOptions)';
}


}

/// @nodoc
abstract mixin class _$SupportMessageCopyWith<$Res> implements $SupportMessageCopyWith<$Res> {
  factory _$SupportMessageCopyWith(_SupportMessage value, $Res Function(_SupportMessage) _then) = __$SupportMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, SupportSender from, String text, DateTime? createdAt, List<SupportQuickReply> quickReplies, bool showContactOptions
});




}
/// @nodoc
class __$SupportMessageCopyWithImpl<$Res>
    implements _$SupportMessageCopyWith<$Res> {
  __$SupportMessageCopyWithImpl(this._self, this._then);

  final _SupportMessage _self;
  final $Res Function(_SupportMessage) _then;

/// Create a copy of SupportMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? from = null,Object? text = null,Object? createdAt = freezed,Object? quickReplies = null,Object? showContactOptions = null,}) {
  return _then(_SupportMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as SupportSender,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,quickReplies: null == quickReplies ? _self._quickReplies : quickReplies // ignore: cast_nullable_to_non_nullable
as List<SupportQuickReply>,showContactOptions: null == showContactOptions ? _self.showContactOptions : showContactOptions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
