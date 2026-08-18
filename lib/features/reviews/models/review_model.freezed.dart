// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewModel {

 String get id; String get rideId; String get reviewerId; String get reviewerName; String get revieweeId; String get revieweeName; ReviewType get type; double get rating;@RequiredTimestampConverter() DateTime get createdAt; String? get reviewerPhotoUrl; String? get revieweePhotoUrl; String? get comment; List<String> get tags; bool get isVisible; String? get response;@TimestampConverter() DateTime? get responseAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewModelCopyWith<ReviewModel> get copyWith => _$ReviewModelCopyWithImpl<ReviewModel>(this as ReviewModel, _$identity);

  /// Serializes this ReviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.revieweeName, revieweeName) || other.revieweeName == revieweeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.revieweePhotoUrl, revieweePhotoUrl) || other.revieweePhotoUrl == revieweePhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.response, response) || other.response == response)&&(identical(other.responseAt, responseAt) || other.responseAt == responseAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,reviewerId,reviewerName,revieweeId,revieweeName,type,rating,createdAt,reviewerPhotoUrl,revieweePhotoUrl,comment,const DeepCollectionEquality().hash(tags),isVisible,response,responseAt,updatedAt);

@override
String toString() {
  return 'ReviewModel(id: $id, rideId: $rideId, reviewerId: $reviewerId, reviewerName: $reviewerName, revieweeId: $revieweeId, revieweeName: $revieweeName, type: $type, rating: $rating, createdAt: $createdAt, reviewerPhotoUrl: $reviewerPhotoUrl, revieweePhotoUrl: $revieweePhotoUrl, comment: $comment, tags: $tags, isVisible: $isVisible, response: $response, responseAt: $responseAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewModelCopyWith<$Res>  {
  factory $ReviewModelCopyWith(ReviewModel value, $Res Function(ReviewModel) _then) = _$ReviewModelCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, String reviewerId, String reviewerName, String revieweeId, String revieweeName, ReviewType type, double rating,@RequiredTimestampConverter() DateTime createdAt, String? reviewerPhotoUrl, String? revieweePhotoUrl, String? comment, List<String> tags, bool isVisible, String? response,@TimestampConverter() DateTime? responseAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$ReviewModelCopyWithImpl<$Res>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._self, this._then);

  final ReviewModel _self;
  final $Res Function(ReviewModel) _then;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? reviewerId = null,Object? reviewerName = null,Object? revieweeId = null,Object? revieweeName = null,Object? type = null,Object? rating = null,Object? createdAt = null,Object? reviewerPhotoUrl = freezed,Object? revieweePhotoUrl = freezed,Object? comment = freezed,Object? tags = null,Object? isVisible = null,Object? response = freezed,Object? responseAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,revieweeName: null == revieweeName ? _self.revieweeName : revieweeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReviewType,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,revieweePhotoUrl: freezed == revieweePhotoUrl ? _self.revieweePhotoUrl : revieweePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,responseAt: freezed == responseAt ? _self.responseAt : responseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewModel].
extension ReviewModelPatterns on ReviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewModel value)  $default,){
final _that = this;
switch (_that) {
case _ReviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  String reviewerId,  String reviewerName,  String revieweeId,  String revieweeName,  ReviewType type,  double rating, @RequiredTimestampConverter()  DateTime createdAt,  String? reviewerPhotoUrl,  String? revieweePhotoUrl,  String? comment,  List<String> tags,  bool isVisible,  String? response, @TimestampConverter()  DateTime? responseAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
return $default(_that.id,_that.rideId,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.createdAt,_that.reviewerPhotoUrl,_that.revieweePhotoUrl,_that.comment,_that.tags,_that.isVisible,_that.response,_that.responseAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  String reviewerId,  String reviewerName,  String revieweeId,  String revieweeName,  ReviewType type,  double rating, @RequiredTimestampConverter()  DateTime createdAt,  String? reviewerPhotoUrl,  String? revieweePhotoUrl,  String? comment,  List<String> tags,  bool isVisible,  String? response, @TimestampConverter()  DateTime? responseAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewModel():
return $default(_that.id,_that.rideId,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.createdAt,_that.reviewerPhotoUrl,_that.revieweePhotoUrl,_that.comment,_that.tags,_that.isVisible,_that.response,_that.responseAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  String reviewerId,  String reviewerName,  String revieweeId,  String revieweeName,  ReviewType type,  double rating, @RequiredTimestampConverter()  DateTime createdAt,  String? reviewerPhotoUrl,  String? revieweePhotoUrl,  String? comment,  List<String> tags,  bool isVisible,  String? response, @TimestampConverter()  DateTime? responseAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewModel() when $default != null:
return $default(_that.id,_that.rideId,_that.reviewerId,_that.reviewerName,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.createdAt,_that.reviewerPhotoUrl,_that.revieweePhotoUrl,_that.comment,_that.tags,_that.isVisible,_that.response,_that.responseAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewModel extends ReviewModel {
  const _ReviewModel({required this.id, required this.rideId, required this.reviewerId, required this.reviewerName, required this.revieweeId, required this.revieweeName, required this.type, required this.rating, @RequiredTimestampConverter() required this.createdAt, this.reviewerPhotoUrl, this.revieweePhotoUrl, this.comment, final  List<String> tags = const [], this.isVisible = true, this.response, @TimestampConverter() this.responseAt, @TimestampConverter() this.updatedAt}): _tags = tags,super._();
  factory _ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  String reviewerId;
@override final  String reviewerName;
@override final  String revieweeId;
@override final  String revieweeName;
@override final  ReviewType type;
@override final  double rating;
@override@RequiredTimestampConverter() final  DateTime createdAt;
@override final  String? reviewerPhotoUrl;
@override final  String? revieweePhotoUrl;
@override final  String? comment;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isVisible;
@override final  String? response;
@override@TimestampConverter() final  DateTime? responseAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewModelCopyWith<_ReviewModel> get copyWith => __$ReviewModelCopyWithImpl<_ReviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.revieweeName, revieweeName) || other.revieweeName == revieweeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.revieweePhotoUrl, revieweePhotoUrl) || other.revieweePhotoUrl == revieweePhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.response, response) || other.response == response)&&(identical(other.responseAt, responseAt) || other.responseAt == responseAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,reviewerId,reviewerName,revieweeId,revieweeName,type,rating,createdAt,reviewerPhotoUrl,revieweePhotoUrl,comment,const DeepCollectionEquality().hash(_tags),isVisible,response,responseAt,updatedAt);

@override
String toString() {
  return 'ReviewModel(id: $id, rideId: $rideId, reviewerId: $reviewerId, reviewerName: $reviewerName, revieweeId: $revieweeId, revieweeName: $revieweeName, type: $type, rating: $rating, createdAt: $createdAt, reviewerPhotoUrl: $reviewerPhotoUrl, revieweePhotoUrl: $revieweePhotoUrl, comment: $comment, tags: $tags, isVisible: $isVisible, response: $response, responseAt: $responseAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewModelCopyWith<$Res> implements $ReviewModelCopyWith<$Res> {
  factory _$ReviewModelCopyWith(_ReviewModel value, $Res Function(_ReviewModel) _then) = __$ReviewModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, String reviewerId, String reviewerName, String revieweeId, String revieweeName, ReviewType type, double rating,@RequiredTimestampConverter() DateTime createdAt, String? reviewerPhotoUrl, String? revieweePhotoUrl, String? comment, List<String> tags, bool isVisible, String? response,@TimestampConverter() DateTime? responseAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$ReviewModelCopyWithImpl<$Res>
    implements _$ReviewModelCopyWith<$Res> {
  __$ReviewModelCopyWithImpl(this._self, this._then);

  final _ReviewModel _self;
  final $Res Function(_ReviewModel) _then;

/// Create a copy of ReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? reviewerId = null,Object? reviewerName = null,Object? revieweeId = null,Object? revieweeName = null,Object? type = null,Object? rating = null,Object? createdAt = null,Object? reviewerPhotoUrl = freezed,Object? revieweePhotoUrl = freezed,Object? comment = freezed,Object? tags = null,Object? isVisible = null,Object? response = freezed,Object? responseAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ReviewModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,revieweeName: null == revieweeName ? _self.revieweeName : revieweeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReviewType,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,revieweePhotoUrl: freezed == revieweePhotoUrl ? _self.revieweePhotoUrl : revieweePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,responseAt: freezed == responseAt ? _self.responseAt : responseAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RatingStats {

 int get totalReviews; double get averageRating; int get fiveStarCount; int get fourStarCount; int get threeStarCount; int get twoStarCount; int get oneStarCount; Map<String, int> get tagCounts;@TimestampConverter() DateTime? get lastReviewAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of RatingStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingStatsCopyWith<RatingStats> get copyWith => _$RatingStatsCopyWithImpl<RatingStats>(this as RatingStats, _$identity);

  /// Serializes this RatingStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatingStats&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.fiveStarCount, fiveStarCount) || other.fiveStarCount == fiveStarCount)&&(identical(other.fourStarCount, fourStarCount) || other.fourStarCount == fourStarCount)&&(identical(other.threeStarCount, threeStarCount) || other.threeStarCount == threeStarCount)&&(identical(other.twoStarCount, twoStarCount) || other.twoStarCount == twoStarCount)&&(identical(other.oneStarCount, oneStarCount) || other.oneStarCount == oneStarCount)&&const DeepCollectionEquality().equals(other.tagCounts, tagCounts)&&(identical(other.lastReviewAt, lastReviewAt) || other.lastReviewAt == lastReviewAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReviews,averageRating,fiveStarCount,fourStarCount,threeStarCount,twoStarCount,oneStarCount,const DeepCollectionEquality().hash(tagCounts),lastReviewAt,updatedAt);

@override
String toString() {
  return 'RatingStats(totalReviews: $totalReviews, averageRating: $averageRating, fiveStarCount: $fiveStarCount, fourStarCount: $fourStarCount, threeStarCount: $threeStarCount, twoStarCount: $twoStarCount, oneStarCount: $oneStarCount, tagCounts: $tagCounts, lastReviewAt: $lastReviewAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RatingStatsCopyWith<$Res>  {
  factory $RatingStatsCopyWith(RatingStats value, $Res Function(RatingStats) _then) = _$RatingStatsCopyWithImpl;
@useResult
$Res call({
 int totalReviews, double averageRating, int fiveStarCount, int fourStarCount, int threeStarCount, int twoStarCount, int oneStarCount, Map<String, int> tagCounts,@TimestampConverter() DateTime? lastReviewAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$RatingStatsCopyWithImpl<$Res>
    implements $RatingStatsCopyWith<$Res> {
  _$RatingStatsCopyWithImpl(this._self, this._then);

  final RatingStats _self;
  final $Res Function(RatingStats) _then;

/// Create a copy of RatingStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalReviews = null,Object? averageRating = null,Object? fiveStarCount = null,Object? fourStarCount = null,Object? threeStarCount = null,Object? twoStarCount = null,Object? oneStarCount = null,Object? tagCounts = null,Object? lastReviewAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,fiveStarCount: null == fiveStarCount ? _self.fiveStarCount : fiveStarCount // ignore: cast_nullable_to_non_nullable
as int,fourStarCount: null == fourStarCount ? _self.fourStarCount : fourStarCount // ignore: cast_nullable_to_non_nullable
as int,threeStarCount: null == threeStarCount ? _self.threeStarCount : threeStarCount // ignore: cast_nullable_to_non_nullable
as int,twoStarCount: null == twoStarCount ? _self.twoStarCount : twoStarCount // ignore: cast_nullable_to_non_nullable
as int,oneStarCount: null == oneStarCount ? _self.oneStarCount : oneStarCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self.tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lastReviewAt: freezed == lastReviewAt ? _self.lastReviewAt : lastReviewAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RatingStats].
extension RatingStatsPatterns on RatingStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatingStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatingStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatingStats value)  $default,){
final _that = this;
switch (_that) {
case _RatingStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatingStats value)?  $default,){
final _that = this;
switch (_that) {
case _RatingStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalReviews,  double averageRating,  int fiveStarCount,  int fourStarCount,  int threeStarCount,  int twoStarCount,  int oneStarCount,  Map<String, int> tagCounts, @TimestampConverter()  DateTime? lastReviewAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatingStats() when $default != null:
return $default(_that.totalReviews,_that.averageRating,_that.fiveStarCount,_that.fourStarCount,_that.threeStarCount,_that.twoStarCount,_that.oneStarCount,_that.tagCounts,_that.lastReviewAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalReviews,  double averageRating,  int fiveStarCount,  int fourStarCount,  int threeStarCount,  int twoStarCount,  int oneStarCount,  Map<String, int> tagCounts, @TimestampConverter()  DateTime? lastReviewAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RatingStats():
return $default(_that.totalReviews,_that.averageRating,_that.fiveStarCount,_that.fourStarCount,_that.threeStarCount,_that.twoStarCount,_that.oneStarCount,_that.tagCounts,_that.lastReviewAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalReviews,  double averageRating,  int fiveStarCount,  int fourStarCount,  int threeStarCount,  int twoStarCount,  int oneStarCount,  Map<String, int> tagCounts, @TimestampConverter()  DateTime? lastReviewAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RatingStats() when $default != null:
return $default(_that.totalReviews,_that.averageRating,_that.fiveStarCount,_that.fourStarCount,_that.threeStarCount,_that.twoStarCount,_that.oneStarCount,_that.tagCounts,_that.lastReviewAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RatingStats extends RatingStats {
  const _RatingStats({this.totalReviews = 0, this.averageRating = 0.0, this.fiveStarCount = 0, this.fourStarCount = 0, this.threeStarCount = 0, this.twoStarCount = 0, this.oneStarCount = 0, final  Map<String, int> tagCounts = const {}, @TimestampConverter() this.lastReviewAt, @TimestampConverter() this.updatedAt}): _tagCounts = tagCounts,super._();
  factory _RatingStats.fromJson(Map<String, dynamic> json) => _$RatingStatsFromJson(json);

@override@JsonKey() final  int totalReviews;
@override@JsonKey() final  double averageRating;
@override@JsonKey() final  int fiveStarCount;
@override@JsonKey() final  int fourStarCount;
@override@JsonKey() final  int threeStarCount;
@override@JsonKey() final  int twoStarCount;
@override@JsonKey() final  int oneStarCount;
 final  Map<String, int> _tagCounts;
@override@JsonKey() Map<String, int> get tagCounts {
  if (_tagCounts is EqualUnmodifiableMapView) return _tagCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tagCounts);
}

@override@TimestampConverter() final  DateTime? lastReviewAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of RatingStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingStatsCopyWith<_RatingStats> get copyWith => __$RatingStatsCopyWithImpl<_RatingStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatingStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatingStats&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.fiveStarCount, fiveStarCount) || other.fiveStarCount == fiveStarCount)&&(identical(other.fourStarCount, fourStarCount) || other.fourStarCount == fourStarCount)&&(identical(other.threeStarCount, threeStarCount) || other.threeStarCount == threeStarCount)&&(identical(other.twoStarCount, twoStarCount) || other.twoStarCount == twoStarCount)&&(identical(other.oneStarCount, oneStarCount) || other.oneStarCount == oneStarCount)&&const DeepCollectionEquality().equals(other._tagCounts, _tagCounts)&&(identical(other.lastReviewAt, lastReviewAt) || other.lastReviewAt == lastReviewAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReviews,averageRating,fiveStarCount,fourStarCount,threeStarCount,twoStarCount,oneStarCount,const DeepCollectionEquality().hash(_tagCounts),lastReviewAt,updatedAt);

@override
String toString() {
  return 'RatingStats(totalReviews: $totalReviews, averageRating: $averageRating, fiveStarCount: $fiveStarCount, fourStarCount: $fourStarCount, threeStarCount: $threeStarCount, twoStarCount: $twoStarCount, oneStarCount: $oneStarCount, tagCounts: $tagCounts, lastReviewAt: $lastReviewAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RatingStatsCopyWith<$Res> implements $RatingStatsCopyWith<$Res> {
  factory _$RatingStatsCopyWith(_RatingStats value, $Res Function(_RatingStats) _then) = __$RatingStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalReviews, double averageRating, int fiveStarCount, int fourStarCount, int threeStarCount, int twoStarCount, int oneStarCount, Map<String, int> tagCounts,@TimestampConverter() DateTime? lastReviewAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$RatingStatsCopyWithImpl<$Res>
    implements _$RatingStatsCopyWith<$Res> {
  __$RatingStatsCopyWithImpl(this._self, this._then);

  final _RatingStats _self;
  final $Res Function(_RatingStats) _then;

/// Create a copy of RatingStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalReviews = null,Object? averageRating = null,Object? fiveStarCount = null,Object? fourStarCount = null,Object? threeStarCount = null,Object? twoStarCount = null,Object? oneStarCount = null,Object? tagCounts = null,Object? lastReviewAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RatingStats(
totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,fiveStarCount: null == fiveStarCount ? _self.fiveStarCount : fiveStarCount // ignore: cast_nullable_to_non_nullable
as int,fourStarCount: null == fourStarCount ? _self.fourStarCount : fourStarCount // ignore: cast_nullable_to_non_nullable
as int,threeStarCount: null == threeStarCount ? _self.threeStarCount : threeStarCount // ignore: cast_nullable_to_non_nullable
as int,twoStarCount: null == twoStarCount ? _self.twoStarCount : twoStarCount // ignore: cast_nullable_to_non_nullable
as int,oneStarCount: null == oneStarCount ? _self.oneStarCount : oneStarCount // ignore: cast_nullable_to_non_nullable
as int,tagCounts: null == tagCounts ? _self._tagCounts : tagCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lastReviewAt: freezed == lastReviewAt ? _self.lastReviewAt : lastReviewAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateReviewRequest {

 String get rideId; String get revieweeId; String get revieweeName; ReviewType get type; double get rating; String? get revieweePhotoUrl; String? get comment; List<String> get tags;
/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReviewRequestCopyWith<CreateReviewRequest> get copyWith => _$CreateReviewRequestCopyWithImpl<CreateReviewRequest>(this as CreateReviewRequest, _$identity);

  /// Serializes this CreateReviewRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReviewRequest&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.revieweeName, revieweeName) || other.revieweeName == revieweeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.revieweePhotoUrl, revieweePhotoUrl) || other.revieweePhotoUrl == revieweePhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId,revieweeId,revieweeName,type,rating,revieweePhotoUrl,comment,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'CreateReviewRequest(rideId: $rideId, revieweeId: $revieweeId, revieweeName: $revieweeName, type: $type, rating: $rating, revieweePhotoUrl: $revieweePhotoUrl, comment: $comment, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $CreateReviewRequestCopyWith<$Res>  {
  factory $CreateReviewRequestCopyWith(CreateReviewRequest value, $Res Function(CreateReviewRequest) _then) = _$CreateReviewRequestCopyWithImpl;
@useResult
$Res call({
 String rideId, String revieweeId, String revieweeName, ReviewType type, double rating, String? revieweePhotoUrl, String? comment, List<String> tags
});




}
/// @nodoc
class _$CreateReviewRequestCopyWithImpl<$Res>
    implements $CreateReviewRequestCopyWith<$Res> {
  _$CreateReviewRequestCopyWithImpl(this._self, this._then);

  final CreateReviewRequest _self;
  final $Res Function(CreateReviewRequest) _then;

/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rideId = null,Object? revieweeId = null,Object? revieweeName = null,Object? type = null,Object? rating = null,Object? revieweePhotoUrl = freezed,Object? comment = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,revieweeName: null == revieweeName ? _self.revieweeName : revieweeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReviewType,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,revieweePhotoUrl: freezed == revieweePhotoUrl ? _self.revieweePhotoUrl : revieweePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateReviewRequest].
extension CreateReviewRequestPatterns on CreateReviewRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateReviewRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateReviewRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateReviewRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateReviewRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rideId,  String revieweeId,  String revieweeName,  ReviewType type,  double rating,  String? revieweePhotoUrl,  String? comment,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
return $default(_that.rideId,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.revieweePhotoUrl,_that.comment,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rideId,  String revieweeId,  String revieweeName,  ReviewType type,  double rating,  String? revieweePhotoUrl,  String? comment,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _CreateReviewRequest():
return $default(_that.rideId,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.revieweePhotoUrl,_that.comment,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rideId,  String revieweeId,  String revieweeName,  ReviewType type,  double rating,  String? revieweePhotoUrl,  String? comment,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _CreateReviewRequest() when $default != null:
return $default(_that.rideId,_that.revieweeId,_that.revieweeName,_that.type,_that.rating,_that.revieweePhotoUrl,_that.comment,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateReviewRequest extends CreateReviewRequest {
  const _CreateReviewRequest({required this.rideId, required this.revieweeId, required this.revieweeName, required this.type, required this.rating, this.revieweePhotoUrl, this.comment, final  List<String> tags = const []}): _tags = tags,super._();
  factory _CreateReviewRequest.fromJson(Map<String, dynamic> json) => _$CreateReviewRequestFromJson(json);

@override final  String rideId;
@override final  String revieweeId;
@override final  String revieweeName;
@override final  ReviewType type;
@override final  double rating;
@override final  String? revieweePhotoUrl;
@override final  String? comment;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateReviewRequestCopyWith<_CreateReviewRequest> get copyWith => __$CreateReviewRequestCopyWithImpl<_CreateReviewRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateReviewRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReviewRequest&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.revieweeName, revieweeName) || other.revieweeName == revieweeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.revieweePhotoUrl, revieweePhotoUrl) || other.revieweePhotoUrl == revieweePhotoUrl)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rideId,revieweeId,revieweeName,type,rating,revieweePhotoUrl,comment,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'CreateReviewRequest(rideId: $rideId, revieweeId: $revieweeId, revieweeName: $revieweeName, type: $type, rating: $rating, revieweePhotoUrl: $revieweePhotoUrl, comment: $comment, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$CreateReviewRequestCopyWith<$Res> implements $CreateReviewRequestCopyWith<$Res> {
  factory _$CreateReviewRequestCopyWith(_CreateReviewRequest value, $Res Function(_CreateReviewRequest) _then) = __$CreateReviewRequestCopyWithImpl;
@override @useResult
$Res call({
 String rideId, String revieweeId, String revieweeName, ReviewType type, double rating, String? revieweePhotoUrl, String? comment, List<String> tags
});




}
/// @nodoc
class __$CreateReviewRequestCopyWithImpl<$Res>
    implements _$CreateReviewRequestCopyWith<$Res> {
  __$CreateReviewRequestCopyWithImpl(this._self, this._then);

  final _CreateReviewRequest _self;
  final $Res Function(_CreateReviewRequest) _then;

/// Create a copy of CreateReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rideId = null,Object? revieweeId = null,Object? revieweeName = null,Object? type = null,Object? rating = null,Object? revieweePhotoUrl = freezed,Object? comment = freezed,Object? tags = null,}) {
  return _then(_CreateReviewRequest(
rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,revieweeName: null == revieweeName ? _self.revieweeName : revieweeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReviewType,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,revieweePhotoUrl: freezed == revieweePhotoUrl ? _self.revieweePhotoUrl : revieweePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
