// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_pricing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RidePricing {

 int get pricePerSeatInCents;
/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePricingCopyWith<RidePricing> get copyWith => _$RidePricingCopyWithImpl<RidePricing>(this as RidePricing, _$identity);

  /// Serializes this RidePricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePricing&&(identical(other.pricePerSeatInCents, pricePerSeatInCents) || other.pricePerSeatInCents == pricePerSeatInCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricePerSeatInCents);

@override
String toString() {
  return 'RidePricing(pricePerSeatInCents: $pricePerSeatInCents)';
}


}

/// @nodoc
abstract mixin class $RidePricingCopyWith<$Res>  {
  factory $RidePricingCopyWith(RidePricing value, $Res Function(RidePricing) _then) = _$RidePricingCopyWithImpl;
@useResult
$Res call({
 int pricePerSeatInCents
});




}
/// @nodoc
class _$RidePricingCopyWithImpl<$Res>
    implements $RidePricingCopyWith<$Res> {
  _$RidePricingCopyWithImpl(this._self, this._then);

  final RidePricing _self;
  final $Res Function(RidePricing) _then;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pricePerSeatInCents = null,}) {
  return _then(RidePricing(
pricePerSeatInCents: null == pricePerSeatInCents ? _self.pricePerSeatInCents : pricePerSeatInCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RidePricing].
extension RidePricingPatterns on RidePricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePricing value)  $default,){
final _that = this;
switch (_that) {
case _RidePricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePricing value)?  $default,){
final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pricePerSeatInCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
return $default(_that.pricePerSeatInCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pricePerSeatInCents)  $default,) {final _that = this;
switch (_that) {
case _RidePricing():
return $default(_that.pricePerSeatInCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pricePerSeatInCents)?  $default,) {final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
return $default(_that.pricePerSeatInCents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RidePricing extends RidePricing {
  const _RidePricing({required this.pricePerSeatInCents}): super._();
  factory _RidePricing.fromJson(Map<String, dynamic> json) => _$RidePricingFromJson(json);

@override final  int pricePerSeatInCents;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePricingCopyWith<_RidePricing> get copyWith => __$RidePricingCopyWithImpl<_RidePricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePricing&&(identical(other.pricePerSeatInCents, pricePerSeatInCents) || other.pricePerSeatInCents == pricePerSeatInCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricePerSeatInCents);

@override
String toString() {
  return 'RidePricing(pricePerSeatInCents: $pricePerSeatInCents)';
}


}

/// @nodoc
abstract mixin class _$RidePricingCopyWith<$Res> implements $RidePricingCopyWith<$Res> {
  factory _$RidePricingCopyWith(_RidePricing value, $Res Function(_RidePricing) _then) = __$RidePricingCopyWithImpl;
@override @useResult
$Res call({
 int pricePerSeatInCents
});




}
/// @nodoc
class __$RidePricingCopyWithImpl<$Res>
    implements _$RidePricingCopyWith<$Res> {
  __$RidePricingCopyWithImpl(this._self, this._then);

  final _RidePricing _self;
  final $Res Function(_RidePricing) _then;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pricePerSeatInCents = null,}) {
  return _then(_RidePricing(
pricePerSeatInCents: null == pricePerSeatInCents ? _self.pricePerSeatInCents : pricePerSeatInCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
