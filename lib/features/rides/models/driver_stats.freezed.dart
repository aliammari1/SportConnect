// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverStats {

 String get driverId; double get rating; int get totalRides; int get ridesToday; int get ridesThisWeek; int get ridesThisMonth; int get pendingRequests; int get totalEarningsInCents; int get earningsTodayInCents; int get earningsThisWeekInCents; int get earningsThisMonthInCents; int get totalSpentInCents; double get totalDistance;@TimestampConverter() DateTime? get lastRideAt;
/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<DriverStats> get copyWith => _$DriverStatsCopyWithImpl<DriverStats>(this as DriverStats, _$identity);

  /// Serializes this DriverStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesToday, ridesToday) || other.ridesToday == ridesToday)&&(identical(other.ridesThisWeek, ridesThisWeek) || other.ridesThisWeek == ridesThisWeek)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.earningsTodayInCents, earningsTodayInCents) || other.earningsTodayInCents == earningsTodayInCents)&&(identical(other.earningsThisWeekInCents, earningsThisWeekInCents) || other.earningsThisWeekInCents == earningsThisWeekInCents)&&(identical(other.earningsThisMonthInCents, earningsThisMonthInCents) || other.earningsThisMonthInCents == earningsThisMonthInCents)&&(identical(other.totalSpentInCents, totalSpentInCents) || other.totalSpentInCents == totalSpentInCents)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,rating,totalRides,ridesToday,ridesThisWeek,ridesThisMonth,pendingRequests,totalEarningsInCents,earningsTodayInCents,earningsThisWeekInCents,earningsThisMonthInCents,totalSpentInCents,totalDistance,lastRideAt);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, rating: $rating, totalRides: $totalRides, ridesToday: $ridesToday, ridesThisWeek: $ridesThisWeek, ridesThisMonth: $ridesThisMonth, pendingRequests: $pendingRequests, totalEarningsInCents: $totalEarningsInCents, earningsTodayInCents: $earningsTodayInCents, earningsThisWeekInCents: $earningsThisWeekInCents, earningsThisMonthInCents: $earningsThisMonthInCents, totalSpentInCents: $totalSpentInCents, totalDistance: $totalDistance, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class $DriverStatsCopyWith<$Res>  {
  factory $DriverStatsCopyWith(DriverStats value, $Res Function(DriverStats) _then) = _$DriverStatsCopyWithImpl;
@useResult
$Res call({
 String driverId, double rating, int totalRides, int ridesToday, int ridesThisWeek, int ridesThisMonth, int pendingRequests, int totalEarningsInCents, int earningsTodayInCents, int earningsThisWeekInCents, int earningsThisMonthInCents, int totalSpentInCents, double totalDistance,@TimestampConverter() DateTime? lastRideAt
});




}
/// @nodoc
class _$DriverStatsCopyWithImpl<$Res>
    implements $DriverStatsCopyWith<$Res> {
  _$DriverStatsCopyWithImpl(this._self, this._then);

  final DriverStats _self;
  final $Res Function(DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? rating = null,Object? totalRides = null,Object? ridesToday = null,Object? ridesThisWeek = null,Object? ridesThisMonth = null,Object? pendingRequests = null,Object? totalEarningsInCents = null,Object? earningsTodayInCents = null,Object? earningsThisWeekInCents = null,Object? earningsThisMonthInCents = null,Object? totalSpentInCents = null,Object? totalDistance = null,Object? lastRideAt = freezed,}) {
  return _then(DriverStats(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesToday: null == ridesToday ? _self.ridesToday : ridesToday // ignore: cast_nullable_to_non_nullable
as int,ridesThisWeek: null == ridesThisWeek ? _self.ridesThisWeek : ridesThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,earningsTodayInCents: null == earningsTodayInCents ? _self.earningsTodayInCents : earningsTodayInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisWeekInCents: null == earningsThisWeekInCents ? _self.earningsThisWeekInCents : earningsThisWeekInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisMonthInCents: null == earningsThisMonthInCents ? _self.earningsThisMonthInCents : earningsThisMonthInCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentInCents: null == totalSpentInCents ? _self.totalSpentInCents : totalSpentInCents // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverStats].
extension DriverStatsPatterns on DriverStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverStats value)  $default,){
final _that = this;
switch (_that) {
case _DriverStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverStats value)?  $default,){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  double rating,  int totalRides,  int ridesToday,  int ridesThisWeek,  int ridesThisMonth,  int pendingRequests,  int totalEarningsInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int totalSpentInCents,  double totalDistance, @TimestampConverter()  DateTime? lastRideAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesToday,_that.ridesThisWeek,_that.ridesThisMonth,_that.pendingRequests,_that.totalEarningsInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.totalSpentInCents,_that.totalDistance,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  double rating,  int totalRides,  int ridesToday,  int ridesThisWeek,  int ridesThisMonth,  int pendingRequests,  int totalEarningsInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int totalSpentInCents,  double totalDistance, @TimestampConverter()  DateTime? lastRideAt)  $default,) {final _that = this;
switch (_that) {
case _DriverStats():
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesToday,_that.ridesThisWeek,_that.ridesThisMonth,_that.pendingRequests,_that.totalEarningsInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.totalSpentInCents,_that.totalDistance,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  double rating,  int totalRides,  int ridesToday,  int ridesThisWeek,  int ridesThisMonth,  int pendingRequests,  int totalEarningsInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int totalSpentInCents,  double totalDistance, @TimestampConverter()  DateTime? lastRideAt)?  $default,) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesToday,_that.ridesThisWeek,_that.ridesThisMonth,_that.pendingRequests,_that.totalEarningsInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.totalSpentInCents,_that.totalDistance,_that.lastRideAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverStats extends DriverStats {
  const _DriverStats({this.driverId = '', this.rating = 0.0, this.totalRides = 0, this.ridesToday = 0, this.ridesThisWeek = 0, this.ridesThisMonth = 0, this.pendingRequests = 0, this.totalEarningsInCents = 0, this.earningsTodayInCents = 0, this.earningsThisWeekInCents = 0, this.earningsThisMonthInCents = 0, this.totalSpentInCents = 0, this.totalDistance = 0.0, @TimestampConverter() this.lastRideAt = null}): super._();
  factory _DriverStats.fromJson(Map<String, dynamic> json) => _$DriverStatsFromJson(json);

@override@JsonKey() final  String driverId;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int ridesToday;
@override@JsonKey() final  int ridesThisWeek;
@override@JsonKey() final  int ridesThisMonth;
@override@JsonKey() final  int pendingRequests;
@override@JsonKey() final  int totalEarningsInCents;
@override@JsonKey() final  int earningsTodayInCents;
@override@JsonKey() final  int earningsThisWeekInCents;
@override@JsonKey() final  int earningsThisMonthInCents;
@override@JsonKey() final  int totalSpentInCents;
@override@JsonKey() final  double totalDistance;
@override@JsonKey()@TimestampConverter() final  DateTime? lastRideAt;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverStatsCopyWith<_DriverStats> get copyWith => __$DriverStatsCopyWithImpl<_DriverStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesToday, ridesToday) || other.ridesToday == ridesToday)&&(identical(other.ridesThisWeek, ridesThisWeek) || other.ridesThisWeek == ridesThisWeek)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.earningsTodayInCents, earningsTodayInCents) || other.earningsTodayInCents == earningsTodayInCents)&&(identical(other.earningsThisWeekInCents, earningsThisWeekInCents) || other.earningsThisWeekInCents == earningsThisWeekInCents)&&(identical(other.earningsThisMonthInCents, earningsThisMonthInCents) || other.earningsThisMonthInCents == earningsThisMonthInCents)&&(identical(other.totalSpentInCents, totalSpentInCents) || other.totalSpentInCents == totalSpentInCents)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,rating,totalRides,ridesToday,ridesThisWeek,ridesThisMonth,pendingRequests,totalEarningsInCents,earningsTodayInCents,earningsThisWeekInCents,earningsThisMonthInCents,totalSpentInCents,totalDistance,lastRideAt);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, rating: $rating, totalRides: $totalRides, ridesToday: $ridesToday, ridesThisWeek: $ridesThisWeek, ridesThisMonth: $ridesThisMonth, pendingRequests: $pendingRequests, totalEarningsInCents: $totalEarningsInCents, earningsTodayInCents: $earningsTodayInCents, earningsThisWeekInCents: $earningsThisWeekInCents, earningsThisMonthInCents: $earningsThisMonthInCents, totalSpentInCents: $totalSpentInCents, totalDistance: $totalDistance, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class _$DriverStatsCopyWith<$Res> implements $DriverStatsCopyWith<$Res> {
  factory _$DriverStatsCopyWith(_DriverStats value, $Res Function(_DriverStats) _then) = __$DriverStatsCopyWithImpl;
@override @useResult
$Res call({
 String driverId, double rating, int totalRides, int ridesToday, int ridesThisWeek, int ridesThisMonth, int pendingRequests, int totalEarningsInCents, int earningsTodayInCents, int earningsThisWeekInCents, int earningsThisMonthInCents, int totalSpentInCents, double totalDistance,@TimestampConverter() DateTime? lastRideAt
});




}
/// @nodoc
class __$DriverStatsCopyWithImpl<$Res>
    implements _$DriverStatsCopyWith<$Res> {
  __$DriverStatsCopyWithImpl(this._self, this._then);

  final _DriverStats _self;
  final $Res Function(_DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? rating = null,Object? totalRides = null,Object? ridesToday = null,Object? ridesThisWeek = null,Object? ridesThisMonth = null,Object? pendingRequests = null,Object? totalEarningsInCents = null,Object? earningsTodayInCents = null,Object? earningsThisWeekInCents = null,Object? earningsThisMonthInCents = null,Object? totalSpentInCents = null,Object? totalDistance = null,Object? lastRideAt = freezed,}) {
  return _then(_DriverStats(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesToday: null == ridesToday ? _self.ridesToday : ridesToday // ignore: cast_nullable_to_non_nullable
as int,ridesThisWeek: null == ridesThisWeek ? _self.ridesThisWeek : ridesThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,earningsTodayInCents: null == earningsTodayInCents ? _self.earningsTodayInCents : earningsTodayInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisWeekInCents: null == earningsThisWeekInCents ? _self.earningsThisWeekInCents : earningsThisWeekInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisMonthInCents: null == earningsThisMonthInCents ? _self.earningsThisMonthInCents : earningsThisMonthInCents // ignore: cast_nullable_to_non_nullable
as int,totalSpentInCents: null == totalSpentInCents ? _self.totalSpentInCents : totalSpentInCents // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EarningsTransaction {

 String get id; String get rideId; int get amountInCents; String get description;@RequiredTimestampConverter() DateTime get createdAt; EarningsTransactionType get type;
/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsTransactionCopyWith<EarningsTransaction> get copyWith => _$EarningsTransactionCopyWithImpl<EarningsTransaction>(this as EarningsTransaction, _$identity);

  /// Serializes this EarningsTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,amountInCents,description,createdAt,type);

@override
String toString() {
  return 'EarningsTransaction(id: $id, rideId: $rideId, amountInCents: $amountInCents, description: $description, createdAt: $createdAt, type: $type)';
}


}

/// @nodoc
abstract mixin class $EarningsTransactionCopyWith<$Res>  {
  factory $EarningsTransactionCopyWith(EarningsTransaction value, $Res Function(EarningsTransaction) _then) = _$EarningsTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, int amountInCents, String description,@RequiredTimestampConverter() DateTime createdAt, EarningsTransactionType type
});




}
/// @nodoc
class _$EarningsTransactionCopyWithImpl<$Res>
    implements $EarningsTransactionCopyWith<$Res> {
  _$EarningsTransactionCopyWithImpl(this._self, this._then);

  final EarningsTransaction _self;
  final $Res Function(EarningsTransaction) _then;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? amountInCents = null,Object? description = null,Object? createdAt = null,Object? type = null,}) {
  return _then(EarningsTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EarningsTransactionType,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsTransaction].
extension EarningsTransactionPatterns on EarningsTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsTransaction value)  $default,){
final _that = this;
switch (_that) {
case _EarningsTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  int amountInCents,  String description, @RequiredTimestampConverter()  DateTime createdAt,  EarningsTransactionType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.amountInCents,_that.description,_that.createdAt,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  int amountInCents,  String description, @RequiredTimestampConverter()  DateTime createdAt,  EarningsTransactionType type)  $default,) {final _that = this;
switch (_that) {
case _EarningsTransaction():
return $default(_that.id,_that.rideId,_that.amountInCents,_that.description,_that.createdAt,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  int amountInCents,  String description, @RequiredTimestampConverter()  DateTime createdAt,  EarningsTransactionType type)?  $default,) {final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.amountInCents,_that.description,_that.createdAt,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsTransaction extends EarningsTransaction {
  const _EarningsTransaction({required this.id, required this.rideId, required this.amountInCents, required this.description, @RequiredTimestampConverter() required this.createdAt, this.type = EarningsTransactionType.ride}): super._();
  factory _EarningsTransaction.fromJson(Map<String, dynamic> json) => _$EarningsTransactionFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  int amountInCents;
@override final  String description;
@override@RequiredTimestampConverter() final  DateTime createdAt;
@override@JsonKey() final  EarningsTransactionType type;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsTransactionCopyWith<_EarningsTransaction> get copyWith => __$EarningsTransactionCopyWithImpl<_EarningsTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,amountInCents,description,createdAt,type);

@override
String toString() {
  return 'EarningsTransaction(id: $id, rideId: $rideId, amountInCents: $amountInCents, description: $description, createdAt: $createdAt, type: $type)';
}


}

/// @nodoc
abstract mixin class _$EarningsTransactionCopyWith<$Res> implements $EarningsTransactionCopyWith<$Res> {
  factory _$EarningsTransactionCopyWith(_EarningsTransaction value, $Res Function(_EarningsTransaction) _then) = __$EarningsTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, int amountInCents, String description,@RequiredTimestampConverter() DateTime createdAt, EarningsTransactionType type
});




}
/// @nodoc
class __$EarningsTransactionCopyWithImpl<$Res>
    implements _$EarningsTransactionCopyWith<$Res> {
  __$EarningsTransactionCopyWithImpl(this._self, this._then);

  final _EarningsTransaction _self;
  final $Res Function(_EarningsTransaction) _then;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? amountInCents = null,Object? description = null,Object? createdAt = null,Object? type = null,}) {
  return _then(_EarningsTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EarningsTransactionType,
  ));
}


}

// dart format on
