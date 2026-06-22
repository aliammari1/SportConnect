import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

part 'user_providers.g.dart';

/// Auth state changes provider (Firebase User)
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(firebaseServiceProvider).auth.userChanges();
}

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.
@Riverpod(keepAlive: true)
Stream<UserModel?> currentUser(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  final uid = await ref.watch(currentAuthUidProvider.future);

  if (uid == null) {
    yield null;
    return;
  }

  // The router treats this stream sitting in `loading` (a signed-in Firebase
  // user with no profile value/error yet) as `isFirestoreStillLoading` and
  // refuses to navigate — so if the very first snapshot never arrives (a
  // blocked App Check token, an unreachable backend) the app is stranded on an
  // infinite loading spinner (App Store 2.1). Cap only the FIRST emission: a
  // healthy snapshots() listener emits once and then stays idle indefinitely,
  // so idle timeouts after the first value are ignored to keep live updates
  // flowing. On a first-emission timeout we surface an error, which unblocks
  // the router (it falls back to the login screen) instead of hanging.
  var hasEmitted = false;
  yield* repository
      .getUserDataStream(uid)
      .map((user) {
        hasEmitted = true;
        return user;
      })
      .timeout(
        const Duration(seconds: 20),
        onTimeout: (sink) {
          if (!hasEmitted) {
            sink
              ..addError(
                TimeoutException('Loading your profile took too long.'),
              )
              ..close();
          }
        },
      );
}

@Riverpod(keepAlive: true)
Future<String?> currentAuthUid(Ref ref) {
  return ref.watch(
    authStateProvider.selectAsync((user) => user?.uid),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium metadata (plan + date — not in freezed model)
// ─────────────────────────────────────────────────────────────────────────────

class PremiumMetadata {
  const PremiumMetadata({
    required this.isPremium,
    this.plan,
    this.updatedAt,
  });
  final bool isPremium;
  final String? plan; // 'monthly' | 'yearly'
  final DateTime? updatedAt;
}

/// Derived from [currentUserProvider] — no extra Firestore listener.
///
/// Premium state (isPremium / premiumPlan / premiumUpdatedAt) now lives on
/// [UserModel], so this reuses the single shared user-document listener instead
/// of opening a second snapshot on users/{uid}. That removes the divergence
/// window where the two listeners could momentarily disagree. The provider keeps
/// returning a [Stream] so existing [AsyncValue] consumers are unaffected.
@riverpod
Stream<PremiumMetadata> premiumMetadata(Ref ref) async* {
  // Re-runs whenever the shared currentUser stream emits a new value, so this
  // stays in lock-step with the single user-document listener.
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const PremiumMetadata(isPremium: false);
    return;
  }
  yield PremiumMetadata(
    isPremium: user.isPremiumUser,
    plan: user.premiumPlan,
    updatedAt: user.premiumUpdatedAt,
  );
}

/// Pending user's selected role intent during onboarding setup.
///
/// Derived from [currentUserProvider] — no extra Firestore listener.
@Riverpod(keepAlive: true)
UserRole? selectedRoleIntent(Ref ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user is! PendingUserModel) return null;
  return switch (user.selectedRoleIntent) {
    'rider' => UserRole.rider,
    'driver' => UserRole.driver,
    _ => null,
  };
}
