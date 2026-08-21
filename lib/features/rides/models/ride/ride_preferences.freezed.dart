// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RidePreferences {

 bool get allowPets; bool get allowSmoking; bool get allowLuggage; bool get isWomenOnly;
/// Create a copy of RidePreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePreferencesCopyWith<RidePreferences> get copyWith => _$RidePreferencesCopyWithImpl<RidePreferences>(this as RidePreferences, _$identity);

  /// Serializes this RidePreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePreferences&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.allowLuggage, allowLuggage) || other.allowLuggage == allowLuggage)&&(identical(other.isWomenOnly, isWomenOnly) || other.isWomenOnly == isWomenOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowPets,allowSmoking,allowLuggage,isWomenOnly);

@override
String toString() {
  return 'RidePreferences(allowPets: $allowPets, allowSmoking: $allowSmoking, allowLuggage: $allowLuggage, isWomenOnly: $isWomenOnly)';
}


}

/// @nodoc
abstract mixin class $RidePreferencesCopyWith<$Res>  {
  factory $RidePreferencesCopyWith(RidePreferences value, $Res Function(RidePreferences) _then) = _$RidePreferencesCopyWithImpl;
@useResult
$Res call({
 bool allowPets, bool allowSmoking, bool allowLuggage, bool isWomenOnly
});




}
/// @nodoc
class _$RidePreferencesCopyWithImpl<$Res>
    implements $RidePreferencesCopyWith<$Res> {
  _$RidePreferencesCopyWithImpl(this._self, this._then);

  final RidePreferences _self;
  final $Res Function(RidePreferences) _then;

/// Create a copy of RidePreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowPets = null,Object? allowSmoking = null,Object? allowLuggage = null,Object? isWomenOnly = null,}) {
  return _then(RidePreferences(
allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,allowLuggage: null == allowLuggage ? _self.allowLuggage : allowLuggage // ignore: cast_nullable_to_non_nullable
as bool,isWomenOnly: null == isWomenOnly ? _self.isWomenOnly : isWomenOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RidePreferences].
extension RidePreferencesPatterns on RidePreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePreferences value)  $default,){
final _that = this;
switch (_that) {
case _RidePreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePreferences value)?  $default,){
final _that = this;
switch (_that) {
case _RidePreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePreferences() when $default != null:
return $default(_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly)  $default,) {final _that = this;
switch (_that) {
case _RidePreferences():
return $default(_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly)?  $default,) {final _that = this;
switch (_that) {
case _RidePreferences() when $default != null:
return $default(_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RidePreferences extends RidePreferences {
  const _RidePreferences({this.allowPets = false, this.allowSmoking = false, this.allowLuggage = true, this.isWomenOnly = false}): super._();
  factory _RidePreferences.fromJson(Map<String, dynamic> json) => _$RidePreferencesFromJson(json);

@override@JsonKey() final  bool allowPets;
@override@JsonKey() final  bool allowSmoking;
@override@JsonKey() final  bool allowLuggage;
@override@JsonKey() final  bool isWomenOnly;

/// Create a copy of RidePreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePreferencesCopyWith<_RidePreferences> get copyWith => __$RidePreferencesCopyWithImpl<_RidePreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePreferences&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.allowLuggage, allowLuggage) || other.allowLuggage == allowLuggage)&&(identical(other.isWomenOnly, isWomenOnly) || other.isWomenOnly == isWomenOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,allowPets,allowSmoking,allowLuggage,isWomenOnly);

@override
String toString() {
  return 'RidePreferences(allowPets: $allowPets, allowSmoking: $allowSmoking, allowLuggage: $allowLuggage, isWomenOnly: $isWomenOnly)';
}


}

/// @nodoc
abstract mixin class _$RidePreferencesCopyWith<$Res> implements $RidePreferencesCopyWith<$Res> {
  factory _$RidePreferencesCopyWith(_RidePreferences value, $Res Function(_RidePreferences) _then) = __$RidePreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool allowPets, bool allowSmoking, bool allowLuggage, bool isWomenOnly
});




}
/// @nodoc
class __$RidePreferencesCopyWithImpl<$Res>
    implements _$RidePreferencesCopyWith<$Res> {
  __$RidePreferencesCopyWithImpl(this._self, this._then);

  final _RidePreferences _self;
  final $Res Function(_RidePreferences) _then;

/// Create a copy of RidePreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowPets = null,Object? allowSmoking = null,Object? allowLuggage = null,Object? isWomenOnly = null,}) {
  return _then(_RidePreferences(
allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,allowLuggage: null == allowLuggage ? _self.allowLuggage : allowLuggage // ignore: cast_nullable_to_non_nullable
as bool,isWomenOnly: null == isWomenOnly ? _self.isWomenOnly : isWomenOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
