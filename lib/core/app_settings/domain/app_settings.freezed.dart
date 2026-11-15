// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeatureFlags {

/// Google Places search when picking an address.
 bool get placesSearch;/// The support bot (off: chats go straight to the team).
 bool get supportBot;/// Phone OTP sign-in (off: Google and guest only).
 bool get phoneOtp; bool get upi; bool get card;/// No new orders; the app shows [maintenanceMessage].
 bool get maintenance; String get maintenanceMessage;/// Service areas where ordering is paused.
 List<String> get closedAreaIds;/// Older app versions must update (x.y.z), or null.
 String? get minAppVersion;
/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureFlagsCopyWith<FeatureFlags> get copyWith => _$FeatureFlagsCopyWithImpl<FeatureFlags>(this as FeatureFlags, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FeatureFlags;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureFlags&&(identical(other.placesSearch, _this.placesSearch) || other.placesSearch == _this.placesSearch)&&(identical(other.supportBot, _this.supportBot) || other.supportBot == _this.supportBot)&&(identical(other.phoneOtp, _this.phoneOtp) || other.phoneOtp == _this.phoneOtp)&&(identical(other.upi, _this.upi) || other.upi == _this.upi)&&(identical(other.card, _this.card) || other.card == _this.card)&&(identical(other.maintenance, _this.maintenance) || other.maintenance == _this.maintenance)&&(identical(other.maintenanceMessage, _this.maintenanceMessage) || other.maintenanceMessage == _this.maintenanceMessage)&&const DeepCollectionEquality().equals(other.closedAreaIds, _this.closedAreaIds)&&(identical(other.minAppVersion, _this.minAppVersion) || other.minAppVersion == _this.minAppVersion));
}


@override
int get hashCode {
  final _this = this as FeatureFlags;
  return Object.hash(runtimeType,_this.placesSearch,_this.supportBot,_this.phoneOtp,_this.upi,_this.card,_this.maintenance,_this.maintenanceMessage,const DeepCollectionEquality().hash(_this.closedAreaIds),_this.minAppVersion);
}

@override
String toString() {
  final _this = this as FeatureFlags;
  return 'FeatureFlags(placesSearch: ${_this.placesSearch}, supportBot: ${_this.supportBot}, phoneOtp: ${_this.phoneOtp}, upi: ${_this.upi}, card: ${_this.card}, maintenance: ${_this.maintenance}, maintenanceMessage: ${_this.maintenanceMessage}, closedAreaIds: ${_this.closedAreaIds}, minAppVersion: ${_this.minAppVersion})';
}


}

/// @nodoc
abstract mixin class $FeatureFlagsCopyWith<$Res>  {
  factory $FeatureFlagsCopyWith(FeatureFlags value, $Res Function(FeatureFlags) _then) = _$FeatureFlagsCopyWithImpl;
@useResult
$Res call({
 bool placesSearch, bool supportBot, bool phoneOtp, bool upi, bool card, bool maintenance, String maintenanceMessage, List<String> closedAreaIds, String? minAppVersion
});




}
/// @nodoc
class _$FeatureFlagsCopyWithImpl<$Res>
    implements $FeatureFlagsCopyWith<$Res> {
  _$FeatureFlagsCopyWithImpl(this._self, this._then);

  final FeatureFlags _self;
  final $Res Function(FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placesSearch = null,Object? supportBot = null,Object? phoneOtp = null,Object? upi = null,Object? card = null,Object? maintenance = null,Object? maintenanceMessage = null,Object? closedAreaIds = null,Object? minAppVersion = freezed,}) {
  return _then(FeatureFlags(
placesSearch: null == placesSearch ? _self.placesSearch : placesSearch // ignore: cast_nullable_to_non_nullable
as bool,supportBot: null == supportBot ? _self.supportBot : supportBot // ignore: cast_nullable_to_non_nullable
as bool,phoneOtp: null == phoneOtp ? _self.phoneOtp : phoneOtp // ignore: cast_nullable_to_non_nullable
as bool,upi: null == upi ? _self.upi : upi // ignore: cast_nullable_to_non_nullable
as bool,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as bool,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as bool,maintenanceMessage: null == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String,closedAreaIds: null == closedAreaIds ? _self.closedAreaIds : closedAreaIds // ignore: cast_nullable_to_non_nullable
as List<String>,minAppVersion: freezed == minAppVersion ? _self.minAppVersion : minAppVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureFlags].
extension FeatureFlagsPatterns on FeatureFlags {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureFlags value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureFlags value)  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureFlags value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool placesSearch,  bool supportBot,  bool phoneOtp,  bool upi,  bool card,  bool maintenance,  String maintenanceMessage,  List<String> closedAreaIds,  String? minAppVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.placesSearch,_that.supportBot,_that.phoneOtp,_that.upi,_that.card,_that.maintenance,_that.maintenanceMessage,_that.closedAreaIds,_that.minAppVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool placesSearch,  bool supportBot,  bool phoneOtp,  bool upi,  bool card,  bool maintenance,  String maintenanceMessage,  List<String> closedAreaIds,  String? minAppVersion)  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags():
return $default(_that.placesSearch,_that.supportBot,_that.phoneOtp,_that.upi,_that.card,_that.maintenance,_that.maintenanceMessage,_that.closedAreaIds,_that.minAppVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool placesSearch,  bool supportBot,  bool phoneOtp,  bool upi,  bool card,  bool maintenance,  String maintenanceMessage,  List<String> closedAreaIds,  String? minAppVersion)?  $default,) {final _that = this;
switch (_that) {
case _FeatureFlags() when $default != null:
return $default(_that.placesSearch,_that.supportBot,_that.phoneOtp,_that.upi,_that.card,_that.maintenance,_that.maintenanceMessage,_that.closedAreaIds,_that.minAppVersion);case _:
  return null;

}
}

}

/// @nodoc


class _FeatureFlags extends FeatureFlags {
  const _FeatureFlags({this.placesSearch = true, this.supportBot = true, this.phoneOtp = true, this.upi = true, this.card = true, this.maintenance = false, this.maintenanceMessage = '',  List<String> closedAreaIds = const <String>[], this.minAppVersion}): _closedAreaIds = closedAreaIds,super._();
  

/// Google Places search when picking an address.
@override@JsonKey() final  bool placesSearch;
/// The support bot (off: chats go straight to the team).
@override@JsonKey() final  bool supportBot;
/// Phone OTP sign-in (off: Google and guest only).
@override@JsonKey() final  bool phoneOtp;
@override@JsonKey() final  bool upi;
@override@JsonKey() final  bool card;
/// No new orders; the app shows [maintenanceMessage].
@override@JsonKey() final  bool maintenance;
@override@JsonKey() final  String maintenanceMessage;
/// Service areas where ordering is paused.
 final  List<String> _closedAreaIds;
/// Service areas where ordering is paused.
@override@JsonKey() List<String> get closedAreaIds {
  if (_closedAreaIds is EqualUnmodifiableListView) return _closedAreaIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_closedAreaIds);
}

/// Older app versions must update (x.y.z), or null.
@override final  String? minAppVersion;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureFlagsCopyWith<_FeatureFlags> get copyWith => __$FeatureFlagsCopyWithImpl<_FeatureFlags>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureFlags&&(identical(other.placesSearch, placesSearch) || other.placesSearch == placesSearch)&&(identical(other.supportBot, supportBot) || other.supportBot == supportBot)&&(identical(other.phoneOtp, phoneOtp) || other.phoneOtp == phoneOtp)&&(identical(other.upi, upi) || other.upi == upi)&&(identical(other.card, card) || other.card == card)&&(identical(other.maintenance, maintenance) || other.maintenance == maintenance)&&(identical(other.maintenanceMessage, maintenanceMessage) || other.maintenanceMessage == maintenanceMessage)&&const DeepCollectionEquality().equals(other.closedAreaIds, _closedAreaIds)&&(identical(other.minAppVersion, minAppVersion) || other.minAppVersion == minAppVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,placesSearch,supportBot,phoneOtp,upi,card,maintenance,maintenanceMessage,const DeepCollectionEquality().hash(_closedAreaIds),minAppVersion);
}

@override
String toString() {
    return 'FeatureFlags(placesSearch: $placesSearch, supportBot: $supportBot, phoneOtp: $phoneOtp, upi: $upi, card: $card, maintenance: $maintenance, maintenanceMessage: $maintenanceMessage, closedAreaIds: $closedAreaIds, minAppVersion: $minAppVersion)';
}


}

/// @nodoc
abstract mixin class _$FeatureFlagsCopyWith<$Res> implements $FeatureFlagsCopyWith<$Res> {
  factory _$FeatureFlagsCopyWith(_FeatureFlags value, $Res Function(_FeatureFlags) _then) = __$FeatureFlagsCopyWithImpl;
@override @useResult
$Res call({
 bool placesSearch, bool supportBot, bool phoneOtp, bool upi, bool card, bool maintenance, String maintenanceMessage, List<String> closedAreaIds, String? minAppVersion
});




}
/// @nodoc
class __$FeatureFlagsCopyWithImpl<$Res>
    implements _$FeatureFlagsCopyWith<$Res> {
  __$FeatureFlagsCopyWithImpl(this._self, this._then);

  final _FeatureFlags _self;
  final $Res Function(_FeatureFlags) _then;

/// Create a copy of FeatureFlags
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placesSearch = null,Object? supportBot = null,Object? phoneOtp = null,Object? upi = null,Object? card = null,Object? maintenance = null,Object? maintenanceMessage = null,Object? closedAreaIds = null,Object? minAppVersion = freezed,}) {
  return _then(_FeatureFlags(
placesSearch: null == placesSearch ? _self.placesSearch : placesSearch // ignore: cast_nullable_to_non_nullable
as bool,supportBot: null == supportBot ? _self.supportBot : supportBot // ignore: cast_nullable_to_non_nullable
as bool,phoneOtp: null == phoneOtp ? _self.phoneOtp : phoneOtp // ignore: cast_nullable_to_non_nullable
as bool,upi: null == upi ? _self.upi : upi // ignore: cast_nullable_to_non_nullable
as bool,card: null == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as bool,maintenance: null == maintenance ? _self.maintenance : maintenance // ignore: cast_nullable_to_non_nullable
as bool,maintenanceMessage: null == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String,closedAreaIds: null == closedAreaIds ? _self._closedAreaIds : closedAreaIds // ignore: cast_nullable_to_non_nullable
as List<String>,minAppVersion: freezed == minAppVersion ? _self.minAppVersion : minAppVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AppConfig {

/// +91 and 10 digits, or null.
 String? get supportPhone; String? get whatsappNumber; String? get supportEmail; bool get announcementEnabled; String get announcementText; AnnouncementTone get announcementTone;
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppConfigCopyWith<AppConfig> get copyWith => _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppConfig&&(identical(other.supportPhone, _this.supportPhone) || other.supportPhone == _this.supportPhone)&&(identical(other.whatsappNumber, _this.whatsappNumber) || other.whatsappNumber == _this.whatsappNumber)&&(identical(other.supportEmail, _this.supportEmail) || other.supportEmail == _this.supportEmail)&&(identical(other.announcementEnabled, _this.announcementEnabled) || other.announcementEnabled == _this.announcementEnabled)&&(identical(other.announcementText, _this.announcementText) || other.announcementText == _this.announcementText)&&(identical(other.announcementTone, _this.announcementTone) || other.announcementTone == _this.announcementTone));
}


@override
int get hashCode {
  final _this = this as AppConfig;
  return Object.hash(runtimeType,_this.supportPhone,_this.whatsappNumber,_this.supportEmail,_this.announcementEnabled,_this.announcementText,_this.announcementTone);
}

@override
String toString() {
  final _this = this as AppConfig;
  return 'AppConfig(supportPhone: ${_this.supportPhone}, whatsappNumber: ${_this.whatsappNumber}, supportEmail: ${_this.supportEmail}, announcementEnabled: ${_this.announcementEnabled}, announcementText: ${_this.announcementText}, announcementTone: ${_this.announcementTone})';
}


}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res>  {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) = _$AppConfigCopyWithImpl;
@useResult
$Res call({
 String? supportPhone, String? whatsappNumber, String? supportEmail, bool announcementEnabled, String announcementText, AnnouncementTone announcementTone
});




}
/// @nodoc
class _$AppConfigCopyWithImpl<$Res>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._self, this._then);

  final AppConfig _self;
  final $Res Function(AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supportPhone = freezed,Object? whatsappNumber = freezed,Object? supportEmail = freezed,Object? announcementEnabled = null,Object? announcementText = null,Object? announcementTone = null,}) {
  return _then(AppConfig(
supportPhone: freezed == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String?,whatsappNumber: freezed == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String?,supportEmail: freezed == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String?,announcementEnabled: null == announcementEnabled ? _self.announcementEnabled : announcementEnabled // ignore: cast_nullable_to_non_nullable
as bool,announcementText: null == announcementText ? _self.announcementText : announcementText // ignore: cast_nullable_to_non_nullable
as String,announcementTone: null == announcementTone ? _self.announcementTone : announcementTone // ignore: cast_nullable_to_non_nullable
as AnnouncementTone,
  ));
}

}


/// Adds pattern-matching-related methods to [AppConfig].
extension AppConfigPatterns on AppConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? supportPhone,  String? whatsappNumber,  String? supportEmail,  bool announcementEnabled,  String announcementText,  AnnouncementTone announcementTone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.supportPhone,_that.whatsappNumber,_that.supportEmail,_that.announcementEnabled,_that.announcementText,_that.announcementTone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? supportPhone,  String? whatsappNumber,  String? supportEmail,  bool announcementEnabled,  String announcementText,  AnnouncementTone announcementTone)  $default,) {final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that.supportPhone,_that.whatsappNumber,_that.supportEmail,_that.announcementEnabled,_that.announcementText,_that.announcementTone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? supportPhone,  String? whatsappNumber,  String? supportEmail,  bool announcementEnabled,  String announcementText,  AnnouncementTone announcementTone)?  $default,) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.supportPhone,_that.whatsappNumber,_that.supportEmail,_that.announcementEnabled,_that.announcementText,_that.announcementTone);case _:
  return null;

}
}

}

/// @nodoc


class _AppConfig extends AppConfig {
  const _AppConfig({this.supportPhone, this.whatsappNumber, this.supportEmail, this.announcementEnabled = false, this.announcementText = '', this.announcementTone = AnnouncementTone.info}): super._();
  

/// +91 and 10 digits, or null.
@override final  String? supportPhone;
@override final  String? whatsappNumber;
@override final  String? supportEmail;
@override@JsonKey() final  bool announcementEnabled;
@override@JsonKey() final  String announcementText;
@override@JsonKey() final  AnnouncementTone announcementTone;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppConfigCopyWith<_AppConfig> get copyWith => __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppConfig&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone)&&(identical(other.whatsappNumber, whatsappNumber) || other.whatsappNumber == whatsappNumber)&&(identical(other.supportEmail, supportEmail) || other.supportEmail == supportEmail)&&(identical(other.announcementEnabled, announcementEnabled) || other.announcementEnabled == announcementEnabled)&&(identical(other.announcementText, announcementText) || other.announcementText == announcementText)&&(identical(other.announcementTone, announcementTone) || other.announcementTone == announcementTone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supportPhone,whatsappNumber,supportEmail,announcementEnabled,announcementText,announcementTone);
}

@override
String toString() {
    return 'AppConfig(supportPhone: $supportPhone, whatsappNumber: $whatsappNumber, supportEmail: $supportEmail, announcementEnabled: $announcementEnabled, announcementText: $announcementText, announcementTone: $announcementTone)';
}


}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(_AppConfig value, $Res Function(_AppConfig) _then) = __$AppConfigCopyWithImpl;
@override @useResult
$Res call({
 String? supportPhone, String? whatsappNumber, String? supportEmail, bool announcementEnabled, String announcementText, AnnouncementTone announcementTone
});




}
/// @nodoc
class __$AppConfigCopyWithImpl<$Res>
    implements _$AppConfigCopyWith<$Res> {
  __$AppConfigCopyWithImpl(this._self, this._then);

  final _AppConfig _self;
  final $Res Function(_AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supportPhone = freezed,Object? whatsappNumber = freezed,Object? supportEmail = freezed,Object? announcementEnabled = null,Object? announcementText = null,Object? announcementTone = null,}) {
  return _then(_AppConfig(
supportPhone: freezed == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String?,whatsappNumber: freezed == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String?,supportEmail: freezed == supportEmail ? _self.supportEmail : supportEmail // ignore: cast_nullable_to_non_nullable
as String?,announcementEnabled: null == announcementEnabled ? _self.announcementEnabled : announcementEnabled // ignore: cast_nullable_to_non_nullable
as bool,announcementText: null == announcementText ? _self.announcementText : announcementText // ignore: cast_nullable_to_non_nullable
as String,announcementTone: null == announcementTone ? _self.announcementTone : announcementTone // ignore: cast_nullable_to_non_nullable
as AnnouncementTone,
  ));
}


}

// dart format on
