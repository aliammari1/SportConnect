// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverStripeStatus implements DiagnosticableTreeMixin {

 bool get isConnected; bool get payoutsEnabled; bool get chargesEnabled; bool get detailsSubmitted; int get availableBalanceInCents; int get pendingBalanceInCents; String get currency; String? get stripeAccountId;
/// Create a copy of DriverStripeStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverStripeStatusCopyWith<DriverStripeStatus> get copyWith => _$DriverStripeStatusCopyWithImpl<DriverStripeStatus>(this as DriverStripeStatus, _$identity);

  /// Serializes this DriverStripeStatus to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DriverStripeStatus'))
    ..add(DiagnosticsProperty('isConnected', isConnected))..add(DiagnosticsProperty('payoutsEnabled', payoutsEnabled))..add(DiagnosticsProperty('chargesEnabled', chargesEnabled))..add(DiagnosticsProperty('detailsSubmitted', detailsSubmitted))..add(DiagnosticsProperty('availableBalanceInCents', availableBalanceInCents))..add(DiagnosticsProperty('pendingBalanceInCents', pendingBalanceInCents))..add(DiagnosticsProperty('currency', currency))..add(DiagnosticsProperty('stripeAccountId', stripeAccountId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverStripeStatus&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isConnected,payoutsEnabled,chargesEnabled,detailsSubmitted,availableBalanceInCents,pendingBalanceInCents,currency,stripeAccountId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DriverStripeStatus(isConnected: $isConnected, payoutsEnabled: $payoutsEnabled, chargesEnabled: $chargesEnabled, detailsSubmitted: $detailsSubmitted, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, currency: $currency, stripeAccountId: $stripeAccountId)';
}


}

/// @nodoc
abstract mixin class $DriverStripeStatusCopyWith<$Res>  {
  factory $DriverStripeStatusCopyWith(DriverStripeStatus value, $Res Function(DriverStripeStatus) _then) = _$DriverStripeStatusCopyWithImpl;
@useResult
$Res call({
 bool isConnected, bool payoutsEnabled, bool chargesEnabled, bool detailsSubmitted, int availableBalanceInCents, int pendingBalanceInCents, String currency, String? stripeAccountId
});




}
/// @nodoc
class _$DriverStripeStatusCopyWithImpl<$Res>
    implements $DriverStripeStatusCopyWith<$Res> {
  _$DriverStripeStatusCopyWithImpl(this._self, this._then);

  final DriverStripeStatus _self;
  final $Res Function(DriverStripeStatus) _then;

/// Create a copy of DriverStripeStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnected = null,Object? payoutsEnabled = null,Object? chargesEnabled = null,Object? detailsSubmitted = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? currency = null,Object? stripeAccountId = freezed,}) {
  return _then(DriverStripeStatus(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverStripeStatus].
extension DriverStripeStatusPatterns on DriverStripeStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverStripeStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverStripeStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverStripeStatus value)  $default,){
final _that = this;
switch (_that) {
case _DriverStripeStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverStripeStatus value)?  $default,){
final _that = this;
switch (_that) {
case _DriverStripeStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnected,  bool payoutsEnabled,  bool chargesEnabled,  bool detailsSubmitted,  int availableBalanceInCents,  int pendingBalanceInCents,  String currency,  String? stripeAccountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverStripeStatus() when $default != null:
return $default(_that.isConnected,_that.payoutsEnabled,_that.chargesEnabled,_that.detailsSubmitted,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.currency,_that.stripeAccountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnected,  bool payoutsEnabled,  bool chargesEnabled,  bool detailsSubmitted,  int availableBalanceInCents,  int pendingBalanceInCents,  String currency,  String? stripeAccountId)  $default,) {final _that = this;
switch (_that) {
case _DriverStripeStatus():
return $default(_that.isConnected,_that.payoutsEnabled,_that.chargesEnabled,_that.detailsSubmitted,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.currency,_that.stripeAccountId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnected,  bool payoutsEnabled,  bool chargesEnabled,  bool detailsSubmitted,  int availableBalanceInCents,  int pendingBalanceInCents,  String currency,  String? stripeAccountId)?  $default,) {final _that = this;
switch (_that) {
case _DriverStripeStatus() when $default != null:
return $default(_that.isConnected,_that.payoutsEnabled,_that.chargesEnabled,_that.detailsSubmitted,_that.availableBalanceInCents,_that.pendingBalanceInCents,_that.currency,_that.stripeAccountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverStripeStatus with DiagnosticableTreeMixin implements DriverStripeStatus {
  const _DriverStripeStatus({this.isConnected = false, this.payoutsEnabled = false, this.chargesEnabled = false, this.detailsSubmitted = false, this.availableBalanceInCents = 0, this.pendingBalanceInCents = 0, this.currency = 'EUR', this.stripeAccountId});
  factory _DriverStripeStatus.fromJson(Map<String, dynamic> json) => _$DriverStripeStatusFromJson(json);

@override@JsonKey() final  bool isConnected;
@override@JsonKey() final  bool payoutsEnabled;
@override@JsonKey() final  bool chargesEnabled;
@override@JsonKey() final  bool detailsSubmitted;
@override@JsonKey() final  int availableBalanceInCents;
@override@JsonKey() final  int pendingBalanceInCents;
@override@JsonKey() final  String currency;
@override final  String? stripeAccountId;

/// Create a copy of DriverStripeStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverStripeStatusCopyWith<_DriverStripeStatus> get copyWith => __$DriverStripeStatusCopyWithImpl<_DriverStripeStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverStripeStatusToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DriverStripeStatus'))
    ..add(DiagnosticsProperty('isConnected', isConnected))..add(DiagnosticsProperty('payoutsEnabled', payoutsEnabled))..add(DiagnosticsProperty('chargesEnabled', chargesEnabled))..add(DiagnosticsProperty('detailsSubmitted', detailsSubmitted))..add(DiagnosticsProperty('availableBalanceInCents', availableBalanceInCents))..add(DiagnosticsProperty('pendingBalanceInCents', pendingBalanceInCents))..add(DiagnosticsProperty('currency', currency))..add(DiagnosticsProperty('stripeAccountId', stripeAccountId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverStripeStatus&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.availableBalanceInCents, availableBalanceInCents) || other.availableBalanceInCents == availableBalanceInCents)&&(identical(other.pendingBalanceInCents, pendingBalanceInCents) || other.pendingBalanceInCents == pendingBalanceInCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isConnected,payoutsEnabled,chargesEnabled,detailsSubmitted,availableBalanceInCents,pendingBalanceInCents,currency,stripeAccountId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DriverStripeStatus(isConnected: $isConnected, payoutsEnabled: $payoutsEnabled, chargesEnabled: $chargesEnabled, detailsSubmitted: $detailsSubmitted, availableBalanceInCents: $availableBalanceInCents, pendingBalanceInCents: $pendingBalanceInCents, currency: $currency, stripeAccountId: $stripeAccountId)';
}


}

/// @nodoc
abstract mixin class _$DriverStripeStatusCopyWith<$Res> implements $DriverStripeStatusCopyWith<$Res> {
  factory _$DriverStripeStatusCopyWith(_DriverStripeStatus value, $Res Function(_DriverStripeStatus) _then) = __$DriverStripeStatusCopyWithImpl;
@override @useResult
$Res call({
 bool isConnected, bool payoutsEnabled, bool chargesEnabled, bool detailsSubmitted, int availableBalanceInCents, int pendingBalanceInCents, String currency, String? stripeAccountId
});




}
/// @nodoc
class __$DriverStripeStatusCopyWithImpl<$Res>
    implements _$DriverStripeStatusCopyWith<$Res> {
  __$DriverStripeStatusCopyWithImpl(this._self, this._then);

  final _DriverStripeStatus _self;
  final $Res Function(_DriverStripeStatus) _then;

/// Create a copy of DriverStripeStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnected = null,Object? payoutsEnabled = null,Object? chargesEnabled = null,Object? detailsSubmitted = null,Object? availableBalanceInCents = null,Object? pendingBalanceInCents = null,Object? currency = null,Object? stripeAccountId = freezed,}) {
  return _then(_DriverStripeStatus(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,availableBalanceInCents: null == availableBalanceInCents ? _self.availableBalanceInCents : availableBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,pendingBalanceInCents: null == pendingBalanceInCents ? _self.pendingBalanceInCents : pendingBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
