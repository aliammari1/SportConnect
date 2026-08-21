// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideSchedule {

@RequiredTimestampConverter() DateTime get departureTime;@TimestampConverter() DateTime? get arrivalTime;@TimestampConverter() DateTime? get actualDepartureTime; int get flexibilityMinutes; bool get isRecurring; List<int> get recurringDays;@TimestampConverter() DateTime? get recurringEndDate;
/// Create a copy of RideSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideScheduleCopyWith<RideSchedule> get copyWith => _$RideScheduleCopyWithImpl<RideSchedule>(this as RideSchedule, _$identity);

  /// Serializes this RideSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSchedule&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.actualDepartureTime, actualDepartureTime) || other.actualDepartureTime == actualDepartureTime)&&(identical(other.flexibilityMinutes, flexibilityMinutes) || other.flexibilityMinutes == flexibilityMinutes)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departureTime,arrivalTime,actualDepartureTime,flexibilityMinutes,isRecurring,const DeepCollectionEquality().hash(recurringDays),recurringEndDate);

@override
String toString() {
  return 'RideSchedule(departureTime: $departureTime, arrivalTime: $arrivalTime, actualDepartureTime: $actualDepartureTime, flexibilityMinutes: $flexibilityMinutes, isRecurring: $isRecurring, recurringDays: $recurringDays, recurringEndDate: $recurringEndDate)';
}


}

/// @nodoc
abstract mixin class $RideScheduleCopyWith<$Res>  {
  factory $RideScheduleCopyWith(RideSchedule value, $Res Function(RideSchedule) _then) = _$RideScheduleCopyWithImpl;
@useResult
$Res call({
@RequiredTimestampConverter() DateTime departureTime,@TimestampConverter() DateTime? arrivalTime,@TimestampConverter() DateTime? actualDepartureTime, int flexibilityMinutes, bool isRecurring, List<int> recurringDays,@TimestampConverter() DateTime? recurringEndDate
});




}
/// @nodoc
class _$RideScheduleCopyWithImpl<$Res>
    implements $RideScheduleCopyWith<$Res> {
  _$RideScheduleCopyWithImpl(this._self, this._then);

  final RideSchedule _self;
  final $Res Function(RideSchedule) _then;

/// Create a copy of RideSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departureTime = null,Object? arrivalTime = freezed,Object? actualDepartureTime = freezed,Object? flexibilityMinutes = null,Object? isRecurring = null,Object? recurringDays = null,Object? recurringEndDate = freezed,}) {
  return _then(RideSchedule(
departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDepartureTime: freezed == actualDepartureTime ? _self.actualDepartureTime : actualDepartureTime // ignore: cast_nullable_to_non_nullable
as DateTime?,flexibilityMinutes: null == flexibilityMinutes ? _self.flexibilityMinutes : flexibilityMinutes // ignore: cast_nullable_to_non_nullable
as int,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<int>,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideSchedule].
extension RideSchedulePatterns on RideSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSchedule value)  $default,){
final _that = this;
switch (_that) {
case _RideSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _RideSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime, @TimestampConverter()  DateTime? actualDepartureTime,  int flexibilityMinutes,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSchedule() when $default != null:
return $default(_that.departureTime,_that.arrivalTime,_that.actualDepartureTime,_that.flexibilityMinutes,_that.isRecurring,_that.recurringDays,_that.recurringEndDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime, @TimestampConverter()  DateTime? actualDepartureTime,  int flexibilityMinutes,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate)  $default,) {final _that = this;
switch (_that) {
case _RideSchedule():
return $default(_that.departureTime,_that.arrivalTime,_that.actualDepartureTime,_that.flexibilityMinutes,_that.isRecurring,_that.recurringDays,_that.recurringEndDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime, @TimestampConverter()  DateTime? actualDepartureTime,  int flexibilityMinutes,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate)?  $default,) {final _that = this;
switch (_that) {
case _RideSchedule() when $default != null:
return $default(_that.departureTime,_that.arrivalTime,_that.actualDepartureTime,_that.flexibilityMinutes,_that.isRecurring,_that.recurringDays,_that.recurringEndDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideSchedule extends RideSchedule {
  const _RideSchedule({@RequiredTimestampConverter() required this.departureTime, @TimestampConverter() this.arrivalTime, @TimestampConverter() this.actualDepartureTime, this.flexibilityMinutes = 15, this.isRecurring = false,  List<int> recurringDays = const [], @TimestampConverter() this.recurringEndDate}): _recurringDays = recurringDays,super._();
  factory _RideSchedule.fromJson(Map<String, dynamic> json) => _$RideScheduleFromJson(json);

@override@RequiredTimestampConverter() final  DateTime departureTime;
@override@TimestampConverter() final  DateTime? arrivalTime;
@override@TimestampConverter() final  DateTime? actualDepartureTime;
@override@JsonKey() final  int flexibilityMinutes;
@override@JsonKey() final  bool isRecurring;
 final  List<int> _recurringDays;
@override@JsonKey() List<int> get recurringDays {
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recurringDays);
}

@override@TimestampConverter() final  DateTime? recurringEndDate;

/// Create a copy of RideSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideScheduleCopyWith<_RideSchedule> get copyWith => __$RideScheduleCopyWithImpl<_RideSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSchedule&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.actualDepartureTime, actualDepartureTime) || other.actualDepartureTime == actualDepartureTime)&&(identical(other.flexibilityMinutes, flexibilityMinutes) || other.flexibilityMinutes == flexibilityMinutes)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departureTime,arrivalTime,actualDepartureTime,flexibilityMinutes,isRecurring,const DeepCollectionEquality().hash(_recurringDays),recurringEndDate);

@override
String toString() {
  return 'RideSchedule(departureTime: $departureTime, arrivalTime: $arrivalTime, actualDepartureTime: $actualDepartureTime, flexibilityMinutes: $flexibilityMinutes, isRecurring: $isRecurring, recurringDays: $recurringDays, recurringEndDate: $recurringEndDate)';
}


}

/// @nodoc
abstract mixin class _$RideScheduleCopyWith<$Res> implements $RideScheduleCopyWith<$Res> {
  factory _$RideScheduleCopyWith(_RideSchedule value, $Res Function(_RideSchedule) _then) = __$RideScheduleCopyWithImpl;
@override @useResult
$Res call({
@RequiredTimestampConverter() DateTime departureTime,@TimestampConverter() DateTime? arrivalTime,@TimestampConverter() DateTime? actualDepartureTime, int flexibilityMinutes, bool isRecurring, List<int> recurringDays,@TimestampConverter() DateTime? recurringEndDate
});




}
/// @nodoc
class __$RideScheduleCopyWithImpl<$Res>
    implements _$RideScheduleCopyWith<$Res> {
  __$RideScheduleCopyWithImpl(this._self, this._then);

  final _RideSchedule _self;
  final $Res Function(_RideSchedule) _then;

/// Create a copy of RideSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departureTime = null,Object? arrivalTime = freezed,Object? actualDepartureTime = freezed,Object? flexibilityMinutes = null,Object? isRecurring = null,Object? recurringDays = null,Object? recurringEndDate = freezed,}) {
  return _then(_RideSchedule(
departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,actualDepartureTime: freezed == actualDepartureTime ? _self.actualDepartureTime : actualDepartureTime // ignore: cast_nullable_to_non_nullable
as DateTime?,flexibilityMinutes: null == flexibilityMinutes ? _self.flexibilityMinutes : flexibilityMinutes // ignore: cast_nullable_to_non_nullable
as int,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<int>,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
