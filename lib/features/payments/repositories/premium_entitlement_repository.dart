import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

part 'premium_entitlement_repository.g.dart';

/// Outcome of server-side purchase verification.
class PremiumVerificationResult {
  const PremiumVerificationResult({required this.isActive, this.platformState});

  /// True when the store reports an entitled subscription and the callable
  /// flipped [isPremium] on the user document.
  final bool isActive;

  /// Raw store-side state label (e.g. SUBSCRIPTION_STATE_ACTIVE, APPLE_STATUS_1).
  final String? platformState;
}

/// Expected (recoverable) verification failures surfaced to callers.
class PremiumEntitlementException implements Exception {
  const PremiumEntitlementException(this.message);

  final String message;

  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
PremiumEntitlementRepository premiumEntitlementRepository(Ref ref) {
  return PremiumEntitlementRepository(
    ref.watch(firebaseServiceProvider).functions,
  );
}

/// Client for the `verifyPremiumPurchase` Cloud Function.
///
/// Entitlement writes happen server-side only (firestore.rules pins isPremium
/// on user docs); this repository forwards opaque store receipt references and
/// maps transport errors into [PremiumEntitlementException].
class PremiumEntitlementRepository {
  PremiumEntitlementRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<PremiumVerificationResult> verifyPurchase({
    required String platform,
    String? purchaseToken,
    String? transactionId,
  }) async {
    try {
      final callable = _functions.httpsCallable('verifyPremiumPurchase');
      final response = await callable.call<dynamic>({
        'platform': platform,
        if (purchaseToken != null && purchaseToken.isNotEmpty)
          'purchaseToken': purchaseToken,
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
      });

      final data = Map<String, dynamic>.from(response.data as Map<dynamic, dynamic>);
      return PremiumVerificationResult(
        isActive: data['status'] == 'active',
        platformState: data['platformState'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw PremiumEntitlementException(
        e.message ?? e.code.replaceAll('_', ' '),
      );
    }
  }
}
