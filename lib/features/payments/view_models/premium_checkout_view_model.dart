import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';

part 'premium_checkout_view_model.g.dart';

class PremiumCheckoutState {
  const PremiumCheckoutState({
    this.selectedPlan = PremiumPlan.monthly,
    this.isProcessing = false,
    this.isCompleted = false,
    this.errorMessage,
  });

  final PremiumPlan selectedPlan;
  final bool isProcessing;
  final bool isCompleted;
  final String? errorMessage;

  PremiumCheckoutState copyWith({
    PremiumPlan? selectedPlan,
    bool? isProcessing,
    bool? isCompleted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumCheckoutState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isProcessing: isProcessing ?? this.isProcessing,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class PremiumCheckoutViewModel extends _$PremiumCheckoutViewModel {
  @override
  PremiumCheckoutState build() {
    return const PremiumCheckoutState();
  }

  void selectPlan(PremiumPlan plan) {
    if (state.isProcessing || plan == state.selectedPlan) return;

    state = state.copyWith(
      selectedPlan: plan,
      isCompleted: false,
      clearError: true,
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;

    state = state.copyWith(clearError: true);
  }

  Future<bool> completeCheckout() async {
    if (state.isProcessing) return false;

    final currentUser = ref.read(currentUserProvider).value;

    if (currentUser == null) {
      state = state.copyWith(
        errorMessage: 'Please sign in and try again.',
      );
      return false;
    }

    final selectedPlan = state.selectedPlan;

    state = state.copyWith(
      isProcessing: true,
      isCompleted: false,
      clearError: true,
    );

    try {
      final iapService = ref.read(premiumIapServiceProvider.notifier);

      final isIapSupported = await iapService.isSupported();

      if (!ref.mounted) return false;

      if (!isIapSupported) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage:
              'In-app purchases are not available on this device right now. '
              'Please try again later.',
        );
        return false;
      }

      final purchaseResult = await iapService.purchasePlan(selectedPlan);

      if (!ref.mounted) return false;

      if (!purchaseResult.isSuccess) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage:
              purchaseResult.errorMessage ??
              'Unable to complete purchase. Please try again.',
        );
        return false;
      }

      final purchase = purchaseResult.purchase;
      final premiumTransactionId = purchase?.purchaseID;
      final verificationPayload =
          purchase?.verificationData.serverVerificationData;

      await _syncStripeCustomer(currentUser);

      if (!ref.mounted) return false;

      await ref.read(profileRepositoryProvider).updateProfile(
        currentUser.uid,
        {
          'premiumEntitlementStatus': 'pending_server_verification',
          'premiumPlan': selectedPlan.name,
          'premiumSource': 'iap',
          'premiumPlatform': purchase?.verificationData.source,
          'premiumProductId': purchase?.productID,
          'premiumPurchaseStatus': purchase?.status.name,
          'premiumPurchaseVerificationRequired': true,
          'premiumUpdatedAt': FieldValue.serverTimestamp(),

          // Useful for debugging Google Play subscriptions with multiple
          // base plans under one subscription product.
          'premiumGooglePlayBasePlanId': selectedPlan.googlePlayBasePlanId,

          if (premiumTransactionId != null && premiumTransactionId.isNotEmpty)
            'premiumTransactionId': premiumTransactionId,

          if (verificationPayload != null && verificationPayload.isNotEmpty)
            'premiumVerificationPayload': verificationPayload,
        },
      );

      if (!ref.mounted) return false;

      ref.invalidate(currentUserProvider);

      state = state.copyWith(
        isProcessing: false,
        isCompleted: true,
        clearError: true,
      );

      return true;
    } on Exception catch (e, st) {
      TalkerService.error('Premium checkout failed', e, st);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        errorMessage: _friendlyCheckoutError(e),
      );

      return false;
    }
  }

  Future<void> _syncStripeCustomer(UserModel currentUser) async {
    try {
      final existingCustomerId = currentUser is RiderModel
          ? currentUser.stripeCustomerId
          : null;

      await ref
          .read(stripeServiceProvider)
          .getOrCreateCustomer(
            userId: currentUser.uid,
            email: currentUser.email,
            name: currentUser.username,
            phone: switch (currentUser) {
              final RiderModel rider => rider.phoneNumber,
              _ => null,
            },
            existingCustomerId: existingCustomerId,
          );
    } on Exception catch (e, st) {
      // Keep premium activation successful even if Stripe metadata sync fails.
      TalkerService.warning(
        'Premium purchase succeeded but Stripe customer sync failed: $e',
      );
      TalkerService.error('Stripe customer sync error', e, st);
    }
  }

  String _friendlyCheckoutError(Object error) {
    final message = error.toString().replaceFirst('Bad state: ', '').trim();

    if (message.isEmpty) {
      return 'Unable to complete checkout. Please try again.';
    }

    return message;
  }
}
