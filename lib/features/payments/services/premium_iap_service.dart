import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/repositories/premium_entitlement_repository.dart';

part 'premium_iap_service.g.dart';

class PremiumIapResult {
  const PremiumIapResult._({
    required this.isSuccess,
    this.errorMessage,
    this.purchase,
  });

  const PremiumIapResult.success({PurchaseDetails? purchase})
    : this._(isSuccess: true, purchase: purchase);

  const PremiumIapResult.failure(String message)
    : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
  final PurchaseDetails? purchase;
}

@Riverpod(keepAlive: true)
class PremiumIapService extends _$PremiumIapService {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Completers keyed by product ID, waiting for a purchase result.
  final _pendingPurchases = <String, Completer<PremiumIapResult>>{};

  @override
  void build() {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: _onPurchaseStreamError,
    );
    ref.onDispose(() => _purchaseSubscription?.cancel());
  }

  InAppPurchase get _iap => InAppPurchase.instance;

  Future<bool> isSupported() async {
    if (kIsWeb) return false;

    final isIosOrAndroid =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (!isIosOrAndroid) return false;

    return _iap.isAvailable();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      try {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            continue;

          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }

            final verified = _hasVerificationPayload(purchase);
            if (!verified) {
              _pendingPurchases
                  .remove(purchase.productID)
                  ?.complete(
                    const PremiumIapResult.failure(
                      'Purchase verification failed. Please contact support.',
                    ),
                  );
              continue;
            }

            _pendingPurchases
                .remove(purchase.productID)
                ?.complete(
                  PremiumIapResult.success(purchase: purchase),
                );

          case PurchaseStatus.error:
            _pendingPurchases
                .remove(purchase.productID)
                ?.complete(
                  PremiumIapResult.failure(
                    purchase.error?.message ??
                        'Your purchase could not be completed. Please try again.',
                  ),
                );

          case PurchaseStatus.canceled:
            _pendingPurchases
                .remove(purchase.productID)
                ?.complete(
                  const PremiumIapResult.failure('Purchase cancelled by user.'),
                );
        }
      } on PlatformException catch (e) {
        _pendingPurchases
            .remove(purchase.productID)
            ?.complete(
              PremiumIapResult.failure(_mapPlatformError(e)),
            );
      } on MissingPluginException {
        _pendingPurchases
            .remove(purchase.productID)
            ?.complete(
              const PremiumIapResult.failure(
                'In-app purchase plugin is not ready. Fully restart the app and try again.',
              ),
            );
      } on Object catch (e) {
        _pendingPurchases
            .remove(purchase.productID)
            ?.complete(
              PremiumIapResult.failure(
                'Purchase handling failed unexpectedly: $e',
              ),
            );
      }
    }
  }

  void _onPurchaseStreamError(Object error) {
    for (final completer in _pendingPurchases.values) {
      if (!completer.isCompleted) {
        completer.complete(
          PremiumIapResult.failure('Purchase stream error: $error'),
        );
      }
    }
    _pendingPurchases.clear();
  }

  /// Fetches the available store plans for the current platform.
  ///
  /// Android:
  /// Queries the Google Play subscription product ID once, then maps returned
  /// base plans by [SubscriptionOfferDetailsWrapper.basePlanId].
  ///
  /// iOS:
  /// Queries the separate App Store product IDs.
  Future<Map<PremiumPlan, ProductDetails>> fetchAvailablePlans() async {
    if (!await isSupported()) {
      throw StateError(
        'In-app purchases are only available on iOS and Android.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _fetchAndroidAvailablePlans();
    }

    return _fetchAppleAvailablePlans();
  }

  Future<Map<PremiumPlan, ProductDetails>> _fetchAndroidAvailablePlans() async {
    final productId = PremiumPlan.monthly.googlePlayProductId;

    final response = await _iap.queryProductDetails({productId});

    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    if (response.productDetails.isEmpty ||
        response.notFoundIDs.contains(productId)) {
      throw StateError(
        'Play Store could not find the subscription "$productId". '
        'Make sure the app is installed from the Internal Testing track '
        'and your Google account is added as a tester in Play Console.',
      );
    }

    final result = <PremiumPlan, ProductDetails>{};

    for (final product
        in response.productDetails.whereType<GooglePlayProductDetails>()) {
      final offer = _subscriptionOfferFor(product);

      if (offer == null) continue;

      for (final plan in PremiumPlan.values) {
        if (offer.basePlanId == plan.googlePlayBasePlanId) {
          // Prefer the base-plan-only offer (no offerId) so we don't
          // accidentally select a promotional offer token for the purchase.
          if (!result.containsKey(plan) || offer.offerId == null) {
            result[plan] = product;
          }
        }
      }
    }

    if (result.isEmpty) {
      throw StateError(
        'Google Play returned "$productId", but no matching base plans were found. '
        'Expected base plans: '
        '${PremiumPlan.values.map((plan) => plan.googlePlayBasePlanId).join(', ')}.',
      );
    }

    return result;
  }

  Future<Map<PremiumPlan, ProductDetails>> _fetchAppleAvailablePlans() async {
    final productIds = PremiumPlan.values
        .map((plan) => plan.iosProductId)
        .toSet();

    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      throw StateError(response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      throw StateError(
        'No App Store subscription products were found: ${productIds.join(', ')}',
      );
    }

    final result = <PremiumPlan, ProductDetails>{};

    for (final plan in PremiumPlan.values) {
      final product = response.productDetails
          .where((product) => product.id == plan.iosProductId)
          .cast<ProductDetails?>()
          .firstOrNull;

      if (product != null) {
        result[plan] = product;
      }
    }

    if (result.isEmpty) {
      throw StateError(
        'No matching App Store subscription products were found. '
        'Expected: ${productIds.join(', ')}.',
      );
    }

    return result;
  }

  Future<PremiumIapResult> purchasePlan(PremiumPlan plan) async {
    try {
      if (!await isSupported()) {
        return const PremiumIapResult.failure(
          'In-app purchases are only available on iOS and Android.',
        );
      }

      final productId = plan.iapProductId;
      final response = await _iap.queryProductDetails({productId});

      if (response.error != null) {
        return PremiumIapResult.failure(response.error!.message);
      }

      if (response.productDetails.isEmpty ||
          response.notFoundIDs.contains(productId)) {
        return PremiumIapResult.failure(
          'Subscription product is not configured or not available: $productId',
        );
      }

      final product = _selectProductForPlan(response.productDetails, plan);
      final purchaseParam = _createPurchaseParam(product: product, plan: plan);

      final completer = Completer<PremiumIapResult>();
      _pendingPurchases[productId] = completer;

      final timeout = Timer(const Duration(minutes: 3), () {
        final c = _pendingPurchases.remove(productId);
        if (c != null && !c.isCompleted) {
          c.complete(
            const PremiumIapResult.failure(
              'Purchase timed out. Please try again.',
            ),
          );
        }
      });

      final launched = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!launched) {
        timeout.cancel();
        _pendingPurchases
            .remove(productId)
            ?.complete(
              const PremiumIapResult.failure(
                'Could not launch store purchase flow.',
              ),
            );
      }

      return completer.future;
    } on PlatformException catch (e) {
      return PremiumIapResult.failure(_mapPlatformError(e));
    } on MissingPluginException {
      return const PremiumIapResult.failure(
        'In-app purchase plugin is not ready. Fully restart the app and try again.',
      );
    } on Object catch (e) {
      return PremiumIapResult.failure(
        'In-app purchase failed unexpectedly: $e',
      );
    }
  }

  /// Sentinel used when no store event resolves a registered restore
  /// completer within the window; filtered before any message reaches users.
  static const String _kNothingRestored = '__nothing_restored__';

  /// Re-fetches previously owned purchases from the store and re-runs server
  /// verification on each one. Entitlement flips here — the store-side
  /// restore itself never writes anything locally.
  Future<PremiumIapResult> restorePurchases() async {
    try {
      if (!await isSupported()) {
        return const PremiumIapResult.failure(
          'Restore purchases is only available on iOS and Android.',
        );
      }

      // Restored purchases arrive asynchronously on the shared purchase
      // stream. Registering completers up front lets us await them instead of
      // dropping receipts nobody was listening for.
      final productIds = defaultTargetPlatform == TargetPlatform.iOS
          ? PremiumPlan.values.map((plan) => plan.iosProductId).toSet()
          : {PremiumPlan.monthly.googlePlayProductId};
      final completers = <Completer<PremiumIapResult>>[];
      for (final productId in productIds) {
        final completer = Completer<PremiumIapResult>();
        _pendingPurchases[productId] = completer;
        completers.add(completer);
      }

      try {
        await _iap.restorePurchases();
      } on Object {
        for (final productId in productIds) {
          _pendingPurchases.remove(productId);
        }
        rethrow;
      }

      final results = await Future.wait(
        completers.map(
          (completer) => completer.future.timeout(
            const Duration(seconds: 25),
            onTimeout: () => const PremiumIapResult.failure(_kNothingRestored),
          ),
        ),
      );
      for (final productId in productIds) {
        _pendingPurchases.remove(productId);
      }

      final restored = results
          .where((result) => result.isSuccess && result.purchase != null)
          .map((result) => result.purchase!)
          .toList();

      if (restored.isEmpty) {
        final meaningfulError = results
            .map((result) => result.errorMessage)
            .whereType<String>()
            .firstWhere(
              (message) => message != _kNothingRestored,
              orElse: () => '',
            );
        return PremiumIapResult.failure(
          meaningfulError.isNotEmpty
              ? meaningfulError
              : 'No previous purchases were found for this account.',
        );
      }

      var activatedAny = false;
      for (final purchase in restored) {
        final activated = await verifyEntitlementForActivation(purchase);
        activatedAny = activatedAny || activated;
      }

      if (!activatedAny) {
        return const PremiumIapResult.failure(
          'Your purchase was found but could not be verified yet. '
          'Please try again shortly.',
        );
      }

      ref.invalidate(currentUserProvider);
      return const PremiumIapResult.success();
    } on PlatformException catch (e) {
      return PremiumIapResult.failure(_mapPlatformError(e));
    } on MissingPluginException {
      return const PremiumIapResult.failure(
        'In-app purchase plugin is not ready. Fully restart the app and try again.',
      );
    } on Object catch (e) {
      return PremiumIapResult.failure('Restore purchases failed: $e');
    }
  }

  /// Single source of truth for which store receipt reference feeds the
  /// entitlement verifier on each platform. Checkout and restore both route
  /// through here so the two flows cannot drift.
  ///
  /// Returns true only when the backend reports an active subscription.
  /// Transport and configuration failures are logged and returned as false;
  /// callers treat false as "receipt recorded, not yet activated".
  Future<bool> verifyEntitlementForActivation(PurchaseDetails? purchase) async {
    if (purchase == null) return false;
    if (kIsWeb) return false;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final purchaseToken = purchase.verificationData.serverVerificationData;
        if (purchaseToken.trim().isEmpty) return false;
        final result = await ref
            .read(premiumEntitlementRepositoryProvider)
            .verifyPurchase(platform: 'android', purchaseToken: purchaseToken);
        return result.isActive;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final transactionId = purchase.purchaseID;
        if (transactionId == null || transactionId.isEmpty) return false;
        final result = await ref
            .read(premiumEntitlementRepositoryProvider)
            .verifyPurchase(platform: 'ios', transactionId: transactionId);
        return result.isActive;
      }
    } on PremiumEntitlementException catch (e, st) {
      TalkerService.warning('Premium verification failed: $e');
      TalkerService.error('Premium verification error', e, st);
    }
    return false;
  }

  ProductDetails _selectProductForPlan(
    List<ProductDetails> products,
    PremiumPlan plan,
  ) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidProduct = _selectAndroidProductForBasePlan(
        products,
        plan.googlePlayBasePlanId,
      );

      if (androidProduct == null) {
        throw StateError(
          'No Google Play base plan found for "${plan.googlePlayBasePlanId}". '
          'Check that the base plan is active in Play Console and available '
          'for this tester account and country.',
        );
      }

      return androidProduct;
    }

    for (final product in products) {
      if (product.id == plan.iapProductId) {
        return product;
      }
    }

    return products.first;
  }

  /// Selects the base-plan-only offer (no promotional offerId) for the given
  /// base plan ID. Falls back to any offer with a matching base plan ID.
  GooglePlayProductDetails? _selectAndroidProductForBasePlan(
    List<ProductDetails> products,
    String basePlanId,
  ) {
    GooglePlayProductDetails? fallback;

    for (final product in products.whereType<GooglePlayProductDetails>()) {
      final offer = _subscriptionOfferFor(product);
      if (offer?.basePlanId != basePlanId) continue;

      // Prefer the base-plan entry (no promotional offerId).
      if (offer?.offerId == null) return product;

      fallback ??= product;
    }

    return fallback;
  }

  PurchaseParam _createPurchaseParam({
    required ProductDetails product,
    required PremiumPlan plan,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android &&
        product is GooglePlayProductDetails) {
      final offerToken = product.offerToken;

      if (offerToken == null || offerToken.trim().isEmpty) {
        throw StateError(
          'Missing Google Play offer token for base plan '
          '"${plan.googlePlayBasePlanId}".',
        );
      }

      return GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: offerToken,
      );
    }

    return PurchaseParam(productDetails: product);
  }

  SubscriptionOfferDetailsWrapper? _subscriptionOfferFor(
    GooglePlayProductDetails product,
  ) {
    final subscriptionIndex = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;

    if (subscriptionIndex == null || offers == null) {
      return null;
    }

    if (subscriptionIndex < 0 || subscriptionIndex >= offers.length) {
      return null;
    }

    return offers[subscriptionIndex];
  }

  bool _hasVerificationPayload(PurchaseDetails purchase) {
    return purchase.verificationData.serverVerificationData.trim().isNotEmpty;
  }

  String _mapPlatformError(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code == 'channel-error' ||
        message.contains('unable to establish connection on channel')) {
      return 'Google Play Billing is not available on this app instance. '
          'Install the app from a Play testing track on a Play-enabled device, '
          'then fully restart the app and try again.';
    }

    if (code.contains('billing_unavailable')) {
      return 'Google Play Billing is unavailable on this device/account.';
    }

    if (code.contains('item_unavailable')) {
      return 'This subscription product is not available for your account/region yet.';
    }

    if (code.contains('user_canceled')) {
      return 'Purchase cancelled by user.';
    }

    return error.message ?? 'In-app purchase could not be started.';
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
