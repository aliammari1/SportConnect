import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'email_verification_view_model.g.dart';

class EmailVerificationState {
  const EmailVerificationState({
    this.isEmailVerified = false,
    this.isSending = false,
    this.resendCooldown = 0,
    this.userEmail = '',
    this.errorMessage,
  });

  final bool isEmailVerified;
  final bool isSending;
  final int resendCooldown;
  final String userEmail;
  final String? errorMessage;

  EmailVerificationState copyWith({
    bool? isEmailVerified,
    bool? isSending,
    int? resendCooldown,
    String? userEmail,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmailVerificationState(
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isSending: isSending ?? this.isSending,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class EmailVerificationViewModel extends _$EmailVerificationViewModel {
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  var _isCheckingVerification = false;
  var _started = false;
  // Exponential backoff state: starts at 3 s, doubles up to 30 s.
  static const _minPollSeconds = 3;
  static const _maxPollSeconds = 30;
  var _currentPollSeconds = _minPollSeconds;

  @override
  EmailVerificationState build() {
    // Keep build() pure: only register disposal and read the initial email.
    // Polling and the initial verification check are started lazily via
    // start() from the screen, to avoid self-scheduling side effects during
    // build that can re-run on rebuild.
    ref.onDispose(_cancelTimers);

    final userEmail =
        ref.read(authActionsViewModelProvider.notifier).currentUser?.email ??
        '';

    return EmailVerificationState(userEmail: userEmail);
  }

  /// Start polling and run the initial verification check.
  ///
  /// Idempotent: safe to call from the screen on every rebuild; the work only
  /// runs once per notifier lifetime.
  void start() {
    if (_started) return;
    _started = true;

    _startPolling();

    scheduleMicrotask(() {
      if (ref.mounted) {
        unawaited(checkEmailVerified());
      }
    });
  }

  void _cancelTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;

    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _currentPollSeconds = _minPollSeconds;
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer(
      Duration(seconds: _currentPollSeconds),
      () async {
        await checkEmailVerified();
        if (ref.mounted && !state.isEmailVerified) {
          // Double the interval, capped at the max, for exponential backoff.
          _currentPollSeconds =
              (_currentPollSeconds * 2).clamp(_minPollSeconds, _maxPollSeconds);
          _scheduleNextPoll();
        }
      },
    );
  }

  Future<void> checkEmailVerified({bool showErrors = false}) async {
    if (_isCheckingVerification || !ref.mounted) return;

    _isCheckingVerification = true;

    try {
      final authActions = ref.read(authActionsViewModelProvider.notifier);
      final user = authActions.currentUser;

      if (user == null) {
        // No signed-in user (e.g. token revoked / signed out elsewhere). Stop
        // the poll timer so it does not reschedule forever doing useless work.
        _pollTimer?.cancel();
        _pollTimer = null;
        return;
      }

      await authActions.reloadUser();
      if (!ref.mounted) return;

      final verified = await authActions.isEmailVerified();
      if (!ref.mounted || !verified) return;

      _pollTimer?.cancel();
      _pollTimer = null;

      ref.invalidate(authStateProvider);

      state = state.copyWith(
        isEmailVerified: true,
        clearError: true,
      );
    } on Exception catch (e, st) {
      TalkerService.debug('Email verification check error: $e\n$st');

      if (showErrors && ref.mounted) {
        state = state.copyWith(errorMessage: userFacingError(e));
      }
    } finally {
      _isCheckingVerification = false;
    }
  }

  Future<void> resendVerification() async {
    if (state.resendCooldown > 0 || state.isSending) return;

    state = state.copyWith(
      isSending: true,
      clearError: true,
    );

    try {
      await ref
          .read(authActionsViewModelProvider.notifier)
          .sendEmailVerification();

      if (!ref.mounted) return;

      state = state.copyWith(
        isSending: false,
        resendCooldown: 60,
        clearError: true,
      );

      _startCooldown();
    } on Exception catch (e, st) {
      TalkerService.debug('Email verification resend error: $e\n$st');

      if (!ref.mounted) return;

      state = state.copyWith(
        isSending: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  Future<void> signOut() {
    _cancelTimers();
    return ref.read(authActionsViewModelProvider.notifier).signOut();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        return;
      }

      final nextCooldown = state.resendCooldown - 1;
      final safeCooldown = nextCooldown < 0 ? 0 : nextCooldown;

      state = state.copyWith(resendCooldown: safeCooldown);

      if (safeCooldown == 0) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
      }
    });
  }
}
