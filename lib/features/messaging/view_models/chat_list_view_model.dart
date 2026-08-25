import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

part 'chat_list_view_model.g.dart';

// ── ChatListUiViewModel ───────────────────────────────────────────────────────

/// Holds the search query typed in the chat list search bar.
///
/// The query is debounced before it reaches state: watchers drive the
/// Firestore people-search and list filtering, so an un-debounced query would
/// fire one remote search per keystroke. The TextField itself keeps its own
/// text; only consumers of `searchQuery` observe the settled value (~250 ms).
class ChatListUiState {
  const ChatListUiState({this.searchQuery = ''});

  final String searchQuery;

  ChatListUiState copyWith({String? searchQuery}) =>
      ChatListUiState(searchQuery: searchQuery ?? this.searchQuery);
}

@riverpod
class ChatListUiViewModel extends _$ChatListUiViewModel {
  Timer? _debounceTimer;

  static const Duration _debounceDelay = Duration(milliseconds: 250);

  @override
  ChatListUiState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const ChatListUiState();
  }

  /// Applies [value] to state after a short idle window, cancelling any
  /// pending application from a previous keystroke.
  void setSearchQuery(String value) {
    _debounceTimer?.cancel();
    final normalized = value.trim().toLowerCase();
    if (normalized == state.searchQuery) return;
    _debounceTimer = Timer(_debounceDelay, () {
      if (!ref.mounted) return;
      state = state.copyWith(searchQuery: normalized);
    });
  }
}

// ── Derived unread counts ─────────────────────────────────────────────────────

/// Exact unread count via a server-side count() aggregation — one billed
/// read per refresh regardless of backlog size. Only watched for chats whose
/// [since] cursor is behind `lastMessageAt`; read rows never query.
///
/// The provider family key includes the cursor so a new message (which bumps
/// lastMessageAt → list rebuild with unchanged cursor still matches) or a
/// markAsRead (cursor advances → new key) naturally re-runs this.
@riverpod
Future<int> unreadCount(
  Ref ref, {
  required String chatId,
  required String userId,
  required DateTime? since,
}) async {
  final db = ref.watch(firebaseServiceProvider).firestore;
  final effectiveSince = since ?? DateTime.fromMillisecondsSinceEpoch(0);
  final snapshot = await db
      .collection(AppConstants.chatsCollection)
      .doc(chatId)
      .collection(AppConstants.messagesCollection)
      .where('deletedAt', isEqualTo: null)
      .where('createdAt', isGreaterThan: Timestamp.fromDate(effectiveSince))
      .count()
      .get();
  return snapshot.count ?? 0;
}
