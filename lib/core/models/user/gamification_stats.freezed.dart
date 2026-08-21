// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GamificationStats {

 int get totalXP; int get totalRides; int get ridesOffered; int get currentStreak; int get longestStreak; double get totalDistance; List<String> get unlockedBadges; List<Achievement> get achievements;
/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamificationStatsCopyWith<GamificationStats> get copyWith => _$GamificationStatsCopyWithImpl<GamificationStats>(this as GamificationStats, _$identity);

  /// Serializes this GamificationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesOffered, ridesOffered) || other.ridesOffered == ridesOffered)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other.unlockedBadges, unlockedBadges)&&const DeepCollectionEquality().equals(other.achievements, achievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,totalRides,ridesOffered,currentStreak,longestStreak,totalDistance,const DeepCollectionEquality().hash(unlockedBadges),const DeepCollectionEquality().hash(achievements));

@override
String toString() {
  return 'GamificationStats(totalXP: $totalXP, totalRides: $totalRides, ridesOffered: $ridesOffered, currentStreak: $currentStreak, longestStreak: $longestStreak, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements)';
}


}

/// @nodoc
abstract mixin class $GamificationStatsCopyWith<$Res>  {
  factory $GamificationStatsCopyWith(GamificationStats value, $Res Function(GamificationStats) _then) = _$GamificationStatsCopyWithImpl;
@useResult
$Res call({
 int totalXP, int totalRides, int ridesOffered, int currentStreak, int longestStreak, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements
});




}
/// @nodoc
class _$GamificationStatsCopyWithImpl<$Res>
    implements $GamificationStatsCopyWith<$Res> {
  _$GamificationStatsCopyWithImpl(this._self, this._then);

  final GamificationStats _self;
  final $Res Function(GamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalXP = null,Object? totalRides = null,Object? ridesOffered = null,Object? currentStreak = null,Object? longestStreak = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,}) {
  return _then(GamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesOffered: null == ridesOffered ? _self.ridesOffered : ridesOffered // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self.unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,
  ));
}

}


/// Adds pattern-matching-related methods to [GamificationStats].
extension GamificationStatsPatterns on GamificationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamificationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamificationStats value)  $default,){
final _that = this;
switch (_that) {
case _GamificationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamificationStats value)?  $default,){
final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalXP,  int totalRides,  int ridesOffered,  int currentStreak,  int longestStreak,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
return $default(_that.totalXP,_that.totalRides,_that.ridesOffered,_that.currentStreak,_that.longestStreak,_that.totalDistance,_that.unlockedBadges,_that.achievements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalXP,  int totalRides,  int ridesOffered,  int currentStreak,  int longestStreak,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements)  $default,) {final _that = this;
switch (_that) {
case _GamificationStats():
return $default(_that.totalXP,_that.totalRides,_that.ridesOffered,_that.currentStreak,_that.longestStreak,_that.totalDistance,_that.unlockedBadges,_that.achievements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalXP,  int totalRides,  int ridesOffered,  int currentStreak,  int longestStreak,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements)?  $default,) {final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
return $default(_that.totalXP,_that.totalRides,_that.ridesOffered,_that.currentStreak,_that.longestStreak,_that.totalDistance,_that.unlockedBadges,_that.achievements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamificationStats extends GamificationStats {
  const _GamificationStats({this.totalXP = 0, this.totalRides = 0, this.ridesOffered = 0, this.currentStreak = 0, this.longestStreak = 0, this.totalDistance = 0.0,  List<String> unlockedBadges = const [],  List<Achievement> achievements = const []}): _unlockedBadges = unlockedBadges,_achievements = achievements,super._();
  factory _GamificationStats.fromJson(Map<String, dynamic> json) => _$GamificationStatsFromJson(json);

@override@JsonKey() final  int totalXP;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int ridesOffered;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  double totalDistance;
 final  List<String> _unlockedBadges;
@override@JsonKey() List<String> get unlockedBadges {
  if (_unlockedBadges is EqualUnmodifiableListView) return _unlockedBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlockedBadges);
}

 final  List<Achievement> _achievements;
@override@JsonKey() List<Achievement> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}


/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamificationStatsCopyWith<_GamificationStats> get copyWith => __$GamificationStatsCopyWithImpl<_GamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesOffered, ridesOffered) || other.ridesOffered == ridesOffered)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,totalRides,ridesOffered,currentStreak,longestStreak,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements));

@override
String toString() {
  return 'GamificationStats(totalXP: $totalXP, totalRides: $totalRides, ridesOffered: $ridesOffered, currentStreak: $currentStreak, longestStreak: $longestStreak, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements)';
}


}

/// @nodoc
abstract mixin class _$GamificationStatsCopyWith<$Res> implements $GamificationStatsCopyWith<$Res> {
  factory _$GamificationStatsCopyWith(_GamificationStats value, $Res Function(_GamificationStats) _then) = __$GamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int totalRides, int ridesOffered, int currentStreak, int longestStreak, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements
});




}
/// @nodoc
class __$GamificationStatsCopyWithImpl<$Res>
    implements _$GamificationStatsCopyWith<$Res> {
  __$GamificationStatsCopyWithImpl(this._self, this._then);

  final _GamificationStats _self;
  final $Res Function(_GamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? totalRides = null,Object? ridesOffered = null,Object? currentStreak = null,Object? longestStreak = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,}) {
  return _then(_GamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesOffered: null == ridesOffered ? _self.ridesOffered : ridesOffered // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self._unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,
  ));
}


}

// dart format on
