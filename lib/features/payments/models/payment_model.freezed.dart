// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StripeCapabilities {

 StripeCapabilityStatus get transfers; StripeCapabilityStatus get cardPayments;
/// Create a copy of StripeCapabilities
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StripeCapabilitiesCopyWith<StripeCapabilities> get copyWith => _$StripeCapabilitiesCopyWithImpl<StripeCapabilities>(this as StripeCapabilities, _$identity);

  /// Serializes this StripeCapabilities to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StripeCapabilities&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.cardPayments, cardPayments) || other.cardPayments == cardPayments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transfers,cardPayments);

@override
String toString() {
  return 'StripeCapabilities(transfers: $transfers, cardPayments: $cardPayments)';
}


}

/// @nodoc
abstract mixin class $StripeCapabilitiesCopyWith<$Res>  {
  factory $StripeCapabilitiesCopyWith(StripeCapabilities value, $Res Function(StripeCapabilities) _then) = _$StripeCapabilitiesCopyWithImpl;
@useResult
$Res call({
 StripeCapabilityStatus transfers, StripeCapabilityStatus cardPayments
});




}
/// @nodoc
class _$StripeCapabilitiesCopyWithImpl<$Res>
    implements $StripeCapabilitiesCopyWith<$Res> {
  _$StripeCapabilitiesCopyWithImpl(this._self, this._then);

  final StripeCapabilities _self;
  final $Res Function(StripeCapabilities) _then;

/// Create a copy of StripeCapabilities
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transfers = null,Object? cardPayments = null,}) {
  return _then(_self.copyWith(
transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as StripeCapabilityStatus,cardPayments: null == cardPayments ? _self.cardPayments : cardPayments // ignore: cast_nullable_to_non_nullable
as StripeCapabilityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [StripeCapabilities].
extension StripeCapabilitiesPatterns on StripeCapabilities {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StripeCapabilities value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StripeCapabilities() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StripeCapabilities value)  $default,){
final _that = this;
switch (_that) {
case _StripeCapabilities():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StripeCapabilities value)?  $default,){
final _that = this;
switch (_that) {
case _StripeCapabilities() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StripeCapabilityStatus transfers,  StripeCapabilityStatus cardPayments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StripeCapabilities() when $default != null:
return $default(_that.transfers,_that.cardPayments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StripeCapabilityStatus transfers,  StripeCapabilityStatus cardPayments)  $default,) {final _that = this;
switch (_that) {
case _StripeCapabilities():
return $default(_that.transfers,_that.cardPayments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StripeCapabilityStatus transfers,  StripeCapabilityStatus cardPayments)?  $default,) {final _that = this;
switch (_that) {
case _StripeCapabilities() when $default != null:
return $default(_that.transfers,_that.cardPayments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StripeCapabilities implements StripeCapabilities {
  const _StripeCapabilities({this.transfers = StripeCapabilityStatus.inactive, this.cardPayments = StripeCapabilityStatus.inactive});
  factory _StripeCapabilities.fromJson(Map<String, dynamic> json) => _$StripeCapabilitiesFromJson(json);

@override@JsonKey() final  StripeCapabilityStatus transfers;
@override@JsonKey() final  StripeCapabilityStatus cardPayments;

/// Create a copy of StripeCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StripeCapabilitiesCopyWith<_StripeCapabilities> get copyWith => __$StripeCapabilitiesCopyWithImpl<_StripeCapabilities>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StripeCapabilitiesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StripeCapabilities&&(identical(other.transfers, transfers) || other.transfers == transfers)&&(identical(other.cardPayments, cardPayments) || other.cardPayments == cardPayments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,transfers,cardPayments);

@override
String toString() {
  return 'StripeCapabilities(transfers: $transfers, cardPayments: $cardPayments)';
}


}

/// @nodoc
abstract mixin class _$StripeCapabilitiesCopyWith<$Res> implements $StripeCapabilitiesCopyWith<$Res> {
  factory _$StripeCapabilitiesCopyWith(_StripeCapabilities value, $Res Function(_StripeCapabilities) _then) = __$StripeCapabilitiesCopyWithImpl;
@override @useResult
$Res call({
 StripeCapabilityStatus transfers, StripeCapabilityStatus cardPayments
});




}
/// @nodoc
class __$StripeCapabilitiesCopyWithImpl<$Res>
    implements _$StripeCapabilitiesCopyWith<$Res> {
  __$StripeCapabilitiesCopyWithImpl(this._self, this._then);

  final _StripeCapabilities _self;
  final $Res Function(_StripeCapabilities) _then;

/// Create a copy of StripeCapabilities
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transfers = null,Object? cardPayments = null,}) {
  return _then(_StripeCapabilities(
transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as StripeCapabilityStatus,cardPayments: null == cardPayments ? _self.cardPayments : cardPayments // ignore: cast_nullable_to_non_nullable
as StripeCapabilityStatus,
  ));
}


}


/// @nodoc
mixin _$StripeRequirements {

 List<String> get currentlyDue; List<String> get eventuallyDue; List<String> get pastDue; List<String> get pendingVerification;@TimestampConverter() DateTime? get currentDeadline; StripeDisabledReason? get disabledReason;
/// Create a copy of StripeRequirements
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StripeRequirementsCopyWith<StripeRequirements> get copyWith => _$StripeRequirementsCopyWithImpl<StripeRequirements>(this as StripeRequirements, _$identity);

  /// Serializes this StripeRequirements to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StripeRequirements&&const DeepCollectionEquality().equals(other.currentlyDue, currentlyDue)&&const DeepCollectionEquality().equals(other.eventuallyDue, eventuallyDue)&&const DeepCollectionEquality().equals(other.pastDue, pastDue)&&const DeepCollectionEquality().equals(other.pendingVerification, pendingVerification)&&(identical(other.currentDeadline, currentDeadline) || other.currentDeadline == currentDeadline)&&(identical(other.disabledReason, disabledReason) || other.disabledReason == disabledReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(currentlyDue),const DeepCollectionEquality().hash(eventuallyDue),const DeepCollectionEquality().hash(pastDue),const DeepCollectionEquality().hash(pendingVerification),currentDeadline,disabledReason);

@override
String toString() {
  return 'StripeRequirements(currentlyDue: $currentlyDue, eventuallyDue: $eventuallyDue, pastDue: $pastDue, pendingVerification: $pendingVerification, currentDeadline: $currentDeadline, disabledReason: $disabledReason)';
}


}

/// @nodoc
abstract mixin class $StripeRequirementsCopyWith<$Res>  {
  factory $StripeRequirementsCopyWith(StripeRequirements value, $Res Function(StripeRequirements) _then) = _$StripeRequirementsCopyWithImpl;
@useResult
$Res call({
 List<String> currentlyDue, List<String> eventuallyDue, List<String> pastDue, List<String> pendingVerification,@TimestampConverter() DateTime? currentDeadline, StripeDisabledReason? disabledReason
});




}
/// @nodoc
class _$StripeRequirementsCopyWithImpl<$Res>
    implements $StripeRequirementsCopyWith<$Res> {
  _$StripeRequirementsCopyWithImpl(this._self, this._then);

  final StripeRequirements _self;
  final $Res Function(StripeRequirements) _then;

/// Create a copy of StripeRequirements
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentlyDue = null,Object? eventuallyDue = null,Object? pastDue = null,Object? pendingVerification = null,Object? currentDeadline = freezed,Object? disabledReason = freezed,}) {
  return _then(_self.copyWith(
currentlyDue: null == currentlyDue ? _self.currentlyDue : currentlyDue // ignore: cast_nullable_to_non_nullable
as List<String>,eventuallyDue: null == eventuallyDue ? _self.eventuallyDue : eventuallyDue // ignore: cast_nullable_to_non_nullable
as List<String>,pastDue: null == pastDue ? _self.pastDue : pastDue // ignore: cast_nullable_to_non_nullable
as List<String>,pendingVerification: null == pendingVerification ? _self.pendingVerification : pendingVerification // ignore: cast_nullable_to_non_nullable
as List<String>,currentDeadline: freezed == currentDeadline ? _self.currentDeadline : currentDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as StripeDisabledReason?,
  ));
}

}


/// Adds pattern-matching-related methods to [StripeRequirements].
extension StripeRequirementsPatterns on StripeRequirements {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StripeRequirements value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StripeRequirements() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StripeRequirements value)  $default,){
final _that = this;
switch (_that) {
case _StripeRequirements():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StripeRequirements value)?  $default,){
final _that = this;
switch (_that) {
case _StripeRequirements() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> currentlyDue,  List<String> eventuallyDue,  List<String> pastDue,  List<String> pendingVerification, @TimestampConverter()  DateTime? currentDeadline,  StripeDisabledReason? disabledReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StripeRequirements() when $default != null:
return $default(_that.currentlyDue,_that.eventuallyDue,_that.pastDue,_that.pendingVerification,_that.currentDeadline,_that.disabledReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> currentlyDue,  List<String> eventuallyDue,  List<String> pastDue,  List<String> pendingVerification, @TimestampConverter()  DateTime? currentDeadline,  StripeDisabledReason? disabledReason)  $default,) {final _that = this;
switch (_that) {
case _StripeRequirements():
return $default(_that.currentlyDue,_that.eventuallyDue,_that.pastDue,_that.pendingVerification,_that.currentDeadline,_that.disabledReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> currentlyDue,  List<String> eventuallyDue,  List<String> pastDue,  List<String> pendingVerification, @TimestampConverter()  DateTime? currentDeadline,  StripeDisabledReason? disabledReason)?  $default,) {final _that = this;
switch (_that) {
case _StripeRequirements() when $default != null:
return $default(_that.currentlyDue,_that.eventuallyDue,_that.pastDue,_that.pendingVerification,_that.currentDeadline,_that.disabledReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StripeRequirements implements StripeRequirements {
  const _StripeRequirements({final  List<String> currentlyDue = const [], final  List<String> eventuallyDue = const [], final  List<String> pastDue = const [], final  List<String> pendingVerification = const [], @TimestampConverter() this.currentDeadline, this.disabledReason}): _currentlyDue = currentlyDue,_eventuallyDue = eventuallyDue,_pastDue = pastDue,_pendingVerification = pendingVerification;
  factory _StripeRequirements.fromJson(Map<String, dynamic> json) => _$StripeRequirementsFromJson(json);

 final  List<String> _currentlyDue;
@override@JsonKey() List<String> get currentlyDue {
  if (_currentlyDue is EqualUnmodifiableListView) return _currentlyDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currentlyDue);
}

 final  List<String> _eventuallyDue;
@override@JsonKey() List<String> get eventuallyDue {
  if (_eventuallyDue is EqualUnmodifiableListView) return _eventuallyDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eventuallyDue);
}

 final  List<String> _pastDue;
@override@JsonKey() List<String> get pastDue {
  if (_pastDue is EqualUnmodifiableListView) return _pastDue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pastDue);
}

 final  List<String> _pendingVerification;
@override@JsonKey() List<String> get pendingVerification {
  if (_pendingVerification is EqualUnmodifiableListView) return _pendingVerification;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingVerification);
}

@override@TimestampConverter() final  DateTime? currentDeadline;
@override final  StripeDisabledReason? disabledReason;

/// Create a copy of StripeRequirements
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StripeRequirementsCopyWith<_StripeRequirements> get copyWith => __$StripeRequirementsCopyWithImpl<_StripeRequirements>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StripeRequirementsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StripeRequirements&&const DeepCollectionEquality().equals(other._currentlyDue, _currentlyDue)&&const DeepCollectionEquality().equals(other._eventuallyDue, _eventuallyDue)&&const DeepCollectionEquality().equals(other._pastDue, _pastDue)&&const DeepCollectionEquality().equals(other._pendingVerification, _pendingVerification)&&(identical(other.currentDeadline, currentDeadline) || other.currentDeadline == currentDeadline)&&(identical(other.disabledReason, disabledReason) || other.disabledReason == disabledReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_currentlyDue),const DeepCollectionEquality().hash(_eventuallyDue),const DeepCollectionEquality().hash(_pastDue),const DeepCollectionEquality().hash(_pendingVerification),currentDeadline,disabledReason);

@override
String toString() {
  return 'StripeRequirements(currentlyDue: $currentlyDue, eventuallyDue: $eventuallyDue, pastDue: $pastDue, pendingVerification: $pendingVerification, currentDeadline: $currentDeadline, disabledReason: $disabledReason)';
}


}

/// @nodoc
abstract mixin class _$StripeRequirementsCopyWith<$Res> implements $StripeRequirementsCopyWith<$Res> {
  factory _$StripeRequirementsCopyWith(_StripeRequirements value, $Res Function(_StripeRequirements) _then) = __$StripeRequirementsCopyWithImpl;
@override @useResult
$Res call({
 List<String> currentlyDue, List<String> eventuallyDue, List<String> pastDue, List<String> pendingVerification,@TimestampConverter() DateTime? currentDeadline, StripeDisabledReason? disabledReason
});




}
/// @nodoc
class __$StripeRequirementsCopyWithImpl<$Res>
    implements _$StripeRequirementsCopyWith<$Res> {
  __$StripeRequirementsCopyWithImpl(this._self, this._then);

  final _StripeRequirements _self;
  final $Res Function(_StripeRequirements) _then;

/// Create a copy of StripeRequirements
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentlyDue = null,Object? eventuallyDue = null,Object? pastDue = null,Object? pendingVerification = null,Object? currentDeadline = freezed,Object? disabledReason = freezed,}) {
  return _then(_StripeRequirements(
currentlyDue: null == currentlyDue ? _self._currentlyDue : currentlyDue // ignore: cast_nullable_to_non_nullable
as List<String>,eventuallyDue: null == eventuallyDue ? _self._eventuallyDue : eventuallyDue // ignore: cast_nullable_to_non_nullable
as List<String>,pastDue: null == pastDue ? _self._pastDue : pastDue // ignore: cast_nullable_to_non_nullable
as List<String>,pendingVerification: null == pendingVerification ? _self._pendingVerification : pendingVerification // ignore: cast_nullable_to_non_nullable
as List<String>,currentDeadline: freezed == currentDeadline ? _self.currentDeadline : currentDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,disabledReason: freezed == disabledReason ? _self.disabledReason : disabledReason // ignore: cast_nullable_to_non_nullable
as StripeDisabledReason?,
  ));
}


}


/// @nodoc
mixin _$PaymentTransaction {

 String get id; String get rideId; String get riderId; String get riderName; String get driverId; String get driverName; int get amountInCents; String get currency; PaymentStatus get status; int get platformFeeInCents; int get driverEarningsInCents; int get stripeFeeInCents; PaymentMethodType? get paymentMethodType; String? get paymentMethodLast4; String? get stripePaymentIntentId; String? get stripeCustomerId; String? get stripeChargeId; String? get stripeTransferId; String? get stripeBalanceTransactionId; String? get stripeRefundId; int? get seatsBooked;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get completedAt;@TimestampConverter() DateTime? get refundedAt; String? get failureReason; String? get refundReason; int? get refundedAmountInCents; Map<String, dynamic> get metadata;
/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentTransactionCopyWith<PaymentTransaction> get copyWith => _$PaymentTransactionCopyWithImpl<PaymentTransaction>(this as PaymentTransaction, _$identity);

  /// Serializes this PaymentTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.riderName, riderName) || other.riderName == riderName)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.platformFeeInCents, platformFeeInCents) || other.platformFeeInCents == platformFeeInCents)&&(identical(other.driverEarningsInCents, driverEarningsInCents) || other.driverEarningsInCents == driverEarningsInCents)&&(identical(other.stripeFeeInCents, stripeFeeInCents) || other.stripeFeeInCents == stripeFeeInCents)&&(identical(other.paymentMethodType, paymentMethodType) || other.paymentMethodType == paymentMethodType)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeChargeId, stripeChargeId) || other.stripeChargeId == stripeChargeId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.stripeBalanceTransactionId, stripeBalanceTransactionId) || other.stripeBalanceTransactionId == stripeBalanceTransactionId)&&(identical(other.stripeRefundId, stripeRefundId) || other.stripeRefundId == stripeRefundId)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&(identical(other.refundedAmountInCents, refundedAmountInCents) || other.refundedAmountInCents == refundedAmountInCents)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,riderId,riderName,driverId,driverName,amountInCents,currency,status,platformFeeInCents,driverEarningsInCents,stripeFeeInCents,paymentMethodType,paymentMethodLast4,stripePaymentIntentId,stripeCustomerId,stripeChargeId,stripeTransferId,stripeBalanceTransactionId,stripeRefundId,seatsBooked,createdAt,updatedAt,completedAt,refundedAt,failureReason,refundReason,refundedAmountInCents,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'PaymentTransaction(id: $id, rideId: $rideId, riderId: $riderId, riderName: $riderName, driverId: $driverId, driverName: $driverName, amountInCents: $amountInCents, currency: $currency, status: $status, platformFeeInCents: $platformFeeInCents, driverEarningsInCents: $driverEarningsInCents, stripeFeeInCents: $stripeFeeInCents, paymentMethodType: $paymentMethodType, paymentMethodLast4: $paymentMethodLast4, stripePaymentIntentId: $stripePaymentIntentId, stripeCustomerId: $stripeCustomerId, stripeChargeId: $stripeChargeId, stripeTransferId: $stripeTransferId, stripeBalanceTransactionId: $stripeBalanceTransactionId, stripeRefundId: $stripeRefundId, seatsBooked: $seatsBooked, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, refundedAt: $refundedAt, failureReason: $failureReason, refundReason: $refundReason, refundedAmountInCents: $refundedAmountInCents, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PaymentTransactionCopyWith<$Res>  {
  factory $PaymentTransactionCopyWith(PaymentTransaction value, $Res Function(PaymentTransaction) _then) = _$PaymentTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, String riderId, String riderName, String driverId, String driverName, int amountInCents, String currency, PaymentStatus status, int platformFeeInCents, int driverEarningsInCents, int stripeFeeInCents, PaymentMethodType? paymentMethodType, String? paymentMethodLast4, String? stripePaymentIntentId, String? stripeCustomerId, String? stripeChargeId, String? stripeTransferId, String? stripeBalanceTransactionId, String? stripeRefundId, int? seatsBooked,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? refundedAt, String? failureReason, String? refundReason, int? refundedAmountInCents, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$PaymentTransactionCopyWithImpl<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  _$PaymentTransactionCopyWithImpl(this._self, this._then);

  final PaymentTransaction _self;
  final $Res Function(PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? riderId = null,Object? riderName = null,Object? driverId = null,Object? driverName = null,Object? amountInCents = null,Object? currency = null,Object? status = null,Object? platformFeeInCents = null,Object? driverEarningsInCents = null,Object? stripeFeeInCents = null,Object? paymentMethodType = freezed,Object? paymentMethodLast4 = freezed,Object? stripePaymentIntentId = freezed,Object? stripeCustomerId = freezed,Object? stripeChargeId = freezed,Object? stripeTransferId = freezed,Object? stripeBalanceTransactionId = freezed,Object? stripeRefundId = freezed,Object? seatsBooked = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? refundedAt = freezed,Object? failureReason = freezed,Object? refundReason = freezed,Object? refundedAmountInCents = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,riderName: null == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,platformFeeInCents: null == platformFeeInCents ? _self.platformFeeInCents : platformFeeInCents // ignore: cast_nullable_to_non_nullable
as int,driverEarningsInCents: null == driverEarningsInCents ? _self.driverEarningsInCents : driverEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,stripeFeeInCents: null == stripeFeeInCents ? _self.stripeFeeInCents : stripeFeeInCents // ignore: cast_nullable_to_non_nullable
as int,paymentMethodType: freezed == paymentMethodType ? _self.paymentMethodType : paymentMethodType // ignore: cast_nullable_to_non_nullable
as PaymentMethodType?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeChargeId: freezed == stripeChargeId ? _self.stripeChargeId : stripeChargeId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,stripeBalanceTransactionId: freezed == stripeBalanceTransactionId ? _self.stripeBalanceTransactionId : stripeBalanceTransactionId // ignore: cast_nullable_to_non_nullable
as String?,stripeRefundId: freezed == stripeRefundId ? _self.stripeRefundId : stripeRefundId // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: freezed == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,refundedAmountInCents: freezed == refundedAmountInCents ? _self.refundedAmountInCents : refundedAmountInCents // ignore: cast_nullable_to_non_nullable
as int?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentTransaction].
extension PaymentTransactionPatterns on PaymentTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  int amountInCents,  String currency,  PaymentStatus status,  int platformFeeInCents,  int driverEarningsInCents,  int stripeFeeInCents,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  String? stripeRefundId,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  int? refundedAmountInCents,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amountInCents,_that.currency,_that.status,_that.platformFeeInCents,_that.driverEarningsInCents,_that.stripeFeeInCents,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.stripeRefundId,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.refundedAmountInCents,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  int amountInCents,  String currency,  PaymentStatus status,  int platformFeeInCents,  int driverEarningsInCents,  int stripeFeeInCents,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  String? stripeRefundId,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  int? refundedAmountInCents,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction():
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amountInCents,_that.currency,_that.status,_that.platformFeeInCents,_that.driverEarningsInCents,_that.stripeFeeInCents,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.stripeRefundId,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.refundedAmountInCents,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  int amountInCents,  String currency,  PaymentStatus status,  int platformFeeInCents,  int driverEarningsInCents,  int stripeFeeInCents,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  String? stripeRefundId,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  int? refundedAmountInCents,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amountInCents,_that.currency,_that.status,_that.platformFeeInCents,_that.driverEarningsInCents,_that.stripeFeeInCents,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.stripeRefundId,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.refundedAmountInCents,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentTransaction extends PaymentTransaction {
  const _PaymentTransaction({required this.id, required this.rideId, required this.riderId, required this.riderName, required this.driverId, required this.driverName, required this.amountInCents, required this.currency, required this.status, required this.platformFeeInCents, required this.driverEarningsInCents, this.stripeFeeInCents = 0, this.paymentMethodType, this.paymentMethodLast4, this.stripePaymentIntentId, this.stripeCustomerId, this.stripeChargeId, this.stripeTransferId, this.stripeBalanceTransactionId, this.stripeRefundId, this.seatsBooked, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.completedAt, @TimestampConverter() this.refundedAt, this.failureReason, this.refundReason, this.refundedAmountInCents, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _PaymentTransaction.fromJson(Map<String, dynamic> json) => _$PaymentTransactionFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  String riderId;
@override final  String riderName;
@override final  String driverId;
@override final  String driverName;
@override final  int amountInCents;
@override final  String currency;
@override final  PaymentStatus status;
@override final  int platformFeeInCents;
@override final  int driverEarningsInCents;
@override@JsonKey() final  int stripeFeeInCents;
@override final  PaymentMethodType? paymentMethodType;
@override final  String? paymentMethodLast4;
@override final  String? stripePaymentIntentId;
@override final  String? stripeCustomerId;
@override final  String? stripeChargeId;
@override final  String? stripeTransferId;
@override final  String? stripeBalanceTransactionId;
@override final  String? stripeRefundId;
@override final  int? seatsBooked;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? completedAt;
@override@TimestampConverter() final  DateTime? refundedAt;
@override final  String? failureReason;
@override final  String? refundReason;
@override final  int? refundedAmountInCents;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentTransactionCopyWith<_PaymentTransaction> get copyWith => __$PaymentTransactionCopyWithImpl<_PaymentTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.riderName, riderName) || other.riderName == riderName)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.platformFeeInCents, platformFeeInCents) || other.platformFeeInCents == platformFeeInCents)&&(identical(other.driverEarningsInCents, driverEarningsInCents) || other.driverEarningsInCents == driverEarningsInCents)&&(identical(other.stripeFeeInCents, stripeFeeInCents) || other.stripeFeeInCents == stripeFeeInCents)&&(identical(other.paymentMethodType, paymentMethodType) || other.paymentMethodType == paymentMethodType)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeChargeId, stripeChargeId) || other.stripeChargeId == stripeChargeId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.stripeBalanceTransactionId, stripeBalanceTransactionId) || other.stripeBalanceTransactionId == stripeBalanceTransactionId)&&(identical(other.stripeRefundId, stripeRefundId) || other.stripeRefundId == stripeRefundId)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&(identical(other.refundedAmountInCents, refundedAmountInCents) || other.refundedAmountInCents == refundedAmountInCents)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,riderId,riderName,driverId,driverName,amountInCents,currency,status,platformFeeInCents,driverEarningsInCents,stripeFeeInCents,paymentMethodType,paymentMethodLast4,stripePaymentIntentId,stripeCustomerId,stripeChargeId,stripeTransferId,stripeBalanceTransactionId,stripeRefundId,seatsBooked,createdAt,updatedAt,completedAt,refundedAt,failureReason,refundReason,refundedAmountInCents,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'PaymentTransaction(id: $id, rideId: $rideId, riderId: $riderId, riderName: $riderName, driverId: $driverId, driverName: $driverName, amountInCents: $amountInCents, currency: $currency, status: $status, platformFeeInCents: $platformFeeInCents, driverEarningsInCents: $driverEarningsInCents, stripeFeeInCents: $stripeFeeInCents, paymentMethodType: $paymentMethodType, paymentMethodLast4: $paymentMethodLast4, stripePaymentIntentId: $stripePaymentIntentId, stripeCustomerId: $stripeCustomerId, stripeChargeId: $stripeChargeId, stripeTransferId: $stripeTransferId, stripeBalanceTransactionId: $stripeBalanceTransactionId, stripeRefundId: $stripeRefundId, seatsBooked: $seatsBooked, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, refundedAt: $refundedAt, failureReason: $failureReason, refundReason: $refundReason, refundedAmountInCents: $refundedAmountInCents, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PaymentTransactionCopyWith<$Res> implements $PaymentTransactionCopyWith<$Res> {
  factory _$PaymentTransactionCopyWith(_PaymentTransaction value, $Res Function(_PaymentTransaction) _then) = __$PaymentTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, String riderId, String riderName, String driverId, String driverName, int amountInCents, String currency, PaymentStatus status, int platformFeeInCents, int driverEarningsInCents, int stripeFeeInCents, PaymentMethodType? paymentMethodType, String? paymentMethodLast4, String? stripePaymentIntentId, String? stripeCustomerId, String? stripeChargeId, String? stripeTransferId, String? stripeBalanceTransactionId, String? stripeRefundId, int? seatsBooked,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? refundedAt, String? failureReason, String? refundReason, int? refundedAmountInCents, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$PaymentTransactionCopyWithImpl<$Res>
    implements _$PaymentTransactionCopyWith<$Res> {
  __$PaymentTransactionCopyWithImpl(this._self, this._then);

  final _PaymentTransaction _self;
  final $Res Function(_PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? riderId = null,Object? riderName = null,Object? driverId = null,Object? driverName = null,Object? amountInCents = null,Object? currency = null,Object? status = null,Object? platformFeeInCents = null,Object? driverEarningsInCents = null,Object? stripeFeeInCents = null,Object? paymentMethodType = freezed,Object? paymentMethodLast4 = freezed,Object? stripePaymentIntentId = freezed,Object? stripeCustomerId = freezed,Object? stripeChargeId = freezed,Object? stripeTransferId = freezed,Object? stripeBalanceTransactionId = freezed,Object? stripeRefundId = freezed,Object? seatsBooked = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? refundedAt = freezed,Object? failureReason = freezed,Object? refundReason = freezed,Object? refundedAmountInCents = freezed,Object? metadata = null,}) {
  return _then(_PaymentTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,riderName: null == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,platformFeeInCents: null == platformFeeInCents ? _self.platformFeeInCents : platformFeeInCents // ignore: cast_nullable_to_non_nullable
as int,driverEarningsInCents: null == driverEarningsInCents ? _self.driverEarningsInCents : driverEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,stripeFeeInCents: null == stripeFeeInCents ? _self.stripeFeeInCents : stripeFeeInCents // ignore: cast_nullable_to_non_nullable
as int,paymentMethodType: freezed == paymentMethodType ? _self.paymentMethodType : paymentMethodType // ignore: cast_nullable_to_non_nullable
as PaymentMethodType?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeChargeId: freezed == stripeChargeId ? _self.stripeChargeId : stripeChargeId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,stripeBalanceTransactionId: freezed == stripeBalanceTransactionId ? _self.stripeBalanceTransactionId : stripeBalanceTransactionId // ignore: cast_nullable_to_non_nullable
as String?,stripeRefundId: freezed == stripeRefundId ? _self.stripeRefundId : stripeRefundId // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: freezed == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,refundedAmountInCents: freezed == refundedAmountInCents ? _self.refundedAmountInCents : refundedAmountInCents // ignore: cast_nullable_to_non_nullable
as int?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DriverPayout {

 String get id; String get driverId; String get driverName; String get connectedAccountId; int get amountInCents; String get currency; PayoutStatus get status; PayoutMethod get method; PayoutType get type; String? get destination; String? get stripePayoutId; String? get stripeTransferId; String? get stripeBalanceTransactionId; List<String> get transactionIds;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get expectedArrivalDate;@TimestampConverter() DateTime? get arrivedAt; String? get failureReason; String? get failureCode; Map<String, dynamic> get metadata;
/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverPayoutCopyWith<DriverPayout> get copyWith => _$DriverPayoutCopyWithImpl<DriverPayout>(this as DriverPayout, _$identity);

  /// Serializes this DriverPayout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverPayout&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.connectedAccountId, connectedAccountId) || other.connectedAccountId == connectedAccountId)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.type, type) || other.type == type)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.stripePayoutId, stripePayoutId) || other.stripePayoutId == stripePayoutId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.stripeBalanceTransactionId, stripeBalanceTransactionId) || other.stripeBalanceTransactionId == stripeBalanceTransactionId)&&const DeepCollectionEquality().equals(other.transactionIds, transactionIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expectedArrivalDate, expectedArrivalDate) || other.expectedArrivalDate == expectedArrivalDate)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.failureCode, failureCode) || other.failureCode == failureCode)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,driverName,connectedAccountId,amountInCents,currency,status,method,type,destination,stripePayoutId,stripeTransferId,stripeBalanceTransactionId,const DeepCollectionEquality().hash(transactionIds),createdAt,expectedArrivalDate,arrivedAt,failureReason,failureCode,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'DriverPayout(id: $id, driverId: $driverId, driverName: $driverName, connectedAccountId: $connectedAccountId, amountInCents: $amountInCents, currency: $currency, status: $status, method: $method, type: $type, destination: $destination, stripePayoutId: $stripePayoutId, stripeTransferId: $stripeTransferId, stripeBalanceTransactionId: $stripeBalanceTransactionId, transactionIds: $transactionIds, createdAt: $createdAt, expectedArrivalDate: $expectedArrivalDate, arrivedAt: $arrivedAt, failureReason: $failureReason, failureCode: $failureCode, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DriverPayoutCopyWith<$Res>  {
  factory $DriverPayoutCopyWith(DriverPayout value, $Res Function(DriverPayout) _then) = _$DriverPayoutCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String driverName, String connectedAccountId, int amountInCents, String currency, PayoutStatus status, PayoutMethod method, PayoutType type, String? destination, String? stripePayoutId, String? stripeTransferId, String? stripeBalanceTransactionId, List<String> transactionIds,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? expectedArrivalDate,@TimestampConverter() DateTime? arrivedAt, String? failureReason, String? failureCode, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DriverPayoutCopyWithImpl<$Res>
    implements $DriverPayoutCopyWith<$Res> {
  _$DriverPayoutCopyWithImpl(this._self, this._then);

  final DriverPayout _self;
  final $Res Function(DriverPayout) _then;

/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? connectedAccountId = null,Object? amountInCents = null,Object? currency = null,Object? status = null,Object? method = null,Object? type = null,Object? destination = freezed,Object? stripePayoutId = freezed,Object? stripeTransferId = freezed,Object? stripeBalanceTransactionId = freezed,Object? transactionIds = null,Object? createdAt = freezed,Object? expectedArrivalDate = freezed,Object? arrivedAt = freezed,Object? failureReason = freezed,Object? failureCode = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,connectedAccountId: null == connectedAccountId ? _self.connectedAccountId : connectedAccountId // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PayoutMethod,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PayoutType,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,stripePayoutId: freezed == stripePayoutId ? _self.stripePayoutId : stripePayoutId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,stripeBalanceTransactionId: freezed == stripeBalanceTransactionId ? _self.stripeBalanceTransactionId : stripeBalanceTransactionId // ignore: cast_nullable_to_non_nullable
as String?,transactionIds: null == transactionIds ? _self.transactionIds : transactionIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedArrivalDate: freezed == expectedArrivalDate ? _self.expectedArrivalDate : expectedArrivalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,failureCode: freezed == failureCode ? _self.failureCode : failureCode // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverPayout].
extension DriverPayoutPatterns on DriverPayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverPayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverPayout value)  $default,){
final _that = this;
switch (_that) {
case _DriverPayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverPayout value)?  $default,){
final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String connectedAccountId,  int amountInCents,  String currency,  PayoutStatus status,  PayoutMethod method,  PayoutType type,  String? destination,  String? stripePayoutId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  List<String> transactionIds, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  String? failureCode,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amountInCents,_that.currency,_that.status,_that.method,_that.type,_that.destination,_that.stripePayoutId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.transactionIds,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.failureCode,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String connectedAccountId,  int amountInCents,  String currency,  PayoutStatus status,  PayoutMethod method,  PayoutType type,  String? destination,  String? stripePayoutId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  List<String> transactionIds, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  String? failureCode,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DriverPayout():
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amountInCents,_that.currency,_that.status,_that.method,_that.type,_that.destination,_that.stripePayoutId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.transactionIds,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.failureCode,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String driverName,  String connectedAccountId,  int amountInCents,  String currency,  PayoutStatus status,  PayoutMethod method,  PayoutType type,  String? destination,  String? stripePayoutId,  String? stripeTransferId,  String? stripeBalanceTransactionId,  List<String> transactionIds, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  String? failureCode,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amountInCents,_that.currency,_that.status,_that.method,_that.type,_that.destination,_that.stripePayoutId,_that.stripeTransferId,_that.stripeBalanceTransactionId,_that.transactionIds,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.failureCode,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverPayout extends DriverPayout {
  const _DriverPayout({required this.id, required this.driverId, required this.driverName, required this.connectedAccountId, required this.amountInCents, required this.currency, required this.status, this.method = PayoutMethod.standard, this.type = PayoutType.bankAccount, this.destination, this.stripePayoutId, this.stripeTransferId, this.stripeBalanceTransactionId, final  List<String> transactionIds = const [], @TimestampConverter() this.createdAt, @TimestampConverter() this.expectedArrivalDate, @TimestampConverter() this.arrivedAt, this.failureReason, this.failureCode, final  Map<String, dynamic> metadata = const {}}): _transactionIds = transactionIds,_metadata = metadata,super._();
  factory _DriverPayout.fromJson(Map<String, dynamic> json) => _$DriverPayoutFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String driverName;
@override final  String connectedAccountId;
@override final  int amountInCents;
@override final  String currency;
@override final  PayoutStatus status;
@override@JsonKey() final  PayoutMethod method;
@override@JsonKey() final  PayoutType type;
@override final  String? destination;
@override final  String? stripePayoutId;
@override final  String? stripeTransferId;
@override final  String? stripeBalanceTransactionId;
 final  List<String> _transactionIds;
@override@JsonKey() List<String> get transactionIds {
  if (_transactionIds is EqualUnmodifiableListView) return _transactionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactionIds);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? expectedArrivalDate;
@override@TimestampConverter() final  DateTime? arrivedAt;
@override final  String? failureReason;
@override final  String? failureCode;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverPayoutCopyWith<_DriverPayout> get copyWith => __$DriverPayoutCopyWithImpl<_DriverPayout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverPayoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverPayout&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.connectedAccountId, connectedAccountId) || other.connectedAccountId == connectedAccountId)&&(identical(other.amountInCents, amountInCents) || other.amountInCents == amountInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.type, type) || other.type == type)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.stripePayoutId, stripePayoutId) || other.stripePayoutId == stripePayoutId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.stripeBalanceTransactionId, stripeBalanceTransactionId) || other.stripeBalanceTransactionId == stripeBalanceTransactionId)&&const DeepCollectionEquality().equals(other._transactionIds, _transactionIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expectedArrivalDate, expectedArrivalDate) || other.expectedArrivalDate == expectedArrivalDate)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.failureCode, failureCode) || other.failureCode == failureCode)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,driverName,connectedAccountId,amountInCents,currency,status,method,type,destination,stripePayoutId,stripeTransferId,stripeBalanceTransactionId,const DeepCollectionEquality().hash(_transactionIds),createdAt,expectedArrivalDate,arrivedAt,failureReason,failureCode,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'DriverPayout(id: $id, driverId: $driverId, driverName: $driverName, connectedAccountId: $connectedAccountId, amountInCents: $amountInCents, currency: $currency, status: $status, method: $method, type: $type, destination: $destination, stripePayoutId: $stripePayoutId, stripeTransferId: $stripeTransferId, stripeBalanceTransactionId: $stripeBalanceTransactionId, transactionIds: $transactionIds, createdAt: $createdAt, expectedArrivalDate: $expectedArrivalDate, arrivedAt: $arrivedAt, failureReason: $failureReason, failureCode: $failureCode, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DriverPayoutCopyWith<$Res> implements $DriverPayoutCopyWith<$Res> {
  factory _$DriverPayoutCopyWith(_DriverPayout value, $Res Function(_DriverPayout) _then) = __$DriverPayoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String driverName, String connectedAccountId, int amountInCents, String currency, PayoutStatus status, PayoutMethod method, PayoutType type, String? destination, String? stripePayoutId, String? stripeTransferId, String? stripeBalanceTransactionId, List<String> transactionIds,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? expectedArrivalDate,@TimestampConverter() DateTime? arrivedAt, String? failureReason, String? failureCode, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DriverPayoutCopyWithImpl<$Res>
    implements _$DriverPayoutCopyWith<$Res> {
  __$DriverPayoutCopyWithImpl(this._self, this._then);

  final _DriverPayout _self;
  final $Res Function(_DriverPayout) _then;

/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? connectedAccountId = null,Object? amountInCents = null,Object? currency = null,Object? status = null,Object? method = null,Object? type = null,Object? destination = freezed,Object? stripePayoutId = freezed,Object? stripeTransferId = freezed,Object? stripeBalanceTransactionId = freezed,Object? transactionIds = null,Object? createdAt = freezed,Object? expectedArrivalDate = freezed,Object? arrivedAt = freezed,Object? failureReason = freezed,Object? failureCode = freezed,Object? metadata = null,}) {
  return _then(_DriverPayout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,connectedAccountId: null == connectedAccountId ? _self.connectedAccountId : connectedAccountId // ignore: cast_nullable_to_non_nullable
as String,amountInCents: null == amountInCents ? _self.amountInCents : amountInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PayoutMethod,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PayoutType,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,stripePayoutId: freezed == stripePayoutId ? _self.stripePayoutId : stripePayoutId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,stripeBalanceTransactionId: freezed == stripeBalanceTransactionId ? _self.stripeBalanceTransactionId : stripeBalanceTransactionId // ignore: cast_nullable_to_non_nullable
as String?,transactionIds: null == transactionIds ? _self._transactionIds : transactionIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedArrivalDate: freezed == expectedArrivalDate ? _self.expectedArrivalDate : expectedArrivalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,failureCode: freezed == failureCode ? _self.failureCode : failureCode // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DriverConnectedAccount {

 String get id; String get driverId; String get stripeAccountId; String get email; String get country; String get defaultCurrency; bool get chargesEnabled; bool get payoutsEnabled; bool get detailsSubmitted; StripeCapabilities get capabilities; StripeRequirements get requirements; StripeRequirements get futureRequirements; bool? get onboardingCompleted;@TimestampConverter() DateTime? get onboardingCompletedAt; String? get accountHolderName; int get totalEarningsInCents; int get availableBalanceInCents; int get pendingBalanceInCents;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get lastPayoutAt; Map<String, dynamic> get metadata;
/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverConnectedAccountCopyWith<DriverConnectedAccount> get copyWith => _$DriverConnectedAccountCopyWithImpl<DriverConnectedAccount>(this as DriverConnectedAccount, _$identity);

  /// Serializes this DriverConnectedAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverConnectedAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.requirements, requirements) || other.requirements == requirements)&&(identical(other.futureRequirements, futureRequirements) || other.futureRequirements == futureRequirements)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastPayoutAt, lastPayoutAt) || other.lastPayoutAt == lastPayoutAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,stripeAccountId,email,country,defaultCurrency,chargesEnabled,payoutsEnabled,detailsSubmitted,capabilities,requirements,futureRequirements,onboardingCompleted,onboardingCompletedAt,accountHolderName,totalEarningsInCents,availableBalanceInCents,pendingBalanceInCents,createdAt,updatedAt,lastPayoutAt,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'DriverConnectedAccount(id: $id, driverId: $driverId, stripeAccountId: $stripeAccountId, email: $email, country: $country, defaultCurrency: $defaultCurrency, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, capabilities: $capabilities, requirements: $requirements, futureRequirements: $futureRequirements, onboardingCompleted: $onboardingCompleted, onboardingCompletedAt: $onboardingCompletedAt, accountHolderName: $accountHolderName, totalEarningsInCents: $totalEarningsInCents, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, createdAt: $createdAt, updatedAt: $updatedAt, lastPayoutAt: $lastPayoutAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DriverConnectedAccountCopyWith<$Res>  {
  factory $DriverConnectedAccountCopyWith(DriverConnectedAccount value, $Res Function(DriverConnectedAccount) _then) = _$DriverConnectedAccountCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String stripeAccountId, String email, String country, String defaultCurrency, bool chargesEnabled, bool payoutsEnabled, bool detailsSubmitted, StripeCapabilities capabilities, StripeRequirements requirements, StripeRequirements futureRequirements, bool? onboardingCompleted,@TimestampConverter() DateTime? onboardingCompletedAt, String? accountHolderName, int totalEarningsInCents, int availableBalanceInCents, int pendingBalanceInCents,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastPayoutAt, Map<String, dynamic> metadata
});


$StripeCapabilitiesCopyWith<$Res> get capabilities;$StripeRequirementsCopyWith<$Res> get requirements;$StripeRequirementsCopyWith<$Res> get futureRequirements;

}
/// @nodoc
class _$DriverConnectedAccountCopyWithImpl<$Res>
    implements $DriverConnectedAccountCopyWith<$Res> {
  _$DriverConnectedAccountCopyWithImpl(this._self, this._then);

  final DriverConnectedAccount _self;
  final $Res Function(DriverConnectedAccount) _then;

/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? stripeAccountId = null,Object? email = null,Object? country = null,Object? defaultCurrency = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? capabilities = null,Object? requirements = null,Object? futureRequirements = null,Object? onboardingCompleted = freezed,Object? onboardingCompletedAt = freezed,Object? accountHolderName = freezed,Object? totalEarningsInCents = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastPayoutAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: null == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as StripeCapabilities,requirements: null == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as StripeRequirements,futureRequirements: null == futureRequirements ? _self.futureRequirements : futureRequirements // ignore: cast_nullable_to_non_nullable
as StripeRequirements,onboardingCompleted: freezed == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountHolderName: freezed == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String?,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutAt: freezed == lastPayoutAt ? _self.lastPayoutAt : lastPayoutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeCapabilitiesCopyWith<$Res> get capabilities {
  
  return $StripeCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeRequirementsCopyWith<$Res> get requirements {
  
  return $StripeRequirementsCopyWith<$Res>(_self.requirements, (value) {
    return _then(_self.copyWith(requirements: value));
  });
}/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeRequirementsCopyWith<$Res> get futureRequirements {
  
  return $StripeRequirementsCopyWith<$Res>(_self.futureRequirements, (value) {
    return _then(_self.copyWith(futureRequirements: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverConnectedAccount].
extension DriverConnectedAccountPatterns on DriverConnectedAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverConnectedAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverConnectedAccount value)  $default,){
final _that = this;
switch (_that) {
case _DriverConnectedAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverConnectedAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  String defaultCurrency,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  StripeCapabilities capabilities,  StripeRequirements requirements,  StripeRequirements futureRequirements,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? accountHolderName,  int totalEarningsInCents,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.defaultCurrency,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.capabilities,_that.requirements,_that.futureRequirements,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.accountHolderName,_that.totalEarningsInCents,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  String defaultCurrency,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  StripeCapabilities capabilities,  StripeRequirements requirements,  StripeRequirements futureRequirements,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? accountHolderName,  int totalEarningsInCents,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DriverConnectedAccount():
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.defaultCurrency,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.capabilities,_that.requirements,_that.futureRequirements,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.accountHolderName,_that.totalEarningsInCents,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  String defaultCurrency,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  StripeCapabilities capabilities,  StripeRequirements requirements,  StripeRequirements futureRequirements,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? accountHolderName,  int totalEarningsInCents,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.defaultCurrency,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.capabilities,_that.requirements,_that.futureRequirements,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.accountHolderName,_that.totalEarningsInCents,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverConnectedAccount extends DriverConnectedAccount {
  const _DriverConnectedAccount({required this.id, required this.driverId, required this.stripeAccountId, required this.email, required this.country, required this.defaultCurrency, required this.chargesEnabled, required this.payoutsEnabled, required this.detailsSubmitted, this.capabilities = const StripeCapabilities(), this.requirements = const StripeRequirements(), this.futureRequirements = const StripeRequirements(), this.onboardingCompleted, @TimestampConverter() this.onboardingCompletedAt, this.accountHolderName, this.totalEarningsInCents = 0, this.availableBalanceInCents = 0, this.pendingBalanceInCents = 0, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastPayoutAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DriverConnectedAccount.fromJson(Map<String, dynamic> json) => _$DriverConnectedAccountFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String stripeAccountId;
@override final  String email;
@override final  String country;
@override final  String defaultCurrency;
@override final  bool chargesEnabled;
@override final  bool payoutsEnabled;
@override final  bool detailsSubmitted;
@override@JsonKey() final  StripeCapabilities capabilities;
@override@JsonKey() final  StripeRequirements requirements;
@override@JsonKey() final  StripeRequirements futureRequirements;
@override final  bool? onboardingCompleted;
@override@TimestampConverter() final  DateTime? onboardingCompletedAt;
@override final  String? accountHolderName;
@override@JsonKey() final  int totalEarningsInCents;
@override@JsonKey() final  int availableBalanceInCents;
@override@JsonKey() final  int pendingBalanceInCents;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastPayoutAt;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverConnectedAccountCopyWith<_DriverConnectedAccount> get copyWith => __$DriverConnectedAccountCopyWithImpl<_DriverConnectedAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverConnectedAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverConnectedAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.capabilities, capabilities) || other.capabilities == capabilities)&&(identical(other.requirements, requirements) || other.requirements == requirements)&&(identical(other.futureRequirements, futureRequirements) || other.futureRequirements == futureRequirements)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastPayoutAt, lastPayoutAt) || other.lastPayoutAt == lastPayoutAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,stripeAccountId,email,country,defaultCurrency,chargesEnabled,payoutsEnabled,detailsSubmitted,capabilities,requirements,futureRequirements,onboardingCompleted,onboardingCompletedAt,accountHolderName,totalEarningsInCents,availableBalanceInCents,pendingBalanceInCents,createdAt,updatedAt,lastPayoutAt,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'DriverConnectedAccount(id: $id, driverId: $driverId, stripeAccountId: $stripeAccountId, email: $email, country: $country, defaultCurrency: $defaultCurrency, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, capabilities: $capabilities, requirements: $requirements, futureRequirements: $futureRequirements, onboardingCompleted: $onboardingCompleted, onboardingCompletedAt: $onboardingCompletedAt, accountHolderName: $accountHolderName, totalEarningsInCents: $totalEarningsInCents, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, createdAt: $createdAt, updatedAt: $updatedAt, lastPayoutAt: $lastPayoutAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DriverConnectedAccountCopyWith<$Res> implements $DriverConnectedAccountCopyWith<$Res> {
  factory _$DriverConnectedAccountCopyWith(_DriverConnectedAccount value, $Res Function(_DriverConnectedAccount) _then) = __$DriverConnectedAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String stripeAccountId, String email, String country, String defaultCurrency, bool chargesEnabled, bool payoutsEnabled, bool detailsSubmitted, StripeCapabilities capabilities, StripeRequirements requirements, StripeRequirements futureRequirements, bool? onboardingCompleted,@TimestampConverter() DateTime? onboardingCompletedAt, String? accountHolderName, int totalEarningsInCents, int availableBalanceInCents, int pendingBalanceInCents,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastPayoutAt, Map<String, dynamic> metadata
});


@override $StripeCapabilitiesCopyWith<$Res> get capabilities;@override $StripeRequirementsCopyWith<$Res> get requirements;@override $StripeRequirementsCopyWith<$Res> get futureRequirements;

}
/// @nodoc
class __$DriverConnectedAccountCopyWithImpl<$Res>
    implements _$DriverConnectedAccountCopyWith<$Res> {
  __$DriverConnectedAccountCopyWithImpl(this._self, this._then);

  final _DriverConnectedAccount _self;
  final $Res Function(_DriverConnectedAccount) _then;

/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? stripeAccountId = null,Object? email = null,Object? country = null,Object? defaultCurrency = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? capabilities = null,Object? requirements = null,Object? futureRequirements = null,Object? onboardingCompleted = freezed,Object? onboardingCompletedAt = freezed,Object? accountHolderName = freezed,Object? totalEarningsInCents = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastPayoutAt = freezed,Object? metadata = null,}) {
  return _then(_DriverConnectedAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: null == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,capabilities: null == capabilities ? _self.capabilities : capabilities // ignore: cast_nullable_to_non_nullable
as StripeCapabilities,requirements: null == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as StripeRequirements,futureRequirements: null == futureRequirements ? _self.futureRequirements : futureRequirements // ignore: cast_nullable_to_non_nullable
as StripeRequirements,onboardingCompleted: freezed == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountHolderName: freezed == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String?,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutAt: freezed == lastPayoutAt ? _self.lastPayoutAt : lastPayoutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeCapabilitiesCopyWith<$Res> get capabilities {
  
  return $StripeCapabilitiesCopyWith<$Res>(_self.capabilities, (value) {
    return _then(_self.copyWith(capabilities: value));
  });
}/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeRequirementsCopyWith<$Res> get requirements {
  
  return $StripeRequirementsCopyWith<$Res>(_self.requirements, (value) {
    return _then(_self.copyWith(requirements: value));
  });
}/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StripeRequirementsCopyWith<$Res> get futureRequirements {
  
  return $StripeRequirementsCopyWith<$Res>(_self.futureRequirements, (value) {
    return _then(_self.copyWith(futureRequirements: value));
  });
}
}


/// @nodoc
mixin _$RiderPaymentMethod {

 String get id; String get riderId; String get stripeCustomerId; String get stripePaymentMethodId; String get brand; String get last4; int get exMonth; int get exYear; String? get fingerprint; String? get funding; String? get cardCountry; bool get isDefault;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderPaymentMethodCopyWith<RiderPaymentMethod> get copyWith => _$RiderPaymentMethodCopyWithImpl<RiderPaymentMethod>(this as RiderPaymentMethod, _$identity);

  /// Serializes this RiderPaymentMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripePaymentMethodId, stripePaymentMethodId) || other.stripePaymentMethodId == stripePaymentMethodId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.exMonth, exMonth) || other.exMonth == exMonth)&&(identical(other.exYear, exYear) || other.exYear == exYear)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.funding, funding) || other.funding == funding)&&(identical(other.cardCountry, cardCountry) || other.cardCountry == cardCountry)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,stripeCustomerId,stripePaymentMethodId,brand,last4,exMonth,exYear,fingerprint,funding,cardCountry,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'RiderPaymentMethod(id: $id, riderId: $riderId, stripeCustomerId: $stripeCustomerId, stripePaymentMethodId: $stripePaymentMethodId, brand: $brand, last4: $last4, exMonth: $exMonth, exYear: $exYear, fingerprint: $fingerprint, funding: $funding, cardCountry: $cardCountry, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RiderPaymentMethodCopyWith<$Res>  {
  factory $RiderPaymentMethodCopyWith(RiderPaymentMethod value, $Res Function(RiderPaymentMethod) _then) = _$RiderPaymentMethodCopyWithImpl;
@useResult
$Res call({
 String id, String riderId, String stripeCustomerId, String stripePaymentMethodId, String brand, String last4, int exMonth, int exYear, String? fingerprint, String? funding, String? cardCountry, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$RiderPaymentMethodCopyWithImpl<$Res>
    implements $RiderPaymentMethodCopyWith<$Res> {
  _$RiderPaymentMethodCopyWithImpl(this._self, this._then);

  final RiderPaymentMethod _self;
  final $Res Function(RiderPaymentMethod) _then;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? riderId = null,Object? stripeCustomerId = null,Object? stripePaymentMethodId = null,Object? brand = null,Object? last4 = null,Object? exMonth = null,Object? exYear = null,Object? fingerprint = freezed,Object? funding = freezed,Object? cardCountry = freezed,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: null == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String,stripePaymentMethodId: null == stripePaymentMethodId ? _self.stripePaymentMethodId : stripePaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,exMonth: null == exMonth ? _self.exMonth : exMonth // ignore: cast_nullable_to_non_nullable
as int,exYear: null == exYear ? _self.exYear : exYear // ignore: cast_nullable_to_non_nullable
as int,fingerprint: freezed == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String?,funding: freezed == funding ? _self.funding : funding // ignore: cast_nullable_to_non_nullable
as String?,cardCountry: freezed == cardCountry ? _self.cardCountry : cardCountry // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiderPaymentMethod].
extension RiderPaymentMethodPatterns on RiderPaymentMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiderPaymentMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiderPaymentMethod value)  $default,){
final _that = this;
switch (_that) {
case _RiderPaymentMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiderPaymentMethod value)?  $default,){
final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  String? fingerprint,  String? funding,  String? cardCountry,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.fingerprint,_that.funding,_that.cardCountry,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  String? fingerprint,  String? funding,  String? cardCountry,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RiderPaymentMethod():
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.fingerprint,_that.funding,_that.cardCountry,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  String? fingerprint,  String? funding,  String? cardCountry,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.fingerprint,_that.funding,_that.cardCountry,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiderPaymentMethod extends RiderPaymentMethod {
  const _RiderPaymentMethod({required this.id, required this.riderId, required this.stripeCustomerId, required this.stripePaymentMethodId, required this.brand, required this.last4, required this.exMonth, required this.exYear, this.fingerprint, this.funding, this.cardCountry, this.isDefault = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): super._();
  factory _RiderPaymentMethod.fromJson(Map<String, dynamic> json) => _$RiderPaymentMethodFromJson(json);

@override final  String id;
@override final  String riderId;
@override final  String stripeCustomerId;
@override final  String stripePaymentMethodId;
@override final  String brand;
@override final  String last4;
@override final  int exMonth;
@override final  int exYear;
@override final  String? fingerprint;
@override final  String? funding;
@override final  String? cardCountry;
@override@JsonKey() final  bool isDefault;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiderPaymentMethodCopyWith<_RiderPaymentMethod> get copyWith => __$RiderPaymentMethodCopyWithImpl<_RiderPaymentMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderPaymentMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiderPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripePaymentMethodId, stripePaymentMethodId) || other.stripePaymentMethodId == stripePaymentMethodId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.exMonth, exMonth) || other.exMonth == exMonth)&&(identical(other.exYear, exYear) || other.exYear == exYear)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.funding, funding) || other.funding == funding)&&(identical(other.cardCountry, cardCountry) || other.cardCountry == cardCountry)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,stripeCustomerId,stripePaymentMethodId,brand,last4,exMonth,exYear,fingerprint,funding,cardCountry,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'RiderPaymentMethod(id: $id, riderId: $riderId, stripeCustomerId: $stripeCustomerId, stripePaymentMethodId: $stripePaymentMethodId, brand: $brand, last4: $last4, exMonth: $exMonth, exYear: $exYear, fingerprint: $fingerprint, funding: $funding, cardCountry: $cardCountry, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RiderPaymentMethodCopyWith<$Res> implements $RiderPaymentMethodCopyWith<$Res> {
  factory _$RiderPaymentMethodCopyWith(_RiderPaymentMethod value, $Res Function(_RiderPaymentMethod) _then) = __$RiderPaymentMethodCopyWithImpl;
@override @useResult
$Res call({
 String id, String riderId, String stripeCustomerId, String stripePaymentMethodId, String brand, String last4, int exMonth, int exYear, String? fingerprint, String? funding, String? cardCountry, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$RiderPaymentMethodCopyWithImpl<$Res>
    implements _$RiderPaymentMethodCopyWith<$Res> {
  __$RiderPaymentMethodCopyWithImpl(this._self, this._then);

  final _RiderPaymentMethod _self;
  final $Res Function(_RiderPaymentMethod) _then;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? riderId = null,Object? stripeCustomerId = null,Object? stripePaymentMethodId = null,Object? brand = null,Object? last4 = null,Object? exMonth = null,Object? exYear = null,Object? fingerprint = freezed,Object? funding = freezed,Object? cardCountry = freezed,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RiderPaymentMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: null == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String,stripePaymentMethodId: null == stripePaymentMethodId ? _self.stripePaymentMethodId : stripePaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,exMonth: null == exMonth ? _self.exMonth : exMonth // ignore: cast_nullable_to_non_nullable
as int,exYear: null == exYear ? _self.exYear : exYear // ignore: cast_nullable_to_non_nullable
as int,fingerprint: freezed == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String?,funding: freezed == funding ? _self.funding : funding // ignore: cast_nullable_to_non_nullable
as String?,cardCountry: freezed == cardCountry ? _self.cardCountry : cardCountry // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EarningsSummary {

 String get driverId; int get totalEarningsInCents; int get totalPlatformFeesInCents; int get totalStripeFeesInCents; int get earningsTodayInCents; int get earningsThisWeekInCents; int get earningsThisMonthInCents; int get earningsThisYearInCents; int get totalRidesCompleted; int get ridesCompletedToday; int get ridesCompletedThisWeek; int get ridesCompletedThisMonth; int get availableBalanceInCents; int get pendingBalanceInCents;@TimestampConverter() DateTime? get lastUpdated;@TimestampConverter() DateTime? get lastPayoutDate;
/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsSummaryCopyWith<EarningsSummary> get copyWith => _$EarningsSummaryCopyWithImpl<EarningsSummary>(this as EarningsSummary, _$identity);

  /// Serializes this EarningsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsSummary&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.totalPlatformFeesInCents, totalPlatformFeesInCents) || other.totalPlatformFeesInCents == totalPlatformFeesInCents)&&(identical(other.totalStripeFeesInCents, totalStripeFeesInCents) || other.totalStripeFeesInCents == totalStripeFeesInCents)&&(identical(other.earningsTodayInCents, earningsTodayInCents) || other.earningsTodayInCents == earningsTodayInCents)&&(identical(other.earningsThisWeekInCents, earningsThisWeekInCents) || other.earningsThisWeekInCents == earningsThisWeekInCents)&&(identical(other.earningsThisMonthInCents, earningsThisMonthInCents) || other.earningsThisMonthInCents == earningsThisMonthInCents)&&(identical(other.earningsThisYearInCents, earningsThisYearInCents) || other.earningsThisYearInCents == earningsThisYearInCents)&&(identical(other.totalRidesCompleted, totalRidesCompleted) || other.totalRidesCompleted == totalRidesCompleted)&&(identical(other.ridesCompletedToday, ridesCompletedToday) || other.ridesCompletedToday == ridesCompletedToday)&&(identical(other.ridesCompletedThisWeek, ridesCompletedThisWeek) || other.ridesCompletedThisWeek == ridesCompletedThisWeek)&&(identical(other.ridesCompletedThisMonth, ridesCompletedThisMonth) || other.ridesCompletedThisMonth == ridesCompletedThisMonth)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastPayoutDate, lastPayoutDate) || other.lastPayoutDate == lastPayoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,totalEarningsInCents,totalPlatformFeesInCents,totalStripeFeesInCents,earningsTodayInCents,earningsThisWeekInCents,earningsThisMonthInCents,earningsThisYearInCents,totalRidesCompleted,ridesCompletedToday,ridesCompletedThisWeek,ridesCompletedThisMonth,availableBalanceInCents,pendingBalanceInCents,lastUpdated,lastPayoutDate);

@override
String toString() {
  return 'EarningsSummary(driverId: $driverId, totalEarningsInCents: $totalEarningsInCents, totalPlatformFeesInCents: $totalPlatformFeesInCents, totalStripeFeesInCents: $totalStripeFeesInCents, earningsTodayInCents: $earningsTodayInCents, earningsThisWeekInCents: $earningsThisWeekInCents, earningsThisMonthInCents: $earningsThisMonthInCents, earningsThisYearInCents: $earningsThisYearInCents, totalRidesCompleted: $totalRidesCompleted, ridesCompletedToday: $ridesCompletedToday, ridesCompletedThisWeek: $ridesCompletedThisWeek, ridesCompletedThisMonth: $ridesCompletedThisMonth, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, lastUpdated: $lastUpdated, lastPayoutDate: $lastPayoutDate)';
}


}

/// @nodoc
abstract mixin class $EarningsSummaryCopyWith<$Res>  {
  factory $EarningsSummaryCopyWith(EarningsSummary value, $Res Function(EarningsSummary) _then) = _$EarningsSummaryCopyWithImpl;
@useResult
$Res call({
 String driverId, int totalEarningsInCents, int totalPlatformFeesInCents, int totalStripeFeesInCents, int earningsTodayInCents, int earningsThisWeekInCents, int earningsThisMonthInCents, int earningsThisYearInCents, int totalRidesCompleted, int ridesCompletedToday, int ridesCompletedThisWeek, int ridesCompletedThisMonth, int availableBalanceInCents, int pendingBalanceInCents,@TimestampConverter() DateTime? lastUpdated,@TimestampConverter() DateTime? lastPayoutDate
});




}
/// @nodoc
class _$EarningsSummaryCopyWithImpl<$Res>
    implements $EarningsSummaryCopyWith<$Res> {
  _$EarningsSummaryCopyWithImpl(this._self, this._then);

  final EarningsSummary _self;
  final $Res Function(EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? totalEarningsInCents = null,Object? totalPlatformFeesInCents = null,Object? totalStripeFeesInCents = null,Object? earningsTodayInCents = null,Object? earningsThisWeekInCents = null,Object? earningsThisMonthInCents = null,Object? earningsThisYearInCents = null,Object? totalRidesCompleted = null,Object? ridesCompletedToday = null,Object? ridesCompletedThisWeek = null,Object? ridesCompletedThisMonth = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? lastUpdated = freezed,Object? lastPayoutDate = freezed,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,totalPlatformFeesInCents: null == totalPlatformFeesInCents ? _self.totalPlatformFeesInCents : totalPlatformFeesInCents // ignore: cast_nullable_to_non_nullable
as int,totalStripeFeesInCents: null == totalStripeFeesInCents ? _self.totalStripeFeesInCents : totalStripeFeesInCents // ignore: cast_nullable_to_non_nullable
as int,earningsTodayInCents: null == earningsTodayInCents ? _self.earningsTodayInCents : earningsTodayInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisWeekInCents: null == earningsThisWeekInCents ? _self.earningsThisWeekInCents : earningsThisWeekInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisMonthInCents: null == earningsThisMonthInCents ? _self.earningsThisMonthInCents : earningsThisMonthInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisYearInCents: null == earningsThisYearInCents ? _self.earningsThisYearInCents : earningsThisYearInCents // ignore: cast_nullable_to_non_nullable
as int,totalRidesCompleted: null == totalRidesCompleted ? _self.totalRidesCompleted : totalRidesCompleted // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedToday: null == ridesCompletedToday ? _self.ridesCompletedToday : ridesCompletedToday // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisWeek: null == ridesCompletedThisWeek ? _self.ridesCompletedThisWeek : ridesCompletedThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisMonth: null == ridesCompletedThisMonth ? _self.ridesCompletedThisMonth : ridesCompletedThisMonth // ignore: cast_nullable_to_non_nullable
as int,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutDate: freezed == lastPayoutDate ? _self.lastPayoutDate : lastPayoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsSummary].
extension EarningsSummaryPatterns on EarningsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsSummary value)  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  int totalEarningsInCents,  int totalPlatformFeesInCents,  int totalStripeFeesInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int earningsThisYearInCents,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.driverId,_that.totalEarningsInCents,_that.totalPlatformFeesInCents,_that.totalStripeFeesInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.earningsThisYearInCents,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.lastUpdated,_that.lastPayoutDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  int totalEarningsInCents,  int totalPlatformFeesInCents,  int totalStripeFeesInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int earningsThisYearInCents,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary():
return $default(_that.driverId,_that.totalEarningsInCents,_that.totalPlatformFeesInCents,_that.totalStripeFeesInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.earningsThisYearInCents,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.lastUpdated,_that.lastPayoutDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  int totalEarningsInCents,  int totalPlatformFeesInCents,  int totalStripeFeesInCents,  int earningsTodayInCents,  int earningsThisWeekInCents,  int earningsThisMonthInCents,  int earningsThisYearInCents,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  int availableBalanceInCents,  int pendingBalanceInCents, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)?  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.driverId,_that.totalEarningsInCents,_that.totalPlatformFeesInCents,_that.totalStripeFeesInCents,_that.earningsTodayInCents,_that.earningsThisWeekInCents,_that.earningsThisMonthInCents,_that.earningsThisYearInCents,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.lastUpdated,_that.lastPayoutDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsSummary extends EarningsSummary {
  const _EarningsSummary({required this.driverId, this.totalEarningsInCents = 0, this.totalPlatformFeesInCents = 0, this.totalStripeFeesInCents = 0, this.earningsTodayInCents = 0, this.earningsThisWeekInCents = 0, this.earningsThisMonthInCents = 0, this.earningsThisYearInCents = 0, this.totalRidesCompleted = 0, this.ridesCompletedToday = 0, this.ridesCompletedThisWeek = 0, this.ridesCompletedThisMonth = 0, this.availableBalanceInCents = 0, this.pendingBalanceInCents = 0, @TimestampConverter() this.lastUpdated, @TimestampConverter() this.lastPayoutDate}): super._();
  factory _EarningsSummary.fromJson(Map<String, dynamic> json) => _$EarningsSummaryFromJson(json);

@override final  String driverId;
@override@JsonKey() final  int totalEarningsInCents;
@override@JsonKey() final  int totalPlatformFeesInCents;
@override@JsonKey() final  int totalStripeFeesInCents;
@override@JsonKey() final  int earningsTodayInCents;
@override@JsonKey() final  int earningsThisWeekInCents;
@override@JsonKey() final  int earningsThisMonthInCents;
@override@JsonKey() final  int earningsThisYearInCents;
@override@JsonKey() final  int totalRidesCompleted;
@override@JsonKey() final  int ridesCompletedToday;
@override@JsonKey() final  int ridesCompletedThisWeek;
@override@JsonKey() final  int ridesCompletedThisMonth;
@override@JsonKey() final  int availableBalanceInCents;
@override@JsonKey() final  int pendingBalanceInCents;
@override@TimestampConverter() final  DateTime? lastUpdated;
@override@TimestampConverter() final  DateTime? lastPayoutDate;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsSummaryCopyWith<_EarningsSummary> get copyWith => __$EarningsSummaryCopyWithImpl<_EarningsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsSummary&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.totalEarningsInCents, totalEarningsInCents) || other.totalEarningsInCents == totalEarningsInCents)&&(identical(other.totalPlatformFeesInCents, totalPlatformFeesInCents) || other.totalPlatformFeesInCents == totalPlatformFeesInCents)&&(identical(other.totalStripeFeesInCents, totalStripeFeesInCents) || other.totalStripeFeesInCents == totalStripeFeesInCents)&&(identical(other.earningsTodayInCents, earningsTodayInCents) || other.earningsTodayInCents == earningsTodayInCents)&&(identical(other.earningsThisWeekInCents, earningsThisWeekInCents) || other.earningsThisWeekInCents == earningsThisWeekInCents)&&(identical(other.earningsThisMonthInCents, earningsThisMonthInCents) || other.earningsThisMonthInCents == earningsThisMonthInCents)&&(identical(other.earningsThisYearInCents, earningsThisYearInCents) || other.earningsThisYearInCents == earningsThisYearInCents)&&(identical(other.totalRidesCompleted, totalRidesCompleted) || other.totalRidesCompleted == totalRidesCompleted)&&(identical(other.ridesCompletedToday, ridesCompletedToday) || other.ridesCompletedToday == ridesCompletedToday)&&(identical(other.ridesCompletedThisWeek, ridesCompletedThisWeek) || other.ridesCompletedThisWeek == ridesCompletedThisWeek)&&(identical(other.ridesCompletedThisMonth, ridesCompletedThisMonth) || other.ridesCompletedThisMonth == ridesCompletedThisMonth)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastPayoutDate, lastPayoutDate) || other.lastPayoutDate == lastPayoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,totalEarningsInCents,totalPlatformFeesInCents,totalStripeFeesInCents,earningsTodayInCents,earningsThisWeekInCents,earningsThisMonthInCents,earningsThisYearInCents,totalRidesCompleted,ridesCompletedToday,ridesCompletedThisWeek,ridesCompletedThisMonth,availableBalanceInCents,pendingBalanceInCents,lastUpdated,lastPayoutDate);

@override
String toString() {
  return 'EarningsSummary(driverId: $driverId, totalEarningsInCents: $totalEarningsInCents, totalPlatformFeesInCents: $totalPlatformFeesInCents, totalStripeFeesInCents: $totalStripeFeesInCents, earningsTodayInCents: $earningsTodayInCents, earningsThisWeekInCents: $earningsThisWeekInCents, earningsThisMonthInCents: $earningsThisMonthInCents, earningsThisYearInCents: $earningsThisYearInCents, totalRidesCompleted: $totalRidesCompleted, ridesCompletedToday: $ridesCompletedToday, ridesCompletedThisWeek: $ridesCompletedThisWeek, ridesCompletedThisMonth: $ridesCompletedThisMonth, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, lastUpdated: $lastUpdated, lastPayoutDate: $lastPayoutDate)';
}


}

/// @nodoc
abstract mixin class _$EarningsSummaryCopyWith<$Res> implements $EarningsSummaryCopyWith<$Res> {
  factory _$EarningsSummaryCopyWith(_EarningsSummary value, $Res Function(_EarningsSummary) _then) = __$EarningsSummaryCopyWithImpl;
@override @useResult
$Res call({
 String driverId, int totalEarningsInCents, int totalPlatformFeesInCents, int totalStripeFeesInCents, int earningsTodayInCents, int earningsThisWeekInCents, int earningsThisMonthInCents, int earningsThisYearInCents, int totalRidesCompleted, int ridesCompletedToday, int ridesCompletedThisWeek, int ridesCompletedThisMonth, int availableBalanceInCents, int pendingBalanceInCents,@TimestampConverter() DateTime? lastUpdated,@TimestampConverter() DateTime? lastPayoutDate
});




}
/// @nodoc
class __$EarningsSummaryCopyWithImpl<$Res>
    implements _$EarningsSummaryCopyWith<$Res> {
  __$EarningsSummaryCopyWithImpl(this._self, this._then);

  final _EarningsSummary _self;
  final $Res Function(_EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? totalEarningsInCents = null,Object? totalPlatformFeesInCents = null,Object? totalStripeFeesInCents = null,Object? earningsTodayInCents = null,Object? earningsThisWeekInCents = null,Object? earningsThisMonthInCents = null,Object? earningsThisYearInCents = null,Object? totalRidesCompleted = null,Object? ridesCompletedToday = null,Object? ridesCompletedThisWeek = null,Object? ridesCompletedThisMonth = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? lastUpdated = freezed,Object? lastPayoutDate = freezed,}) {
  return _then(_EarningsSummary(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,totalEarningsInCents: null == totalEarningsInCents ? _self.totalEarningsInCents : totalEarningsInCents // ignore: cast_nullable_to_non_nullable
as int,totalPlatformFeesInCents: null == totalPlatformFeesInCents ? _self.totalPlatformFeesInCents : totalPlatformFeesInCents // ignore: cast_nullable_to_non_nullable
as int,totalStripeFeesInCents: null == totalStripeFeesInCents ? _self.totalStripeFeesInCents : totalStripeFeesInCents // ignore: cast_nullable_to_non_nullable
as int,earningsTodayInCents: null == earningsTodayInCents ? _self.earningsTodayInCents : earningsTodayInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisWeekInCents: null == earningsThisWeekInCents ? _self.earningsThisWeekInCents : earningsThisWeekInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisMonthInCents: null == earningsThisMonthInCents ? _self.earningsThisMonthInCents : earningsThisMonthInCents // ignore: cast_nullable_to_non_nullable
as int,earningsThisYearInCents: null == earningsThisYearInCents ? _self.earningsThisYearInCents : earningsThisYearInCents // ignore: cast_nullable_to_non_nullable
as int,totalRidesCompleted: null == totalRidesCompleted ? _self.totalRidesCompleted : totalRidesCompleted // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedToday: null == ridesCompletedToday ? _self.ridesCompletedToday : ridesCompletedToday // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisWeek: null == ridesCompletedThisWeek ? _self.ridesCompletedThisWeek : ridesCompletedThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisMonth: null == ridesCompletedThisMonth ? _self.ridesCompletedThisMonth : ridesCompletedThisMonth // ignore: cast_nullable_to_non_nullable
as int,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutDate: freezed == lastPayoutDate ? _self.lastPayoutDate : lastPayoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
