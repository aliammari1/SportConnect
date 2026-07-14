import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';

part 'notification_preferences_view_model.g.dart';

/// State for the notification preferences screen.
class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.userId,
    this.preferences = const AsyncLoading(),
    this.isSaving = false,
    this.errorMessage,
  });

  /// The UID of the currently authenticated user; null when signed out.
  final String? userId;

  /// Live preferences, driven via [ref.listen] on the Firestore stream.
  final AsyncValue<NotificationPreferences> preferences;

  /// True while a toggle/time change is being written to Firestore.
  final bool isSaving;

  /// Set when the most recent save failed; cleared via [clearError].
  final String? errorMessage;

  NotificationPreferencesState copyWith({
    String? userId,
    AsyncValue<NotificationPreferences>? preferences,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationPreferencesState(
      userId: userId ?? this.userId,
      preferences: preferences ?? this.preferences,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Stream provider for a user's notification preferences.
@riverpod
Stream<NotificationPreferences> notificationPreferencesStream(
  Ref ref,
  String userId,
) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamPreferences(userId);
}

/// ViewModel backing the notification preferences screen: exposes the live
/// preferences plus per-field setters that persist to Firestore.
@riverpod
class NotificationPreferencesViewModel
    extends _$NotificationPreferencesViewModel {
  @override
  NotificationPreferencesState build() {
    // Watch auth state — infrequent (login/logout only), safe to use ref.watch.
    final userId = ref.watch(currentAuthUidProvider).value;

    // Subscribe via ref.listen so incoming Firestore emissions update state
    // without re-running build() (which would otherwise reset isSaving).
    if (userId != null) {
      ref.listen(notificationPreferencesStreamProvider(userId), (_, next) {
        state = state.copyWith(preferences: next);
      });
    }

    return NotificationPreferencesState(
      userId: userId,
      preferences: userId != null
          ? ref.read(notificationPreferencesStreamProvider(userId))
          : const AsyncData(NotificationPreferences()),
    );
  }

  /// Applies [transform] to the current preferences, optimistically updates
  /// the UI, and persists the result. On failure, reverts to the
  /// pre-optimistic value and surfaces [errorMessage] so the caller can show
  /// a visible error instead of silently no-oping.
  Future<void> _update(
    NotificationPreferences Function(NotificationPreferences current)
    transform,
  ) async {
    final userId = state.userId;
    if (userId == null) return;

    final previous = state.preferences;
    final current = previous.value ?? const NotificationPreferences();
    final updated = transform(current);

    state = state.copyWith(
      preferences: AsyncData(updated),
      isSaving: true,
      clearError: true,
    );

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.updatePreferences(userId, updated);
      if (!ref.mounted) return;
      state = state.copyWith(isSaving: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        preferences: previous,
        isSaving: false,
        errorMessage: 'Failed to save notification preferences: $e',
      );
    }
  }

  Future<void> setPushEnabled(bool value) =>
      _update((p) => p.copyWith(pushEnabled: value));

  Future<void> setRideNotifications(bool value) =>
      _update((p) => p.copyWith(rideNotifications: value));

  Future<void> setMessageNotifications(bool value) =>
      _update((p) => p.copyWith(messageNotifications: value));

  Future<void> setSocialNotifications(bool value) =>
      _update((p) => p.copyWith(socialNotifications: value));

  Future<void> setGamificationNotifications(bool value) =>
      _update((p) => p.copyWith(gamificationNotifications: value));

  Future<void> setPromotionNotifications(bool value) =>
      _update((p) => p.copyWith(promotionNotifications: value));

  Future<void> setEmailEnabled(bool value) =>
      _update((p) => p.copyWith(emailEnabled: value));

  Future<void> setEmailRideSummary(bool value) =>
      _update((p) => p.copyWith(emailRideSummary: value));

  Future<void> setEmailWeeklyDigest(bool value) =>
      _update((p) => p.copyWith(emailWeeklyDigest: value));

  Future<void> setQuietHoursEnabled(bool value) =>
      _update((p) => p.copyWith(quietHoursEnabled: value));

  Future<void> setQuietHoursStart(String value) =>
      _update((p) => p.copyWith(quietHoursStart: value));

  Future<void> setQuietHoursEnd(String value) =>
      _update((p) => p.copyWith(quietHoursEnd: value));

  Future<void> setSoundEnabled(bool value) =>
      _update((p) => p.copyWith(soundEnabled: value));

  Future<void> setVibrationEnabled(bool value) =>
      _update((p) => p.copyWith(vibrationEnabled: value));

  /// Clear the current error message explicitly (e.g. after showing it).
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
