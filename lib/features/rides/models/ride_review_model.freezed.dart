// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideReviewModel {

 String get id; String get reviewerId; String get reviewerName; String get revieweeId; double get rating; String? get reviewerPhotoUrl; String? get comment; List<String> get tags;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of RideReviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideReviewModelCopyWith<RideReviewModel> get copyWith => _$RideReviewModelCopyWithImpl<RideReviewModel>(this as RideReviewModel, _$identity);

  /// Serializes this RideReviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewerId,reviewerName,revieweeId,rating,reviewerPhotoUrl,comment,const DeepCollectionEquality().hash(tags),createdAt);

@override
String toString() {
  return 'RideReviewModel(id: $id, reviewerId: $reviewerId, reviewerName: $reviewerName, revieweeId: $revieweeId, rating: $rating, reviewerPhotoUrl: $reviewerPhotoUrl, comment: $comment, tags: $tags, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RideReviewModelCopyWith<$Res>  {
  factory $RideReviewModelCopyWith(RideReviewModel value, $Res Function(RideReviewModel) _then) = _$RideReviewModelCopyWithImpl;
@useResult
$Res call({
 String id, String reviewerId, String reviewerName, String revieweeId, double rating, String? reviewerPhotoUrl, String? comment, List<String> tags,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$RideReviewModelCopyWithImpl<$Res>
    implements $RideReviewModelCopyWith<$Res> {
  _$RideReviewModelCopyWithImpl(this._self, this._then);

  final RideReviewModel _self;
  final $Res Function(RideReviewModel) _then;

/// Create a copy of RideReviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reviewerId = null,Object? reviewerName = null,Object? revieweeId = null,Object? rating = null,Object? reviewerPhotoUrl = freezed,Object? comment = freezed,Object? tags = null,Object? createdAt = freezed,}) {
  return _then(RideReviewModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideReviewModel].
extension RideReviewModelPatterns on RideReviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideReviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideReviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideReviewModel value)  $default,){
final _that = this;
switch (_that) {
case _RideReviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideReviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideReviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reviewerId,  String reviewerName,  String revieweeId,  double rating,  String? reviewerPhotoUrl,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideReviewModel() when $default != null:
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.rating,_that.reviewerPhotoUrl,_that.comment,_that.tags,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reviewerId,  String reviewerName,  String revieweeId,  double rating,  String? reviewerPhotoUrl,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RideReviewModel():
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.rating,_that.reviewerPhotoUrl,_that.comment,_that.tags,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reviewerId,  String reviewerName,  String revieweeId,  double rating,  String? reviewerPhotoUrl,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RideReviewModel() when $default != null:
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.rating,_that.reviewerPhotoUrl,_that.comment,_that.tags,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideReviewModel extends RideReviewModel {
  const _RideReviewModel({required this.id, required this.reviewerId, required this.reviewerName, required this.revieweeId, required this.rating, this.reviewerPhotoUrl, this.comment,  List<String> tags = const [], @TimestampConverter() this.createdAt}): _tags = tags,super._();
  factory _RideReviewModel.fromJson(Map<String, dynamic> json) => _$RideReviewModelFromJson(json);

@override final  String id;
@override final  String reviewerId;
@override final  String reviewerName;
@override final  String revieweeId;
@override final  double rating;
@override final  String? reviewerPhotoUrl;
@override final  String? comment;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of RideReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideReviewModelCopyWith<_RideReviewModel> get copyWith => __$RideReviewModelCopyWithImpl<_RideReviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideReviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewerId,reviewerName,revieweeId,rating,reviewerPhotoUrl,comment,const DeepCollectionEquality().hash(_tags),createdAt);

@override
String toString() {
  return 'RideReviewModel(id: $id, reviewerId: $reviewerId, reviewerName: $reviewerName, revieweeId: $revieweeId, rating: $rating, reviewerPhotoUrl: $reviewerPhotoUrl, comment: $comment, tags: $tags, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RideReviewModelCopyWith<$Res> implements $RideReviewModelCopyWith<$Res> {
  factory _$RideReviewModelCopyWith(_RideReviewModel value, $Res Function(_RideReviewModel) _then) = __$RideReviewModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String reviewerId, String reviewerName, String revieweeId, double rating, String? reviewerPhotoUrl, String? comment, List<String> tags,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$RideReviewModelCopyWithImpl<$Res>
    implements _$RideReviewModelCopyWith<$Res> {
  __$RideReviewModelCopyWithImpl(this._self, this._then);

  final _RideReviewModel _self;
  final $Res Function(_RideReviewModel) _then;

/// Create a copy of RideReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reviewerId = null,Object? reviewerName = null,Object? revieweeId = null,Object? rating = null,Object? reviewerPhotoUrl = freezed,Object? comment = freezed,Object? tags = null,Object? createdAt = freezed,}) {
  return _then(_RideReviewModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
