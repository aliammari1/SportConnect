import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/messaging/widgets/message_content_widgets.dart';
import 'package:sport_connect/features/messaging/widgets/typing_dot.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Chat Detail Screen with real-time Firestore messaging.
class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({
    required this.chatId,
    required this.receiver,
    super.key,
    this.isGroup = false,
  });

  final String chatId;
  final UserModel receiver;
  final bool isGroup;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late String _activeChatId;
  late UserModel _resolvedReceiver;
  bool _isResolvingReceiver = false;

  // Local-only marker for the most recent send failure. The Firestore write
  // in ChatRepository.sendMessage is a single atomic batch, so a failure
  // means no message document was ever created — there is nothing server-side
  // to mark `failed`. This tracks the attempt purely on-device so the UI can
  // show a visually distinct "failed to send" state instead of silently
  // dropping it (beyond the existing composer-restore + snackbar).
  MessageModel? _lastFailedMessage;

  // ── Convenience getters ──────────────────────────────────────────────────

  UserModel? get currentUser => ref.read(currentUserProvider).value;
  String get _chatId => _activeChatId;
  bool get _isDraftChat => isDraftChatId(_activeChatId);
  UserModel get _receiver => _resolvedReceiver;

  // ── Snack-bar helpers ────────────────────────────────────────────────────

  void _showStatusSnackBar(
    String message, {
    AdaptiveSnackBarType type = AdaptiveSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onActionPressed,
  }) {
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: type,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
    );
  }

  void _showSendingSnackBar(String message) {
    _showStatusSnackBar(
      message,
      duration: const Duration(seconds: 30),
    );
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    _resolvedReceiver = widget.receiver;
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveReceiverIfNeeded();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Scroll / text listeners ──────────────────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .loadMoreMessages();
    }
  }

  void _onTextChanged() {
    ref
        .read(
          chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
        )
        .handleComposerTextChanged(
          _messageController.text,
          currentUser?.username ?? AppLocalizations.of(context).user,
        );
  }

  // ── Chat persistence ─────────────────────────────────────────────────────

  Future<bool> _ensurePersistedChat() async {
    if (!_isDraftChat) return true;
    final user = currentUser;
    if (user == null) return false;
    if (_receiver.uid.isEmpty) return false;

    try {
      final chat = await ref
          .read(chatActionsViewModelProvider.notifier)
          .getOrCreatePrivateChat(
            userId1: user.uid,
            userId2: _receiver.uid,
            userName1: user.username,
            userName2: _receiver.username,
            userPhoto1: user.photoUrl,
            userPhoto2: _receiver.photoUrl,
          );
      if (!mounted) return false;
      setState(() => _activeChatId = chat.id);
      ref.invalidate(userChatsProvider(user.uid));
      return true;
    } on Exception {
      if (!mounted) return false;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToCreateChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return false;
    }
  }

  Future<void> _resolveReceiverIfNeeded() async {
    if (_isResolvingReceiver || widget.isGroup) return;
    if (_receiver.uid.isNotEmpty || _isDraftChat) return;
    final user = currentUser;
    if (user == null) return;

    _isResolvingReceiver = true;
    try {
      final chat = await ref
          .read(chatActionsViewModelProvider.notifier)
          .getChatById(_chatId);
      if (!mounted || chat == null) return;
      final other = chat.getOtherParticipant(user.uid);
      final fallbackId = chat.participantIds.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );
      final resolvedUid = other?.userId ?? fallbackId;
      if (resolvedUid.isEmpty) return;
      setState(() {
        _resolvedReceiver = UserModel.rider(
          uid: resolvedUid,
          email: '',
          username: other?.username ?? _receiver.username,
          photoUrl: other?.photoUrl ?? _receiver.photoUrl,
        );
      });
    } finally {
      _isResolvingReceiver = false;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ── Send operations ──────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (!await _ensurePersistedChat()) return;
    if (!mounted) return;

    // A new attempt supersedes any previously shown failure banner.
    if (_lastFailedMessage != null) {
      setState(() => _lastFailedMessage = null);
    }

    unawaited(HapticFeedback.lightImpact());
    _messageController.clear();

    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );
    final chatState = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
    );

    notifier.setEmojiPickerVisible(false);

    final success = await notifier.sendMessage(
      content: text,
      senderName: currentUser?.username ?? AppLocalizations.of(context).user,
      senderPhotoUrl: currentUser?.photoUrl,
      replyToMessageId: chatState.replyToMessage?.id,
      replyToContent: chatState.replyToMessage?.content,
    );

    if (!mounted) return;

    if (!success) {
      final error = ref
          .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
          .error;

      _messageController.value = TextEditingValue(
        text: text,
        // Restore the caret to the end of the restored text — without this,
        // assigning `_messageController.text = text` snaps the caret to
        // position 0, forcing the user to click back where they were.
        selection: TextSelection.collapsed(offset: text.length),
      );

      _showStatusSnackBar(
        error ?? AppLocalizations.of(context).failedToSendMessage,
        type: AdaptiveSnackBarType.error,
      );

      setState(() {
        _lastFailedMessage = MessageModel(
          id: 'local-failed-${DateTime.now().microsecondsSinceEpoch}',
          chatId: _chatId,
          senderId: currentUser?.uid ?? '',
          senderName:
              currentUser?.username ?? AppLocalizations.of(context).user,
          content: text,
          status: MessageStatus.failed,
          createdAt: DateTime.now(),
        );
      });

      return;
    }

    notifier.clearReply();
    _scrollToBottom();
  }

  Future<void> _sendImageFromSource(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    final customMessage = source == ImageSource.gallery
        ? AppLocalizations.of(context).permissionPhotoLibraryMessage
        : AppLocalizations.of(
            context,
          ).cameraAccessIsNeededToTakeAndSendPhotosInThisChat;

    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: customMessage,
    );
    if (!accepted) return;

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;
    if (!await _ensurePersistedChat()) return;

    unawaited(HapticFeedback.lightImpact());
    if (!context.mounted) return;
    _showSendingSnackBar(l10n.sendingImage);

    try {
      final notifier = ref.read(
        chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
      );
      final success = await notifier.sendImageMessage(
        imageFile: File(pickedFile.path),
        fileName: '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}',
        senderName: currentUser?.username ?? AppLocalizations.of(context).user,
        senderPhotoUrl: currentUser?.photoUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!success) {
        final error =
            ref
                .read(
                  chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''),
                )
                .error ??
            AppLocalizations.of(context).failedToSendImage;
        _showStatusSnackBar(
          l10n.failedToSendImageValue(error),
          type: AdaptiveSnackBarType.error,
        );
        return;
      }
      _scrollToBottom();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showStatusSnackBar(
        l10n.failedToSendImageValue(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  // ── Emoji picker ─────────────────────────────────────────────────────────

  void _toggleEmojiPicker() {
    final showing = ref
        .read(chatDetailViewModelProvider(_chatId, currentUser?.uid ?? ''))
        .showEmojiPicker;
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser?.uid ?? '').notifier,
    );

    if (showing) {
      notifier.setEmojiPickerVisible(false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      notifier.setEmojiPickerVisible(true);
    }
  }

  // ── Options sheets ───────────────────────────────────────────────────────

  void _showOptionsSheet({required bool isReceiverBlocked}) {
    final l10n = AppLocalizations.of(context);

    void onViewProfile() {
      final receiverId = _receiver.uid;
      if (receiverId.isEmpty) {
        AdaptiveSnackBar.show(
          context,
          message: l10n.failedToLoadChats,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }
      context.push(
        AppRoutes.userProfile.path.replaceFirst(':id', receiverId),
        extra: _receiver,
      );
    }

    AppModalSheet.showActions<void>(
      context: context,
      title: l10n.moreOptions,
      maxHeightFactor: 0.78,
      actions: [
        if (!widget.isGroup)
          AppModalAction(
            icon: Icons.person_outline_rounded,
            title: l10n.viewProfile,
            onTap: onViewProfile,
          ),
        AppModalAction(
          icon: Icons.notifications_off_outlined,
          title: l10n.muteNotifications,
          onTap: () => unawaited(_muteChat()),
        ),
        AppModalAction(
          icon: Icons.flag_outlined,
          title: l10n.reportUser,
          onTap: _reportUser,
        ),
        AppModalAction(
          icon: isReceiverBlocked
              ? Icons.person_remove_outlined
              : Icons.block_rounded,
          title: isReceiverBlocked ? l10n.unblockUser : l10n.blockUser,
          isDestructive: !isReceiverBlocked,
          onTap: () {
            if (isReceiverBlocked) {
              _confirmUnblockUser();
            } else {
              _confirmBlockUser();
            }
          },
        ),
        AppModalAction(
          icon: Icons.cleaning_services_outlined,
          title: l10n.clear_chat_history,
          isDestructive: true,
          onTap: _confirmClearChatHistory,
        ),
        AppModalAction(
          icon: Icons.delete_outline_rounded,
          title: l10n.delete_conversation,
          isDestructive: true,
          onTap: _confirmDeleteConversation,
        ),
      ],
    );
  }

  void _confirmDeleteConversation() {
    final uid = currentUser?.uid;
    if (uid == null) return;
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).delete_conversation,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).deleteConversationTitle),
        content: Text(AppLocalizations.of(context).deleteConversationMessage),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();

              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .clearChat(
                      chatId: _chatId,
                      userId: uid,
                    );

                if (!mounted) return;

                context.pop();

                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).conversation_deleted,
                  type: AdaptiveSnackBarType.success,
                );
              } on Exception {
                if (!mounted) return;

                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotClearChatTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _reportUser() {
    context.push(
      AppRoutes.reportIssue.path,
      extra: {
        'reportedUserId': _receiver.uid,
        'reportedUserName': _receiver.username,
        'reportContext': 'chat',
        'chatId': _chatId,
      },
    );
  }

  void _confirmBlockUser() {
    final uid = currentUser?.uid;
    if (uid == null) return;
    if (_receiver.uid.isEmpty) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotBlockUserTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).blockUserDialogTitle,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).blockUserDialogTitle),
        content: Text(
          AppLocalizations.of(
            context,
          ).blockUserDialogMessage(_receiver.username),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .blockUser(
                      chatId: _isDraftChat ? null : _chatId,
                      userId: uid,
                      blockedUserId: _receiver.uid,
                    );
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).blockedUserSuccess(_receiver.username),
                  type: AdaptiveSnackBarType.success,
                );
                context.pop();
              } on Exception {
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotBlockUserTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).actionBlock,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmUnblockUser() {
    final uid = currentUser?.uid;
    if (uid == null) return;
    if (_receiver.uid.isEmpty) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).couldNotUnblockUserTryAgain,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).unblockUser,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).unblockUser),
        content: Text(
          AppLocalizations.of(
            context,
          ).unblockUserDialogMessage(_receiver.username),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .unblockUser(
                      chatId: _isDraftChat ? null : _chatId,
                      userId: uid,
                      blockedUserId: _receiver.uid,
                    );
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).userUnblocked,
                  type: AdaptiveSnackBarType.success,
                );
              } on Exception {
                if (!mounted) return;
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotUnblockUserTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            child: Text(AppLocalizations.of(context).actionUnblock),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: AppColors.warning, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context).youBlockedThisUser,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: _confirmUnblockUser,
            child: Text(AppLocalizations.of(context).actionUnblock),
          ),
        ],
      ),
    );
  }

  Future<void> _muteChat() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await ref
        .read(chatActionsViewModelProvider.notifier)
        .toggleMute(
          chatId: _chatId,
          userId: uid,
          mute: true,
        );
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: AppLocalizations.of(context).notificationsMutedForThisChat,
    );
  }

  void _confirmClearChatHistory() {
    final uid = currentUser?.uid;
    if (uid == null) return;
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).clear_chat_history,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).clear_chat_history),
        content: Text(AppLocalizations.of(context).clearChatHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();

              try {
                await ref
                    .read(chatActionsViewModelProvider.notifier)
                    .clearChatHistoryForUser(
                      chatId: _chatId,
                      userId: uid,
                    );

                if (!mounted) return;

                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).chatCleared,
                  type: AdaptiveSnackBarType.success,
                );
              } on Exception {
                if (!mounted) return;

                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).couldNotClearChatTryAgain,
                  type: AdaptiveSnackBarType.error,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              AppLocalizations.of(context).clear_history,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small reusable builders ──────────────────────────────────────────────

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const AdaptiveScaffold(
        body: MaxWidthContainer(
          maxWidth: kMaxWidthWide,
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    if (_receiver.uid.isEmpty && !_isResolvingReceiver) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _resolveReceiverIfNeeded(),
      );
    }

    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );
    final isReceiverBlocked =
        ref
            .watch(
              blockedUserIdsProvider(currentUser!.uid).select((a) => a.value),
            )
            ?.contains(_receiver.uid) ??
        false;

    ref.listen(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
      (prev, next) {
        if (next.messages.isNotEmpty &&
            (prev == null ||
                prev.messages.isEmpty ||
                prev.messages.first.id != next.messages.first.id)) {
          ref
              .read(
                chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
              )
              .markVisibleMessagesAsRead();
        }
      },
    );

    return AdaptiveScaffold(
      appBar: _buildAppBar(chatState, isReceiverBlocked),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthWide,
        child: Stack(
          children: [
            Column(
              children: [
                if (isReceiverBlocked) _buildBlockedBanner(),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _focusNode.unfocus();
                      ref
                          .read(
                            chatDetailViewModelProvider(
                              _chatId,
                              currentUser!.uid,
                            ).notifier,
                          )
                          .setEmojiPickerVisible(false);
                    },
                    child: chatState.isLoading
                        ? const SkeletonLoader(
                            type: SkeletonType.chatTile,
                            itemCount: 6,
                          )
                        : chatState.messages.isEmpty
                        ? _buildEmptyState()
                        : _buildMessagesList(chatState),
                  ),
                ),
                if (chatState.typingUsers.isNotEmpty) _buildTypingIndicator(),
                if (_lastFailedMessage != null) _buildFailedMessageBanner(),
                if (chatState.replyToMessage != null)
                  _buildReplyPreview(chatState.replyToMessage!),
                if (!isReceiverBlocked) _buildInputArea(),
                if (!isReceiverBlocked && chatState.showEmojiPicker)
                  SizedBox(
                    height: 280.h,
                    child: emoji_picker.EmojiPicker(
                      textEditingController: _messageController,
                      config: emoji_picker.Config(
                        height: 280.h,
                        emojiViewConfig: const emoji_picker.EmojiViewConfig(
                          backgroundColor: AppColors.cardBg,
                          columns: 8,
                        ),
                        categoryViewConfig:
                            const emoji_picker.CategoryViewConfig(
                              backgroundColor: AppColors.cardBg,
                              indicatorColor: AppColors.primary,
                              iconColor: AppColors.textTertiary,
                              iconColorSelected: AppColors.primary,
                            ),
                        bottomActionBarConfig:
                            const emoji_picker.BottomActionBarConfig(
                              enabled: false,
                            ),
                        searchViewConfig: const emoji_picker.SearchViewConfig(
                          backgroundColor: AppColors.cardBg,
                          buttonIconColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen sections ──────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              AppLocalizations.of(context).noMessagesYet,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).sendAMessageToStart,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatDetailState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      reverse: true,
      itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (chatState.isLoadingMore && index == chatState.messages.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const CircularProgressIndicator.adaptive(),
            ),
          );
        }
        final message = chatState.messages[index];
        final isMe = message.senderId == currentUser!.uid;
        final showAvatar =
            !isMe &&
            (index == chatState.messages.length - 1 ||
                chatState.messages[index + 1].senderId != message.senderId);
        return _buildMessageBubble(message, isMe, showAvatar, index);
      },
    );
  }

  AdaptiveAppBar _buildAppBar(
    ChatDetailState chatState,
    bool isReceiverBlocked,
  ) {
    // 1. Extract your custom leading button
    final customLeading = Container(
      margin: EdgeInsets.only(left: 8.w),
      child: IconButton(
        tooltip: AppLocalizations.of(context).goBackTooltip,
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.adaptive.arrow_back_rounded,
          size: 18.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );

    // 2. Extract your rich custom title (Avatar + Name + Status)
    final customTitle = Row(
      children: [
        if (_receiver.photoUrl != null)
          CircleAvatar(
            radius: 16.r,
            backgroundImage: CachedNetworkImageProvider(_receiver.photoUrl!),
          )
        else
          PremiumAvatar(name: _receiver.username, size: 32),
        SizedBox(width: 12.w),
        Expanded(
          // mainAxisSize.min + tight line heights keep the name+status block
          // within the fixed toolbar height once everything is 1.5×-scaled on
          // tablets (was overflowing the app bar by ~7px).
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _receiver.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  // Tight line heights keep the name+status block within the
                  // fixed CupertinoNavigationBar height once text is ~1.5×
                  // scaled on tablets (previously overflowed by 6px).
                  height: 1.05,
                  color: AppColors.textPrimary,
                ),
              ),
              // Only assert a status when we have a real signal (typing). There
              // is no presence/online lookup wired here, so we deliberately
              // avoid showing a permanent "Offline" label + grey dot, which
              // would be misleading dead UI.
              if (chatState.typingUsers.isNotEmpty)
                Row(
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      margin: EdgeInsets.only(right: 6.w),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).typing,
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.0,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );

    // 3. Extract your custom action button
    final customAction = Container(
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        tooltip: AppLocalizations.of(context).moreOptions,
        onPressed: () =>
            _showOptionsSheet(isReceiverBlocked: isReceiverBlocked),
        icon: Icon(
          Icons.adaptive.more_rounded,
          color: AppColors.textPrimary,
          size: 22.sp,
        ),
      ),
    );

    return AdaptiveAppBar(
      // --- NATIVE FALLBACK CONFIG ---
      // Used by iOS 26+ if useNativeToolbar is true.
      title: _receiver.username,
      leading: customLeading,
      useNativeToolbar:
          false, // Keep false to ensure your custom UI (Avatar/Status) renders on iOS
      actions: [
        // Note: Map params here based on your specific AdaptiveAppBarAction class structure
        AdaptiveAppBarAction(
          iosSymbol: 'ellipsis.circle',
          icon: Icons.more_horiz_rounded,
          onPressed: () =>
              _showOptionsSheet(isReceiverBlocked: isReceiverBlocked),
        ),
      ],

      // --- ANDROID ---
      // Wraps your exact original setup in a Material AppBar
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: customLeading,
        titleSpacing: 0,
        title: customTitle,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1.h, thickness: 1, color: AppColors.border),
        ),
        actions: [customAction],
      ),

      // --- IOS (< 26 OR useNativeToolbar: false) ---
      // Translates your custom UI to Cupertino to prevent missing features on Apple devices
      cupertinoNavigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.surface,
        padding: EdgeInsetsDirectional.zero,
        leading: customLeading,
        middle: customTitle,
        trailing: customAction,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1.h,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          PremiumAvatar(name: _receiver.username, size: 28),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const TypingDot(index: 0),
                SizedBox(width: 4.w),
                const TypingDot(index: 1),
                SizedBox(width: 4.w),
                const TypingDot(index: 2),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms);
  }

  /// Inline banner shown when the most recent send attempt failed. Visually
  /// distinguishes a failed message from a sent one (error tint + icon)
  /// and offers a quick retry without retyping.
  Widget _buildFailedMessageBanner() {
    final failed = _lastFailedMessage;
    if (failed == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.failedToSendMessage,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              _messageController
                ..text = failed.content
                ..selection = TextSelection.collapsed(
                  offset: failed.content.length,
                );
              setState(() => _lastFailedMessage = null);
              _focusNode.requestFocus();
            },
            child: Text(l10n.retry),
          ),
          IconButton(
            tooltip: l10n.dismiss,
            onPressed: () => setState(() => _lastFailedMessage = null),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(MessageModel message) {
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
    );
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).replyingToValue(message.senderName),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).clearReply,
            onPressed: notifier.clearReply,
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMe,
    bool showAvatar,
    int index,
  ) {
    return Semantics(
          label: AppLocalizations.of(
            context,
          ).messageFromLongPressOptions(message.senderName),
          child: GestureDetector(
            onLongPress: () => _showMessageOptions(message),
            child: Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    if (showAvatar)
                      PremiumAvatar(name: message.senderName, size: 32)
                    else
                      SizedBox(width: 32.w),
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.replyToContent != null)
                          ReplyIndicator(content: message.replyToContent!),
                        Container(
                          // Cap bubbles relative to the available column width
                          // instead of a fixed 300.w. On phones this stays close
                          // to the previous size; on iPad the column is up to
                          // kMaxWidthWide (900) so bubbles can use ~72% of it and
                          // no longer leave large empty gutters.
                          constraints: BoxConstraints(
                            maxWidth:
                                (MediaQuery.sizeOf(
                                          context,
                                        ).width.clamp(0.0, kMaxWidthWide) *
                                        0.72)
                                    .clamp(280.w, kMaxWidthWide * 0.72),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 9.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: isMe
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.92),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isMe ? null : AppColors.surface,
                            border: isMe
                                ? null
                                : Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.75,
                                    ),
                                  ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.r),
                              topRight: Radius.circular(20.r),
                              bottomLeft: isMe
                                  ? Radius.circular(20.r)
                                  : Radius.circular(4.r),
                              bottomRight: isMe
                                  ? Radius.circular(4.r)
                                  : Radius.circular(20.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isMe
                                    ? AppColors.primary.withValues(alpha: 0.16)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: isMe ? 6 : 4,
                                offset: Offset(0, isMe ? 2 : 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MessageContent(
                                message: message,
                                isMe: isMe,
                                onLocationTap: _openLocationInMaps,
                              ),
                              SizedBox(height: 4.h),
                              MessageMetaRow(
                                message: message,
                                isMe: isMe,
                                formattedTime: _formatTime(message.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isMe) SizedBox(width: 8.w),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 50 * (index % 5)),
        )
        .slideX(begin: isMe ? 0.1 : -0.1, curve: Curves.easeOut);
  }

  void _showMessageOptions(MessageModel message) {
    final isMe = message.senderId == currentUser!.uid;
    final notifier = ref.read(
      chatDetailViewModelProvider(_chatId, currentUser!.uid).notifier,
    );
    final l10n = AppLocalizations.of(context);

    void onReply() {
      notifier.setReplyTo(message);
      _focusNode.requestFocus();
    }

    void onCopy() {
      Clipboard.setData(ClipboardData(text: message.content));
      AdaptiveSnackBar.show(
        context,
        message: l10n.messageCopied,
      );
    }

    Future<void> onDelete() async {
      try {
        await notifier.deleteMessage(message.id);
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: l10n.thisMessageWasDeleted,
          type: AdaptiveSnackBarType.success,
        );
      } on Exception {
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: l10n.couldNotClearChatTryAgain,
          type: AdaptiveSnackBarType.error,
        );
      }
    }

    AppModalSheet.showActions<void>(
      context: context,
      title: l10n.message_options,
      maxHeightFactor: 0.6,
      actions: [
        AppModalAction(
          icon: Icons.reply_rounded,
          title: l10n.reply,
          onTap: onReply,
        ),
        AppModalAction(
          icon: Icons.copy_rounded,
          title: l10n.copy,
          onTap: onCopy,
        ),
        if (isMe && !message.isDeleted)
          AppModalAction(
            icon: Icons.edit_rounded,
            title: l10n.actionEdit,
            onTap: () => _showEditDialog(message),
          ),
        if (isMe && !message.isDeleted)
          AppModalAction(
            icon: Icons.delete_outline_rounded,
            title: l10n.actionDelete,
            isDestructive: true,
            onTap: () => unawaited(onDelete()),
          ),
      ],
    );
  }

  void _showEditDialog(MessageModel message) {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).editMessage,
      builder: (ctx) => _EditMessageDialog(
        message: message,
        chatId: _chatId,
        currentUserId: currentUser!.uid,
      ),
    );
  }

  // Firestore timestamps are UTC; render local device time in chat UI.
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    return '${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }

  // ── Input area ───────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final chatState = ref.watch(
      chatDetailViewModelProvider(_chatId, currentUser!.uid),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context).attachFile,
                onPressed: () {
                  unawaited(HapticFeedback.lightImpact());
                  _showAttachmentOptions();
                },
                icon: Icon(
                  Icons.attach_file_rounded,
                  size: 22.sp,
                  color: AppColors.textSecondary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size(44.w, 44.w),
                  maximumSize: Size(44.w, 44.w),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ListenableBuilder(
                  listenable: _focusNode,
                  builder: (context, child) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? AppColors.primary
                            : AppColors.border.withOpacity(0.4),
                        width: _focusNode.hasFocus ? 1.5 : 1,
                      ),
                      boxShadow: _focusNode.hasFocus
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : const [],
                    ),
                    child: child,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          onTap: () {
                            if (chatState.showEmojiPicker) {
                              ref
                                  .read(
                                    chatDetailViewModelProvider(
                                      _chatId,
                                      currentUser!.uid,
                                    ).notifier,
                                  )
                                  .setEmojiPickerVisible(false);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).typeAMessage,
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(
                              16.w,
                              10.h,
                              4.w,
                              10.h,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      IconButton(
                        tooltip: chatState.showEmojiPicker
                            ? AppLocalizations.of(context).showKeyboard
                            : AppLocalizations.of(context).showEmojiPicker,
                        onPressed: _toggleEmojiPicker,
                        icon: Icon(
                          chatState.showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_rounded,
                          size: 22.sp,
                        ),
                        color: chatState.showEmojiPicker
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.fromLTRB(4.w, 8.h, 12.w, 8.h),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  final isSending = chatState.isSending;
                  final showPrimary = hasText;
                  return Semantics(
                    button: true,
                    label: AppLocalizations.of(context).sendMessage,
                    child: GestureDetector(
                      onTap: () {
                        if (hasText && !isSending) {
                          _sendMessage();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(11.w),
                        decoration: BoxDecoration(
                          gradient: showPrimary
                              ? AppColors.primaryGradient
                              : null,
                          color: showPrimary ? null : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: showPrimary
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.26,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : const [],
                        ),
                        // While a send is in flight, swap the icon for a small
                        // spinner and ignore taps so the UI isn't inert
                        // between tapping send and the message appearing.
                        child: isSending
                            ? SizedBox(
                                width: 22.sp,
                                height: 22.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    showPrimary
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: showPrimary
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                size: 22.sp,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAttachmentOptions() async {
    final l10n = AppLocalizations.of(context);
    await AppModalSheet.showActions<void>(
      context: context,
      title: l10n.attachments,
      maxHeightFactor: 0.56,
      description: l10n.choose_what_you_want_to_share_in_this_chat,
      actions: [
        AppModalAction(
          icon: Icons.camera_alt_rounded,
          title: l10n.camera,
          accentColor: const Color(0xFFE91E63),
          onTap: () => unawaited(_sendImageFromSource(ImageSource.camera)),
        ),
        AppModalAction(
          icon: Icons.photo_rounded,
          title: l10n.gallery,
          accentColor: const Color(0xFF9C27B0),
          onTap: () => unawaited(_sendImageFromSource(ImageSource.gallery)),
        ),
        AppModalAction(
          icon: Icons.location_on_rounded,
          title: l10n.location,
          accentColor: const Color(0xFF4CAF50),
          onTap: () => unawaited(_shareLocation()),
        ),
      ],
    );
  }

  // Check location/service permissions before showing a blocking progress dialog.
  Future<void> _shareLocation() async {
    final l10n = AppLocalizations.of(context);

    final accepted = await PermissionDialogHelper.showLocationSharingRationale(
      context,
    );
    if (!accepted) return;
    if (!mounted) return;

    final svc = ref.read(locationServiceProvider);
    if (!await svc.isServiceEnabled()) {
      if (!mounted) return;
      _showLocationError(l10n.pleaseEnableLocationServices);
      return;
    }
    if (!await svc.checkPermission()) {
      final granted = await svc.requestPermission();
      if (!granted) {
        if (!mounted) return;
        _showLocationError(l10n.locationPermissionRequired);
        return;
      }
    }

    if (!await _ensurePersistedChat()) return;
    if (!mounted) return;

    // Do not await this dialog; it is dismissed programmatically below.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.gettingYourLocation,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      if (!mounted) return;
      if (position == null) {
        Navigator.of(context).pop();
        _showLocationError(l10n.couldNotGetYourLocation);
        return;
      }

      final locationName =
          await ref
              .read(locationServiceProvider)
              .getAddressFromCoordinates(
                position.latitude,
                position.longitude,
              ) ??
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog.

      final success = await ref
          .read(
            chatDetailViewModelProvider(
              _chatId,
              currentUser?.uid ?? '',
            ).notifier,
          )
          .sendLocationMessage(
            content: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
            senderName:
                currentUser?.username ?? AppLocalizations.of(context).user,
            senderPhotoUrl: currentUser?.photoUrl,
          );

      if (success && mounted) {
        unawaited(HapticFeedback.lightImpact());
        _showStatusSnackBar(
          l10n.locationShared,
          type: AdaptiveSnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showLocationError(l10n.failedToGetLocationValue(e.toString()));
    }
  }

  void _showLocationError(String message) {
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
      duration: const Duration(seconds: 3),
      action: AppLocalizations.of(context).settings,
      onActionPressed: () =>
          ref.read(locationServiceProvider).openLocationSettings(),
    );
  }

  Future<void> _openLocationInMaps(double lat, double lng, String label) async {
    unawaited(HapticFeedback.lightImpact());
    final encodedLabel = Uri.encodeComponent(label.replaceFirst('📍 ', ''));
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
    );
    final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');

    try {
      var launched = false;
      if (Platform.isAndroid) {
        if (await canLaunchUrl(geoUrl)) launched = await launchUrl(geoUrl);
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      } else if (Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          launched = await launchUrl(
            appleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
        if (!launched && await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        if (await canLaunchUrl(googleMapsUrl)) {
          launched = await launchUrl(
            googleMapsUrl,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      if (!launched && mounted) {
        await Clipboard.setData(ClipboardData(text: '$lat, $lng'));
        if (!mounted) return;
        _showStatusSnackBar(
          AppLocalizations.of(context).coordinatesCopiedToClipboard,
          type: AdaptiveSnackBarType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      _showStatusSnackBar(
        AppLocalizations.of(context).couldNotOpenMapsValue(e),
        type: AdaptiveSnackBarType.error,
      );
    }
  }
}

/// Stateful dialog that owns the TextEditingController used in the
/// edit-message flow. Replaces the previous inline `TextEditingController`
/// created inside `showDialog`'s builder, which leaked whenever the user
/// dismissed the dialog via tap-outside or back gesture (the controller was
/// never disposed).
class _EditMessageDialog extends ConsumerStatefulWidget {
  const _EditMessageDialog({
    required this.message,
    required this.chatId,
    required this.currentUserId,
  });

  final MessageModel message;
  final String chatId;
  final String currentUserId;

  @override
  ConsumerState<_EditMessageDialog> createState() =>
      _EditMessageDialogState();
}

class _EditMessageDialogState extends ConsumerState<_EditMessageDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newContent = _controller.text.trim();
    if (newContent.isEmpty || newContent == widget.message.content) {
      // Reject empty/whitespace-only edits (defensive — view-model may not
      // enforce this) and avoid an unnecessary VM round-trip when nothing
      // changed.
      Navigator.of(context).pop();
      return;
    }
    await ref
        .read(
          chatDetailViewModelProvider(
            widget.chatId,
            widget.currentUserId,
          ).notifier,
        )
        .editMessage(widget.message.id, newContent);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
      ),
      title: Text(AppLocalizations.of(context).editMessage),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: null,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).actionCancel),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(
            AppLocalizations.of(context).actionSave,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
