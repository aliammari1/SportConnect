// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageModel {

 String get id; String get chatId; String get senderId;/// Idempotency key: deterministic doc id = hash(chatId, clientMsgId) so
/// offline retries overwrite instead of duplicating (zero extra reads).
 String? get clientMsgId;/// Hydrated display copy; bubbles fall back to chat.profiles when null.
 String? get senderName; String? get senderPhotoUrl; String get content; MessageType get type;/// Local send-pipeline state only (sending/sent/failed).
 MessageStatus get status; String? get mediaUrl; String? get thumbnailUrl; double? get latitude; double? get longitude; String? get locationName; String? get rideId; String? get replyToMessageId; String? get replyToContent; Map<String, List<String>> get reactions; bool get isEdited;@TimestampConverter() DateTime? get deletedAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get editedAt;
/// Create a copy of MessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageModelCopyWith<MessageModel> get copyWith => _$MessageModelCopyWithImpl<MessageModel>(this as MessageModel, _$identity);

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToContent, replyToContent) || other.replyToContent == replyToContent)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,chatId,senderId,clientMsgId,senderName,senderPhotoUrl,content,type,status,mediaUrl,thumbnailUrl,latitude,longitude,locationName,rideId,replyToMessageId,replyToContent,const DeepCollectionEquality().hash(reactions),isEdited,deletedAt,createdAt,editedAt]);

@override
String toString() {
  return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, clientMsgId: $clientMsgId, senderName: $senderName, senderPhotoUrl: $senderPhotoUrl, content: $content, type: $type, status: $status, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, latitude: $latitude, longitude: $longitude, locationName: $locationName, rideId: $rideId, replyToMessageId: $replyToMessageId, replyToContent: $replyToContent, reactions: $reactions, isEdited: $isEdited, deletedAt: $deletedAt, createdAt: $createdAt, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class $MessageModelCopyWith<$Res>  {
  factory $MessageModelCopyWith(MessageModel value, $Res Function(MessageModel) _then) = _$MessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, String senderId, String? clientMsgId, String? senderName, String? senderPhotoUrl, String content, MessageType type, MessageStatus status, String? mediaUrl, String? thumbnailUrl, double? latitude, double? longitude, String? locationName, String? rideId, String? replyToMessageId, String? replyToContent, Map<String, List<String>> reactions, bool isEdited,@TimestampConverter() DateTime? deletedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? editedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? clientMsgId = freezed,Object? senderName = freezed,Object? senderPhotoUrl = freezed,Object? content = null,Object? type = null,Object? status = null,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationName = freezed,Object? rideId = freezed,Object? replyToMessageId = freezed,Object? replyToContent = freezed,Object? reactions = null,Object? isEdited = null,Object? deletedAt = freezed,Object? createdAt = freezed,Object? editedAt = freezed,}) {
  return _then(MessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
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
as Map<String, List<String>>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String? clientMsgId,  String? senderName,  String? senderPhotoUrl,  String content,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  bool isEdited, @TimestampConverter()  DateTime? deletedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.clientMsgId,_that.senderName,_that.senderPhotoUrl,_that.content,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.isEdited,_that.deletedAt,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  String senderId,  String? clientMsgId,  String? senderName,  String? senderPhotoUrl,  String content,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  bool isEdited, @TimestampConverter()  DateTime? deletedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)  $default,) {final _that = this;
switch (_that) {
case _MessageModel():
return $default(_that.id,_that.chatId,_that.senderId,_that.clientMsgId,_that.senderName,_that.senderPhotoUrl,_that.content,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.isEdited,_that.deletedAt,_that.createdAt,_that.editedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  String senderId,  String? clientMsgId,  String? senderName,  String? senderPhotoUrl,  String content,  MessageType type,  MessageStatus status,  String? mediaUrl,  String? thumbnailUrl,  double? latitude,  double? longitude,  String? locationName,  String? rideId,  String? replyToMessageId,  String? replyToContent,  Map<String, List<String>> reactions,  bool isEdited, @TimestampConverter()  DateTime? deletedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? editedAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageModel() when $default != null:
return $default(_that.id,_that.chatId,_that.senderId,_that.clientMsgId,_that.senderName,_that.senderPhotoUrl,_that.content,_that.type,_that.status,_that.mediaUrl,_that.thumbnailUrl,_that.latitude,_that.longitude,_that.locationName,_that.rideId,_that.replyToMessageId,_that.replyToContent,_that.reactions,_that.isEdited,_that.deletedAt,_that.createdAt,_that.editedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageModel extends MessageModel {
  const _MessageModel({required this.id, required this.chatId, required this.senderId, this.clientMsgId, this.senderName, this.senderPhotoUrl, required this.content, this.type = MessageType.text, this.status = MessageStatus.sending, this.mediaUrl, this.thumbnailUrl, this.latitude, this.longitude, this.locationName, this.rideId, this.replyToMessageId, this.replyToContent,  Map<String, List<String>> reactions = const {}, this.isEdited = false, @TimestampConverter() this.deletedAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.editedAt}): _reactions = reactions,super._();
  factory _MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

@override final  String id;
@override final  String chatId;
@override final  String senderId;
/// Idempotency key: deterministic doc id = hash(chatId, clientMsgId) so
/// offline retries overwrite instead of duplicating (zero extra reads).
@override final  String? clientMsgId;
/// Hydrated display copy; bubbles fall back to chat.profiles when null.
@override final  String? senderName;
@override final  String? senderPhotoUrl;
@override final  String content;
@override@JsonKey() final  MessageType type;
/// Local send-pipeline state only (sending/sent/failed).
@override@JsonKey() final  MessageStatus status;
@override final  String? mediaUrl;
@override final  String? thumbnailUrl;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? locationName;
@override final  String? rideId;
@override final  String? replyToMessageId;
@override final  String? replyToContent;
 final  Map<String, List<String>> _reactions;
@override@JsonKey() Map<String, List<String>> get reactions {
  if (_reactions is EqualUnmodifiableMapView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactions);
}

@override@JsonKey() final  bool isEdited;
@override@TimestampConverter() final  DateTime? deletedAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.clientMsgId, clientMsgId) || other.clientMsgId == clientMsgId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderPhotoUrl, senderPhotoUrl) || other.senderPhotoUrl == senderPhotoUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.replyToContent, replyToContent) || other.replyToContent == replyToContent)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,chatId,senderId,clientMsgId,senderName,senderPhotoUrl,content,type,status,mediaUrl,thumbnailUrl,latitude,longitude,locationName,rideId,replyToMessageId,replyToContent,const DeepCollectionEquality().hash(_reactions),isEdited,deletedAt,createdAt,editedAt]);

@override
String toString() {
  return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, clientMsgId: $clientMsgId, senderName: $senderName, senderPhotoUrl: $senderPhotoUrl, content: $content, type: $type, status: $status, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, latitude: $latitude, longitude: $longitude, locationName: $locationName, rideId: $rideId, replyToMessageId: $replyToMessageId, replyToContent: $replyToContent, reactions: $reactions, isEdited: $isEdited, deletedAt: $deletedAt, createdAt: $createdAt, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class _$MessageModelCopyWith<$Res> implements $MessageModelCopyWith<$Res> {
  factory _$MessageModelCopyWith(_MessageModel value, $Res Function(_MessageModel) _then) = __$MessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, String senderId, String? clientMsgId, String? senderName, String? senderPhotoUrl, String content, MessageType type, MessageStatus status, String? mediaUrl, String? thumbnailUrl, double? latitude, double? longitude, String? locationName, String? rideId, String? replyToMessageId, String? replyToContent, Map<String, List<String>> reactions, bool isEdited,@TimestampConverter() DateTime? deletedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? editedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? senderId = null,Object? clientMsgId = freezed,Object? senderName = freezed,Object? senderPhotoUrl = freezed,Object? content = null,Object? type = null,Object? status = null,Object? mediaUrl = freezed,Object? thumbnailUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationName = freezed,Object? rideId = freezed,Object? replyToMessageId = freezed,Object? replyToContent = freezed,Object? reactions = null,Object? isEdited = null,Object? deletedAt = freezed,Object? createdAt = freezed,Object? editedAt = freezed,}) {
  return _then(_MessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,clientMsgId: freezed == clientMsgId ? _self.clientMsgId : clientMsgId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,senderPhotoUrl: freezed == senderPhotoUrl ? _self.senderPhotoUrl : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
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
as Map<String, List<String>>,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatMember {

@JsonKey(name: 'uid') String get userId; String? get username; String? get photoUrl; MemberRole get role;@TimestampConverter() DateTime? get joinedAt;/// Read cursor: everything with createdAt <= this is read by this member.
/// Derived receipts/badges compare against this — no per-message writes.
@TimestampConverter() DateTime? get lastReadAt;
/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMemberCopyWith<ChatMember> get copyWith => _$ChatMemberCopyWithImpl<ChatMember>(this as ChatMember, _$identity);

  /// Serializes this ChatMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,photoUrl,role,joinedAt,lastReadAt);

@override
String toString() {
  return 'ChatMember(userId: $userId, username: $username, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt, lastReadAt: $lastReadAt)';
}


}

/// @nodoc
abstract mixin class $ChatMemberCopyWith<$Res>  {
  factory $ChatMemberCopyWith(ChatMember value, $Res Function(ChatMember) _then) = _$ChatMemberCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'uid') String userId, String? username, String? photoUrl, MemberRole role,@TimestampConverter() DateTime? joinedAt,@TimestampConverter() DateTime? lastReadAt
});




}
/// @nodoc
class _$ChatMemberCopyWithImpl<$Res>
    implements $ChatMemberCopyWith<$Res> {
  _$ChatMemberCopyWithImpl(this._self, this._then);

  final ChatMember _self;
  final $Res Function(ChatMember) _then;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = freezed,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = freezed,Object? lastReadAt = freezed,}) {
  return _then(ChatMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMember].
extension ChatMemberPatterns on ChatMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMember value)  $default,){
final _that = this;
switch (_that) {
case _ChatMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMember value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String userId,  String? username,  String? photoUrl,  MemberRole role, @TimestampConverter()  DateTime? joinedAt, @TimestampConverter()  DateTime? lastReadAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
return $default(_that.userId,_that.username,_that.photoUrl,_that.role,_that.joinedAt,_that.lastReadAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'uid')  String userId,  String? username,  String? photoUrl,  MemberRole role, @TimestampConverter()  DateTime? joinedAt, @TimestampConverter()  DateTime? lastReadAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMember():
return $default(_that.userId,_that.username,_that.photoUrl,_that.role,_that.joinedAt,_that.lastReadAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'uid')  String userId,  String? username,  String? photoUrl,  MemberRole role, @TimestampConverter()  DateTime? joinedAt, @TimestampConverter()  DateTime? lastReadAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMember() when $default != null:
return $default(_that.userId,_that.username,_that.photoUrl,_that.role,_that.joinedAt,_that.lastReadAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMember extends ChatMember {
  const _ChatMember({@JsonKey(name: 'uid') required this.userId, this.username, this.photoUrl, this.role = MemberRole.member, @TimestampConverter() this.joinedAt, @TimestampConverter() this.lastReadAt}): super._();
  factory _ChatMember.fromJson(Map<String, dynamic> json) => _$ChatMemberFromJson(json);

@override@JsonKey(name: 'uid') final  String userId;
@override final  String? username;
@override final  String? photoUrl;
@override@JsonKey() final  MemberRole role;
@override@TimestampConverter() final  DateTime? joinedAt;
/// Read cursor: everything with createdAt <= this is read by this member.
/// Derived receipts/badges compare against this — no per-message writes.
@override@TimestampConverter() final  DateTime? lastReadAt;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMemberCopyWith<_ChatMember> get copyWith => __$ChatMemberCopyWithImpl<_ChatMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,photoUrl,role,joinedAt,lastReadAt);

@override
String toString() {
  return 'ChatMember(userId: $userId, username: $username, photoUrl: $photoUrl, role: $role, joinedAt: $joinedAt, lastReadAt: $lastReadAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMemberCopyWith<$Res> implements $ChatMemberCopyWith<$Res> {
  factory _$ChatMemberCopyWith(_ChatMember value, $Res Function(_ChatMember) _then) = __$ChatMemberCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'uid') String userId, String? username, String? photoUrl, MemberRole role,@TimestampConverter() DateTime? joinedAt,@TimestampConverter() DateTime? lastReadAt
});




}
/// @nodoc
class __$ChatMemberCopyWithImpl<$Res>
    implements _$ChatMemberCopyWith<$Res> {
  __$ChatMemberCopyWithImpl(this._self, this._then);

  final _ChatMember _self;
  final $Res Function(_ChatMember) _then;

/// Create a copy of ChatMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = freezed,Object? photoUrl = freezed,Object? role = null,Object? joinedAt = freezed,Object? lastReadAt = freezed,}) {
  return _then(_ChatMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatModel {

 String get id; ChatType get type; String? get createdBy; List<String> get participantIds; Map<String, ChatMember> get members; String? get groupName; String? get groupPhotoUrl; String? get description; String? get rideId; String? get eventId; bool get premiumOnly; String? get lastMessageContent; String? get lastMessageSenderId; MessageType get lastMessageType;@TimestampConverter() DateTime? get lastMessageAt;@TimestampMapConverter() Map<String, DateTime> get mutedUntil; List<String> get pinnedBy;@TimestampMapConverter() Map<String, DateTime> get hiddenBy;@TimestampMapConverter() Map<String, DateTime> get clearedAt; bool get isActive;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatModelCopyWith<ChatModel> get copyWith => _$ChatModelCopyWithImpl<ChatModel>(this as ChatModel, _$identity);

  /// Serializes this ChatModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupPhotoUrl, groupPhotoUrl) || other.groupPhotoUrl == groupPhotoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.premiumOnly, premiumOnly) || other.premiumOnly == premiumOnly)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other.mutedUntil, mutedUntil)&&const DeepCollectionEquality().equals(other.pinnedBy, pinnedBy)&&const DeepCollectionEquality().equals(other.hiddenBy, hiddenBy)&&const DeepCollectionEquality().equals(other.clearedAt, clearedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,createdBy,const DeepCollectionEquality().hash(participantIds),const DeepCollectionEquality().hash(members),groupName,groupPhotoUrl,description,rideId,eventId,premiumOnly,lastMessageContent,lastMessageSenderId,lastMessageType,lastMessageAt,const DeepCollectionEquality().hash(mutedUntil),const DeepCollectionEquality().hash(pinnedBy),const DeepCollectionEquality().hash(hiddenBy),const DeepCollectionEquality().hash(clearedAt),isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'ChatModel(id: $id, type: $type, createdBy: $createdBy, participantIds: $participantIds, members: $members, groupName: $groupName, groupPhotoUrl: $groupPhotoUrl, description: $description, rideId: $rideId, eventId: $eventId, premiumOnly: $premiumOnly, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, mutedUntil: $mutedUntil, pinnedBy: $pinnedBy, hiddenBy: $hiddenBy, clearedAt: $clearedAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatModelCopyWith<$Res>  {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) _then) = _$ChatModelCopyWithImpl;
@useResult
$Res call({
 String id, ChatType type, String? createdBy, List<String> participantIds, Map<String, ChatMember> members, String? groupName, String? groupPhotoUrl, String? description, String? rideId, String? eventId, bool premiumOnly, String? lastMessageContent, String? lastMessageSenderId, MessageType lastMessageType,@TimestampConverter() DateTime? lastMessageAt,@TimestampMapConverter() Map<String, DateTime> mutedUntil, List<String> pinnedBy,@TimestampMapConverter() Map<String, DateTime> hiddenBy,@TimestampMapConverter() Map<String, DateTime> clearedAt, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? createdBy = freezed,Object? participantIds = null,Object? members = null,Object? groupName = freezed,Object? groupPhotoUrl = freezed,Object? description = freezed,Object? rideId = freezed,Object? eventId = freezed,Object? premiumOnly = null,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageType = null,Object? lastMessageAt = freezed,Object? mutedUntil = null,Object? pinnedBy = null,Object? hiddenBy = null,Object? clearedAt = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ChatModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as Map<String, ChatMember>,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,groupPhotoUrl: freezed == groupPhotoUrl ? _self.groupPhotoUrl : groupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,premiumOnly: null == premiumOnly ? _self.premiumOnly : premiumOnly // ignore: cast_nullable_to_non_nullable
as bool,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as MessageType,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mutedUntil: null == mutedUntil ? _self.mutedUntil : mutedUntil // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,pinnedBy: null == pinnedBy ? _self.pinnedBy : pinnedBy // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenBy: null == hiddenBy ? _self.hiddenBy : hiddenBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,clearedAt: null == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChatType type,  String? createdBy,  List<String> participantIds,  Map<String, ChatMember> members,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  bool premiumOnly,  String? lastMessageContent,  String? lastMessageSenderId,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt, @TimestampMapConverter()  Map<String, DateTime> mutedUntil,  List<String> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> hiddenBy, @TimestampMapConverter()  Map<String, DateTime> clearedAt,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.type,_that.createdBy,_that.participantIds,_that.members,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.premiumOnly,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageType,_that.lastMessageAt,_that.mutedUntil,_that.pinnedBy,_that.hiddenBy,_that.clearedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChatType type,  String? createdBy,  List<String> participantIds,  Map<String, ChatMember> members,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  bool premiumOnly,  String? lastMessageContent,  String? lastMessageSenderId,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt, @TimestampMapConverter()  Map<String, DateTime> mutedUntil,  List<String> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> hiddenBy, @TimestampMapConverter()  Map<String, DateTime> clearedAt,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatModel():
return $default(_that.id,_that.type,_that.createdBy,_that.participantIds,_that.members,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.premiumOnly,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageType,_that.lastMessageAt,_that.mutedUntil,_that.pinnedBy,_that.hiddenBy,_that.clearedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChatType type,  String? createdBy,  List<String> participantIds,  Map<String, ChatMember> members,  String? groupName,  String? groupPhotoUrl,  String? description,  String? rideId,  String? eventId,  bool premiumOnly,  String? lastMessageContent,  String? lastMessageSenderId,  MessageType lastMessageType, @TimestampConverter()  DateTime? lastMessageAt, @TimestampMapConverter()  Map<String, DateTime> mutedUntil,  List<String> pinnedBy, @TimestampMapConverter()  Map<String, DateTime> hiddenBy, @TimestampMapConverter()  Map<String, DateTime> clearedAt,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.type,_that.createdBy,_that.participantIds,_that.members,_that.groupName,_that.groupPhotoUrl,_that.description,_that.rideId,_that.eventId,_that.premiumOnly,_that.lastMessageContent,_that.lastMessageSenderId,_that.lastMessageType,_that.lastMessageAt,_that.mutedUntil,_that.pinnedBy,_that.hiddenBy,_that.clearedAt,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatModel extends ChatModel {
  const _ChatModel({required this.id, this.type = ChatType.private, this.createdBy,  List<String> participantIds = const [],  Map<String, ChatMember> members = const {}, this.groupName, this.groupPhotoUrl, this.description, this.rideId, this.eventId, this.premiumOnly = false, this.lastMessageContent, this.lastMessageSenderId, this.lastMessageType = MessageType.text, @TimestampConverter() this.lastMessageAt, @TimestampMapConverter()  Map<String, DateTime> mutedUntil = const {},  List<String> pinnedBy = const [], @TimestampMapConverter()  Map<String, DateTime> hiddenBy = const {}, @TimestampMapConverter()  Map<String, DateTime> clearedAt = const {}, this.isActive = true, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _participantIds = participantIds,_members = members,_mutedUntil = mutedUntil,_pinnedBy = pinnedBy,_hiddenBy = hiddenBy,_clearedAt = clearedAt,super._();
  factory _ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);

@override final  String id;
@override@JsonKey() final  ChatType type;
@override final  String? createdBy;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

 final  Map<String, ChatMember> _members;
@override@JsonKey() Map<String, ChatMember> get members {
  if (_members is EqualUnmodifiableMapView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_members);
}

@override final  String? groupName;
@override final  String? groupPhotoUrl;
@override final  String? description;
@override final  String? rideId;
@override final  String? eventId;
@override@JsonKey() final  bool premiumOnly;
@override final  String? lastMessageContent;
@override final  String? lastMessageSenderId;
@override@JsonKey() final  MessageType lastMessageType;
@override@TimestampConverter() final  DateTime? lastMessageAt;
 final  Map<String, DateTime> _mutedUntil;
@override@JsonKey()@TimestampMapConverter() Map<String, DateTime> get mutedUntil {
  if (_mutedUntil is EqualUnmodifiableMapView) return _mutedUntil;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mutedUntil);
}

 final  List<String> _pinnedBy;
@override@JsonKey() List<String> get pinnedBy {
  if (_pinnedBy is EqualUnmodifiableListView) return _pinnedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinnedBy);
}

 final  Map<String, DateTime> _hiddenBy;
@override@JsonKey()@TimestampMapConverter() Map<String, DateTime> get hiddenBy {
  if (_hiddenBy is EqualUnmodifiableMapView) return _hiddenBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hiddenBy);
}

 final  Map<String, DateTime> _clearedAt;
@override@JsonKey()@TimestampMapConverter() Map<String, DateTime> get clearedAt {
  if (_clearedAt is EqualUnmodifiableMapView) return _clearedAt;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_clearedAt);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.groupPhotoUrl, groupPhotoUrl) || other.groupPhotoUrl == groupPhotoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.premiumOnly, premiumOnly) || other.premiumOnly == premiumOnly)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&const DeepCollectionEquality().equals(other._mutedUntil, _mutedUntil)&&const DeepCollectionEquality().equals(other._pinnedBy, _pinnedBy)&&const DeepCollectionEquality().equals(other._hiddenBy, _hiddenBy)&&const DeepCollectionEquality().equals(other._clearedAt, _clearedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,createdBy,const DeepCollectionEquality().hash(_participantIds),const DeepCollectionEquality().hash(_members),groupName,groupPhotoUrl,description,rideId,eventId,premiumOnly,lastMessageContent,lastMessageSenderId,lastMessageType,lastMessageAt,const DeepCollectionEquality().hash(_mutedUntil),const DeepCollectionEquality().hash(_pinnedBy),const DeepCollectionEquality().hash(_hiddenBy),const DeepCollectionEquality().hash(_clearedAt),isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'ChatModel(id: $id, type: $type, createdBy: $createdBy, participantIds: $participantIds, members: $members, groupName: $groupName, groupPhotoUrl: $groupPhotoUrl, description: $description, rideId: $rideId, eventId: $eventId, premiumOnly: $premiumOnly, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, lastMessageType: $lastMessageType, lastMessageAt: $lastMessageAt, mutedUntil: $mutedUntil, pinnedBy: $pinnedBy, hiddenBy: $hiddenBy, clearedAt: $clearedAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatModelCopyWith<$Res> implements $ChatModelCopyWith<$Res> {
  factory _$ChatModelCopyWith(_ChatModel value, $Res Function(_ChatModel) _then) = __$ChatModelCopyWithImpl;
@override @useResult
$Res call({
 String id, ChatType type, String? createdBy, List<String> participantIds, Map<String, ChatMember> members, String? groupName, String? groupPhotoUrl, String? description, String? rideId, String? eventId, bool premiumOnly, String? lastMessageContent, String? lastMessageSenderId, MessageType lastMessageType,@TimestampConverter() DateTime? lastMessageAt,@TimestampMapConverter() Map<String, DateTime> mutedUntil, List<String> pinnedBy,@TimestampMapConverter() Map<String, DateTime> hiddenBy,@TimestampMapConverter() Map<String, DateTime> clearedAt, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? createdBy = freezed,Object? participantIds = null,Object? members = null,Object? groupName = freezed,Object? groupPhotoUrl = freezed,Object? description = freezed,Object? rideId = freezed,Object? eventId = freezed,Object? premiumOnly = null,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageType = null,Object? lastMessageAt = freezed,Object? mutedUntil = null,Object? pinnedBy = null,Object? hiddenBy = null,Object? clearedAt = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ChatModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatType,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as Map<String, ChatMember>,groupName: freezed == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String?,groupPhotoUrl: freezed == groupPhotoUrl ? _self.groupPhotoUrl : groupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rideId: freezed == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String?,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,premiumOnly: null == premiumOnly ? _self.premiumOnly : premiumOnly // ignore: cast_nullable_to_non_nullable
as bool,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as MessageType,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mutedUntil: null == mutedUntil ? _self._mutedUntil : mutedUntil // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,pinnedBy: null == pinnedBy ? _self._pinnedBy : pinnedBy // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenBy: null == hiddenBy ? _self._hiddenBy : hiddenBy // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,clearedAt: null == clearedAt ? _self._clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
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
  return _then(TypingIndicator(
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
  const _TypingIndicator({required this.userId, this.username = '', required this.chatId, @TimestampConverter() this.startedAt}): super._();
  factory _TypingIndicator.fromJson(Map<String, dynamic> json) => _$TypingIndicatorFromJson(json);

@override final  String userId;
@override@JsonKey() final  String username;
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
