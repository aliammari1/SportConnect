// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatDetailState {

 List<MessageModel> get messages; List<TypingIndicator> get typingUsers; bool get isLoading; bool get isSending; bool get isLoadingMore; bool get hasMoreMessages; bool get showEmojiPicker; bool get isLocallyTyping; String? get error; MessageModel? get replyToMessage;
/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDetailStateCopyWith<ChatDetailState> get copyWith => _$ChatDetailStateCopyWithImpl<ChatDetailState>(this as ChatDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDetailState&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.typingUsers, typingUsers)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMoreMessages, hasMoreMessages) || other.hasMoreMessages == hasMoreMessages)&&(identical(other.showEmojiPicker, showEmojiPicker) || other.showEmojiPicker == showEmojiPicker)&&(identical(other.isLocallyTyping, isLocallyTyping) || other.isLocallyTyping == isLocallyTyping)&&(identical(other.error, error) || other.error == error)&&(identical(other.replyToMessage, replyToMessage) || other.replyToMessage == replyToMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(typingUsers),isLoading,isSending,isLoadingMore,hasMoreMessages,showEmojiPicker,isLocallyTyping,error,replyToMessage);

@override
String toString() {
  return 'ChatDetailState(messages: $messages, typingUsers: $typingUsers, isLoading: $isLoading, isSending: $isSending, isLoadingMore: $isLoadingMore, hasMoreMessages: $hasMoreMessages, showEmojiPicker: $showEmojiPicker, isLocallyTyping: $isLocallyTyping, error: $error, replyToMessage: $replyToMessage)';
}


}

/// @nodoc
abstract mixin class $ChatDetailStateCopyWith<$Res>  {
  factory $ChatDetailStateCopyWith(ChatDetailState value, $Res Function(ChatDetailState) _then) = _$ChatDetailStateCopyWithImpl;
@useResult
$Res call({
 List<MessageModel> messages, List<TypingIndicator> typingUsers, bool isLoading, bool isSending, bool isLoadingMore, bool hasMoreMessages, bool showEmojiPicker, bool isLocallyTyping, String? error, MessageModel? replyToMessage
});


$MessageModelCopyWith<$Res>? get replyToMessage;

}
/// @nodoc
class _$ChatDetailStateCopyWithImpl<$Res>
    implements $ChatDetailStateCopyWith<$Res> {
  _$ChatDetailStateCopyWithImpl(this._self, this._then);

  final ChatDetailState _self;
  final $Res Function(ChatDetailState) _then;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? typingUsers = null,Object? isLoading = null,Object? isSending = null,Object? isLoadingMore = null,Object? hasMoreMessages = null,Object? showEmojiPicker = null,Object? isLocallyTyping = null,Object? error = freezed,Object? replyToMessage = freezed,}) {
  return _then(ChatDetailState(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<MessageModel>,typingUsers: null == typingUsers ? _self.typingUsers : typingUsers // ignore: cast_nullable_to_non_nullable
as List<TypingIndicator>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMoreMessages: null == hasMoreMessages ? _self.hasMoreMessages : hasMoreMessages // ignore: cast_nullable_to_non_nullable
as bool,showEmojiPicker: null == showEmojiPicker ? _self.showEmojiPicker : showEmojiPicker // ignore: cast_nullable_to_non_nullable
as bool,isLocallyTyping: null == isLocallyTyping ? _self.isLocallyTyping : isLocallyTyping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,replyToMessage: freezed == replyToMessage ? _self.replyToMessage : replyToMessage // ignore: cast_nullable_to_non_nullable
as MessageModel?,
  ));
}
/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageModelCopyWith<$Res>? get replyToMessage {
    if (_self.replyToMessage == null) {
    return null;
  }

  return $MessageModelCopyWith<$Res>(_self.replyToMessage!, (value) {
    return _then(_self.copyWith(replyToMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatDetailState].
extension ChatDetailStatePatterns on ChatDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDetailState value)  $default,){
final _that = this;
switch (_that) {
case _ChatDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageModel> messages,  List<TypingIndicator> typingUsers,  bool isLoading,  bool isSending,  bool isLoadingMore,  bool hasMoreMessages,  bool showEmojiPicker,  bool isLocallyTyping,  String? error,  MessageModel? replyToMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
return $default(_that.messages,_that.typingUsers,_that.isLoading,_that.isSending,_that.isLoadingMore,_that.hasMoreMessages,_that.showEmojiPicker,_that.isLocallyTyping,_that.error,_that.replyToMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageModel> messages,  List<TypingIndicator> typingUsers,  bool isLoading,  bool isSending,  bool isLoadingMore,  bool hasMoreMessages,  bool showEmojiPicker,  bool isLocallyTyping,  String? error,  MessageModel? replyToMessage)  $default,) {final _that = this;
switch (_that) {
case _ChatDetailState():
return $default(_that.messages,_that.typingUsers,_that.isLoading,_that.isSending,_that.isLoadingMore,_that.hasMoreMessages,_that.showEmojiPicker,_that.isLocallyTyping,_that.error,_that.replyToMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageModel> messages,  List<TypingIndicator> typingUsers,  bool isLoading,  bool isSending,  bool isLoadingMore,  bool hasMoreMessages,  bool showEmojiPicker,  bool isLocallyTyping,  String? error,  MessageModel? replyToMessage)?  $default,) {final _that = this;
switch (_that) {
case _ChatDetailState() when $default != null:
return $default(_that.messages,_that.typingUsers,_that.isLoading,_that.isSending,_that.isLoadingMore,_that.hasMoreMessages,_that.showEmojiPicker,_that.isLocallyTyping,_that.error,_that.replyToMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ChatDetailState implements ChatDetailState {
  const _ChatDetailState({ List<MessageModel> messages = const [],  List<TypingIndicator> typingUsers = const [], this.isLoading = true, this.isSending = false, this.isLoadingMore = false, this.hasMoreMessages = true, this.showEmojiPicker = false, this.isLocallyTyping = false, this.error, this.replyToMessage}): _messages = messages,_typingUsers = typingUsers;
  

 final  List<MessageModel> _messages;
@override@JsonKey() List<MessageModel> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<TypingIndicator> _typingUsers;
@override@JsonKey() List<TypingIndicator> get typingUsers {
  if (_typingUsers is EqualUnmodifiableListView) return _typingUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_typingUsers);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSending;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMoreMessages;
@override@JsonKey() final  bool showEmojiPicker;
@override@JsonKey() final  bool isLocallyTyping;
@override final  String? error;
@override final  MessageModel? replyToMessage;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDetailStateCopyWith<_ChatDetailState> get copyWith => __$ChatDetailStateCopyWithImpl<_ChatDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDetailState&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._typingUsers, _typingUsers)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMoreMessages, hasMoreMessages) || other.hasMoreMessages == hasMoreMessages)&&(identical(other.showEmojiPicker, showEmojiPicker) || other.showEmojiPicker == showEmojiPicker)&&(identical(other.isLocallyTyping, isLocallyTyping) || other.isLocallyTyping == isLocallyTyping)&&(identical(other.error, error) || other.error == error)&&(identical(other.replyToMessage, replyToMessage) || other.replyToMessage == replyToMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_typingUsers),isLoading,isSending,isLoadingMore,hasMoreMessages,showEmojiPicker,isLocallyTyping,error,replyToMessage);

@override
String toString() {
  return 'ChatDetailState(messages: $messages, typingUsers: $typingUsers, isLoading: $isLoading, isSending: $isSending, isLoadingMore: $isLoadingMore, hasMoreMessages: $hasMoreMessages, showEmojiPicker: $showEmojiPicker, isLocallyTyping: $isLocallyTyping, error: $error, replyToMessage: $replyToMessage)';
}


}

/// @nodoc
abstract mixin class _$ChatDetailStateCopyWith<$Res> implements $ChatDetailStateCopyWith<$Res> {
  factory _$ChatDetailStateCopyWith(_ChatDetailState value, $Res Function(_ChatDetailState) _then) = __$ChatDetailStateCopyWithImpl;
@override @useResult
$Res call({
 List<MessageModel> messages, List<TypingIndicator> typingUsers, bool isLoading, bool isSending, bool isLoadingMore, bool hasMoreMessages, bool showEmojiPicker, bool isLocallyTyping, String? error, MessageModel? replyToMessage
});


@override $MessageModelCopyWith<$Res>? get replyToMessage;

}
/// @nodoc
class __$ChatDetailStateCopyWithImpl<$Res>
    implements _$ChatDetailStateCopyWith<$Res> {
  __$ChatDetailStateCopyWithImpl(this._self, this._then);

  final _ChatDetailState _self;
  final $Res Function(_ChatDetailState) _then;

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? typingUsers = null,Object? isLoading = null,Object? isSending = null,Object? isLoadingMore = null,Object? hasMoreMessages = null,Object? showEmojiPicker = null,Object? isLocallyTyping = null,Object? error = freezed,Object? replyToMessage = freezed,}) {
  return _then(_ChatDetailState(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<MessageModel>,typingUsers: null == typingUsers ? _self._typingUsers : typingUsers // ignore: cast_nullable_to_non_nullable
as List<TypingIndicator>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMoreMessages: null == hasMoreMessages ? _self.hasMoreMessages : hasMoreMessages // ignore: cast_nullable_to_non_nullable
as bool,showEmojiPicker: null == showEmojiPicker ? _self.showEmojiPicker : showEmojiPicker // ignore: cast_nullable_to_non_nullable
as bool,isLocallyTyping: null == isLocallyTyping ? _self.isLocallyTyping : isLocallyTyping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,replyToMessage: freezed == replyToMessage ? _self.replyToMessage : replyToMessage // ignore: cast_nullable_to_non_nullable
as MessageModel?,
  ));
}

/// Create a copy of ChatDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageModelCopyWith<$Res>? get replyToMessage {
    if (_self.replyToMessage == null) {
    return null;
  }

  return $MessageModelCopyWith<$Res>(_self.replyToMessage!, (value) {
    return _then(_self.copyWith(replyToMessage: value));
  });
}
}

// dart format on
