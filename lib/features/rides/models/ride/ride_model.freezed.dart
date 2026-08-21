// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideModel {

@JsonKey(includeToJson: false) String get id; String get driverId; RideRoute get route; RideSchedule get schedule; RideCapacity get capacity; RidePricing get pricing; RidePreferences get preferences; String? get eventId; String? get eventName; RideStatus get status; String? get ridePhase; String? get vehicleId; String? get vehicleInfo; List<String> get bookingIds;@JsonKey(includeToJson: false, includeFromJson: false) List<RideBooking> get bookings; int get reviewCount; double get averageRating; int get xpReward; String? get notes; List<String> get tags;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get completedAt;@TimestampConverter() DateTime? get cancelledAt; String? get cancellationReason;
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideModelCopyWith<RideModel> get copyWith => _$RideModelCopyWithImpl<RideModel>(this as RideModel, _$identity);

  /// Serializes this RideModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.route, route) || other.route == route)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.status, status) || other.status == status)&&(identical(other.ridePhase, ridePhase) || other.ridePhase == ridePhase)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&const DeepCollectionEquality().equals(other.bookingIds, bookingIds)&&const DeepCollectionEquality().equals(other.bookings, bookings)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,route,schedule,capacity,pricing,preferences,eventId,eventName,status,ridePhase,vehicleId,vehicleInfo,const DeepCollectionEquality().hash(bookingIds),const DeepCollectionEquality().hash(bookings),reviewCount,averageRating,xpReward,notes,const DeepCollectionEquality().hash(tags),createdAt,updatedAt,completedAt,cancelledAt,cancellationReason]);

@override
String toString() {
  return 'RideModel(id: $id, driverId: $driverId, route: $route, schedule: $schedule, capacity: $capacity, pricing: $pricing, preferences: $preferences, eventId: $eventId, eventName: $eventName, status: $status, ridePhase: $ridePhase, vehicleId: $vehicleId, vehicleInfo: $vehicleInfo, bookingIds: $bookingIds, bookings: $bookings, reviewCount: $reviewCount, averageRating: $averageRating, xpReward: $xpReward, notes: $notes, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason)';
}


}

/// @nodoc
abstract mixin class $RideModelCopyWith<$Res>  {
  factory $RideModelCopyWith(RideModel value, $Res Function(RideModel) _then) = _$RideModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String driverId, RideRoute route, RideSchedule schedule, RideCapacity capacity, RidePricing pricing, RidePreferences preferences, String? eventId, String? eventName, RideStatus status, String? ridePhase, String? vehicleId, String? vehicleInfo, List<String> bookingIds,@JsonKey(includeToJson: false, includeFromJson: false) List<RideBooking> bookings, int reviewCount, double averageRating, int xpReward, String? notes, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? cancelledAt, String? cancellationReason
});


$RideRouteCopyWith<$Res> get route;$RideScheduleCopyWith<$Res> get schedule;$RideCapacityCopyWith<$Res> get capacity;$RidePricingCopyWith<$Res> get pricing;$RidePreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$RideModelCopyWithImpl<$Res>
    implements $RideModelCopyWith<$Res> {
  _$RideModelCopyWithImpl(this._self, this._then);

  final RideModel _self;
  final $Res Function(RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? route = null,Object? schedule = null,Object? capacity = null,Object? pricing = null,Object? preferences = null,Object? eventId = freezed,Object? eventName = freezed,Object? status = null,Object? ridePhase = freezed,Object? vehicleId = freezed,Object? vehicleInfo = freezed,Object? bookingIds = null,Object? bookings = null,Object? reviewCount = null,Object? averageRating = null,Object? xpReward = null,Object? notes = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? cancellationReason = freezed,}) {
  return _then(RideModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RideRoute,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as RideSchedule,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as RideCapacity,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as RidePricing,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as RidePreferences,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,ridePhase: freezed == ridePhase ? _self.ridePhase : ridePhase // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as String?,bookingIds: null == bookingIds ? _self.bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<String>,bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRouteCopyWith<$Res> get route {
  
  return $RideRouteCopyWith<$Res>(_self.route, (value) {
    return _then(_self.copyWith(route: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideScheduleCopyWith<$Res> get schedule {
  
  return $RideScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideCapacityCopyWith<$Res> get capacity {
  
  return $RideCapacityCopyWith<$Res>(_self.capacity, (value) {
    return _then(_self.copyWith(capacity: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePricingCopyWith<$Res> get pricing {
  
  return $RidePricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePreferencesCopyWith<$Res> get preferences {
  
  return $RidePreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideModel].
extension RideModelPatterns on RideModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideModel value)  $default,){
final _that = this;
switch (_that) {
case _RideModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String driverId,  RideRoute route,  RideSchedule schedule,  RideCapacity capacity,  RidePricing pricing,  RidePreferences preferences,  String? eventId,  String? eventName,  RideStatus status,  String? ridePhase,  String? vehicleId,  String? vehicleInfo,  List<String> bookingIds, @JsonKey(includeToJson: false, includeFromJson: false)  List<RideBooking> bookings,  int reviewCount,  double averageRating,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? cancelledAt,  String? cancellationReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.driverId,_that.route,_that.schedule,_that.capacity,_that.pricing,_that.preferences,_that.eventId,_that.eventName,_that.status,_that.ridePhase,_that.vehicleId,_that.vehicleInfo,_that.bookingIds,_that.bookings,_that.reviewCount,_that.averageRating,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt,_that.completedAt,_that.cancelledAt,_that.cancellationReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String driverId,  RideRoute route,  RideSchedule schedule,  RideCapacity capacity,  RidePricing pricing,  RidePreferences preferences,  String? eventId,  String? eventName,  RideStatus status,  String? ridePhase,  String? vehicleId,  String? vehicleInfo,  List<String> bookingIds, @JsonKey(includeToJson: false, includeFromJson: false)  List<RideBooking> bookings,  int reviewCount,  double averageRating,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? cancelledAt,  String? cancellationReason)  $default,) {final _that = this;
switch (_that) {
case _RideModel():
return $default(_that.id,_that.driverId,_that.route,_that.schedule,_that.capacity,_that.pricing,_that.preferences,_that.eventId,_that.eventName,_that.status,_that.ridePhase,_that.vehicleId,_that.vehicleInfo,_that.bookingIds,_that.bookings,_that.reviewCount,_that.averageRating,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt,_that.completedAt,_that.cancelledAt,_that.cancellationReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String driverId,  RideRoute route,  RideSchedule schedule,  RideCapacity capacity,  RidePricing pricing,  RidePreferences preferences,  String? eventId,  String? eventName,  RideStatus status,  String? ridePhase,  String? vehicleId,  String? vehicleInfo,  List<String> bookingIds, @JsonKey(includeToJson: false, includeFromJson: false)  List<RideBooking> bookings,  int reviewCount,  double averageRating,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? cancelledAt,  String? cancellationReason)?  $default,) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.driverId,_that.route,_that.schedule,_that.capacity,_that.pricing,_that.preferences,_that.eventId,_that.eventName,_that.status,_that.ridePhase,_that.vehicleId,_that.vehicleInfo,_that.bookingIds,_that.bookings,_that.reviewCount,_that.averageRating,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt,_that.completedAt,_that.cancelledAt,_that.cancellationReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideModel extends RideModel {
  const _RideModel({@JsonKey(includeToJson: false) required this.id, required this.driverId, required this.route, required this.schedule, required this.capacity, required this.pricing, required this.preferences, this.eventId, this.eventName, this.status = RideStatus.draft, this.ridePhase, this.vehicleId, this.vehicleInfo,  List<String> bookingIds = const [], @JsonKey(includeToJson: false, includeFromJson: false)  List<RideBooking> bookings = const [], this.reviewCount = 0, this.averageRating = 0.0, this.xpReward = 50, this.notes,  List<String> tags = const [], @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.completedAt, @TimestampConverter() this.cancelledAt, this.cancellationReason}): _bookingIds = bookingIds,_bookings = bookings,_tags = tags,super._();
  factory _RideModel.fromJson(Map<String, dynamic> json) => _$RideModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String driverId;
@override final  RideRoute route;
@override final  RideSchedule schedule;
@override final  RideCapacity capacity;
@override final  RidePricing pricing;
@override final  RidePreferences preferences;
@override final  String? eventId;
@override final  String? eventName;
@override@JsonKey() final  RideStatus status;
@override final  String? ridePhase;
@override final  String? vehicleId;
@override final  String? vehicleInfo;
 final  List<String> _bookingIds;
@override@JsonKey() List<String> get bookingIds {
  if (_bookingIds is EqualUnmodifiableListView) return _bookingIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookingIds);
}

 final  List<RideBooking> _bookings;
@override@JsonKey(includeToJson: false, includeFromJson: false) List<RideBooking> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}

@override@JsonKey() final  int reviewCount;
@override@JsonKey() final  double averageRating;
@override@JsonKey() final  int xpReward;
@override final  String? notes;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? completedAt;
@override@TimestampConverter() final  DateTime? cancelledAt;
@override final  String? cancellationReason;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideModelCopyWith<_RideModel> get copyWith => __$RideModelCopyWithImpl<_RideModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.route, route) || other.route == route)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.status, status) || other.status == status)&&(identical(other.ridePhase, ridePhase) || other.ridePhase == ridePhase)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&const DeepCollectionEquality().equals(other._bookingIds, _bookingIds)&&const DeepCollectionEquality().equals(other._bookings, _bookings)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,route,schedule,capacity,pricing,preferences,eventId,eventName,status,ridePhase,vehicleId,vehicleInfo,const DeepCollectionEquality().hash(_bookingIds),const DeepCollectionEquality().hash(_bookings),reviewCount,averageRating,xpReward,notes,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt,completedAt,cancelledAt,cancellationReason]);

@override
String toString() {
  return 'RideModel(id: $id, driverId: $driverId, route: $route, schedule: $schedule, capacity: $capacity, pricing: $pricing, preferences: $preferences, eventId: $eventId, eventName: $eventName, status: $status, ridePhase: $ridePhase, vehicleId: $vehicleId, vehicleInfo: $vehicleInfo, bookingIds: $bookingIds, bookings: $bookings, reviewCount: $reviewCount, averageRating: $averageRating, xpReward: $xpReward, notes: $notes, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason)';
}


}

/// @nodoc
abstract mixin class _$RideModelCopyWith<$Res> implements $RideModelCopyWith<$Res> {
  factory _$RideModelCopyWith(_RideModel value, $Res Function(_RideModel) _then) = __$RideModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String driverId, RideRoute route, RideSchedule schedule, RideCapacity capacity, RidePricing pricing, RidePreferences preferences, String? eventId, String? eventName, RideStatus status, String? ridePhase, String? vehicleId, String? vehicleInfo, List<String> bookingIds,@JsonKey(includeToJson: false, includeFromJson: false) List<RideBooking> bookings, int reviewCount, double averageRating, int xpReward, String? notes, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? cancelledAt, String? cancellationReason
});


@override $RideRouteCopyWith<$Res> get route;@override $RideScheduleCopyWith<$Res> get schedule;@override $RideCapacityCopyWith<$Res> get capacity;@override $RidePricingCopyWith<$Res> get pricing;@override $RidePreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class __$RideModelCopyWithImpl<$Res>
    implements _$RideModelCopyWith<$Res> {
  __$RideModelCopyWithImpl(this._self, this._then);

  final _RideModel _self;
  final $Res Function(_RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? route = null,Object? schedule = null,Object? capacity = null,Object? pricing = null,Object? preferences = null,Object? eventId = freezed,Object? eventName = freezed,Object? status = null,Object? ridePhase = freezed,Object? vehicleId = freezed,Object? vehicleInfo = freezed,Object? bookingIds = null,Object? bookings = null,Object? reviewCount = null,Object? averageRating = null,Object? xpReward = null,Object? notes = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? cancellationReason = freezed,}) {
  return _then(_RideModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as RideRoute,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as RideSchedule,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as RideCapacity,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as RidePricing,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as RidePreferences,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,ridePhase: freezed == ridePhase ? _self.ridePhase : ridePhase // ignore: cast_nullable_to_non_nullable
as String?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as String?,bookingIds: null == bookingIds ? _self._bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<String>,bookings: null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideRouteCopyWith<$Res> get route {
  
  return $RideRouteCopyWith<$Res>(_self.route, (value) {
    return _then(_self.copyWith(route: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideScheduleCopyWith<$Res> get schedule {
  
  return $RideScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RideCapacityCopyWith<$Res> get capacity {
  
  return $RideCapacityCopyWith<$Res>(_self.capacity, (value) {
    return _then(_self.copyWith(capacity: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePricingCopyWith<$Res> get pricing {
  
  return $RidePricingCopyWith<$Res>(_self.pricing, (value) {
    return _then(_self.copyWith(pricing: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RidePreferencesCopyWith<$Res> get preferences {
  
  return $RidePreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}

// dart format on
