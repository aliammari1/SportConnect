// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_search_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideSearchFilters {

 LocationPoint? get origin; LocationPoint? get destination;@TimestampConverter() DateTime? get departureDate;@TimestampConverter() DateTime? get departureTimeFrom;@TimestampConverter() DateTime? get departureTimeTo; int get minSeats; int? get maxPrice; bool get allowPets; bool get allowSmoking; bool get womenOnly; double? get minDriverRating; String get sortBy; bool get sortAscending;
/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSearchFiltersCopyWith<RideSearchFilters> get copyWith => _$RideSearchFiltersCopyWithImpl<RideSearchFilters>(this as RideSearchFilters, _$identity);

  /// Serializes this RideSearchFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSearchFilters&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.departureTimeTo, departureTimeTo) || other.departureTimeTo == departureTimeTo)&&(identical(other.minSeats, minSeats) || other.minSeats == minSeats)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.womenOnly, womenOnly) || other.womenOnly == womenOnly)&&(identical(other.minDriverRating, minDriverRating) || other.minDriverRating == minDriverRating)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureTimeFrom,departureTimeTo,minSeats,maxPrice,allowPets,allowSmoking,womenOnly,minDriverRating,sortBy,sortAscending);

@override
String toString() {
  return 'RideSearchFilters(origin: $origin, destination: $destination, departureDate: $departureDate, departureTimeFrom: $departureTimeFrom, departureTimeTo: $departureTimeTo, minSeats: $minSeats, maxPrice: $maxPrice, allowPets: $allowPets, allowSmoking: $allowSmoking, womenOnly: $womenOnly, minDriverRating: $minDriverRating, sortBy: $sortBy, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class $RideSearchFiltersCopyWith<$Res>  {
  factory $RideSearchFiltersCopyWith(RideSearchFilters value, $Res Function(RideSearchFilters) _then) = _$RideSearchFiltersCopyWithImpl;
@useResult
$Res call({
 LocationPoint? origin, LocationPoint? destination,@TimestampConverter() DateTime? departureDate,@TimestampConverter() DateTime? departureTimeFrom,@TimestampConverter() DateTime? departureTimeTo, int minSeats, int? maxPrice, bool allowPets, bool allowSmoking, bool womenOnly, double? minDriverRating, String sortBy, bool sortAscending
});


$LocationPointCopyWith<$Res>? get origin;$LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class _$RideSearchFiltersCopyWithImpl<$Res>
    implements $RideSearchFiltersCopyWith<$Res> {
  _$RideSearchFiltersCopyWithImpl(this._self, this._then);

  final RideSearchFilters _self;
  final $Res Function(RideSearchFilters) _then;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureTimeFrom = freezed,Object? departureTimeTo = freezed,Object? minSeats = null,Object? maxPrice = freezed,Object? allowPets = null,Object? allowSmoking = null,Object? womenOnly = null,Object? minDriverRating = freezed,Object? sortBy = null,Object? sortAscending = null,}) {
  return _then(_self.copyWith(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeTo: freezed == departureTimeTo ? _self.departureTimeTo : departureTimeTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minSeats: null == minSeats ? _self.minSeats : minSeats // ignore: cast_nullable_to_non_nullable
as int,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,womenOnly: null == womenOnly ? _self.womenOnly : womenOnly // ignore: cast_nullable_to_non_nullable
as bool,minDriverRating: freezed == minDriverRating ? _self.minDriverRating : minDriverRating // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideSearchFilters].
extension RideSearchFiltersPatterns on RideSearchFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSearchFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSearchFilters value)  $default,){
final _that = this;
switch (_that) {
case _RideSearchFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSearchFilters value)?  $default,){
final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  int? maxPrice,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  int? maxPrice,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)  $default,) {final _that = this;
switch (_that) {
case _RideSearchFilters():
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  int? maxPrice,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)?  $default,) {final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideSearchFilters extends RideSearchFilters {
  const _RideSearchFilters({this.origin, this.destination, @TimestampConverter() this.departureDate, @TimestampConverter() this.departureTimeFrom, @TimestampConverter() this.departureTimeTo, this.minSeats = 1, this.maxPrice, this.allowPets = false, this.allowSmoking = false, this.womenOnly = false, this.minDriverRating, this.sortBy = 'departure_time', this.sortAscending = true}): super._();
  factory _RideSearchFilters.fromJson(Map<String, dynamic> json) => _$RideSearchFiltersFromJson(json);

@override final  LocationPoint? origin;
@override final  LocationPoint? destination;
@override@TimestampConverter() final  DateTime? departureDate;
@override@TimestampConverter() final  DateTime? departureTimeFrom;
@override@TimestampConverter() final  DateTime? departureTimeTo;
@override@JsonKey() final  int minSeats;
@override final  int? maxPrice;
@override@JsonKey() final  bool allowPets;
@override@JsonKey() final  bool allowSmoking;
@override@JsonKey() final  bool womenOnly;
@override final  double? minDriverRating;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortAscending;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSearchFiltersCopyWith<_RideSearchFilters> get copyWith => __$RideSearchFiltersCopyWithImpl<_RideSearchFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideSearchFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSearchFilters&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.departureTimeTo, departureTimeTo) || other.departureTimeTo == departureTimeTo)&&(identical(other.minSeats, minSeats) || other.minSeats == minSeats)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.womenOnly, womenOnly) || other.womenOnly == womenOnly)&&(identical(other.minDriverRating, minDriverRating) || other.minDriverRating == minDriverRating)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureTimeFrom,departureTimeTo,minSeats,maxPrice,allowPets,allowSmoking,womenOnly,minDriverRating,sortBy,sortAscending);

@override
String toString() {
  return 'RideSearchFilters(origin: $origin, destination: $destination, departureDate: $departureDate, departureTimeFrom: $departureTimeFrom, departureTimeTo: $departureTimeTo, minSeats: $minSeats, maxPrice: $maxPrice, allowPets: $allowPets, allowSmoking: $allowSmoking, womenOnly: $womenOnly, minDriverRating: $minDriverRating, sortBy: $sortBy, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class _$RideSearchFiltersCopyWith<$Res> implements $RideSearchFiltersCopyWith<$Res> {
  factory _$RideSearchFiltersCopyWith(_RideSearchFilters value, $Res Function(_RideSearchFilters) _then) = __$RideSearchFiltersCopyWithImpl;
@override @useResult
$Res call({
 LocationPoint? origin, LocationPoint? destination,@TimestampConverter() DateTime? departureDate,@TimestampConverter() DateTime? departureTimeFrom,@TimestampConverter() DateTime? departureTimeTo, int minSeats, int? maxPrice, bool allowPets, bool allowSmoking, bool womenOnly, double? minDriverRating, String sortBy, bool sortAscending
});


@override $LocationPointCopyWith<$Res>? get origin;@override $LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class __$RideSearchFiltersCopyWithImpl<$Res>
    implements _$RideSearchFiltersCopyWith<$Res> {
  __$RideSearchFiltersCopyWithImpl(this._self, this._then);

  final _RideSearchFilters _self;
  final $Res Function(_RideSearchFilters) _then;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureTimeFrom = freezed,Object? departureTimeTo = freezed,Object? minSeats = null,Object? maxPrice = freezed,Object? allowPets = null,Object? allowSmoking = null,Object? womenOnly = null,Object? minDriverRating = freezed,Object? sortBy = null,Object? sortAscending = null,}) {
  return _then(_RideSearchFilters(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeTo: freezed == departureTimeTo ? _self.departureTimeTo : departureTimeTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minSeats: null == minSeats ? _self.minSeats : minSeats // ignore: cast_nullable_to_non_nullable
as int,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,womenOnly: null == womenOnly ? _self.womenOnly : womenOnly // ignore: cast_nullable_to_non_nullable
as bool,minDriverRating: freezed == minDriverRating ? _self.minDriverRating : minDriverRating // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
