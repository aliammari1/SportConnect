// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideBooking {

 String get id; String get rideId; String get passengerId; String? get driverId; int get seatsBooked; BookingStatus get status; LocationPoint? get pickupLocation; LocationPoint? get dropoffLocation; String? get note;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get respondedAt; String? get paymentIntentId;@TimestampConverter() DateTime? get paidAt; String? get pickupOtp; int? get pricePerSeatInCents;@TimestampConverter() DateTime? get cancelledAt;
/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideBookingCopyWith<RideBooking> get copyWith => _$RideBookingCopyWithImpl<RideBooking>(this as RideBooking, _$identity);

  /// Serializes this RideBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.pickupOtp, pickupOtp) || other.pickupOtp == pickupOtp)&&(identical(other.pricePerSeatInCents, pricePerSeatInCents) || other.pricePerSeatInCents == pricePerSeatInCents)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,passengerId,driverId,seatsBooked,status,pickupLocation,dropoffLocation,note,createdAt,respondedAt,paymentIntentId,paidAt,pickupOtp,pricePerSeatInCents,cancelledAt);

@override
String toString() {
  return 'RideBooking(id: $id, rideId: $rideId, passengerId: $passengerId, driverId: $driverId, seatsBooked: $seatsBooked, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, note: $note, createdAt: $createdAt, respondedAt: $respondedAt, paymentIntentId: $paymentIntentId, paidAt: $paidAt, pickupOtp: $pickupOtp, pricePerSeatInCents: $pricePerSeatInCents, cancelledAt: $cancelledAt)';
}


}

/// @nodoc
abstract mixin class $RideBookingCopyWith<$Res>  {
  factory $RideBookingCopyWith(RideBooking value, $Res Function(RideBooking) _then) = _$RideBookingCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, String passengerId, String? driverId, int seatsBooked, BookingStatus status, LocationPoint? pickupLocation, LocationPoint? dropoffLocation, String? note,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? respondedAt, String? paymentIntentId,@TimestampConverter() DateTime? paidAt, String? pickupOtp, int? pricePerSeatInCents,@TimestampConverter() DateTime? cancelledAt
});


$LocationPointCopyWith<$Res>? get pickupLocation;$LocationPointCopyWith<$Res>? get dropoffLocation;

}
/// @nodoc
class _$RideBookingCopyWithImpl<$Res>
    implements $RideBookingCopyWith<$Res> {
  _$RideBookingCopyWithImpl(this._self, this._then);

  final RideBooking _self;
  final $Res Function(RideBooking) _then;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? passengerId = null,Object? driverId = freezed,Object? seatsBooked = null,Object? status = null,Object? pickupLocation = freezed,Object? dropoffLocation = freezed,Object? note = freezed,Object? createdAt = freezed,Object? respondedAt = freezed,Object? paymentIntentId = freezed,Object? paidAt = freezed,Object? pickupOtp = freezed,Object? pricePerSeatInCents = freezed,Object? cancelledAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: null == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupOtp: freezed == pickupOtp ? _self.pickupOtp : pickupOtp // ignore: cast_nullable_to_non_nullable
as String?,pricePerSeatInCents: freezed == pricePerSeatInCents ? _self.pricePerSeatInCents : pricePerSeatInCents // ignore: cast_nullable_to_non_nullable
as int?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get dropoffLocation {
    if (_self.dropoffLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.dropoffLocation!, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideBooking].
extension RideBookingPatterns on RideBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideBooking value)  $default,){
final _that = this;
switch (_that) {
case _RideBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideBooking value)?  $default,){
final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  String passengerId,  String? driverId,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt,  String? paymentIntentId, @TimestampConverter()  DateTime? paidAt,  String? pickupOtp,  int? pricePerSeatInCents, @TimestampConverter()  DateTime? cancelledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
return $default(_that.id,_that.rideId,_that.passengerId,_that.driverId,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt,_that.paymentIntentId,_that.paidAt,_that.pickupOtp,_that.pricePerSeatInCents,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  String passengerId,  String? driverId,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt,  String? paymentIntentId, @TimestampConverter()  DateTime? paidAt,  String? pickupOtp,  int? pricePerSeatInCents, @TimestampConverter()  DateTime? cancelledAt)  $default,) {final _that = this;
switch (_that) {
case _RideBooking():
return $default(_that.id,_that.rideId,_that.passengerId,_that.driverId,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt,_that.paymentIntentId,_that.paidAt,_that.pickupOtp,_that.pricePerSeatInCents,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  String passengerId,  String? driverId,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt,  String? paymentIntentId, @TimestampConverter()  DateTime? paidAt,  String? pickupOtp,  int? pricePerSeatInCents, @TimestampConverter()  DateTime? cancelledAt)?  $default,) {final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
return $default(_that.id,_that.rideId,_that.passengerId,_that.driverId,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt,_that.paymentIntentId,_that.paidAt,_that.pickupOtp,_that.pricePerSeatInCents,_that.cancelledAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideBooking extends RideBooking {
  const _RideBooking({required this.id, required this.rideId, required this.passengerId, this.driverId, this.seatsBooked = 1, this.status = BookingStatus.pending, this.pickupLocation, this.dropoffLocation, this.note, @TimestampConverter() this.createdAt, @TimestampConverter() this.respondedAt, this.paymentIntentId, @TimestampConverter() this.paidAt, this.pickupOtp, this.pricePerSeatInCents, @TimestampConverter() this.cancelledAt}): super._();
  factory _RideBooking.fromJson(Map<String, dynamic> json) => _$RideBookingFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  String passengerId;
@override final  String? driverId;
@override@JsonKey() final  int seatsBooked;
@override@JsonKey() final  BookingStatus status;
@override final  LocationPoint? pickupLocation;
@override final  LocationPoint? dropoffLocation;
@override final  String? note;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? respondedAt;
@override final  String? paymentIntentId;
@override@TimestampConverter() final  DateTime? paidAt;
@override final  String? pickupOtp;
@override final  int? pricePerSeatInCents;
@override@TimestampConverter() final  DateTime? cancelledAt;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideBookingCopyWith<_RideBooking> get copyWith => __$RideBookingCopyWithImpl<_RideBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.paymentIntentId, paymentIntentId) || other.paymentIntentId == paymentIntentId)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.pickupOtp, pickupOtp) || other.pickupOtp == pickupOtp)&&(identical(other.pricePerSeatInCents, pricePerSeatInCents) || other.pricePerSeatInCents == pricePerSeatInCents)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,passengerId,driverId,seatsBooked,status,pickupLocation,dropoffLocation,note,createdAt,respondedAt,paymentIntentId,paidAt,pickupOtp,pricePerSeatInCents,cancelledAt);

@override
String toString() {
  return 'RideBooking(id: $id, rideId: $rideId, passengerId: $passengerId, driverId: $driverId, seatsBooked: $seatsBooked, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, note: $note, createdAt: $createdAt, respondedAt: $respondedAt, paymentIntentId: $paymentIntentId, paidAt: $paidAt, pickupOtp: $pickupOtp, pricePerSeatInCents: $pricePerSeatInCents, cancelledAt: $cancelledAt)';
}


}

/// @nodoc
abstract mixin class _$RideBookingCopyWith<$Res> implements $RideBookingCopyWith<$Res> {
  factory _$RideBookingCopyWith(_RideBooking value, $Res Function(_RideBooking) _then) = __$RideBookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, String passengerId, String? driverId, int seatsBooked, BookingStatus status, LocationPoint? pickupLocation, LocationPoint? dropoffLocation, String? note,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? respondedAt, String? paymentIntentId,@TimestampConverter() DateTime? paidAt, String? pickupOtp, int? pricePerSeatInCents,@TimestampConverter() DateTime? cancelledAt
});


@override $LocationPointCopyWith<$Res>? get pickupLocation;@override $LocationPointCopyWith<$Res>? get dropoffLocation;

}
/// @nodoc
class __$RideBookingCopyWithImpl<$Res>
    implements _$RideBookingCopyWith<$Res> {
  __$RideBookingCopyWithImpl(this._self, this._then);

  final _RideBooking _self;
  final $Res Function(_RideBooking) _then;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? passengerId = null,Object? driverId = freezed,Object? seatsBooked = null,Object? status = null,Object? pickupLocation = freezed,Object? dropoffLocation = freezed,Object? note = freezed,Object? createdAt = freezed,Object? respondedAt = freezed,Object? paymentIntentId = freezed,Object? paidAt = freezed,Object? pickupOtp = freezed,Object? pricePerSeatInCents = freezed,Object? cancelledAt = freezed,}) {
  return _then(_RideBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: null == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentIntentId: freezed == paymentIntentId ? _self.paymentIntentId : paymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupOtp: freezed == pickupOtp ? _self.pickupOtp : pickupOtp // ignore: cast_nullable_to_non_nullable
as String?,pricePerSeatInCents: freezed == pricePerSeatInCents ? _self.pricePerSeatInCents : pricePerSeatInCents // ignore: cast_nullable_to_non_nullable
as int?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get dropoffLocation {
    if (_self.dropoffLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.dropoffLocation!, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}

// dart format on
