// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Plain-class wrapper for one-shot chat operations (upload, mute, block, etc.)
/// that don't require reactive state of their own.
// keepAlive: action-only VM - accessed from notification/background contexts.

@ProviderFor(ChatActionsViewModel)
final chatActionsViewModelProvider = ChatActionsViewModelProvider._();

/// Plain-class wrapper for one-shot chat operations (upload, mute, block, etc.)
/// that don't require reactive state of their own.
// keepAlive: action-only VM - accessed from notification/background contexts.
final class ChatActionsViewModelProvider
    extends $NotifierProvider<ChatActionsViewModel, void> {
  /// Plain-class wrapper for one-shot chat operations (upload, mute, block, etc.)
  /// that don't require reactive state of their own.
  // keepAlive: action-only VM - accessed from notification/background contexts.
  ChatActionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatActionsViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatActionsViewModelHash();

  @$internal
  @override
  ChatActionsViewModel create() => ChatActionsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$chatActionsViewModelHash() =>
    r'28a7c22e554722ed004680d215f1164454719513';

/// Plain-class wrapper for one-shot chat operations (upload, mute, block, etc.)
/// that don't require reactive state of their own.
// keepAlive: action-only VM - accessed from notification/background contexts.

abstract class _$ChatActionsViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Live stream of the user's chat list, ordered by last message time.

@ProviderFor(userChats)
final userChatsProvider = UserChatsFamily._();

/// Live stream of the user's chat list, ordered by last message time.

final class UserChatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatModel>>,
          List<ChatModel>,
          Stream<List<ChatModel>>
        >
    with $FutureModifier<List<ChatModel>>, $StreamProvider<List<ChatModel>> {
  /// Live stream of the user's chat list, ordered by last message time.
  UserChatsProvider._({
    required UserChatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userChatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userChatsHash();

  @override
  String toString() {
    return r'userChatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChatModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userChats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserChatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userChatsHash() => r'4338cfcd270cd9738dbaa2e45a2b4e81dcf791e4';

/// Live stream of the user's chat list, ordered by last message time.

final class UserChatsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChatModel>>, String> {
  UserChatsFamily._()
    : super(
        retry: null,
        name: r'userChatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live stream of the user's chat list, ordered by last message time.

  UserChatsProvider call(String userId) =>
      UserChatsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userChatsProvider';
}

@ProviderFor(blockedUserIds)
final blockedUserIdsProvider = BlockedUserIdsFamily._();

final class BlockedUserIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  BlockedUserIdsProvider._({
    required BlockedUserIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'blockedUserIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$blockedUserIdsHash();

  @override
  String toString() {
    return r'blockedUserIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return blockedUserIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BlockedUserIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$blockedUserIdsHash() => r'd820ab67b5f978a2c84d148d4cb55c95d62f967b';

final class BlockedUserIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  BlockedUserIdsFamily._()
    : super(
        retry: null,
        name: r'blockedUserIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BlockedUserIdsProvider call(String userId) =>
      BlockedUserIdsProvider._(argument: userId, from: this);

  @override
  String toString() => r'blockedUserIdsProvider';
}

/// Messages stream for a single chat, filtered to non-deleted only.

@ProviderFor(chatMessages)
final chatMessagesProvider = ChatMessagesFamily._();

/// Messages stream for a single chat, filtered to non-deleted only.

final class ChatMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessageModel>>,
          List<MessageModel>,
          Stream<List<MessageModel>>
        >
    with
        $FutureModifier<List<MessageModel>>,
        $StreamProvider<List<MessageModel>> {
  /// Messages stream for a single chat, filtered to non-deleted only.
  ChatMessagesProvider._({
    required ChatMessagesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'chatMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesHash();

  @override
  String toString() {
    return r'chatMessagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<MessageModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MessageModel>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return chatMessages(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMessagesHash() => r'30e07c648a8114c05a390ca67605c6c55b2e76e9';

/// Messages stream for a single chat, filtered to non-deleted only.

final class ChatMessagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<MessageModel>>,
          (String, String)
        > {
  ChatMessagesFamily._()
    : super(
        retry: null,
        name: r'chatMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Messages stream for a single chat, filtered to non-deleted only.

  ChatMessagesProvider call(String chatId, String currentUserId) =>
      ChatMessagesProvider._(argument: (chatId, currentUserId), from: this);

  @override
  String toString() => r'chatMessagesProvider';
}

/// Typing indicators stream for a single chat, non-expired only.

@ProviderFor(chatTyping)
final chatTypingProvider = ChatTypingFamily._();

/// Typing indicators stream for a single chat, non-expired only.

final class ChatTypingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TypingIndicator>>,
          List<TypingIndicator>,
          Stream<List<TypingIndicator>>
        >
    with
        $FutureModifier<List<TypingIndicator>>,
        $StreamProvider<List<TypingIndicator>> {
  /// Typing indicators stream for a single chat, non-expired only.
  ChatTypingProvider._({
    required ChatTypingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatTypingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatTypingHash();

  @override
  String toString() {
    return r'chatTypingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TypingIndicator>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TypingIndicator>> create(Ref ref) {
    final argument = this.argument as String;
    return chatTyping(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatTypingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatTypingHash() => r'dc6e881844129fcd96a609e322b4542f8e4453f1';

/// Typing indicators stream for a single chat, non-expired only.

final class ChatTypingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TypingIndicator>>, String> {
  ChatTypingFamily._()
    : super(
        retry: null,
        name: r'chatTypingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Typing indicators stream for a single chat, non-expired only.

  ChatTypingProvider call(String chatId) =>
      ChatTypingProvider._(argument: chatId, from: this);

  @override
  String toString() => r'chatTypingProvider';
}

@ProviderFor(ChatDetailViewModel)
final chatDetailViewModelProvider = ChatDetailViewModelFamily._();

final class ChatDetailViewModelProvider
    extends $NotifierProvider<ChatDetailViewModel, ChatDetailState> {
  ChatDetailViewModelProvider._({
    required ChatDetailViewModelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'chatDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatDetailViewModelHash();

  @override
  String toString() {
    return r'chatDetailViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatDetailViewModel create() => ChatDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDetailViewModelHash() =>
    r'e2dc6d12ad4a2cfa252962a67cbc5d3da8b619c8';

final class ChatDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatDetailViewModel,
          ChatDetailState,
          ChatDetailState,
          ChatDetailState,
          (String, String)
        > {
  ChatDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'chatDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatDetailViewModelProvider call(String chatId, String currentUserId) =>
      ChatDetailViewModelProvider._(
        argument: (chatId, currentUserId),
        from: this,
      );

  @override
  String toString() => r'chatDetailViewModelProvider';
}

abstract class _$ChatDetailViewModel extends $Notifier<ChatDetailState> {
  late final _$args = ref.$arg as (String, String);
  String get chatId => _$args.$1;
  String get currentUserId => _$args.$2;

  ChatDetailState build(String chatId, String currentUserId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatDetailState, ChatDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatDetailState, ChatDetailState>,
              ChatDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// Returns an existing direct chat or a local draft. The draft is persisted
/// to Firestore on first message send.

@ProviderFor(getOrCreateChat)
final getOrCreateChatProvider = GetOrCreateChatFamily._();

/// Returns an existing direct chat or a local draft. The draft is persisted
/// to Firestore on first message send.

final class GetOrCreateChatProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatModel>,
          ChatModel,
          FutureOr<ChatModel>
        >
    with $FutureModifier<ChatModel>, $FutureProvider<ChatModel> {
  /// Returns an existing direct chat or a local draft. The draft is persisted
  /// to Firestore on first message send.
  GetOrCreateChatProvider._({
    required GetOrCreateChatFamily super.from,
    required ({
      String userId1,
      String userId2,
      String userName1,
      String userName2,
      String? userPhoto1,
      String? userPhoto2,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'getOrCreateChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getOrCreateChatHash();

  @override
  String toString() {
    return r'getOrCreateChatProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ChatModel> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatModel> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String userId1,
              String userId2,
              String userName1,
              String userName2,
              String? userPhoto1,
              String? userPhoto2,
            });
    return getOrCreateChat(
      ref,
      userId1: argument.userId1,
      userId2: argument.userId2,
      userName1: argument.userName1,
      userName2: argument.userName2,
      userPhoto1: argument.userPhoto1,
      userPhoto2: argument.userPhoto2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrCreateChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getOrCreateChatHash() => r'82e34af561bcddcb5f188b6251cc8d9d713e57a0';

/// Returns an existing direct chat or a local draft. The draft is persisted
/// to Firestore on first message send.

final class GetOrCreateChatFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ChatModel>,
          ({
            String userId1,
            String userId2,
            String userName1,
            String userName2,
            String? userPhoto1,
            String? userPhoto2,
          })
        > {
  GetOrCreateChatFamily._()
    : super(
        retry: null,
        name: r'getOrCreateChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns an existing direct chat or a local draft. The draft is persisted
  /// to Firestore on first message send.

  GetOrCreateChatProvider call({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) => GetOrCreateChatProvider._(
    argument: (
      userId1: userId1,
      userId2: userId2,
      userName1: userName1,
      userName2: userName2,
      userPhoto1: userPhoto1,
      userPhoto2: userPhoto2,
    ),
    from: this,
  );

  @override
  String toString() => r'getOrCreateChatProvider';
}

/// Fetches the ride group chat for [rideId], or null if none exists.

@ProviderFor(rideChatByRideId)
final rideChatByRideIdProvider = RideChatByRideIdFamily._();

/// Fetches the ride group chat for [rideId], or null if none exists.

final class RideChatByRideIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatModel?>,
          ChatModel?,
          FutureOr<ChatModel?>
        >
    with $FutureModifier<ChatModel?>, $FutureProvider<ChatModel?> {
  /// Fetches the ride group chat for [rideId], or null if none exists.
  RideChatByRideIdProvider._({
    required RideChatByRideIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideChatByRideIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideChatByRideIdHash();

  @override
  String toString() {
    return r'rideChatByRideIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ChatModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatModel?> create(Ref ref) {
    final argument = this.argument as String;
    return rideChatByRideId(ref, rideId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RideChatByRideIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideChatByRideIdHash() => r'6e3be780290c8d5f663870c558c286804a7544b7';

/// Fetches the ride group chat for [rideId], or null if none exists.

final class RideChatByRideIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChatModel?>, String> {
  RideChatByRideIdFamily._()
    : super(
        retry: null,
        name: r'rideChatByRideIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the ride group chat for [rideId], or null if none exists.

  RideChatByRideIdProvider call({required String rideId}) =>
      RideChatByRideIdProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideChatByRideIdProvider';
}
