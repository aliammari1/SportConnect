import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';

part 'notification_view_model.g.dart';

/// State for managing notifications UI
class NotificationState {
  const NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedNotificationIds = const [],
    this.filter = NotificationFilter.all,
    this.userId,
  });
  final bool isLoading;
  final String? errorMessage;
  final List<String> selectedNotificationIds;
  final NotificationFilter filter;

  /// The UID of the currently authenticated user; null when signed out.
  final String? userId;

  NotificationState copyWith({
    bool? isLoading,
    // Use the [_Unset] sentinel so callers that do not pass errorMessage
    // preserve the current value, while clearError can explicitly set null.
    Object? errorMessage = _unset,
    List<String>? selectedNotificationIds,
    NotificationFilter? filter,
    String? userId,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      selectedNotificationIds:
          selectedNotificationIds ?? this.selectedNotificationIds,
      filter: filter ?? this.filter,
      userId: userId ?? this.userId,
    );
  }
}

/// Private sentinel for the [NotificationState.copyWith] errorMessage param.
const Object _unset = Object();

/// Filter options for notifications
enum NotificationFilter { all, unread, rides, payments, messages }

/// ViewModel for notifications screen
@riverpod
class NotificationViewModel extends _$NotificationViewModel {
  @override
  NotificationState build() {
    // Watch auth state — infrequent (login/logout only), safe to use ref.watch.
    // When auth changes, build() re-runs and all transient state (selection,
    // filter) is intentionally reset, which is the correct behaviour.
    final userId = ref.watch(currentAuthUidProvider).value;

    // The notifications stream is consumed directly by the UI via
    // `ref.watch(userNotificationsProvider)`; this notifier only owns transient
    // UI state (selection, filter, loading, errors) and actions. Mirroring the
    // stream here would observe it twice and risk drifting from the provider.
    return NotificationState(userId: userId);
  }

  /// Force-refresh the notifications stream.
  void refresh() {
    ref.invalidate(userNotificationsProvider);
  }

  String? _getCurrentUserId() {
    return ref.read(currentAuthUidProvider).value;
  }

  /// Set filter
  void setFilter(NotificationFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(notificationId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to mark as read: $e',
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(userId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to mark all as read: $e',
      );
    }
  }

  /// Archive all notifications for current user
  Future<void> archiveAll() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.archiveAll(userId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear notifications: $e',
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.archiveNotification(notificationId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete notification: $e',
      );
    }
  }

  /// Toggle selection for batch operations
  void toggleSelection(String notificationId) {
    final currentSelection = List<String>.from(state.selectedNotificationIds);
    if (currentSelection.contains(notificationId)) {
      currentSelection.remove(notificationId);
    } else {
      currentSelection.add(notificationId);
    }
    state = state.copyWith(selectedNotificationIds: currentSelection);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(selectedNotificationIds: []);
  }

  /// Delete selected notifications atomically via a Firestore batch write.
  Future<void> deleteSelected() async {
    if (state.selectedNotificationIds.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.archiveSelected(
        List<String>.from(state.selectedNotificationIds),
      );
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, selectedNotificationIds: []);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete notifications: $e',
      );
    }
  }

  /// Clear error message explicitly.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Stream provider for user notifications
@riverpod
Stream<List<NotificationModel>> userNotifications(Ref ref) {
  final userId = ref.watch(currentAuthUidProvider).value;
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUserNotifications(userId);
}
