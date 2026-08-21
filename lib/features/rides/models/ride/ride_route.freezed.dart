// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteWaypoint {

 LocationPoint get location; int get order;@TimestampConverter() DateTime? get estimatedArrival;
/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteWaypointCopyWith<RouteWaypoint> get copyWith => _$RouteWaypointCopyWithImpl<RouteWaypoint>(this as RouteWaypoint, _$identity);

  /// Serializes this RouteWaypoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteWaypoint&&(identical(other.location, location) || other.location == location)&&(identical(other.order, order) || other.order == order)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,order,estimatedArrival);

@override
String toString() {
  return 'RouteWaypoint(location: $location, order: $order, estimatedArrival: $estimatedArrival)';
}


}

/// @nodoc
abstract mixin class $RouteWaypointCopyWith<$Res>  {
  factory $RouteWaypointCopyWith(RouteWaypoint value, $Res Function(RouteWaypoint) _then) = _$RouteWaypointCopyWithImpl;
@useResult
$Res call({
 LocationPoint location, int order,@TimestampConverter() DateTime? estimatedArrival
});


$LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class _$RouteWaypointCopyWithImpl<$Res>
    implements $RouteWaypointCopyWith<$Res> {
  _$RouteWaypointCopyWithImpl(this._self, this._then);

  final RouteWaypoint _self;
  final $Res Function(RouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? order = null,Object? estimatedArrival = freezed,}) {
  return _then(RouteWaypoint(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteWaypoint].
extension RouteWaypointPatterns on RouteWaypoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteWaypoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteWaypoint value)  $default,){
final _that = this;
switch (_that) {
case _RouteWaypoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteWaypoint value)?  $default,){
final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)  $default,) {final _that = this;
switch (_that) {
case _RouteWaypoint():
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)?  $default,) {final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteWaypoint implements RouteWaypoint {
  const _RouteWaypoint({required this.location, this.order = 0, @TimestampConverter() this.estimatedArrival});
  factory _RouteWaypoint.fromJson(Map<String, dynamic> json) => _$RouteWaypointFromJson(json);

@override final  LocationPoint location;
@override@JsonKey() final  int order;
@override@TimestampConverter() final  DateTime? estimatedArrival;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteWaypointCopyWith<_RouteWaypoint> get copyWith => __$RouteWaypointCopyWithImpl<_RouteWaypoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteWaypointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteWaypoint&&(identical(other.location, location) || other.location == location)&&(identical(other.order, order) || other.order == order)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,order,estimatedArrival);

@override
String toString() {
  return 'RouteWaypoint(location: $location, order: $order, estimatedArrival: $estimatedArrival)';
}


}

/// @nodoc
abstract mixin class _$RouteWaypointCopyWith<$Res> implements $RouteWaypointCopyWith<$Res> {
  factory _$RouteWaypointCopyWith(_RouteWaypoint value, $Res Function(_RouteWaypoint) _then) = __$RouteWaypointCopyWithImpl;
@override @useResult
$Res call({
 LocationPoint location, int order,@TimestampConverter() DateTime? estimatedArrival
});


@override $LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class __$RouteWaypointCopyWithImpl<$Res>
    implements _$RouteWaypointCopyWith<$Res> {
  __$RouteWaypointCopyWithImpl(this._self, this._then);

  final _RouteWaypoint _self;
  final $Res Function(_RouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? order = null,Object? estimatedArrival = freezed,}) {
  return _then(_RouteWaypoint(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$RideRoute {

 LocationPoint get origin; LocationPoint get destination; List<RouteWaypoint> get waypoints; double? get distanceKm; int? get durationMinutes; String? get polylineEncoded;
/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideRouteCopyWith<RideRoute> get copyWith => _$RideRouteCopyWithImpl<RideRoute>(this as RideRoute, _$identity);

  /// Serializes this RideRoute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideRoute&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.waypoints, waypoints)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.polylineEncoded, polylineEncoded) || other.polylineEncoded == polylineEncoded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,const DeepCollectionEquality().hash(waypoints),distanceKm,durationMinutes,polylineEncoded);

@override
String toString() {
  return 'RideRoute(origin: $origin, destination: $destination, waypoints: $waypoints, distanceKm: $distanceKm, durationMinutes: $durationMinutes, polylineEncoded: $polylineEncoded)';
}


}

/// @nodoc
abstract mixin class $RideRouteCopyWith<$Res>  {
  factory $RideRouteCopyWith(RideRoute value, $Res Function(RideRoute) _then) = _$RideRouteCopyWithImpl;
@useResult
$Res call({
 LocationPoint origin, LocationPoint destination, List<RouteWaypoint> waypoints, double? distanceKm, int? durationMinutes, String? polylineEncoded
});


$LocationPointCopyWith<$Res> get origin;$LocationPointCopyWith<$Res> get destination;

}
/// @nodoc
class _$RideRouteCopyWithImpl<$Res>
    implements $RideRouteCopyWith<$Res> {
  _$RideRouteCopyWithImpl(this._self, this._then);

  final RideRoute _self;
  final $Res Function(RideRoute) _then;

/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = null,Object? destination = null,Object? waypoints = null,Object? distanceKm = freezed,Object? durationMinutes = freezed,Object? polylineEncoded = freezed,}) {
  return _then(RideRoute(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint,waypoints: null == waypoints ? _self.waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,polylineEncoded: freezed == polylineEncoded ? _self.polylineEncoded : polylineEncoded // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get origin {
  
  return $LocationPointCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get destination {
  
  return $LocationPointCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideRoute].
extension RideRoutePatterns on RideRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideRoute value)  $default,){
final _that = this;
switch (_that) {
case _RideRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideRoute value)?  $default,){
final _that = this;
switch (_that) {
case _RideRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideRoute() when $default != null:
return $default(_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded)  $default,) {final _that = this;
switch (_that) {
case _RideRoute():
return $default(_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded)?  $default,) {final _that = this;
switch (_that) {
case _RideRoute() when $default != null:
return $default(_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideRoute extends RideRoute {
  const _RideRoute({required this.origin, required this.destination,  List<RouteWaypoint> waypoints = const [], this.distanceKm, this.durationMinutes, this.polylineEncoded}): _waypoints = waypoints,super._();
  factory _RideRoute.fromJson(Map<String, dynamic> json) => _$RideRouteFromJson(json);

@override final  LocationPoint origin;
@override final  LocationPoint destination;
 final  List<RouteWaypoint> _waypoints;
@override@JsonKey() List<RouteWaypoint> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}

@override final  double? distanceKm;
@override final  int? durationMinutes;
@override final  String? polylineEncoded;

/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideRouteCopyWith<_RideRoute> get copyWith => __$RideRouteCopyWithImpl<_RideRoute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideRouteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideRoute&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.polylineEncoded, polylineEncoded) || other.polylineEncoded == polylineEncoded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,const DeepCollectionEquality().hash(_waypoints),distanceKm,durationMinutes,polylineEncoded);

@override
String toString() {
  return 'RideRoute(origin: $origin, destination: $destination, waypoints: $waypoints, distanceKm: $distanceKm, durationMinutes: $durationMinutes, polylineEncoded: $polylineEncoded)';
}


}

/// @nodoc
abstract mixin class _$RideRouteCopyWith<$Res> implements $RideRouteCopyWith<$Res> {
  factory _$RideRouteCopyWith(_RideRoute value, $Res Function(_RideRoute) _then) = __$RideRouteCopyWithImpl;
@override @useResult
$Res call({
 LocationPoint origin, LocationPoint destination, List<RouteWaypoint> waypoints, double? distanceKm, int? durationMinutes, String? polylineEncoded
});


@override $LocationPointCopyWith<$Res> get origin;@override $LocationPointCopyWith<$Res> get destination;

}
/// @nodoc
class __$RideRouteCopyWithImpl<$Res>
    implements _$RideRouteCopyWith<$Res> {
  __$RideRouteCopyWithImpl(this._self, this._then);

  final _RideRoute _self;
  final $Res Function(_RideRoute) _then;

/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = null,Object? destination = null,Object? waypoints = null,Object? distanceKm = freezed,Object? durationMinutes = freezed,Object? polylineEncoded = freezed,}) {
  return _then(_RideRoute(
origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,polylineEncoded: freezed == polylineEncoded ? _self.polylineEncoded : polylineEncoded // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get origin {
  
  return $LocationPointCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideRoute
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get destination {
  
  return $LocationPointCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
