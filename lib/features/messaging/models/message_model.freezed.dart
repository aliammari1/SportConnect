// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageModel {

 String get id; String get chatId; String get senderId; String get senderName; String get content; String? get senderPhotoUrl; MessageType get type; MessageStatus get status; String? get mediaUrl; String? get thumbnailUrl;// Location
 double? get latitude; double? get longitude; String? get locationName;// Ride attachment
 String? get rideId;// Reply context
 String? get replyToMessageId; String? get replyToContent;// Reactions: emoji → [userId, ...]
 Map<String, List<String>> get reactions;// Read receipts
 List<String> get readBy; List<String> get deliveredTo;// Metadata
 bool get isEdited; bool get isDeleted;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get editedAt;
/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageModelCopyWith<MessageModel> get copyWith => _$MessageModelCopyWithImpl<MessageModel>(this as MessageModel, _$identity);

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToContent, replyToContent) || other.replyToContent == replyToContent)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.readBy, readBy)&&const DeepCollectionEquality().equals(other.deliveredTo, deliveredTo)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,chatId,senderId,senderName,content,senderPhotoUrl,type,status,mediaUrl,thumbnailUrl,latitude,longitude,locationName,rideId,replyToMessageId,replyToContent,const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(readBy),const DeepCollectionEquality().hash(deliveredTo),isEdited,isDeleted,createdAt,editedAt]);

@override
String toString() {
  return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, content: $content, senderPhotoUrl: $senderPhotoUrl, type: $type, status: $status, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, latitude: $latitude, longitude: $longitude, locationName: $locationName, rideId: $rideId, replyToMessageId: $replyToMessageId, replyToContent: $replyToContent, reactions: $reactions, readBy: $readBy, deliveredTo: $deliveredTo, isEdited: $isEdited, isDeleted: $isDeleted, createdAt: $createdAt, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class $MessageModelCopyWith<$Res>  {
  factory $MessageModelCopyWith(MessageModel value, $Res Function(MessageModel) _then) = _$MessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, String senderId, String senderName, String content, String? senderPhotoUrl, MessageType type, MessageStatus status, String? mediaUrl, String? thumbnailUrl, double? latitude, double? longitude, String? locationName, String? rideId, String? replyToMessageId, String? replyToContent, Map<String, List<String>> reactions, List<String> readBy, List<String> deliveredTo, bool isEdited, bool isDeleted,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? editedAt
});




}
/// @nodoc
class _$MessageModelCopyWithImpl<$Res>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._self, this._then);

  final MessageModel _self;
  final $Res Function(MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? senderName = null,Object? content = null,Object? senderPhotoUrl = freezed,Object? type = null,Object? status = null,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationName = freezed,Object? rideId = freezed,Object? replyToMessageId = freezed,Object? replyToContent = freezed,Object? reactions = null,Object? readBy = null,Object? deliveredTo = null,Object? isEdited = null,Object? isDeleted = null,Object? createdAt = freezed,Object? editedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,replyToContent: freezed == replyToContent ? _self.replyToContent : replyToContent // ignore: cast_nullable_to_non_nullable
as String?,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,readBy: null == readBy ? _self.readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,deliveredTo: null == deliveredTo ? _self.deliveredTo : deliveredTo // ignore: cast_nullable_to_non_nullable
as List<String>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageModel].
extension MessageModelPatterns on MessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageModel value)  $default,){
final _that = this;
switch (_that) {
case _MessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String senderName,  String content,  String? senderPhotoUrl,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  List<String> readBy,  List<String> deliveredTo,  bool isEdited,  bool isDeleted, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.content,_that.senderPhotoUrl,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.readBy,_that.deliveredTo,_that.isEdited,_that.isDeleted,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String senderName,  String content,  String? senderPhotoUrl,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  List<String> readBy,  List<String> deliveredTo,  bool isEdited,  bool isDeleted, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)  $default,) {final _that = this;
switch (_that) {
case _MessageModel():
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.content,_that.senderPhotoUrl,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.readBy,_that.deliveredTo,_that.isEdited,_that.isDeleted,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  String senderId,  String senderName,  String content,  String? senderPhotoUrl,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  List<String> readBy,  List<String> deliveredTo,  bool isEdited,  bool isDeleted, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.senderName,_that.content,_that.senderPhotoUrl,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.readBy,_that.deliveredTo,_that.isEdited,_that.isDeleted,_that.createdAt,_that.editedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageModel extends MessageModel {
  const _MessageModel({required this.id, required this.chatId, required this.senderId, required this.senderName, required this.content, this.senderPhotoUrl, this.type = MessageType.text, this.status = MessageStatus.sending, this.mediaUrl, this.thumbnailUrl, this.latitude, this.longitude, this.locationName, this.rideId, this.replyToMessageId, this.replyToContent, final  Map<String, List<String>> reactions = const {}, final  List<String> readBy = const [], final  List<String> deliveredTo = const [], this.isEdited = false, this.isDeleted = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.editedAt}): _reactions = reactions,_readBy = readBy,_deliveredTo = deliveredTo,super._();
  factory _MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

@override final  String id;
@override final  String chatId;
@override final  String senderId;
@override final  String senderName;
@override final  String content;
@override final  String? senderPhotoUrl;
@override@JsonKey() final  MessageType type;
@override@JsonKey() final  MessageStatus status;
@override final  String? mediaUrl;
@override final  String? thumbnailUrl;
// Location
@override final  double? latitude;
@override final  double? longitude;
@override final  String? locationName;
// Ride attachment
@override final  String? rideId;
// Reply context
@override final  String? replyToMessageId;
@override final  String? replyToContent;
// Reactions: emoji → [userId, ...]
 final  Map<String, List<String>> _reactions;
// Reactions: emoji → [userId, ...]
@override@JsonKey() Map<String, List<String>> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

// Read receipts
 final  List<String> _readBy;
// Read receipts
@override@JsonKey() List<String> get readBy {
  if (_readBy is EqualUnmodifiableListView) return _readBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readBy);
}

 final  List<String> _deliveredTo;
@override@JsonKey() List<String> get deliveredTo {
  if (_deliveredTo is EqualUnmodifiableListView) return _deliveredTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveredTo);
}

// Metadata
@override@JsonKey() final  bool isEdited;
@override@JsonKey() final  bool isDeleted;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? editedAt;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageModelCopyWith<_MessageModel> get copyWith => __$MessageModelCopyWithImpl<_MessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToContent, replyToContent) || other.replyToContent == replyToContent)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._readBy, _readBy)&&const DeepCollectionEquality().equals(other._deliveredTo, _deliveredTo)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,chatId,senderId,senderName,content,senderPhotoUrl,type,status,mediaUrl,thumbnailUrl,latitude,longitude,locationName,rideId,replyToMessageId,replyToContent,const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_readBy),const DeepCollectionEquality().hash(_deliveredTo),isEdited,isDeleted,createdAt,editedAt]);

@override
String toString() {
  return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, content: $content, senderPhotoUrl: $senderPhotoUrl, type: $type, status: $status, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, latitude: $latitude, longitude: $longitude, locationName: $locationName, rideId: $rideId, replyToMessageId: $replyToMessageId, replyToContent: $replyToContent, reactions: $reactions, readBy: $readBy, deliveredTo: $deliveredTo, isEdited: $isEdited, isDeleted: $isDeleted, createdAt: $createdAt, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class _$MessageModelCopyWith<$Res> implements $MessageModelCopyWith<$Res> {
  factory _$MessageModelCopyWith(_MessageModel value, $Res Function(_MessageModel) _then) = __$MessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, String senderId, String senderName, String content, String? senderPhotoUrl, MessageType type, MessageStatus status, String? mediaUrl, String? thumbnailUrl, double? latitude, double? longitude, String? locationName, String? rideId, String? replyToMessageId, String? replyToContent, Map<String, List<String>> reactions, List<String> readBy, List<String> deliveredTo, bool isEdited, bool isDeleted,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? editedAt
});




}
/// @nodoc
class __$MessageModelCopyWithImpl<$Res>
    implements _$MessageModelCopyWith<$Res> {
  __$MessageModelCopyWithImpl(this._self, this._then);

  final _MessageModel _self;
  final $Res Function(_MessageModel) _then;

/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? senderName = null,Object? content = null,Object? senderPhotoUrl = freezed,Object? type = null,Object? status = null,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationName = freezed,Object? rideId = freezed,Object? replyToMessageId = freezed,Object? replyToContent = freezed,Object? reactions = null,Object? readBy = null,Object? deliveredTo = null,Object? isEdited = null,Object? isDeleted = null,Object? createdAt = freezed,Object? editedAt = freezed,}) {
  return _then(_MessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as String?,replyToContent: freezed == replyToContent ? _self.replyToContent : replyToContent // ignore: cast_nullable_to_non_nullable
as String?,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,readBy: null == readBy ? _self._readBy : readBy // ignore: cast_nullable_to_non_nullable
as List<String>,deliveredTo: null == deliveredTo ? _self._deliveredTo : deliveredTo // ignore: cast_nullable_to_non_nullable
as List<String>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatParticipant {

@JsonKey(name: 'uid') String get userId; String get username; String? get photoUrl; bool get isAdmin; bool get isMuted;// Role distinguishes the group owner/creator from regular admins/members.
// Optional & nullable: legacy docs without this key deserialize to null.
 ParticipantRole? get role;@TimestampConverter() DateTime? get lastSeenAt;@TimestampConverter() DateTime? get joinedAt;
/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<ChatParticipant> get copyWith => _$ChatParticipantCopyWithImpl<ChatParticipant>(this as ChatParticipant, _$identity);

  /// Serializes this ChatParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatParticipant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,photoUrl,isAdmin,isMuted,role,lastSeenAt,joinedAt);

@override
String toString() {
  return 'ChatParticipant(userId: $userId, username: $username, photoUrl: $photoUrl, isAdmin: $isAdmin, isMuted: $isMuted, role: $role, lastSeenAt: $lastSeenAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $ChatParticipantCopyWith<$Res>  {
  factory $ChatParticipantCopyWith(ChatParticipant value, $Res Function(ChatParticipant) _then) = _$ChatParticipantCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String userId, String username, String? photoUrl, bool isAdmin, bool isMuted, ParticipantRole? role,@TimestampConverter() DateTime? lastSeenAt,@TimestampConverter() DateTime? joinedAt
});




}
/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._self, this._then);

  final ChatParticipant _self;
  final $Res Function(ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? photoUrl = freezed,Object? isAdmin = null,Object? isMuted = null,Object? role = freezed,Object? lastSeenAt = freezed,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ParticipantRole?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatParticipant].
extension ChatParticipantPatterns on ChatParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatParticipant value)  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String userId,  String username,  String? photoUrl,  bool isAdmin,  bool isMuted,  ParticipantRole? role, @TimestampConverter()  DateTime? lastSeenAt, @TimestampConverter()  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.userId,_that.username,_that.photoUrl,_that.isAdmin,_that.isMuted,_that.role,_that.lastSeenAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String userId,  String username,  String? photoUrl,  bool isAdmin,  bool isMuted,  ParticipantRole? role, @TimestampConverter()  DateTime? lastSeenAt, @TimestampConverter()  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant():
return $default(_that.userId,_that.username,_that.photoUrl,_that.isAdmin,_that.isMuted,_that.role,_that.lastSeenAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String userId,  String username,  String? photoUrl,  bool isAdmin,  bool isMuted,  ParticipantRole? role, @TimestampConverter()  DateTime? lastSeenAt, @TimestampConverter()  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.userId,_that.username,_that.photoUrl,_that.isAdmin,_that.isMuted,_that.role,_that.lastSeenAt,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatParticipant extends ChatParticipant {
  const _ChatParticipant({@JsonKey(name: 'uid') required this.userId, required this.username, this.photoUrl, this.isAdmin = false, this.isMuted = false, this.role, @TimestampConverter() this.lastSeenAt, @TimestampConverter() this.joinedAt}): super._();
  factory _ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);

@override@JsonKey(name: 'uid') final  String userId;
@override final  String username;
@override final  String? photoUrl;
@override@JsonKey() final  bool isAdmin;
@override@JsonKey() final  bool isMuted;
// Role distinguishes the group owner/creator from regular admins/members.
// Optional & nullable: legacy docs without this key deserialize to null.
@override final  ParticipantRole? role;
@override@TimestampConverter() final  DateTime? lastSeenAt;
@override@TimestampConverter() final  DateTime? joinedAt;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatParticipantCopyWith<_ChatParticipant> get copyWith => __$ChatParticipantCopyWithImpl<_ChatParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatParticipant&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,photoUrl,isAdmin,isMuted,role,lastSeenAt,joinedAt);

@override
String toString() {
  return 'ChatParticipant(userId: $userId, username: $username, photoUrl: $photoUrl, isAdmin: $isAdmin, isMuted: $isMuted, role: $role, lastSeenAt: $lastSeenAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatParticipantCopyWith<$Res> implements $ChatParticipantCopyWith<$Res> {
  factory _$ChatParticipantCopyWith(_ChatParticipant value, $Res Function(_ChatParticipant) _then) = __$ChatParticipantCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String userId, String username, String? photoUrl, bool isAdmin, bool isMuted, ParticipantRole? role,@TimestampConverter() DateTime? lastSeenAt,@TimestampConverter() DateTime? joinedAt
});




}
/// @nodoc
class __$ChatParticipantCopyWithImpl<$Res>
    implements _$ChatParticipantCopyWith<$Res> {
  __$ChatParticipantCopyWithImpl(this._self, this._then);

  final _ChatParticipant _self;
  final $Res Function(_ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? photoUrl = freezed,Object? isAdmin = null,Object? isMuted = null,Object? role = freezed,Object? lastSeenAt = freezed,Object? joinedAt = freezed,}) {
  return _then(_ChatParticipant(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ParticipantRole?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatModel {

 String get id; ChatType get type;// Participants
 List<ChatParticipant> get participants; List<String> get participantIds;// Group
 String? get groupName; String? get groupPhotoUrl; String? get description;// Ride / event
 String? get rideId; String? get eventId;// Last message preview
 String? get lastMessageContent; String? get lastMessageSenderId; String? get lastMessageSenderName; MessageType get lastMessageType;@TimestampConverter() DateTime? get lastMessageAt;// Unread counts: userId → count
 Map<String, int> get unreadCounts;// Per-user settings
 Map<String, bool> get mutedBy; Map<String, bool> get pinnedBy;// One-sided deletion: userId → true
// User removed the conversation from their chat list.
// If a newer message arrives after this timestamp, the chat appears again.
@TimestampMapConverter() Map<String, DateTime> get deletedAtBy;// User cleared message history up to this timestamp.
// The chat can stay visible, but older messages are hidden for this user.
@TimestampMapConverter() Map<String, DateTime> get clearedAtBy; bool get isActive;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatModelCopyWith<ChatModel> get copyWith => _$ChatModelCopyWithImpl<ChatModel>(this as ChatModel, _$identity);

  /// Serializes this ChatModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.participants, participants)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupPhotoUrl, groupPhotoUrl) || other.groupPhotoUrl == groupPhotoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageSenderName, lastMessageSenderName) || other.lastMessageSenderName == lastMessageSenderName)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other.unreadCounts, unreadCounts)&&const DeepCollectionEquality().equals(other.mutedBy, mutedBy)&&const DeepCollectionEquality().equals(other.pinnedBy, pinnedBy)&&const DeepCollectionEquality().equals(other.deletedAtBy, deletedAtBy)&&const DeepCollectionEquality().equals(other.clearedAtBy, clearedAtBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,const DeepCollectionEquality().hash(participants),const DeepCollectionEquality().hash(participantIds),groupName,groupPhotoUrl,description,rideId,eventId,lastMessageContent,lastMessageSenderId,lastMessageSenderName,lastMessageType,lastMessageAt,const DeepCollectionEquality().hash(unreadCounts),const DeepCollectionEquality().hash(mutedBy),const DeepCollectionEquality().hash(pinnedBy),const DeepCollectionEquality().hash(deletedAtBy),const DeepCollectionEquality().hash(clearedAtBy),isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'ChatModel(id: $id, type: $type, participants: $participants, participantIds: $participantIds, groupName: $groupName, groupPhotoUrl: $groupPhotoUrl, description: $description, rideId: $rideId, eventId: $eventId, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, lastMessageSenderName: $lastMessageSenderName, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, unreadCounts: $unreadCounts, mutedBy: $mutedBy, pinnedBy: $pinnedBy, deletedAtBy: $deletedAtBy, clearedAtBy: $clearedAtBy, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatModelCopyWith<$Res>  {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) _then) = _$ChatModelCopyWithImpl;
@useResult
$Res call({
 String id, ChatType type, List<ChatParticipant> participants, List<String> participantIds, String? groupName, String? groupPhotoUrl, String? description, String? rideId, String? eventId, String? lastMessageContent, String? lastMessageSenderId, String? lastMessageSenderName, MessageType lastMessageType,@TimestampConverter() DateTime? lastMessageAt, Map<String, int> unreadCounts, Map<String, bool> mutedBy, Map<String, bool> pinnedBy,@TimestampMapConverter() Map<String, DateTime> deletedAtBy,@TimestampMapConverter() Map<String, DateTime> clearedAtBy, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$ChatModelCopyWithImpl<$Res>
    implements $ChatModelCopyWith<$Res> {
  _$ChatModelCopyWithImpl(this._self, this._then);

  final ChatModel _self;
  final $Res Function(ChatModel) _then;

/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? participants = null,Object? participantIds = null,Object? groupName = freezed,Object? groupPhotoUrl = freezed,Object? description = freezed,Object? rideId = freezed,Object? eventId = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageSenderName = freezed,Object? lastMessageType = null,Object? lastMessageAt = freezed,Object? unreadCounts = null,Object? mutedBy = null,Object? pinnedBy = null,Object? deletedAtBy = null,Object? clearedAtBy = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,groupPhotoUrl: freezed == groupPhotoUrl ? _self.groupPhotoUrl : groupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderName: freezed == lastMessageSenderName ? _self.lastMessageSenderName : lastMessageSenderName // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as MessageType,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCounts: null == unreadCounts ? _self.unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,mutedBy: null == mutedBy ? _self.mutedBy : mutedBy // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,pinnedBy: null == pinnedBy ? _self.pinnedBy : pinnedBy // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,deletedAtBy: null == deletedAtBy ? _self.deletedAtBy : deletedAtBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,clearedAtBy: null == clearedAtBy ? _self.clearedAtBy : clearedAtBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatModel].
extension ChatModelPatterns on ChatModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChatType type,  List<ChatParticipant> participants,  List<String> participantIds,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  String? lastMessageContent,  String? lastMessageSenderId,  String? lastMessageSenderName,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt,  Map<String, int> unreadCounts,  Map<String, bool> mutedBy,  Map<String, bool> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> deletedAtBy, @TimestampMapConverter()  Map<String, DateTime> clearedAtBy,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.type,_that.participants,_that.participantIds,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageSenderName,_that.lastMessageType,_that.lastMessageAt,_that.unreadCounts,_that.mutedBy,_that.pinnedBy,_that.deletedAtBy,_that.clearedAtBy,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChatType type,  List<ChatParticipant> participants,  List<String> participantIds,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  String? lastMessageContent,  String? lastMessageSenderId,  String? lastMessageSenderName,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt,  Map<String, int> unreadCounts,  Map<String, bool> mutedBy,  Map<String, bool> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> deletedAtBy, @TimestampMapConverter()  Map<String, DateTime> clearedAtBy,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatModel():
return $default(_that.id,_that.type,_that.participants,_that.participantIds,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageSenderName,_that.lastMessageType,_that.lastMessageAt,_that.unreadCounts,_that.mutedBy,_that.pinnedBy,_that.deletedAtBy,_that.clearedAtBy,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChatType type,  List<ChatParticipant> participants,  List<String> participantIds,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  String? lastMessageContent,  String? lastMessageSenderId,  String? lastMessageSenderName,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt,  Map<String, int> unreadCounts,  Map<String, bool> mutedBy,  Map<String, bool> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> deletedAtBy, @TimestampMapConverter()  Map<String, DateTime> clearedAtBy,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.type,_that.participants,_that.participantIds,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageSenderName,_that.lastMessageType,_that.lastMessageAt,_that.unreadCounts,_that.mutedBy,_that.pinnedBy,_that.deletedAtBy,_that.clearedAtBy,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatModel extends ChatModel {
  const _ChatModel({required this.id, this.type = ChatType.private, final  List<ChatParticipant> participants = const [], final  List<String> participantIds = const [], this.groupName, this.groupPhotoUrl, this.description, this.rideId, this.eventId, this.lastMessageContent, this.lastMessageSenderId, this.lastMessageSenderName, this.lastMessageType = MessageType.text, @TimestampConverter() this.lastMessageAt, final  Map<String, int> unreadCounts = const {}, final  Map<String, bool> mutedBy = const {}, final  Map<String, bool> pinnedBy = const {}, @TimestampMapConverter() final  Map<String, DateTime> deletedAtBy = const {}, @TimestampMapConverter() final  Map<String, DateTime> clearedAtBy = const {}, this.isActive = true, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _participants = participants,_participantIds = participantIds,_unreadCounts = unreadCounts,_mutedBy = mutedBy,_pinnedBy = pinnedBy,_deletedAtBy = deletedAtBy,_clearedAtBy = clearedAtBy,super._();
  factory _ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);

@override final  String id;
@override@JsonKey() final  ChatType type;
// Participants
 final  List<ChatParticipant> _participants;
// Participants
@override@JsonKey() List<ChatParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

// Group
@override final  String? groupName;
@override final  String? groupPhotoUrl;
@override final  String? description;
// Ride / event
@override final  String? rideId;
@override final  String? eventId;
// Last message preview
@override final  String? lastMessageContent;
@override final  String? lastMessageSenderId;
@override final  String? lastMessageSenderName;
@override@JsonKey() final  MessageType lastMessageType;
@override@TimestampConverter() final  DateTime? lastMessageAt;
// Unread counts: userId → count
 final  Map<String, int> _unreadCounts;
// Unread counts: userId → count
@override@JsonKey() Map<String, int> get unreadCounts {
  if (_unreadCounts is EqualUnmodifiableMapView) return _unreadCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadCounts);
}

// Per-user settings
 final  Map<String, bool> _mutedBy;
// Per-user settings
@override@JsonKey() Map<String, bool> get mutedBy {
  if (_mutedBy is EqualUnmodifiableMapView) return _mutedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mutedBy);
}

 final  Map<String, bool> _pinnedBy;
@override@JsonKey() Map<String, bool> get pinnedBy {
  if (_pinnedBy is EqualUnmodifiableMapView) return _pinnedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pinnedBy);
}

// One-sided deletion: userId → true
// User removed the conversation from their chat list.
// If a newer message arrives after this timestamp, the chat appears again.
 final  Map<String, DateTime> _deletedAtBy;
// One-sided deletion: userId → true
// User removed the conversation from their chat list.
// If a newer message arrives after this timestamp, the chat appears again.
@override@JsonKey()@TimestampMapConverter() Map<String, DateTime> get deletedAtBy {
  if (_deletedAtBy is EqualUnmodifiableMapView) return _deletedAtBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_deletedAtBy);
}

// User cleared message history up to this timestamp.
// The chat can stay visible, but older messages are hidden for this user.
 final  Map<String, DateTime> _clearedAtBy;
// User cleared message history up to this timestamp.
// The chat can stay visible, but older messages are hidden for this user.
@override@JsonKey()@TimestampMapConverter() Map<String, DateTime> get clearedAtBy {
  if (_clearedAtBy is EqualUnmodifiableMapView) return _clearedAtBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_clearedAtBy);
}

@override@JsonKey() final  bool isActive;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatModelCopyWith<_ChatModel> get copyWith => __$ChatModelCopyWithImpl<_ChatModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._participants, _participants)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupPhotoUrl, groupPhotoUrl) || other.groupPhotoUrl == groupPhotoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageSenderName, lastMessageSenderName) || other.lastMessageSenderName == lastMessageSenderName)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other._unreadCounts, _unreadCounts)&&const DeepCollectionEquality().equals(other._mutedBy, _mutedBy)&&const DeepCollectionEquality().equals(other._pinnedBy, _pinnedBy)&&const DeepCollectionEquality().equals(other._deletedAtBy, _deletedAtBy)&&const DeepCollectionEquality().equals(other._clearedAtBy, _clearedAtBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_participantIds),groupName,groupPhotoUrl,description,rideId,eventId,lastMessageContent,lastMessageSenderId,lastMessageSenderName,lastMessageType,lastMessageAt,const DeepCollectionEquality().hash(_unreadCounts),const DeepCollectionEquality().hash(_mutedBy),const DeepCollectionEquality().hash(_pinnedBy),const DeepCollectionEquality().hash(_deletedAtBy),const DeepCollectionEquality().hash(_clearedAtBy),isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'ChatModel(id: $id, type: $type, participants: $participants, participantIds: $participantIds, groupName: $groupName, groupPhotoUrl: $groupPhotoUrl, description: $description, rideId: $rideId, eventId: $eventId, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, lastMessageSenderName: $lastMessageSenderName, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, unreadCounts: $unreadCounts, mutedBy: $mutedBy, pinnedBy: $pinnedBy, deletedAtBy: $deletedAtBy, clearedAtBy: $clearedAtBy, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatModelCopyWith<$Res> implements $ChatModelCopyWith<$Res> {
  factory _$ChatModelCopyWith(_ChatModel value, $Res Function(_ChatModel) _then) = __$ChatModelCopyWithImpl;
@override @useResult
$Res call({
 String id, ChatType type, List<ChatParticipant> participants, List<String> participantIds, String? groupName, String? groupPhotoUrl, String? description, String? rideId, String? eventId, String? lastMessageContent, String? lastMessageSenderId, String? lastMessageSenderName, MessageType lastMessageType,@TimestampConverter() DateTime? lastMessageAt, Map<String, int> unreadCounts, Map<String, bool> mutedBy, Map<String, bool> pinnedBy,@TimestampMapConverter() Map<String, DateTime> deletedAtBy,@TimestampMapConverter() Map<String, DateTime> clearedAtBy, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$ChatModelCopyWithImpl<$Res>
    implements _$ChatModelCopyWith<$Res> {
  __$ChatModelCopyWithImpl(this._self, this._then);

  final _ChatModel _self;
  final $Res Function(_ChatModel) _then;

/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? participants = null,Object? participantIds = null,Object? groupName = freezed,Object? groupPhotoUrl = freezed,Object? description = freezed,Object? rideId = freezed,Object? eventId = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageSenderName = freezed,Object? lastMessageType = null,Object? lastMessageAt = freezed,Object? unreadCounts = null,Object? mutedBy = null,Object? pinnedBy = null,Object? deletedAtBy = null,Object? clearedAtBy = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ChatModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,groupPhotoUrl: freezed == groupPhotoUrl ? _self.groupPhotoUrl : groupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderName: freezed == lastMessageSenderName ? _self.lastMessageSenderName : lastMessageSenderName // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as MessageType,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCounts: null == unreadCounts ? _self._unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,mutedBy: null == mutedBy ? _self._mutedBy : mutedBy // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,pinnedBy: null == pinnedBy ? _self._pinnedBy : pinnedBy // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,deletedAtBy: null == deletedAtBy ? _self._deletedAtBy : deletedAtBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,clearedAtBy: null == clearedAtBy ? _self._clearedAtBy : clearedAtBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TypingIndicator {

 String get userId; String get username; String get chatId;@TimestampConverter() DateTime? get startedAt;
/// Create a copy of TypingIndicator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TypingIndicatorCopyWith<TypingIndicator> get copyWith => _$TypingIndicatorCopyWithImpl<TypingIndicator>(this as TypingIndicator, _$identity);

  /// Serializes this TypingIndicator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TypingIndicator&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,chatId,startedAt);

@override
String toString() {
  return 'TypingIndicator(userId: $userId, username: $username, chatId: $chatId, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class $TypingIndicatorCopyWith<$Res>  {
  factory $TypingIndicatorCopyWith(TypingIndicator value, $Res Function(TypingIndicator) _then) = _$TypingIndicatorCopyWithImpl;
@useResult
$Res call({
 String userId, String username, String chatId,@TimestampConverter() DateTime? startedAt
});




}
/// @nodoc
class _$TypingIndicatorCopyWithImpl<$Res>
    implements $TypingIndicatorCopyWith<$Res> {
  _$TypingIndicatorCopyWithImpl(this._self, this._then);

  final TypingIndicator _self;
  final $Res Function(TypingIndicator) _then;

/// Create a copy of TypingIndicator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? chatId = null,Object? startedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TypingIndicator].
extension TypingIndicatorPatterns on TypingIndicator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TypingIndicator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TypingIndicator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TypingIndicator value)  $default,){
final _that = this;
switch (_that) {
case _TypingIndicator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TypingIndicator value)?  $default,){
final _that = this;
switch (_that) {
case _TypingIndicator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  String chatId, @TimestampConverter()  DateTime? startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TypingIndicator() when $default != null:
return $default(_that.userId,_that.username,_that.chatId,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  String chatId, @TimestampConverter()  DateTime? startedAt)  $default,) {final _that = this;
switch (_that) {
case _TypingIndicator():
return $default(_that.userId,_that.username,_that.chatId,_that.startedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  String chatId, @TimestampConverter()  DateTime? startedAt)?  $default,) {final _that = this;
switch (_that) {
case _TypingIndicator() when $default != null:
return $default(_that.userId,_that.username,_that.chatId,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TypingIndicator extends TypingIndicator {
  const _TypingIndicator({required this.userId, required this.username, required this.chatId, @TimestampConverter() this.startedAt}): super._();
  factory _TypingIndicator.fromJson(Map<String, dynamic> json) => _$TypingIndicatorFromJson(json);

@override final  String userId;
@override final  String username;
@override final  String chatId;
@override@TimestampConverter() final  DateTime? startedAt;

/// Create a copy of TypingIndicator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TypingIndicatorCopyWith<_TypingIndicator> get copyWith => __$TypingIndicatorCopyWithImpl<_TypingIndicator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TypingIndicatorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TypingIndicator&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,chatId,startedAt);

@override
String toString() {
  return 'TypingIndicator(userId: $userId, username: $username, chatId: $chatId, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$TypingIndicatorCopyWith<$Res> implements $TypingIndicatorCopyWith<$Res> {
  factory _$TypingIndicatorCopyWith(_TypingIndicator value, $Res Function(_TypingIndicator) _then) = __$TypingIndicatorCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, String chatId,@TimestampConverter() DateTime? startedAt
});




}
/// @nodoc
class __$TypingIndicatorCopyWithImpl<$Res>
    implements _$TypingIndicatorCopyWith<$Res> {
  __$TypingIndicatorCopyWithImpl(this._self, this._then);

  final _TypingIndicator _self;
  final $Res Function(_TypingIndicator) _then;

/// Create a copy of TypingIndicator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? chatId = null,Object? startedAt = freezed,}) {
  return _then(_TypingIndicator(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
