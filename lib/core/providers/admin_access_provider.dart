import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

/// Resolves whether the currently authenticated user has admin/support access.
///
/// Watches [currentAuthUidProvider] so the claims are re-evaluated on every
/// sign-in / sign-out / token refresh. Without this dependency the result would
/// be cached for the app lifetime and stale admin claims could leak across
/// account switches.
///
/// Forces an ID token refresh ([getIdTokenResult] with `forceRefresh: true`) so
/// that custom claims granted server-side (admin/support/refunds) are picked up
/// immediately rather than waiting for Firebase's ~hourly automatic refresh.
/// Invalidate this provider after a privilege change to re-run the check.
final adminAccessProvider = FutureProvider<bool>((ref) async {
  final uid = await ref.watch(currentAuthUidProvider.future);
  if (uid == null) return false;

  final user = ref.read(firebaseServiceProvider).auth.currentUser;
  if (user == null) return false;

  final token = await user.getIdTokenResult(true);
  final claims = token.claims ?? const <String, dynamic>{};

  return claims['admin'] == true ||
      claims['support'] == true ||
      claims['refunds'] == true ||
      claims['role'] == 'admin' ||
      claims['role'] == 'support';
});
