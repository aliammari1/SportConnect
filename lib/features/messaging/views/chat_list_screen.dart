import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_list_view_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/messaging/views/chat_detail_screen.dart';
import 'package:sport_connect/features/profile/view_models/user_search_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatUserData {
  _ChatUserData({
    required this.uid,
    required this.username,
    required this.blockedIds,
    this.photoUrl,
  });

  factory _ChatUserData.from(UserModel user) {
    final blockedUsers = switch (user) {
      RiderModel(:final blockedUsers) => blockedUsers,
      DriverModel(:final blockedUsers) => blockedUsers,
      _ => const <String>[],
    };

    return _ChatUserData(
      uid: user.uid,
      username: user.username,
      photoUrl: user.photoUrl,
      blockedIds: Set.unmodifiable(blockedUsers),
    );
  }

  final String uid;
  final String username;
  final String? photoUrl;
  final Set<String> blockedIds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ChatUserData &&
            other.uid == uid &&
            other.username == username &&
            other.photoUrl == photoUrl &&
            setEquals(other.blockedIds, blockedIds);
  }

  @override
  int get hashCode => Object.hash(
    uid,
    username,
    photoUrl,
    Object.hashAllUnordered(blockedIds),
  );
}

class _SelectedChatDetail {
  const _SelectedChatDetail({
    required this.chatId,
    required this.receiver,
    required this.isGroup,
  });

  final String chatId;
  final UserModel receiver;
  final bool isGroup;
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  _SelectedChatDetail? _selectedChat;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: AdaptiveMasterDetailScaffold(
        master: _buildChatListBody(constrainWidth: false),
        detail: _buildTabletDetail(),
        phone: _buildChatListBody(),
      ),
    );
  }

  Widget _buildChatListBody({bool constrainWidth = true}) {
    final l10n = AppLocalizations.of(context);
    final body = SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: adaptiveScreenPadding(
              context,
            ).copyWith(bottom: 12.h, top: 12.h),
            child: PremiumSearchField(
              hint: l10n.searchChatsOrPeople,
              onChanged: (value) => ref
                  .read(chatListUiViewModelProvider.notifier)
                  .setSearchQuery(value),
            ),
          ),
          Expanded(
            child: AdaptiveTabBarView(
              tabs: [l10n.direct, l10n.groups, l10n.rides],
              selectedColor: Colors.white,
              backgroundColor: AppColors.primary,
              children: [
                _buildDirectChats(),
                _buildGroupChats(),
                _buildRideChats(),
              ],
            ),
          ),
        ],
      ),
    );

    if (!constrainWidth) return body;

    return MaxWidthContainer(maxWidth: kMaxWidthForm, child: body);
  }

  Widget _buildTabletDetail() {
    final selectedChat = _selectedChat;
    if (selectedChat == null) {
      final l10n = AppLocalizations.of(context);
      return TabletEmptyDetail(
        icon: Icons.chat_bubble_outline_rounded,
        title: l10n.messages,
        message: l10n.searchChatsOrPeople,
      );
    }

    return ChatDetailScreen(
      key: ValueKey(
        'chat_${selectedChat.chatId}_${selectedChat.receiver.uid}_${selectedChat.isGroup}',
      ),
      chatId: selectedChat.chatId,
      receiver: selectedChat.receiver,
      isGroup: selectedChat.isGroup,
    );
  }

  bool get _usesTwoPaneLayout => context.screenWidth >= Breakpoints.medium;

  UserModel _receiverForChat(ChatModel chat, String currentUserId) {
    final title = chat.getChatTitle(currentUserId);
    final photoUrl = chat.getChatPhoto(currentUserId);
    final otherParticipant = chat.getOtherParticipant(currentUserId);
    final fallbackId = chat.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return UserModel.rider(
      uid: otherParticipant?.userId ?? fallbackId,
      email: '',
      username: title,
      photoUrl: photoUrl,
    );
  }

  void _openExistingChat(ChatModel chat, String currentUserId) {
    final receiverUser = _receiverForChat(chat, currentUserId);
    final isGroup = chat.type != ChatType.private;

    if (_usesTwoPaneLayout) {
      setState(() {
        _selectedChat = _SelectedChatDetail(
          chatId: chat.id,
          receiver: receiverUser,
          isGroup: isGroup,
        );
      });
      return;
    }

    final routeName = switch (chat.type) {
      ChatType.rideGroup || ChatType.eventGroup => AppRoutes.chatGroup.name,
      _ => AppRoutes.chatDetail.name,
    };
    context.pushNamed(
      routeName,
      pathParameters: {'id': chat.id},
      queryParameters: {
        'receiverId': receiverUser.uid,
        'receiverName': receiverUser.username,
        if (receiverUser.photoUrl != null)
          'receiverPhotoUrl': receiverUser.photoUrl,
      },
      extra: receiverUser,
    );
  }

  // ── Pull-to-refresh ──────────────────────────────────────────────────────

  Future<void> _refreshChatsForUser(String userId) async {
    ref.invalidate(userChatsProvider(userId));
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _withChatPullToRefresh({
    required String userId,
    required Widget child,
  }) {
    // If child is already a scroll view, wrap directly. Otherwise nest inside
    // an always-scrollable ListView so the refresh gesture still triggers.
    final scrollable = child is ScrollView
        ? child
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 120.h),
              child,
            ],
          );

    return RefreshIndicator.adaptive(
      onRefresh: () => _refreshChatsForUser(userId),
      child: scrollable,
    );
  }

  // ── Header / tabs ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
        child: Text(
          AppLocalizations.of(context).messages,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0,
            height: 1,
          ),
        ),
      ),
    );
  }

  // ── Tab: Direct ──────────────────────────────────────────────────────────

  Widget _buildDirectChats() {
    final searchQuery = ref.watch(
      chatListUiViewModelProvider.select((state) => state.searchQuery),
    );
    final currentUserAsync = ref.watch(
      currentUserProvider.select(
        (value) => value.whenData(
          (user) => user == null ? null : _ChatUserData.from(user),
        ),
      ),
    );

    return currentUserAsync.when(
      loading: () =>
          const SkeletonLoader(type: SkeletonType.chatTile, itemCount: 6),
      error: (_, _) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUser) {
        if (currentUser == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUser.uid));
        final peopleAsync = searchQuery.length >= 2
            ? ref.watch(searchResultsProvider(searchQuery))
            : const AsyncData(<UserModel>[]);

        return chatsAsync.when(
          loading: () =>
              const SkeletonLoader(type: SkeletonType.chatTile, itemCount: 6),
          error: (_, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).failedToLoadChats,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(userChatsProvider(currentUser.uid)),
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
          data: (chats) {
            final directChats = _filterDirectChats(
              chats: chats,
              currentUserId: currentUser.uid,
              blockedIds: currentUser.blockedIds,
              searchQuery: searchQuery,
            );

            final peopleMatches = _filterPeopleResults(
              people: peopleAsync.value ?? const [],
              currentUserId: currentUser.uid,
              blockedIds: currentUser.blockedIds,
              searchQuery: searchQuery,
            );

            final showPeopleBlock = searchQuery.length >= 2;

            if (directChats.isEmpty && !showPeopleBlock) {
              return _withChatPullToRefresh(
                userId: currentUser.uid,
                child: _buildEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: AppLocalizations.of(context).noConversationsYet,
                  subtitle: AppLocalizations.of(context).startAConversationWith,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUser.uid,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: directChats.length + (showPeopleBlock ? 1 : 0),
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 88.w,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  if (showPeopleBlock && index == 0) {
                    return _buildPeopleSearchSection(
                      peopleAsync: peopleAsync,
                      peopleMatches: peopleMatches,
                      currentUser: currentUser,
                    );
                  }
                  final chatIndex = showPeopleBlock ? index - 1 : index;
                  final tile = _buildSwipeableChatTile(
                    directChats[chatIndex],
                    currentUser.uid,
                  );
                  return tile
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        delay: Duration(milliseconds: 50 + (index * 60)),
                      )
                      .slideX(begin: 0.1, curve: Curves.easeOutCubic);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Always hide blocked users, including when search is empty.
  List<ChatModel> _filterDirectChats({
    required List<ChatModel> chats,
    required String currentUserId,
    required Set<String> blockedIds,
    required String searchQuery,
  }) {
    return chats.where((c) {
      if (c.type != ChatType.private) return false;

      final other = c.getOtherParticipant(currentUserId);
      final otherId = (other != null && other.userId.isNotEmpty)
          ? other.userId
          : c.participantIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

      // Always hide blocked users, regardless of search state.
      if (blockedIds.contains(otherId)) return false;

      if (searchQuery.isEmpty) return true;
      return c.getChatTitle(currentUserId).toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<UserModel> _filterPeopleResults({
    required List<UserModel> people,
    required String currentUserId,
    required Set<String> blockedIds,
    required String searchQuery,
  }) {
    if (searchQuery.isEmpty) return const [];
    return people
        .where((user) {
          if (user.uid == currentUserId) return false;
          if (blockedIds.contains(user.uid)) return false;
          final name = user.username.toLowerCase();
          final email = user.email.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        })
        .toList(growable: false);
  }

  // ── Tab: Groups ──────────────────────────────────────────────────────────

  Widget _buildGroupChats() {
    final searchQuery = ref.watch(
      chatListUiViewModelProvider.select((state) => state.searchQuery),
    );
    final currentUserAsync = ref.watch(currentAuthUidProvider);

    return currentUserAsync.when(
      loading: () => const SkeletonLoader(type: SkeletonType.chatTile),
      error: (_, _) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUserId) {
        if (currentUserId == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUserId));

        return chatsAsync.when(
          loading: () => const SkeletonLoader(type: SkeletonType.chatTile),
          error: (_, _) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUserId)),
          ),
          data: (chats) {
            final groupChats = chats.where((c) {
              if (c.type != ChatType.eventGroup && c.type != ChatType.support) {
                return false;
              }
              if (searchQuery.isEmpty) return true;
              return c
                  .getChatTitle(currentUserId)
                  .toLowerCase()
                  .contains(
                    searchQuery,
                  );
            }).toList();

            if (groupChats.isEmpty) {
              return _withChatPullToRefresh(
                userId: currentUserId,
                child: _buildEmptyState(
                  icon: Icons.group_outlined,
                  title: AppLocalizations.of(context).noGroupChats,
                  subtitle: AppLocalizations.of(context).joinOrCreateAGroup,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUserId,
              child: _buildChatList(groupChats, currentUserId),
            );
          },
        );
      },
    );
  }

  // ── Tab: Rides ───────────────────────────────────────────────────────────

  Widget _buildRideChats() {
    final searchQuery = ref.watch(
      chatListUiViewModelProvider.select((state) => state.searchQuery),
    );
    final currentUserAsync = ref.watch(currentAuthUidProvider);

    return currentUserAsync.when(
      loading: () => const SkeletonLoader(type: SkeletonType.chatTile),
      error: (_, _) => Center(
        child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
      ),
      data: (currentUserId) {
        if (currentUserId == null) {
          return Center(
            child: Text(AppLocalizations.of(context).pleaseLoginToViewChats),
          );
        }

        final chatsAsync = ref.watch(userChatsProvider(currentUserId));

        return chatsAsync.when(
          loading: () => const SkeletonLoader(type: SkeletonType.chatTile),
          error: (_, _) => _buildChatErrorState(
            onRetry: () => ref.invalidate(userChatsProvider(currentUserId)),
          ),
          data: (chats) {
            final rideChats = chats.where((c) {
              if (c.type != ChatType.rideGroup) return false;
              if (searchQuery.isEmpty) return true;
              return c
                  .getChatTitle(currentUserId)
                  .toLowerCase()
                  .contains(
                    searchQuery,
                  );
            }).toList();

            if (rideChats.isEmpty) {
              return _withChatPullToRefresh(
                userId: currentUserId,
                child: _buildEmptyState(
                  icon: Icons.directions_car_outlined,
                  title: AppLocalizations.of(context).noRideChats,
                  subtitle: AppLocalizations.of(context).joinARideToChat,
                ),
              );
            }

            return _withChatPullToRefresh(
              userId: currentUserId,
              child: _buildChatList(rideChats, currentUserId),
            );
          },
        );
      },
    );
  }

  Widget _buildChatList(List<ChatModel> chats, String currentUserId) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: chats.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 88.w,
        color: AppColors.border.withValues(alpha: 0.5),
      ),
      itemBuilder: (_, index) =>
          _buildSwipeableChatTile(chats[index], currentUserId),
    );
  }

  // ── Open chat with user ──────────────────────────────────────────────────

  Future<void> _openChatWithUser(
    _ChatUserData currentUser,
    UserModel user,
  ) async {
    // Show spinner without awaiting — closed programmatically after async work.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: AppLocalizations.of(context).creatingChatLabel,
        builder: (_) =>
            const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );

    try {
      final chatModel = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: user.uid,
          userName1: currentUser.username,
          userName2: user.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: user.photoUrl,
        ).future,
      );

      if (!mounted) return;
      context.pop(); // Close spinner.
      if (_usesTwoPaneLayout) {
        setState(() {
          _selectedChat = _SelectedChatDetail(
            chatId: chatModel.id,
            receiver: user,
            isGroup: false,
          );
        });
        return;
      }

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chatModel.id},
        queryParameters: {
          'receiverId': user.uid,
          'receiverName': user.username,
          if (user.photoUrl != null) 'receiverPhotoUrl': user.photoUrl,
        },
        extra: user,
      );
    } on Exception {
      if (!mounted) return;
      context.pop(); // Close spinner.
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToCreateChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  // ── People search section ────────────────────────────────────────────────

  Widget _buildPeopleSearchSection({
    required AsyncValue<List<UserModel>> peopleAsync,
    required List<UserModel> peopleMatches,
    required _ChatUserData currentUser,
  }) {
    if (peopleAsync.isLoading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
            Text(
              AppLocalizations.of(context).peopleResults,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (peopleMatches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                AppLocalizations.of(context).peopleResults,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${peopleMatches.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...peopleMatches.map(
            (user) => Container(
              margin: EdgeInsets.only(bottom: 6.h),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
              ),
              child: AdaptiveListTile(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                leading: PremiumAvatar(
                  imageUrl: user.photoUrl,
                  name: user.username,
                  size: 36,
                ),
                title: Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.north_east_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                onTap: () => _openChatWithUser(currentUser, user),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error / empty states ─────────────────────────────────────────────────

  Widget _buildChatErrorState({required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).failedToLoadChats,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context).retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Swipeable chat tile ──────────────────────────────────────────────────

  Widget _buildSwipeableChatTile(ChatModel chat, String currentUserId) {
    final isMuted = chat.mutedBy[currentUserId] == true;

    return Dismissible(
      key: ValueKey('chat_${chat.id}'),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: isMuted ? AppColors.warning : AppColors.success,
        icon: isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: isMuted
            ? AppLocalizations.of(context).unmuteChat
            : AppLocalizations.of(context).muteChat,
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete_outline_rounded,
        label: AppLocalizations.of(context).deleteChat,
      ),
      confirmDismiss: (direction) => _confirmDismiss(
        direction: direction,
        chat: chat,
        currentUserId: currentUserId,
        isMuted: isMuted,
      ),
      child: _buildChatTile(chat, currentUserId),
    );
  }

  Widget _buildSwipeBackground({
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDismiss({
    required DismissDirection direction,
    required ChatModel chat,
    required String currentUserId,
    required bool isMuted,
  }) async {
    if (direction == DismissDirection.startToEnd) {
      // Mute / unmute — tile stays in place regardless of outcome.
      try {
        await ref
            .read(chatActionsViewModelProvider.notifier)
            .toggleMute(
              chatId: chat.id,
              userId: currentUserId,
              mute: !isMuted,
            );
        if (!mounted) return false;
        AdaptiveSnackBar.show(
          context,
          message: isMuted
              ? AppLocalizations.of(context).chatUnmuted
              : AppLocalizations.of(context).chatMuted,
          type: isMuted
              ? AdaptiveSnackBarType.warning
              : AdaptiveSnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      } on Exception {
        if (!mounted) return false;
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).couldNotClearChatTryAgain,
          type: AdaptiveSnackBarType.error,
          duration: const Duration(seconds: 2),
        );
      }
      return false; // Always keep tile in place for mute.
    }

    // Swipe left → confirm delete.
    final confirmed = await showDialog<bool>(
      context: context,
      barrierLabel: AppLocalizations.of(context).deleteConversationTitle,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).deleteConversationTitle),
        content: Text(AppLocalizations.of(context).deleteConversationMessage),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await ref
          .read(chatActionsViewModelProvider.notifier)
          .clearChat(
            chatId: chat.id,
            userId: currentUserId,
          );
      if (!mounted) return false;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).conversationRemoved,
        type: AdaptiveSnackBarType.success,
        duration: const Duration(seconds: 2),
      );
      if (_selectedChat?.chatId == chat.id) {
        setState(() => _selectedChat = null);
      }
      return true;
    } on Exception {
      if (!mounted) return false;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotClearChatTryAgain,
        type: AdaptiveSnackBarType.error,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  // ── Chat tile ────────────────────────────────────────────────────────────

  Widget _buildChatTile(ChatModel chat, String currentUserId) {
    final title = chat.getChatTitle(currentUserId);
    final photoUrl = chat.getChatPhoto(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final lastMessage =
        chat.lastMessageContent ?? AppLocalizations.of(context).noMessagesYet;
    final lastMessageTime = _formatTime(chat.lastMessageAt);

    return InkWell(
      onTap: () => _openExistingChat(chat, currentUserId),
      child: Padding(
        padding: adaptiveScreenPadding(
          context,
        ).copyWith(bottom: 12.h, top: 12.h),
        child: Row(
          children: [
            PremiumAvatar(imageUrl: photoUrl, name: title, size: 56),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageTime,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unreadCount > 99
                                ? AppLocalizations.of(context).text99
                                : AppLocalizations.of(
                                    context,
                                  ).value2(unreadCount),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  // Firestore timestamps are UTC; convert to local before relative formatting.
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return AppLocalizations.of(context).timeNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return AppLocaleFormatters.formatMonthDay(context, local);
  }
}
