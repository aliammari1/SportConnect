// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideSummary {

 String get id; String get driverId; String get originAddress; String get destinationAddress;@RequiredTimestampConverter() DateTime get departureTime; String get formattedPrice; int get seatsAvailable; bool get isBookable;
/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSummaryCopyWith<RideSummary> get copyWith => _$RideSummaryCopyWithImpl<RideSummary>(this as RideSummary, _$identity);

  /// Serializes this RideSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.originAddress, originAddress) || other.originAddress == originAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.formattedPrice, formattedPrice) || other.formattedPrice == formattedPrice)&&(identical(other.seatsAvailable, seatsAvailable) || other.seatsAvailable == seatsAvailable)&&(identical(other.isBookable, isBookable) || other.isBookable == isBookable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,originAddress,destinationAddress,departureTime,formattedPrice,seatsAvailable,isBookable);

@override
String toString() {
  return 'RideSummary(id: $id, driverId: $driverId, originAddress: $originAddress, destinationAddress: $destinationAddress, departureTime: $departureTime, formattedPrice: $formattedPrice, seatsAvailable: $seatsAvailable, isBookable: $isBookable)';
}


}

/// @nodoc
abstract mixin class $RideSummaryCopyWith<$Res>  {
  factory $RideSummaryCopyWith(RideSummary value, $Res Function(RideSummary) _then) = _$RideSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String originAddress, String destinationAddress,@RequiredTimestampConverter() DateTime departureTime, String formattedPrice, int seatsAvailable, bool isBookable
});




}
/// @nodoc
class _$RideSummaryCopyWithImpl<$Res>
    implements $RideSummaryCopyWith<$Res> {
  _$RideSummaryCopyWithImpl(this._self, this._then);

  final RideSummary _self;
  final $Res Function(RideSummary) _then;

/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? originAddress = null,Object? destinationAddress = null,Object? departureTime = null,Object? formattedPrice = null,Object? seatsAvailable = null,Object? isBookable = null,}) {
  return _then(RideSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,originAddress: null == originAddress ? _self.originAddress : originAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,formattedPrice: null == formattedPrice ? _self.formattedPrice : formattedPrice // ignore: cast_nullable_to_non_nullable
as String,seatsAvailable: null == seatsAvailable ? _self.seatsAvailable : seatsAvailable // ignore: cast_nullable_to_non_nullable
as int,isBookable: null == isBookable ? _self.isBookable : isBookable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RideSummary].
extension RideSummaryPatterns on RideSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSummary value)  $default,){
final _that = this;
switch (_that) {
case _RideSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String originAddress,  String destinationAddress, @RequiredTimestampConverter()  DateTime departureTime,  String formattedPrice,  int seatsAvailable,  bool isBookable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
return $default(_that.id,_that.driverId,_that.originAddress,_that.destinationAddress,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.isBookable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String originAddress,  String destinationAddress, @RequiredTimestampConverter()  DateTime departureTime,  String formattedPrice,  int seatsAvailable,  bool isBookable)  $default,) {final _that = this;
switch (_that) {
case _RideSummary():
return $default(_that.id,_that.driverId,_that.originAddress,_that.destinationAddress,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.isBookable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String originAddress,  String destinationAddress, @RequiredTimestampConverter()  DateTime departureTime,  String formattedPrice,  int seatsAvailable,  bool isBookable)?  $default,) {final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
return $default(_that.id,_that.driverId,_that.originAddress,_that.destinationAddress,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.isBookable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideSummary implements RideSummary {
  const _RideSummary({required this.id, required this.driverId, required this.originAddress, required this.destinationAddress, @RequiredTimestampConverter() required this.departureTime, required this.formattedPrice, required this.seatsAvailable, required this.isBookable});
  factory _RideSummary.fromJson(Map<String, dynamic> json) => _$RideSummaryFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String originAddress;
@override final  String destinationAddress;
@override@RequiredTimestampConverter() final  DateTime departureTime;
@override final  String formattedPrice;
@override final  int seatsAvailable;
@override final  bool isBookable;

/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSummaryCopyWith<_RideSummary> get copyWith => __$RideSummaryCopyWithImpl<_RideSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.originAddress, originAddress) || other.originAddress == originAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.formattedPrice, formattedPrice) || other.formattedPrice == formattedPrice)&&(identical(other.seatsAvailable, seatsAvailable) || other.seatsAvailable == seatsAvailable)&&(identical(other.isBookable, isBookable) || other.isBookable == isBookable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,originAddress,destinationAddress,departureTime,formattedPrice,seatsAvailable,isBookable);

@override
String toString() {
  return 'RideSummary(id: $id, driverId: $driverId, originAddress: $originAddress, destinationAddress: $destinationAddress, departureTime: $departureTime, formattedPrice: $formattedPrice, seatsAvailable: $seatsAvailable, isBookable: $isBookable)';
}


}

/// @nodoc
abstract mixin class _$RideSummaryCopyWith<$Res> implements $RideSummaryCopyWith<$Res> {
  factory _$RideSummaryCopyWith(_RideSummary value, $Res Function(_RideSummary) _then) = __$RideSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String originAddress, String destinationAddress,@RequiredTimestampConverter() DateTime departureTime, String formattedPrice, int seatsAvailable, bool isBookable
});




}
/// @nodoc
class __$RideSummaryCopyWithImpl<$Res>
    implements _$RideSummaryCopyWith<$Res> {
  __$RideSummaryCopyWithImpl(this._self, this._then);

  final _RideSummary _self;
  final $Res Function(_RideSummary) _then;

/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? originAddress = null,Object? destinationAddress = null,Object? departureTime = null,Object? formattedPrice = null,Object? seatsAvailable = null,Object? isBookable = null,}) {
  return _then(_RideSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,originAddress: null == originAddress ? _self.originAddress : originAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,formattedPrice: null == formattedPrice ? _self.formattedPrice : formattedPrice // ignore: cast_nullable_to_non_nullable
as String,seatsAvailable: null == seatsAvailable ? _self.seatsAvailable : seatsAvailable // ignore: cast_nullable_to_non_nullable
as int,isBookable: null == isBookable ? _self.isBookable : isBookable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RideDetailState {

 String get id; String? get driverId; LocationPoint? get origin; LocationPoint? get destination; DateTime? get departureTime; String? get formattedPrice; int? get seatsAvailable; List<RideBooking> get activeBookings; int get pendingRequestsCount; bool get canBook; bool get isLoading; String? get errorMessage;
/// Create a copy of RideDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideDetailStateCopyWith<RideDetailState> get copyWith => _$RideDetailStateCopyWithImpl<RideDetailState>(this as RideDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideDetailState&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.formattedPrice, formattedPrice) || other.formattedPrice == formattedPrice)&&(identical(other.seatsAvailable, seatsAvailable) || other.seatsAvailable == seatsAvailable)&&const DeepCollectionEquality().equals(other.activeBookings, activeBookings)&&(identical(other.pendingRequestsCount, pendingRequestsCount) || other.pendingRequestsCount == pendingRequestsCount)&&(identical(other.canBook, canBook) || other.canBook == canBook)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,driverId,origin,destination,departureTime,formattedPrice,seatsAvailable,const DeepCollectionEquality().hash(activeBookings),pendingRequestsCount,canBook,isLoading,errorMessage);

@override
String toString() {
  return 'RideDetailState(id: $id, driverId: $driverId, origin: $origin, destination: $destination, departureTime: $departureTime, formattedPrice: $formattedPrice, seatsAvailable: $seatsAvailable, activeBookings: $activeBookings, pendingRequestsCount: $pendingRequestsCount, canBook: $canBook, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $RideDetailStateCopyWith<$Res>  {
  factory $RideDetailStateCopyWith(RideDetailState value, $Res Function(RideDetailState) _then) = _$RideDetailStateCopyWithImpl;
@useResult
$Res call({
 String id, String? driverId, LocationPoint? origin, LocationPoint? destination, DateTime? departureTime, String? formattedPrice, int? seatsAvailable, List<RideBooking> activeBookings, int pendingRequestsCount, bool canBook, bool isLoading, String? errorMessage
});


$LocationPointCopyWith<$Res>? get origin;$LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class _$RideDetailStateCopyWithImpl<$Res>
    implements $RideDetailStateCopyWith<$Res> {
  _$RideDetailStateCopyWithImpl(this._self, this._then);

  final RideDetailState _self;
  final $Res Function(RideDetailState) _then;

/// Create a copy of RideDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = freezed,Object? origin = freezed,Object? destination = freezed,Object? departureTime = freezed,Object? formattedPrice = freezed,Object? seatsAvailable = freezed,Object? activeBookings = null,Object? pendingRequestsCount = null,Object? canBook = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(RideDetailState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureTime: freezed == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime?,formattedPrice: freezed == formattedPrice ? _self.formattedPrice : formattedPrice // ignore: cast_nullable_to_non_nullable
as String?,seatsAvailable: freezed == seatsAvailable ? _self.seatsAvailable : seatsAvailable // ignore: cast_nullable_to_non_nullable
as int?,activeBookings: null == activeBookings ? _self.activeBookings : activeBookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,pendingRequestsCount: null == pendingRequestsCount ? _self.pendingRequestsCount : pendingRequestsCount // ignore: cast_nullable_to_non_nullable
as int,canBook: null == canBook ? _self.canBook : canBook // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RideDetailState
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
}/// Create a copy of RideDetailState
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


/// Adds pattern-matching-related methods to [RideDetailState].
extension RideDetailStatePatterns on RideDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideDetailState value)  $default,){
final _that = this;
switch (_that) {
case _RideDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _RideDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? driverId,  LocationPoint? origin,  LocationPoint? destination,  DateTime? departureTime,  String? formattedPrice,  int? seatsAvailable,  List<RideBooking> activeBookings,  int pendingRequestsCount,  bool canBook,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideDetailState() when $default != null:
return $default(_that.id,_that.driverId,_that.origin,_that.destination,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.activeBookings,_that.pendingRequestsCount,_that.canBook,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? driverId,  LocationPoint? origin,  LocationPoint? destination,  DateTime? departureTime,  String? formattedPrice,  int? seatsAvailable,  List<RideBooking> activeBookings,  int pendingRequestsCount,  bool canBook,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _RideDetailState():
return $default(_that.id,_that.driverId,_that.origin,_that.destination,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.activeBookings,_that.pendingRequestsCount,_that.canBook,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? driverId,  LocationPoint? origin,  LocationPoint? destination,  DateTime? departureTime,  String? formattedPrice,  int? seatsAvailable,  List<RideBooking> activeBookings,  int pendingRequestsCount,  bool canBook,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _RideDetailState() when $default != null:
return $default(_that.id,_that.driverId,_that.origin,_that.destination,_that.departureTime,_that.formattedPrice,_that.seatsAvailable,_that.activeBookings,_that.pendingRequestsCount,_that.canBook,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _RideDetailState implements RideDetailState {
  const _RideDetailState({required this.id, this.driverId, this.origin, this.destination, this.departureTime, this.formattedPrice, this.seatsAvailable,  List<RideBooking> activeBookings = const [], this.pendingRequestsCount = 0, this.canBook = false, this.isLoading = false, this.errorMessage}): _activeBookings = activeBookings;
  

@override final  String id;
@override final  String? driverId;
@override final  LocationPoint? origin;
@override final  LocationPoint? destination;
@override final  DateTime? departureTime;
@override final  String? formattedPrice;
@override final  int? seatsAvailable;
 final  List<RideBooking> _activeBookings;
@override@JsonKey() List<RideBooking> get activeBookings {
  if (_activeBookings is EqualUnmodifiableListView) return _activeBookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeBookings);
}

@override@JsonKey() final  int pendingRequestsCount;
@override@JsonKey() final  bool canBook;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of RideDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideDetailStateCopyWith<_RideDetailState> get copyWith => __$RideDetailStateCopyWithImpl<_RideDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideDetailState&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.formattedPrice, formattedPrice) || other.formattedPrice == formattedPrice)&&(identical(other.seatsAvailable, seatsAvailable) || other.seatsAvailable == seatsAvailable)&&const DeepCollectionEquality().equals(other._activeBookings, _activeBookings)&&(identical(other.pendingRequestsCount, pendingRequestsCount) || other.pendingRequestsCount == pendingRequestsCount)&&(identical(other.canBook, canBook) || other.canBook == canBook)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,driverId,origin,destination,departureTime,formattedPrice,seatsAvailable,const DeepCollectionEquality().hash(_activeBookings),pendingRequestsCount,canBook,isLoading,errorMessage);

@override
String toString() {
  return 'RideDetailState(id: $id, driverId: $driverId, origin: $origin, destination: $destination, departureTime: $departureTime, formattedPrice: $formattedPrice, seatsAvailable: $seatsAvailable, activeBookings: $activeBookings, pendingRequestsCount: $pendingRequestsCount, canBook: $canBook, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$RideDetailStateCopyWith<$Res> implements $RideDetailStateCopyWith<$Res> {
  factory _$RideDetailStateCopyWith(_RideDetailState value, $Res Function(_RideDetailState) _then) = __$RideDetailStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String? driverId, LocationPoint? origin, LocationPoint? destination, DateTime? departureTime, String? formattedPrice, int? seatsAvailable, List<RideBooking> activeBookings, int pendingRequestsCount, bool canBook, bool isLoading, String? errorMessage
});


@override $LocationPointCopyWith<$Res>? get origin;@override $LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class __$RideDetailStateCopyWithImpl<$Res>
    implements _$RideDetailStateCopyWith<$Res> {
  __$RideDetailStateCopyWithImpl(this._self, this._then);

  final _RideDetailState _self;
  final $Res Function(_RideDetailState) _then;

/// Create a copy of RideDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = freezed,Object? origin = freezed,Object? destination = freezed,Object? departureTime = freezed,Object? formattedPrice = freezed,Object? seatsAvailable = freezed,Object? activeBookings = null,Object? pendingRequestsCount = null,Object? canBook = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_RideDetailState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureTime: freezed == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime?,formattedPrice: freezed == formattedPrice ? _self.formattedPrice : formattedPrice // ignore: cast_nullable_to_non_nullable
as String?,seatsAvailable: freezed == seatsAvailable ? _self.seatsAvailable : seatsAvailable // ignore: cast_nullable_to_non_nullable
as int?,activeBookings: null == activeBookings ? _self._activeBookings : activeBookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,pendingRequestsCount: null == pendingRequestsCount ? _self.pendingRequestsCount : pendingRequestsCount // ignore: cast_nullable_to_non_nullable
as int,canBook: null == canBook ? _self.canBook : canBook // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RideDetailState
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
}/// Create a copy of RideDetailState
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
