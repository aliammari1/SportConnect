// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatListUiViewModel)
final chatListUiViewModelProvider = ChatListUiViewModelProvider._();

final class ChatListUiViewModelProvider
    extends $NotifierProvider<ChatListUiViewModel, ChatListUiState> {
  ChatListUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListUiViewModelHash();

  @$internal
  @override
  ChatListUiViewModel create() => ChatListUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatListUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatListUiState>(value),
    );
  }
}

String _$chatListUiViewModelHash() =>
    r'36e70fc696d3f7ca376144782b5b3d5467e83d82';

abstract class _$ChatListUiViewModel extends $Notifier<ChatListUiState> {
  ChatListUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatListUiState, ChatListUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatListUiState, ChatListUiState>,
              ChatListUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Exact unread count via a server-side count() aggregation — one billed
/// read per refresh regardless of backlog size. Only watched for chats whose
/// [since] cursor is behind `lastMessageAt`; read rows never query.
///
/// The provider family key includes the cursor so a new message (which bumps
/// lastMessageAt → list rebuild with unchanged cursor still matches) or a
/// markAsRead (cursor advances → new key) naturally re-runs this.

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountFamily._();

/// Exact unread count via a server-side count() aggregation — one billed
/// read per refresh regardless of backlog size. Only watched for chats whose
/// [since] cursor is behind `lastMessageAt`; read rows never query.
///
/// The provider family key includes the cursor so a new message (which bumps
/// lastMessageAt → list rebuild with unchanged cursor still matches) or a
/// markAsRead (cursor advances → new key) naturally re-runs this.

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Exact unread count via a server-side count() aggregation — one billed
  /// read per refresh regardless of backlog size. Only watched for chats whose
  /// [since] cursor is behind `lastMessageAt`; read rows never query.
  ///
  /// The provider family key includes the cursor so a new message (which bumps
  /// lastMessageAt → list rebuild with unchanged cursor still matches) or a
  /// markAsRead (cursor advances → new key) naturally re-runs this.
  UnreadCountProvider._({
    required UnreadCountFamily super.from,
    required ({String chatId, String userId, DateTime? since}) super.argument,
  }) : super(
         retry: null,
         name: r'unreadCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @override
  String toString() {
    return r'unreadCountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument =
        this.argument as ({String chatId, String userId, DateTime? since});
    return unreadCount(
      ref,
      chatId: argument.chatId,
      userId: argument.userId,
      since: argument.since,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadCountHash() => r'78e691118024f20ecc47187bd40ca13d6096077a';

/// Exact unread count via a server-side count() aggregation — one billed
/// read per refresh regardless of backlog size. Only watched for chats whose
/// [since] cursor is behind `lastMessageAt`; read rows never query.
///
/// The provider family key includes the cursor so a new message (which bumps
/// lastMessageAt → list rebuild with unchanged cursor still matches) or a
/// markAsRead (cursor advances → new key) naturally re-runs this.

final class UnreadCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<int>,
          ({String chatId, String userId, DateTime? since})
        > {
  UnreadCountFamily._()
    : super(
        retry: null,
        name: r'unreadCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Exact unread count via a server-side count() aggregation — one billed
  /// read per refresh regardless of backlog size. Only watched for chats whose
  /// [since] cursor is behind `lastMessageAt`; read rows never query.
  ///
  /// The provider family key includes the cursor so a new message (which bumps
  /// lastMessageAt → list rebuild with unchanged cursor still matches) or a
  /// markAsRead (cursor advances → new key) naturally re-runs this.

  UnreadCountProvider call({
    required String chatId,
    required String userId,
    required DateTime? since,
  }) => UnreadCountProvider._(
    argument: (chatId: chatId, userId: userId, since: since),
    from: this,
  );

  @override
  String toString() => r'unreadCountProvider';
}
