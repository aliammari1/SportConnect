// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel {

 String get id; String get userId; NotificationType get type; String get title; String get body; NotificationPriority get priority;// Related entity
 String? get referenceId; String? get referenceType;// Sender info (for social notifications)
 String? get senderId; String? get senderName; String? get senderPhotoUrl;// Rich media (e.g. promotion banners, achievement art); distinct from the
// sender's avatar.
 String? get imageUrl;// Action
 String? get actionUrl; Map<String, dynamic> get data;// Status
 bool get isRead; bool get isArchived; bool get isPushSent;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get readAt;@TimestampConverter() DateTime? get expiresAt;
/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationModelCopyWith<NotificationModel> get copyWith => _$NotificationModelCopyWithImpl<NotificationModel>(this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isPushSent, isPushSent) || other.isPushSent == isPushSent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,type,title,body,priority,referenceId,referenceType,senderId,senderName,senderPhotoUrl,imageUrl,actionUrl,const DeepCollectionEquality().hash(data),isRead,isArchived,isPushSent,createdAt,readAt,expiresAt]);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, type: $type, title: $title, body: $body, priority: $priority, referenceId: $referenceId, referenceType: $referenceType, senderId: $senderId, senderName: $senderName, senderPhotoUrl: $senderPhotoUrl, imageUrl: $imageUrl, actionUrl: $actionUrl, data: $data, isRead: $isRead, isArchived: $isArchived, isPushSent: $isPushSent, createdAt: $createdAt, readAt: $readAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res>  {
  factory $NotificationModelCopyWith(NotificationModel value, $Res Function(NotificationModel) _then) = _$NotificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, NotificationType type, String title, String body, NotificationPriority priority, String? referenceId, String? referenceType, String? senderId, String? senderName, String? senderPhotoUrl, String? imageUrl, String? actionUrl, Map<String, dynamic> data, bool isRead, bool isArchived, bool isPushSent,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? readAt,@TimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? body = null,Object? priority = null,Object? referenceId = freezed,Object? referenceType = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? senderPhotoUrl = freezed,Object? imageUrl = freezed,Object? actionUrl = freezed,Object? data = null,Object? isRead = null,Object? isArchived = null,Object? isPushSent = null,Object? createdAt = freezed,Object? readAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as NotificationPriority,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isPushSent: null == isPushSent ? _self.isPushSent : isPushSent // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  NotificationType type,  String title,  String body,  NotificationPriority priority,  String? referenceId,  String? referenceType,  String? senderId,  String? senderName,  String? senderPhotoUrl,  String? imageUrl,  String? actionUrl,  Map<String, dynamic> data,  bool isRead,  bool isArchived,  bool isPushSent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? readAt, @TimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.body,_that.priority,_that.referenceId,_that.referenceType,_that.senderId,_that.senderName,_that.senderPhotoUrl,_that.imageUrl,_that.actionUrl,_that.data,_that.isRead,_that.isArchived,_that.isPushSent,_that.createdAt,_that.readAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  NotificationType type,  String title,  String body,  NotificationPriority priority,  String? referenceId,  String? referenceType,  String? senderId,  String? senderName,  String? senderPhotoUrl,  String? imageUrl,  String? actionUrl,  Map<String, dynamic> data,  bool isRead,  bool isArchived,  bool isPushSent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? readAt, @TimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationModel():
return $default(_that.id,_that.userId,_that.type,_that.title,_that.body,_that.priority,_that.referenceId,_that.referenceType,_that.senderId,_that.senderName,_that.senderPhotoUrl,_that.imageUrl,_that.actionUrl,_that.data,_that.isRead,_that.isArchived,_that.isPushSent,_that.createdAt,_that.readAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  NotificationType type,  String title,  String body,  NotificationPriority priority,  String? referenceId,  String? referenceType,  String? senderId,  String? senderName,  String? senderPhotoUrl,  String? imageUrl,  String? actionUrl,  Map<String, dynamic> data,  bool isRead,  bool isArchived,  bool isPushSent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? readAt, @TimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.title,_that.body,_that.priority,_that.referenceId,_that.referenceType,_that.senderId,_that.senderName,_that.senderPhotoUrl,_that.imageUrl,_that.actionUrl,_that.data,_that.isRead,_that.isArchived,_that.isPushSent,_that.createdAt,_that.readAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationModel extends NotificationModel {
  const _NotificationModel({required this.id, required this.userId, required this.type, required this.title, required this.body, this.priority = NotificationPriority.normal, this.referenceId, this.referenceType, this.senderId, this.senderName, this.senderPhotoUrl, this.imageUrl, this.actionUrl, final  Map<String, dynamic> data = const {}, this.isRead = false, this.isArchived = false, this.isPushSent = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.readAt, @TimestampConverter() this.expiresAt}): _data = data,super._();
  factory _NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  NotificationType type;
@override final  String title;
@override final  String body;
@override@JsonKey() final  NotificationPriority priority;
// Related entity
@override final  String? referenceId;
@override final  String? referenceType;
// Sender info (for social notifications)
@override final  String? senderId;
@override final  String? senderName;
@override final  String? senderPhotoUrl;
// Rich media (e.g. promotion banners, achievement art); distinct from the
// sender's avatar.
@override final  String? imageUrl;
// Action
@override final  String? actionUrl;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

// Status
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  bool isPushSent;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? readAt;
@override@TimestampConverter() final  DateTime? expiresAt;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationModelCopyWith<_NotificationModel> get copyWith => __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.isPushSent, isPushSent) || other.isPushSent == isPushSent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,type,title,body,priority,referenceId,referenceType,senderId,senderName,senderPhotoUrl,imageUrl,actionUrl,const DeepCollectionEquality().hash(_data),isRead,isArchived,isPushSent,createdAt,readAt,expiresAt]);

@override
String toString() {
  return 'NotificationModel(id: $id, userId: $userId, type: $type, title: $title, body: $body, priority: $priority, referenceId: $referenceId, referenceType: $referenceType, senderId: $senderId, senderName: $senderName, senderPhotoUrl: $senderPhotoUrl, imageUrl: $imageUrl, actionUrl: $actionUrl, data: $data, isRead: $isRead, isArchived: $isArchived, isPushSent: $isPushSent, createdAt: $createdAt, readAt: $readAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res> implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(_NotificationModel value, $Res Function(_NotificationModel) _then) = __$NotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, NotificationType type, String title, String body, NotificationPriority priority, String? referenceId, String? referenceType, String? senderId, String? senderName, String? senderPhotoUrl, String? imageUrl, String? actionUrl, Map<String, dynamic> data, bool isRead, bool isArchived, bool isPushSent,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? readAt,@TimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

/// Create a copy of NotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? body = null,Object? priority = null,Object? referenceId = freezed,Object? referenceType = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? senderPhotoUrl = freezed,Object? imageUrl = freezed,Object? actionUrl = freezed,Object? data = null,Object? isRead = null,Object? isArchived = null,Object? isPushSent = null,Object? createdAt = freezed,Object? readAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_NotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as NotificationPriority,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,isPushSent: null == isPushSent ? _self.isPushSent : isPushSent // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationPreferences {

// Push notifications
 bool get pushEnabled; bool get rideNotifications; bool get messageNotifications; bool get socialNotifications; bool get gamificationNotifications; bool get promotionNotifications;// Email notifications
 bool get emailEnabled; bool get emailRideSummary; bool get emailWeeklyDigest;// Quiet hours
 bool get quietHoursEnabled; String get quietHoursStart; String get quietHoursEnd;// Sound & vibration
 bool get soundEnabled; bool get vibrationEnabled;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.rideNotifications, rideNotifications) || other.rideNotifications == rideNotifications)&&(identical(other.messageNotifications, messageNotifications) || other.messageNotifications == messageNotifications)&&(identical(other.socialNotifications, socialNotifications) || other.socialNotifications == socialNotifications)&&(identical(other.gamificationNotifications, gamificationNotifications) || other.gamificationNotifications == gamificationNotifications)&&(identical(other.promotionNotifications, promotionNotifications) || other.promotionNotifications == promotionNotifications)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.emailRideSummary, emailRideSummary) || other.emailRideSummary == emailRideSummary)&&(identical(other.emailWeeklyDigest, emailWeeklyDigest) || other.emailWeeklyDigest == emailWeeklyDigest)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pushEnabled,rideNotifications,messageNotifications,socialNotifications,gamificationNotifications,promotionNotifications,emailEnabled,emailRideSummary,emailWeeklyDigest,quietHoursEnabled,quietHoursStart,quietHoursEnd,soundEnabled,vibrationEnabled);

@override
String toString() {
  return 'NotificationPreferences(pushEnabled: $pushEnabled, rideNotifications: $rideNotifications, messageNotifications: $messageNotifications, socialNotifications: $socialNotifications, gamificationNotifications: $gamificationNotifications, promotionNotifications: $promotionNotifications, emailEnabled: $emailEnabled, emailRideSummary: $emailRideSummary, emailWeeklyDigest: $emailWeeklyDigest, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool pushEnabled, bool rideNotifications, bool messageNotifications, bool socialNotifications, bool gamificationNotifications, bool promotionNotifications, bool emailEnabled, bool emailRideSummary, bool emailWeeklyDigest, bool quietHoursEnabled, String quietHoursStart, String quietHoursEnd, bool soundEnabled, bool vibrationEnabled
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pushEnabled = null,Object? rideNotifications = null,Object? messageNotifications = null,Object? socialNotifications = null,Object? gamificationNotifications = null,Object? promotionNotifications = null,Object? emailEnabled = null,Object? emailRideSummary = null,Object? emailWeeklyDigest = null,Object? quietHoursEnabled = null,Object? quietHoursStart = null,Object? quietHoursEnd = null,Object? soundEnabled = null,Object? vibrationEnabled = null,}) {
  return _then(_self.copyWith(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,rideNotifications: null == rideNotifications ? _self.rideNotifications : rideNotifications // ignore: cast_nullable_to_non_nullable
as bool,messageNotifications: null == messageNotifications ? _self.messageNotifications : messageNotifications // ignore: cast_nullable_to_non_nullable
as bool,socialNotifications: null == socialNotifications ? _self.socialNotifications : socialNotifications // ignore: cast_nullable_to_non_nullable
as bool,gamificationNotifications: null == gamificationNotifications ? _self.gamificationNotifications : gamificationNotifications // ignore: cast_nullable_to_non_nullable
as bool,promotionNotifications: null == promotionNotifications ? _self.promotionNotifications : promotionNotifications // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailRideSummary: null == emailRideSummary ? _self.emailRideSummary : emailRideSummary // ignore: cast_nullable_to_non_nullable
as bool,emailWeeklyDigest: null == emailWeeklyDigest ? _self.emailWeeklyDigest : emailWeeklyDigest // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: null == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnd: null == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool pushEnabled,  bool rideNotifications,  bool messageNotifications,  bool socialNotifications,  bool gamificationNotifications,  bool promotionNotifications,  bool emailEnabled,  bool emailRideSummary,  bool emailWeeklyDigest,  bool quietHoursEnabled,  String quietHoursStart,  String quietHoursEnd,  bool soundEnabled,  bool vibrationEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.rideNotifications,_that.messageNotifications,_that.socialNotifications,_that.gamificationNotifications,_that.promotionNotifications,_that.emailEnabled,_that.emailRideSummary,_that.emailWeeklyDigest,_that.quietHoursEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.soundEnabled,_that.vibrationEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool pushEnabled,  bool rideNotifications,  bool messageNotifications,  bool socialNotifications,  bool gamificationNotifications,  bool promotionNotifications,  bool emailEnabled,  bool emailRideSummary,  bool emailWeeklyDigest,  bool quietHoursEnabled,  String quietHoursStart,  String quietHoursEnd,  bool soundEnabled,  bool vibrationEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.pushEnabled,_that.rideNotifications,_that.messageNotifications,_that.socialNotifications,_that.gamificationNotifications,_that.promotionNotifications,_that.emailEnabled,_that.emailRideSummary,_that.emailWeeklyDigest,_that.quietHoursEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.soundEnabled,_that.vibrationEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool pushEnabled,  bool rideNotifications,  bool messageNotifications,  bool socialNotifications,  bool gamificationNotifications,  bool promotionNotifications,  bool emailEnabled,  bool emailRideSummary,  bool emailWeeklyDigest,  bool quietHoursEnabled,  String quietHoursStart,  String quietHoursEnd,  bool soundEnabled,  bool vibrationEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.pushEnabled,_that.rideNotifications,_that.messageNotifications,_that.socialNotifications,_that.gamificationNotifications,_that.promotionNotifications,_that.emailEnabled,_that.emailRideSummary,_that.emailWeeklyDigest,_that.quietHoursEnabled,_that.quietHoursStart,_that.quietHoursEnd,_that.soundEnabled,_that.vibrationEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.pushEnabled = true, this.rideNotifications = true, this.messageNotifications = true, this.socialNotifications = true, this.gamificationNotifications = true, this.promotionNotifications = true, this.emailEnabled = true, this.emailRideSummary = true, this.emailWeeklyDigest = true, this.quietHoursEnabled = false, this.quietHoursStart = '22:00', this.quietHoursEnd = '08:00', this.soundEnabled = true, this.vibrationEnabled = true}): super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

// Push notifications
@override@JsonKey() final  bool pushEnabled;
@override@JsonKey() final  bool rideNotifications;
@override@JsonKey() final  bool messageNotifications;
@override@JsonKey() final  bool socialNotifications;
@override@JsonKey() final  bool gamificationNotifications;
@override@JsonKey() final  bool promotionNotifications;
// Email notifications
@override@JsonKey() final  bool emailEnabled;
@override@JsonKey() final  bool emailRideSummary;
@override@JsonKey() final  bool emailWeeklyDigest;
// Quiet hours
@override@JsonKey() final  bool quietHoursEnabled;
@override@JsonKey() final  String quietHoursStart;
@override@JsonKey() final  String quietHoursEnd;
// Sound & vibration
@override@JsonKey() final  bool soundEnabled;
@override@JsonKey() final  bool vibrationEnabled;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.rideNotifications, rideNotifications) || other.rideNotifications == rideNotifications)&&(identical(other.messageNotifications, messageNotifications) || other.messageNotifications == messageNotifications)&&(identical(other.socialNotifications, socialNotifications) || other.socialNotifications == socialNotifications)&&(identical(other.gamificationNotifications, gamificationNotifications) || other.gamificationNotifications == gamificationNotifications)&&(identical(other.promotionNotifications, promotionNotifications) || other.promotionNotifications == promotionNotifications)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.emailRideSummary, emailRideSummary) || other.emailRideSummary == emailRideSummary)&&(identical(other.emailWeeklyDigest, emailWeeklyDigest) || other.emailWeeklyDigest == emailWeeklyDigest)&&(identical(other.quietHoursEnabled, quietHoursEnabled) || other.quietHoursEnabled == quietHoursEnabled)&&(identical(other.quietHoursStart, quietHoursStart) || other.quietHoursStart == quietHoursStart)&&(identical(other.quietHoursEnd, quietHoursEnd) || other.quietHoursEnd == quietHoursEnd)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.vibrationEnabled, vibrationEnabled) || other.vibrationEnabled == vibrationEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pushEnabled,rideNotifications,messageNotifications,socialNotifications,gamificationNotifications,promotionNotifications,emailEnabled,emailRideSummary,emailWeeklyDigest,quietHoursEnabled,quietHoursStart,quietHoursEnd,soundEnabled,vibrationEnabled);

@override
String toString() {
  return 'NotificationPreferences(pushEnabled: $pushEnabled, rideNotifications: $rideNotifications, messageNotifications: $messageNotifications, socialNotifications: $socialNotifications, gamificationNotifications: $gamificationNotifications, promotionNotifications: $promotionNotifications, emailEnabled: $emailEnabled, emailRideSummary: $emailRideSummary, emailWeeklyDigest: $emailWeeklyDigest, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool pushEnabled, bool rideNotifications, bool messageNotifications, bool socialNotifications, bool gamificationNotifications, bool promotionNotifications, bool emailEnabled, bool emailRideSummary, bool emailWeeklyDigest, bool quietHoursEnabled, String quietHoursStart, String quietHoursEnd, bool soundEnabled, bool vibrationEnabled
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pushEnabled = null,Object? rideNotifications = null,Object? messageNotifications = null,Object? socialNotifications = null,Object? gamificationNotifications = null,Object? promotionNotifications = null,Object? emailEnabled = null,Object? emailRideSummary = null,Object? emailWeeklyDigest = null,Object? quietHoursEnabled = null,Object? quietHoursStart = null,Object? quietHoursEnd = null,Object? soundEnabled = null,Object? vibrationEnabled = null,}) {
  return _then(_NotificationPreferences(
pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,rideNotifications: null == rideNotifications ? _self.rideNotifications : rideNotifications // ignore: cast_nullable_to_non_nullable
as bool,messageNotifications: null == messageNotifications ? _self.messageNotifications : messageNotifications // ignore: cast_nullable_to_non_nullable
as bool,socialNotifications: null == socialNotifications ? _self.socialNotifications : socialNotifications // ignore: cast_nullable_to_non_nullable
as bool,gamificationNotifications: null == gamificationNotifications ? _self.gamificationNotifications : gamificationNotifications // ignore: cast_nullable_to_non_nullable
as bool,promotionNotifications: null == promotionNotifications ? _self.promotionNotifications : promotionNotifications // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailRideSummary: null == emailRideSummary ? _self.emailRideSummary : emailRideSummary // ignore: cast_nullable_to_non_nullable
as bool,emailWeeklyDigest: null == emailWeeklyDigest ? _self.emailWeeklyDigest : emailWeeklyDigest // ignore: cast_nullable_to_non_nullable
as bool,quietHoursEnabled: null == quietHoursEnabled ? _self.quietHoursEnabled : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
as bool,quietHoursStart: null == quietHoursStart ? _self.quietHoursStart : quietHoursStart // ignore: cast_nullable_to_non_nullable
as String,quietHoursEnd: null == quietHoursEnd ? _self.quietHoursEnd : quietHoursEnd // ignore: cast_nullable_to_non_nullable
as String,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,vibrationEnabled: null == vibrationEnabled ? _self.vibrationEnabled : vibrationEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
