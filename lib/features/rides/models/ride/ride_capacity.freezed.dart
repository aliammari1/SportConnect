// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_capacity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideCapacity {

 int get available; int get booked;
/// Create a copy of RideCapacity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideCapacityCopyWith<RideCapacity> get copyWith => _$RideCapacityCopyWithImpl<RideCapacity>(this as RideCapacity, _$identity);

  /// Serializes this RideCapacity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideCapacity&&(identical(other.available, available) || other.available == available)&&(identical(other.booked, booked) || other.booked == booked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,booked);

@override
String toString() {
  return 'RideCapacity(available: $available, booked: $booked)';
}


}

/// @nodoc
abstract mixin class $RideCapacityCopyWith<$Res>  {
  factory $RideCapacityCopyWith(RideCapacity value, $Res Function(RideCapacity) _then) = _$RideCapacityCopyWithImpl;
@useResult
$Res call({
 int available, int booked
});




}
/// @nodoc
class _$RideCapacityCopyWithImpl<$Res>
    implements $RideCapacityCopyWith<$Res> {
  _$RideCapacityCopyWithImpl(this._self, this._then);

  final RideCapacity _self;
  final $Res Function(RideCapacity) _then;

/// Create a copy of RideCapacity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? booked = null,}) {
  return _then(RideCapacity(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as int,booked: null == booked ? _self.booked : booked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RideCapacity].
extension RideCapacityPatterns on RideCapacity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideCapacity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideCapacity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideCapacity value)  $default,){
final _that = this;
switch (_that) {
case _RideCapacity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideCapacity value)?  $default,){
final _that = this;
switch (_that) {
case _RideCapacity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int available,  int booked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideCapacity() when $default != null:
return $default(_that.available,_that.booked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int available,  int booked)  $default,) {final _that = this;
switch (_that) {
case _RideCapacity():
return $default(_that.available,_that.booked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int available,  int booked)?  $default,) {final _that = this;
switch (_that) {
case _RideCapacity() when $default != null:
return $default(_that.available,_that.booked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideCapacity extends RideCapacity {
  const _RideCapacity({this.available = 3, this.booked = 0}): super._();
  factory _RideCapacity.fromJson(Map<String, dynamic> json) => _$RideCapacityFromJson(json);

@override@JsonKey() final  int available;
@override@JsonKey() final  int booked;

/// Create a copy of RideCapacity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideCapacityCopyWith<_RideCapacity> get copyWith => __$RideCapacityCopyWithImpl<_RideCapacity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideCapacityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideCapacity&&(identical(other.available, available) || other.available == available)&&(identical(other.booked, booked) || other.booked == booked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,booked);

@override
String toString() {
  return 'RideCapacity(available: $available, booked: $booked)';
}


}

/// @nodoc
abstract mixin class _$RideCapacityCopyWith<$Res> implements $RideCapacityCopyWith<$Res> {
  factory _$RideCapacityCopyWith(_RideCapacity value, $Res Function(_RideCapacity) _then) = __$RideCapacityCopyWithImpl;
@override @useResult
$Res call({
 int available, int booked
});




}
/// @nodoc
class __$RideCapacityCopyWithImpl<$Res>
    implements _$RideCapacityCopyWith<$Res> {
  __$RideCapacityCopyWithImpl(this._self, this._then);

  final _RideCapacity _self;
  final $Res Function(_RideCapacity) _then;

/// Create a copy of RideCapacity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? booked = null,}) {
  return _then(_RideCapacity(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as int,booked: null == booked ? _self.booked : booked // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
