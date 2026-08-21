// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String get id; String get creatorId; String get title; EventType get type; LocationPoint get location;@RequiredTimestampConverter() DateTime get startsAt;@TimestampConverter() DateTime? get endsAt; String? get description;/// Display name of the organiser (denormalized for fast rendering).
 String? get organizerName;/// Cover image URL (Firebase Storage).
 String? get imageUrl; List<String> get participantIds; int get maxParticipants; bool get isActive;/// RSVP ride status per participant: { uid: 'driving' | 'need_ride' | 'self_arranged' }.
 Map<String, String> get rideStatuses;/// Post-event meetup pin location for coordinating departure.
 LocationPoint? get meetupPinLocation;/// Auto-created chat group ID for event participants.
 String? get chatGroupId;/// Whether this is a recurring event (e.g. weekly training).
 bool get isRecurring;/// Recurrence pattern for recurring events (daily, weekly, biweekly, monthly).
 RecurrencePattern? get recurringPattern;/// End date for the recurring series.
@TimestampConverter() DateTime? get recurringEndDate;/// Whether cost-splitting is enabled for event carpools.
 bool get costSplitEnabled;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.location, location) || other.location == location)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.rideStatuses, rideStatuses)&&(identical(other.meetupPinLocation, meetupPinLocation) || other.meetupPinLocation == meetupPinLocation)&&(identical(other.chatGroupId, chatGroupId) || other.chatGroupId == chatGroupId)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringPattern, recurringPattern) || other.recurringPattern == recurringPattern)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.costSplitEnabled, costSplitEnabled) || other.costSplitEnabled == costSplitEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,title,type,location,startsAt,endsAt,description,organizerName,imageUrl,const DeepCollectionEquality().hash(participantIds),maxParticipants,isActive,const DeepCollectionEquality().hash(rideStatuses),meetupPinLocation,chatGroupId,isRecurring,recurringPattern,recurringEndDate,costSplitEnabled,createdAt,updatedAt]);

@override
String toString() {
  return 'EventModel(id: $id, creatorId: $creatorId, title: $title, type: $type, location: $location, startsAt: $startsAt, endsAt: $endsAt, description: $description, organizerName: $organizerName, imageUrl: $imageUrl, participantIds: $participantIds, maxParticipants: $maxParticipants, isActive: $isActive, rideStatuses: $rideStatuses, meetupPinLocation: $meetupPinLocation, chatGroupId: $chatGroupId, isRecurring: $isRecurring, recurringPattern: $recurringPattern, recurringEndDate: $recurringEndDate, costSplitEnabled: $costSplitEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String id, String creatorId, String title, EventType type, LocationPoint location,@RequiredTimestampConverter() DateTime startsAt,@TimestampConverter() DateTime? endsAt, String? description, String? organizerName, String? imageUrl, List<String> participantIds, int maxParticipants, bool isActive, Map<String, String> rideStatuses, LocationPoint? meetupPinLocation, String? chatGroupId, bool isRecurring, RecurrencePattern? recurringPattern,@TimestampConverter() DateTime? recurringEndDate, bool costSplitEnabled,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$LocationPointCopyWith<$Res> get location;$LocationPointCopyWith<$Res>? get meetupPinLocation;

}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? type = null,Object? location = null,Object? startsAt = null,Object? endsAt = freezed,Object? description = freezed,Object? organizerName = freezed,Object? imageUrl = freezed,Object? participantIds = null,Object? maxParticipants = null,Object? isActive = null,Object? rideStatuses = null,Object? meetupPinLocation = freezed,Object? chatGroupId = freezed,Object? isRecurring = null,Object? recurringPattern = freezed,Object? recurringEndDate = freezed,Object? costSplitEnabled = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rideStatuses: null == rideStatuses ? _self.rideStatuses : rideStatuses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,meetupPinLocation: freezed == meetupPinLocation ? _self.meetupPinLocation : meetupPinLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,chatGroupId: freezed == chatGroupId ? _self.chatGroupId : chatGroupId // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringPattern: freezed == recurringPattern ? _self.recurringPattern : recurringPattern // ignore: cast_nullable_to_non_nullable
as RecurrencePattern?,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,costSplitEnabled: null == costSplitEnabled ? _self.costSplitEnabled : costSplitEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get meetupPinLocation {
    if (_self.meetupPinLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.meetupPinLocation!, (value) {
    return _then(_self.copyWith(meetupPinLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive,  Map<String, String> rideStatuses,  LocationPoint? meetupPinLocation,  String? chatGroupId,  bool isRecurring,  RecurrencePattern? recurringPattern, @TimestampConverter()  DateTime? recurringEndDate,  bool costSplitEnabled, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.rideStatuses,_that.meetupPinLocation,_that.chatGroupId,_that.isRecurring,_that.recurringPattern,_that.recurringEndDate,_that.costSplitEnabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive,  Map<String, String> rideStatuses,  LocationPoint? meetupPinLocation,  String? chatGroupId,  bool isRecurring,  RecurrencePattern? recurringPattern, @TimestampConverter()  DateTime? recurringEndDate,  bool costSplitEnabled, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.rideStatuses,_that.meetupPinLocation,_that.chatGroupId,_that.isRecurring,_that.recurringPattern,_that.recurringEndDate,_that.costSplitEnabled,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive,  Map<String, String> rideStatuses,  LocationPoint? meetupPinLocation,  String? chatGroupId,  bool isRecurring,  RecurrencePattern? recurringPattern, @TimestampConverter()  DateTime? recurringEndDate,  bool costSplitEnabled, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.rideStatuses,_that.meetupPinLocation,_that.chatGroupId,_that.isRecurring,_that.recurringPattern,_that.recurringEndDate,_that.costSplitEnabled,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel extends EventModel {
  const _EventModel({required this.id, required this.creatorId, required this.title, required this.type, required this.location, @RequiredTimestampConverter() required this.startsAt, @TimestampConverter() this.endsAt, this.description, this.organizerName, this.imageUrl,  List<String> participantIds = const [], this.maxParticipants = 0, this.isActive = true,  Map<String, String> rideStatuses = const {}, this.meetupPinLocation, this.chatGroupId, this.isRecurring = false, this.recurringPattern, @TimestampConverter() this.recurringEndDate, this.costSplitEnabled = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _participantIds = participantIds,_rideStatuses = rideStatuses,super._();
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  String id;
@override final  String creatorId;
@override final  String title;
@override final  EventType type;
@override final  LocationPoint location;
@override@RequiredTimestampConverter() final  DateTime startsAt;
@override@TimestampConverter() final  DateTime? endsAt;
@override final  String? description;
/// Display name of the organiser (denormalized for fast rendering).
@override final  String? organizerName;
/// Cover image URL (Firebase Storage).
@override final  String? imageUrl;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override@JsonKey() final  int maxParticipants;
@override@JsonKey() final  bool isActive;
/// RSVP ride status per participant: { uid: 'driving' | 'need_ride' | 'self_arranged' }.
 final  Map<String, String> _rideStatuses;
/// RSVP ride status per participant: { uid: 'driving' | 'need_ride' | 'self_arranged' }.
@override@JsonKey() Map<String, String> get rideStatuses {
  if (_rideStatuses is EqualUnmodifiableMapView) return _rideStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rideStatuses);
}

/// Post-event meetup pin location for coordinating departure.
@override final  LocationPoint? meetupPinLocation;
/// Auto-created chat group ID for event participants.
@override final  String? chatGroupId;
/// Whether this is a recurring event (e.g. weekly training).
@override@JsonKey() final  bool isRecurring;
/// Recurrence pattern for recurring events (daily, weekly, biweekly, monthly).
@override final  RecurrencePattern? recurringPattern;
/// End date for the recurring series.
@override@TimestampConverter() final  DateTime? recurringEndDate;
/// Whether cost-splitting is enabled for event carpools.
@override@JsonKey() final  bool costSplitEnabled;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.location, location) || other.location == location)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._rideStatuses, _rideStatuses)&&(identical(other.meetupPinLocation, meetupPinLocation) || other.meetupPinLocation == meetupPinLocation)&&(identical(other.chatGroupId, chatGroupId) || other.chatGroupId == chatGroupId)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringPattern, recurringPattern) || other.recurringPattern == recurringPattern)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.costSplitEnabled, costSplitEnabled) || other.costSplitEnabled == costSplitEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,creatorId,title,type,location,startsAt,endsAt,description,organizerName,imageUrl,const DeepCollectionEquality().hash(_participantIds),maxParticipants,isActive,const DeepCollectionEquality().hash(_rideStatuses),meetupPinLocation,chatGroupId,isRecurring,recurringPattern,recurringEndDate,costSplitEnabled,createdAt,updatedAt]);

@override
String toString() {
  return 'EventModel(id: $id, creatorId: $creatorId, title: $title, type: $type, location: $location, startsAt: $startsAt, endsAt: $endsAt, description: $description, organizerName: $organizerName, imageUrl: $imageUrl, participantIds: $participantIds, maxParticipants: $maxParticipants, isActive: $isActive, rideStatuses: $rideStatuses, meetupPinLocation: $meetupPinLocation, chatGroupId: $chatGroupId, isRecurring: $isRecurring, recurringPattern: $recurringPattern, recurringEndDate: $recurringEndDate, costSplitEnabled: $costSplitEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String creatorId, String title, EventType type, LocationPoint location,@RequiredTimestampConverter() DateTime startsAt,@TimestampConverter() DateTime? endsAt, String? description, String? organizerName, String? imageUrl, List<String> participantIds, int maxParticipants, bool isActive, Map<String, String> rideStatuses, LocationPoint? meetupPinLocation, String? chatGroupId, bool isRecurring, RecurrencePattern? recurringPattern,@TimestampConverter() DateTime? recurringEndDate, bool costSplitEnabled,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


@override $LocationPointCopyWith<$Res> get location;@override $LocationPointCopyWith<$Res>? get meetupPinLocation;

}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? type = null,Object? location = null,Object? startsAt = null,Object? endsAt = freezed,Object? description = freezed,Object? organizerName = freezed,Object? imageUrl = freezed,Object? participantIds = null,Object? maxParticipants = null,Object? isActive = null,Object? rideStatuses = null,Object? meetupPinLocation = freezed,Object? chatGroupId = freezed,Object? isRecurring = null,Object? recurringPattern = freezed,Object? recurringEndDate = freezed,Object? costSplitEnabled = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rideStatuses: null == rideStatuses ? _self._rideStatuses : rideStatuses // ignore: cast_nullable_to_non_nullable
as Map<String, String>,meetupPinLocation: freezed == meetupPinLocation ? _self.meetupPinLocation : meetupPinLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,chatGroupId: freezed == chatGroupId ? _self.chatGroupId : chatGroupId // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringPattern: freezed == recurringPattern ? _self.recurringPattern : recurringPattern // ignore: cast_nullable_to_non_nullable
as RecurrencePattern?,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,costSplitEnabled: null == costSplitEnabled ? _self.costSplitEnabled : costSplitEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get meetupPinLocation {
    if (_self.meetupPinLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.meetupPinLocation!, (value) {
    return _then(_self.copyWith(meetupPinLocation: value));
  });
}
}

// dart format on
