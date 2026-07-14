import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as fr;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/repositories/payment_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'payment_view_model.freezed.dart';
part 'payment_view_model.g.dart';

class DriverStripeOnboardingFlowState {
  const DriverStripeOnboardingFlowState({
    this.isLoading = false,
    this.showWebView = false,
    this.isVerifying = false,
    this.completionHandled = false,
    this.isConnected = false,
    this.webViewProgress = 0,
    this.onboardingUrl,
    this.errorMessage,
    this.successMessage,
    this.pendingRequirementCategory,
  });
  final bool isLoading;
  final bool showWebView;
  final bool isVerifying;
  final bool completionHandled;
  final bool isConnected;
  final double webViewProgress;
  final String? onboardingUrl;
  final String? errorMessage;
  final String? successMessage;
  // Set only when a completed onboarding attempt is still missing
  // requirements; lets the UI say specifically what's missing (identity doc /
  // banking / tax info) instead of only a generic "additional info" message.
  final StripeRequirementCategory? pendingRequirementCategory;

  DriverStripeOnboardingFlowState copyWith({
    bool? isLoading,
    bool? showWebView,
    bool? isVerifying,
    bool? completionHandled,
    bool? isConnected,
    double? webViewProgress,
    String? onboardingUrl,
    String? errorMessage,
    String? successMessage,
    StripeRequirementCategory? pendingRequirementCategory,
    bool clearOnboardingUrl = false,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPendingRequirementCategory = false,
  }) {
    return DriverStripeOnboardingFlowState(
      isLoading: isLoading ?? this.isLoading,
      showWebView: showWebView ?? this.showWebView,
      isVerifying: isVerifying ?? this.isVerifying,
      completionHandled: completionHandled ?? this.completionHandled,
      isConnected: isConnected ?? this.isConnected,
      webViewProgress: webViewProgress ?? this.webViewProgress,
      onboardingUrl: clearOnboardingUrl
          ? null
          : (onboardingUrl ?? this.onboardingUrl),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      pendingRequirementCategory: clearPendingRequirementCategory
          ? null
          : (pendingRequirementCategory ?? this.pendingRequirementCategory),
    );
  }
}

class PaymentHistoryFilterState {
  const PaymentHistoryFilterState({this.selectedFilter = 'completed'});

  final String selectedFilter;

  PaymentHistoryFilterState copyWith({String? selectedFilter}) {
    return PaymentHistoryFilterState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

@riverpod
class PaymentHistoryFilterViewModel extends _$PaymentHistoryFilterViewModel {
  @override
  PaymentHistoryFilterState build() => const PaymentHistoryFilterState();

  static const validFilters = <String>{
    'all',
    'completed',
    'pending',
    'refunded',
    'failed',
  };

  void setFilter(String filter) {
    if (!validFilters.contains(filter) || filter == state.selectedFilter) {
      return;
    }
    state = state.copyWith(selectedFilter: filter);
  }
}

@riverpod
List<PaymentTransaction> filteredRiderPayments(
  Ref ref,
  List<PaymentTransaction> payments,
) {
  final selectedFilter = ref
      .watch(paymentHistoryFilterViewModelProvider)
      .selectedFilter;

  return switch (selectedFilter) {
    'completed' =>
      payments.where((p) => p.status == PaymentStatus.succeeded).toList(),
    'pending' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.pending ||
                p.status == PaymentStatus.processing,
          )
          .toList(),
    'refunded' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.refunded ||
                p.status == PaymentStatus.partiallyRefunded,
          )
          .toList(),
    'failed' =>
      payments
          .where(
            (p) =>
                p.status == PaymentStatus.failed ||
                p.status == PaymentStatus.cancelled,
          )
          .toList(),
    _ => payments,
  };
}

class DriverEarningsPeriodState {
  const DriverEarningsPeriodState({this.selectedPeriod = 'thisWeek'});

  final String selectedPeriod;

  DriverEarningsPeriodState copyWith({String? selectedPeriod}) {
    return DriverEarningsPeriodState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class DriverPayoutEligibility {
  const DriverPayoutEligibility({
    this.completedEarningsInCents = 0,
    this.activePayoutsInCents = 0,
    this.eligibleBalanceInCents = 0,
    this.stripeAvailableBalanceInCents = 0,
    this.withdrawableBalanceInCents = 0,
    this.blockedPendingRideEarningsInCents = 0,
  });

  factory DriverPayoutEligibility.fromJson(Map<String, dynamic> json) {
    int cents(String key) => (json[key] as num?)?.round() ?? 0;
    return DriverPayoutEligibility(
      completedEarningsInCents: cents('completedEarningsInCents'),
      activePayoutsInCents: cents('activePayoutsInCents'),
      eligibleBalanceInCents: cents('eligibleBalanceInCents'),
      stripeAvailableBalanceInCents: cents('stripeAvailableBalanceInCents'),
      withdrawableBalanceInCents: cents('withdrawableBalanceInCents'),
      blockedPendingRideEarningsInCents: cents(
        'blockedPendingRideEarningsInCents',
      ),
    );
  }

  final int completedEarningsInCents;
  final int activePayoutsInCents;
  final int eligibleBalanceInCents;
  final int stripeAvailableBalanceInCents;
  final int withdrawableBalanceInCents;
  final int blockedPendingRideEarningsInCents;
}

final fr.FutureProvider<DriverPayoutEligibility>
driverPayoutEligibilityProvider =
    fr.FutureProvider.autoDispose<DriverPayoutEligibility>((ref) async {
      final status = await ref.watch(driverStripeStatusProvider.future);
      final stripeAccountId = status.stripeAccountId;
      if (stripeAccountId == null || stripeAccountId.isEmpty) {
        return const DriverPayoutEligibility();
      }

      final response = await ref
          .read(stripeServiceProvider)
          .getDriverPayoutEligibility(
            stripeAccountId: stripeAccountId,
            currency: status.currency,
          );
      return DriverPayoutEligibility.fromJson(response);
    });

@riverpod
class DriverEarningsPeriodViewModel extends _$DriverEarningsPeriodViewModel {
  @override
  DriverEarningsPeriodState build() => const DriverEarningsPeriodState();

  static const validPeriods = <String>{
    'today',
    'thisWeek',
    'thisMonth',
    'allTime',
  };

  void setPeriod(String period) {
    if (!validPeriods.contains(period) || period == state.selectedPeriod) {
      return;
    }
    state = state.copyWith(selectedPeriod: period);
  }
}

/// Payment Processing View Model
@riverpod
class PaymentViewModel extends _$PaymentViewModel {
  @override
  FutureOr<void> build() {}

  /// Process booking payment for rider
  /// Uses Firebase Cloud Functions for secure payment processing
  Future<PaymentTransaction> processBookingPayment({
    required RideModel ride,
    required String riderId,
    required String riderName,
    required String driverName,
    required int seatsBooked,
    required String customerId,
    required String driverStripeAccountId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);

      // Canonical stored currency ('EUR'). Stripe's API expects the lowercase
      // ISO form, so the API call uses [kPaymentCurrencyApi] ('eur') while the
      // record we build/return stores [kPaymentCurrency] ('EUR'). Both derive
      // from the same constant so the two never drift in casing.
      const currency = kPaymentCurrency;

      // Create Stripe Payment Intent via Firebase Cloud Function
      // This automatically handles:
      // - Payment creation
      // - Destination charges (driver transfer)
      // - Fee calculation
      // - Firestore record creation
      final paymentIntentData = await stripeService.createPaymentIntent(
        rideId: ride.id,
        riderId: riderId,
        riderName: riderName,
        driverId: ride.driverId,
        driverName: driverName,
        amountInCents: ride.pricing.pricePerSeatInCents * seatsBooked,
        currency: kPaymentCurrencyApi,
        customerId: customerId,
        driverStripeAccountId: driverStripeAccountId,
        description:
            '${ride.route.origin.address} → ${ride.route.destination.address}',
      );

      // Process payment with Payment Sheet (pass ephemeral key for saved cards
      // and currency for Google/Apple Pay)
      final success = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentIntentData['clientSecret'] as String,
        customerId: customerId,
        ephemeralKeySecret: paymentIntentData['ephemeralKey'] as String?,
        currency: currency,
      );

      if (success) {
        final paymentIntentId = paymentIntentData['paymentIntentId'] as String?;
        if (paymentIntentId == null || paymentIntentId.isEmpty) {
          throw StateError('Payment intent response did not include an ID.');
        }

        // Payment succeeded in Stripe. The Firestore payment record is written
        // asynchronously by the Stripe webhook (Cloud Function), so it may not
        // exist the instant the Payment Sheet returns. Poll briefly with
        // backoff before giving up.
        final payment = await _awaitPaymentRecord(paymentRepo, paymentIntentId);

        // Check if provider is still mounted after async operation
        if (!ref.mounted) {
          return payment ??
              _processingPaymentRecord(
                ride: ride,
                riderId: riderId,
                riderName: riderName,
                driverName: driverName,
                seatsBooked: seatsBooked,
                currency: currency,
                customerId: customerId,
                paymentIntentId: paymentIntentId,
              );
        }

        state = const AsyncValue.data(null);

        // The charge already succeeded in the Payment Sheet. If the webhook
        // hasn't written the record yet, do NOT surface this as an error —
        // return a synthetic "processing" transaction and let the webhook
        // reconcile the persisted record shortly. The server idempotency key
        // ('pi_{bookingId}_{amountInCents}') guards against any double charge.
        return payment ??
            _processingPaymentRecord(
              ride: ride,
              riderId: riderId,
              riderName: riderName,
              driverName: driverName,
              seatsBooked: seatsBooked,
              currency: currency,
              customerId: customerId,
              paymentIntentId: paymentIntentId,
            );
      } else {
        throw Exception('Payment cancelled by user');
      }
    } on Exception catch (e, st) {
      TalkerService.error('Error processing payment: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Polls for the webhook-written payment record with backoff so a charge
  /// that already succeeded in Stripe is not reported as a failure just
  /// because the Cloud Function webhook hasn't finished writing it yet.
  /// Total wait ≈ 7.5s across 6 attempts.
  Future<PaymentTransaction?> _awaitPaymentRecord(
    PaymentRepository paymentRepo,
    String paymentIntentId,
  ) async {
    const delaysMs = [0, 500, 1000, 1500, 2000, 2500];
    for (final delayMs in delaysMs) {
      if (delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
      if (!ref.mounted) return null;
      final payment = await paymentRepo.getPaymentById(paymentIntentId);
      if (payment != null) return payment;
    }
    return null;
  }

  /// Builds a synthetic "processing" transaction to return when the Stripe
  /// charge already succeeded but the webhook-written Firestore record hasn't
  /// landed yet. The authoritative record (with server-computed fees) is
  /// reconciled by the webhook and keyed by [paymentIntentId].
  PaymentTransaction _processingPaymentRecord({
    required RideModel ride,
    required String riderId,
    required String riderName,
    required String driverName,
    required int seatsBooked,
    required String currency,
    required String customerId,
    required String paymentIntentId,
  }) {
    return PaymentTransaction(
      id: paymentIntentId,
      rideId: ride.id,
      riderId: riderId,
      riderName: riderName,
      driverId: ride.driverId,
      driverName: driverName,
      amountInCents: ride.pricing.pricePerSeatInCents * seatsBooked,
      currency: currency,
      status: PaymentStatus.processing,
      platformFeeInCents: 0,
      driverEarningsInCents: 0,
      stripePaymentIntentId: paymentIntentId,
      stripeCustomerId: customerId,
      seatsBooked: seatsBooked,
    );
  }

  /// Get or create Stripe customer for rider
  Future<String> getOrCreateCustomer({
    required String userId,
    required String email,
    String? name,
    String? phone,
    String? existingCustomerId,
  }) async {
    try {
      final stripeService = ref.read(stripeServiceProvider);
      final result = await stripeService.getOrCreateCustomer(
        userId: userId,
        email: email,
        name: name,
        phone: phone,
        existingCustomerId: existingCustomerId,
      );
      return result['customerId'] as String;
    } on Exception catch (e) {
      TalkerService.error('Error getting/creating customer: $e');
      rethrow;
    }
  }

  /// Request an automatic refund for a ride payment.
  Future<void> requestBookingRefund({
    required String paymentId,
    required String reason,
    String? details,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      await paymentRepo.requestRefundReview(
        paymentId: paymentId,
        reason: reason,
        details: details,
      );

      // Check if provider is still mounted after async operation
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } on Exception catch (e, st) {
      TalkerService.error('Error requesting automatic refund: $e');

      // Check if provider is still mounted before setting error state
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}

/// Driver Onboarding View Model
///
/// Handles Stripe Connect account creation and onboarding for drivers.
@riverpod
class DriverOnboardingViewModel extends _$DriverOnboardingViewModel {
  @override
  FutureOr<void> build() {}

  /// Creates a connected account via Stripe and persists it via the repository.
  Future<ConnectedAccountCreationResult?> createConnectedAccount({
    required String userId,
    required String email,
  }) async {
    state = const AsyncValue.loading();

    try {
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final account = await paymentRepo.createConnectedAccount(
        userId: userId,
        email: email,
      );

      if (!ref.mounted) return account;

      state = const AsyncValue.data(null);
      return account;
    } on Exception catch (e, st) {
      TalkerService.error('Error creating connected account: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      return null;
    }
  }
}

@riverpod
class DriverStripeOnboardingFlowViewModel
    extends _$DriverStripeOnboardingFlowViewModel {
  @override
  DriverStripeOnboardingFlowState build() =>
      const DriverStripeOnboardingFlowState();

  Future<void> checkExistingAccount(UserModel? user) async {
    if (user == null) return;

    try {
      final status = await ref.read(driverStripeStatusProvider.future);
      if (!ref.mounted) return;
      if (status.isConnected) {
        state = state.copyWith(isConnected: true, clearError: true);
      }
    } on Exception catch (e) {
      TalkerService.error('Error checking existing Stripe account: $e');
    }
  }

  Future<void> startOnboarding(UserModel? user) async {
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'Please sign in to continue.',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      clearPendingRequirementCategory: true,
    );

    try {
      final result = await ref
          .read(driverOnboardingViewModelProvider.notifier)
          .createConnectedAccount(
            userId: user.uid,
            email: user.email,
          );

      if (!ref.mounted) return;

      if (result != null &&
          result.onboardingUrl != null &&
          result.account.stripeAccountId.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          onboardingUrl: result.onboardingUrl,
          showWebView: true,
          completionHandled: false,
          webViewProgress: 0,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Stripe account creation failed.',
        );
      }
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Stripe setup failed.',
      );
    }
  }

  void failWebViewLoad(String message) {
    state = state.copyWith(
      errorMessage: message,
      showWebView: false,
      webViewProgress: 0,
      clearOnboardingUrl: true,
    );
  }

  void markCompletionHandled() {
    state = state.copyWith(
      completionHandled: true,
      showWebView: false,
      webViewProgress: 0,
      clearError: true,
    );
  }

  void setWebViewProgress(double progress) {
    final normalized = progress.clamp(0, 1).toDouble();
    if (normalized == state.webViewProgress) return;
    state = state.copyWith(webViewProgress: normalized);
  }

  /// Called when Stripe hits the refresh_url (link expired).
  /// Fetches a fresh account link and reloads the WebView.
  Future<void> resumeOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stripeService = ref.read(stripeServiceProvider);
      final result = await stripeService.createAccountLink();
      if (!ref.mounted) return;
      final url = result['url'] as String?;
      if (url == null || url.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to refresh onboarding link.',
        );
        return;
      }
      state = state.copyWith(isLoading: false, onboardingUrl: url);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFacingError(e),
      );
    }
  }

  Future<void> handleOnboardingComplete({
    required UserModel? user,
    required String successMessage,
    required String additionalInfoMessage,
    required String verifyFailedMessage,
  }) async {
    state = state.copyWith(
      isVerifying: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      if (user == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final driver = user is DriverModel ? user : null;
      if (driver == null) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final paymentRepo = ref.read(paymentRepositoryProvider);
      final connectedAccount = await paymentRepo.getConnectedAccount(
        driver.uid,
      );
      final stripeAccountId =
          connectedAccount?.stripeAccountId ?? driver.stripeAccountId;
      if (stripeAccountId == null || stripeAccountId.isEmpty) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: verifyFailedMessage,
          completionHandled: false,
        );
        return;
      }

      final result = await paymentRepo.refreshConnectedAccountFromServer(
        driverId: driver.uid,
        accountId: stripeAccountId,
      );

      if (!ref.mounted) return;

      final isReady =
          result != null &&
          result.chargesEnabled &&
          result.payoutsEnabled &&
          result.detailsSubmitted &&
          result.capabilities.transfers.name == 'active';

      final pendingCategory = isReady
          ? null
          : result?.primaryPendingRequirementCategory;

      state = state.copyWith(
        isVerifying: false,
        isConnected: isReady,
        successMessage: isReady ? successMessage : additionalInfoMessage,
        pendingRequirementCategory: pendingCategory,
        clearPendingRequirementCategory: pendingCategory == null,
        showWebView: false,
        webViewProgress: 0,
        clearOnboardingUrl: true,
      );
    } on Exception catch (e, st) {
      TalkerService.error(
        'Stripe onboarding verification failed: $e',
        e,
        st,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        isVerifying: false,
        completionHandled: false,
        errorMessage: verifyFailedMessage,
        showWebView: false,
        webViewProgress: 0,
        clearOnboardingUrl: true,
        clearPendingRequirementCategory: true,
      );
    }
  }

  void cancelOnboarding() {
    state = state.copyWith(
      showWebView: false,
      completionHandled: false,
      webViewProgress: 0,
      clearOnboardingUrl: true,
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Rider Payment History Provider
@riverpod
Future<List<PaymentTransaction>> riderPaymentHistory(
  Ref ref,
  String riderId,
) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getRiderPaymentHistory(riderId: riderId);
}

/// Rider Payment History Stream Provider
@riverpod
Stream<List<PaymentTransaction>> riderPaymentHistoryStream(
  Ref ref,
  String riderId,
) {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.streamRiderPaymentHistory(riderId: riderId);
}

/// Driver Connected Account View Model
@riverpod
class DriverConnectedAccountViewModel
    extends _$DriverConnectedAccountViewModel {
  @override
  Future<DriverConnectedAccount?> build(String driverId) async {
    final paymentRepo = ref.watch(paymentRepositoryProvider);
    return paymentRepo.getConnectedAccount(driverId);
  }

  /// Refresh connected account status
  /// Status is automatically updated via webhooks
  /// This method just refreshes the local state from Firestore
  Future<void> refreshAccountStatus() async {
    try {
      // Refresh from Firestore (webhooks keep it updated)
      ref.invalidateSelf();
    } on Exception catch (e) {
      TalkerService.error('Error refreshing account status: $e');
      rethrow;
    }
  }
}

/// Driver Earnings Summary Provider
@riverpod
Future<EarningsSummary> driverEarningsSummary(Ref ref, String driverId) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.calculateEarningsSummary(driverId);
}

/// Driver Earnings Transactions Provider
@riverpod
Future<List<PaymentTransaction>> driverEarningsTransactions(
  Ref ref,
  String driverId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getDriverEarnings(
    driverId: driverId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Driver Payouts Provider
@riverpod
Future<List<DriverPayout>> driverPayouts(Ref ref, String driverId) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getDriverPayouts(driverId: driverId);
}

/// Single Payout Detail Provider
@riverpod
Future<DriverPayout?> payoutDetail(Ref ref, String payoutId) async {
  final paymentRepo = ref.watch(paymentRepositoryProvider);
  return paymentRepo.getPayoutById(payoutId);
}

/// Driver Payout View Model
@riverpod
class DriverPayoutViewModel extends _$DriverPayoutViewModel {
  @override
  FutureOr<void> build() {}

  /// Requests an instant payout to the driver's bank account.
  ///
  /// [stripeAccountId] - driver's Stripe Connect account ID from Firestore.
  Future<bool> requestInstantPayout({
    required String stripeAccountId,
    required int amountInCents,
    required String currency,
  }) async {
    state = const AsyncValue.loading();

    try {
      final stripeService = ref.read(stripeServiceProvider);

      // Re-read eligibility from the live Stripe status immediately before
      // sending. The amount/eligibility passed in originate from a possibly
      // stale autoDispose snapshot and a confirm dialog that awaits user input,
      // so the balance may have changed in the meantime. Refusing here guards
      // against over-withdrawal and duplicate/stale payouts if the Cloud
      // Function trusts the client-supplied amount.
      ref.invalidate(driverStripeStatusProvider);
      final freshStatus = await ref.read(driverStripeStatusProvider.future);

      if (!freshStatus.payoutsEnabled) {
        throw Exception(
          'Instant payouts are not currently enabled for this account.',
        );
      }
      if (freshStatus.stripeAccountId != null &&
          freshStatus.stripeAccountId != stripeAccountId) {
        throw Exception(
          'Stripe account changed; payout cancelled for safety.',
        );
      }
      if (amountInCents <= 0 ||
          amountInCents > freshStatus.availableBalanceInCents) {
        throw Exception(
          'Requested payout amount exceeds the available balance.',
        );
      }

      await stripeService.createInstantPayout(
        stripeAccountId: stripeAccountId,
        amountInCents: amountInCents, // Amount in cents
        currency: currency,
      );

      if (!ref.mounted) return true;

      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('Error requesting payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
  }

  /// Cancels a pending instant payout via Stripe then updates Firestore.
  Future<bool> cancelPayout(
    String payoutDocId, {
    required String stripePayoutId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final stripeService = ref.read(stripeServiceProvider);
      await stripeService.cancelInstantPayout(
        payoutDocId: payoutDocId,
        stripePayoutId: stripePayoutId,
      );

      if (!ref.mounted) return true;
      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('Error cancelling payout: $e');
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
  }
}

/// Driver Stripe Status model for UI display
///
/// Represents the current state of a driver's Stripe Connect account.
@freezed
abstract class DriverStripeStatus with _$DriverStripeStatus {
  const factory DriverStripeStatus({
    @Default(false) bool isConnected,
    @Default(false) bool payoutsEnabled,
    @Default(false) bool chargesEnabled,
    @Default(false) bool detailsSubmitted,
    @Default(0) int availableBalanceInCents,
    @Default(0) int pendingBalanceInCents,
    @Default('EUR') String currency,
    String? stripeAccountId,
  }) = _DriverStripeStatus;

  factory DriverStripeStatus.fromJson(Map<String, dynamic> json) =>
      _$DriverStripeStatusFromJson(json);
}

/// Provider to get current driver's Stripe status
@riverpod
Future<DriverStripeStatus> driverStripeStatus(Ref ref) async {
  // Keep the result cached for 5 minutes so navigating away and back (or any
  // unrelated provider rebuild) does not hammer the getAccountStatus function.
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);

  // Watch only authState — the correct trigger (login / logout / ~hourly token
  // refresh). Do NOT watch currentUserProvider: it is a live Firestore stream
  // that fires on every user-document field update, which would call
  // getAccountStatus on every location update, ride status change, etc.
  final authuserUID = await ref.watch(currentAuthUidProvider.future);

  // Read services and user model once — no reactive dependency needed.
  final paymentRepo = ref.read(paymentRepositoryProvider);
  final stripeService = ref.read(stripeServiceProvider);
  final userModel = ref.read(currentUserProvider).value;

  if (authuserUID == null) return const DriverStripeStatus();

  try {
    final connectedAccount = await paymentRepo.getConnectedAccount(
      authuserUID,
    );
    final driver = userModel is DriverModel ? userModel : null;

    final accountId =
        connectedAccount?.stripeAccountId ?? driver?.stripeAccountId;

    if (accountId == null || accountId.isEmpty) {
      return const DriverStripeStatus();
    }

    try {
      final liveStatus = await stripeService
          .getAccountStatus(accountId: accountId)
          .timeout(const Duration(seconds: 8));

      int balanceInCents(String centsKey, String legacyMajorKey) {
        final cents = liveStatus[centsKey] as num?;
        if (cents != null) return cents.round();

        final legacyMajor = liveStatus[legacyMajorKey] as num?;
        return legacyMajor == null ? 0 : (legacyMajor * 100).round();
      }

      final liveChargesEnabled = liveStatus['chargesEnabled'] == true;
      final livePayoutsEnabled = liveStatus['payoutsEnabled'] == true;
      final liveDetailsSubmitted = liveStatus['detailsSubmitted'] == true;
      final liveCapabilities = liveStatus['capabilities'];
      final liveTransfersActive =
          liveCapabilities is Map && liveCapabilities['transfers'] == 'active';
      final liveAvailableBalance = balanceInCents(
        'availableBalanceInCents',
        'availableBalance',
      );
      final livePendingBalance = balanceInCents(
        'pendingBalanceInCents',
        'pendingBalance',
      );

      return DriverStripeStatus(
        isConnected:
            liveChargesEnabled &&
            livePayoutsEnabled &&
            liveDetailsSubmitted &&
            liveTransfersActive,
        payoutsEnabled: livePayoutsEnabled,
        chargesEnabled: liveChargesEnabled,
        detailsSubmitted: liveDetailsSubmitted,
        availableBalanceInCents: liveAvailableBalance,
        pendingBalanceInCents: livePendingBalance,
        currency: (liveStatus['currency'] as String?) ?? 'EUR',
        stripeAccountId: accountId,
      );
    } catch (e) {
      TalkerService.warning(
        'Live Stripe status fetch failed, falling back to cached status: $e',
      );

      final cachedChargesEnabled = connectedAccount?.chargesEnabled ?? false;
      final cachedPayoutsEnabled = connectedAccount?.payoutsEnabled ?? false;
      final cachedDetailsSubmitted =
          connectedAccount?.detailsSubmitted ?? false;

      return DriverStripeStatus(
        isConnected:
            (connectedAccount?.isFullySetup ?? false) ||
            (cachedChargesEnabled &&
                cachedPayoutsEnabled &&
                cachedDetailsSubmitted),
        payoutsEnabled: cachedPayoutsEnabled,
        chargesEnabled: cachedChargesEnabled,
        detailsSubmitted: cachedDetailsSubmitted,
        availableBalanceInCents: connectedAccount?.availableBalanceInCents ?? 0,
        pendingBalanceInCents: connectedAccount?.pendingBalanceInCents ?? 0,
        currency: connectedAccount?.defaultCurrency ?? 'EUR',
        stripeAccountId: accountId,
      );
    }
  } on Exception catch (e, st) {
    TalkerService.error('Error loading driverStripeStatus: $e', e, st);
    return const DriverStripeStatus();
  }
}

@Riverpod(keepAlive: true)
Stream<DriverConnectedAccount?> currentDriverConnectedAccount(Ref ref) async* {
  final userUIDFuture = ref.watch(
    currentUserProvider.selectAsync((user) {
      if (user == null) return null;
      if (user.role != UserRole.driver) return null;
      return user.uid;
    }),
  );

  final paymentRepo = ref.watch(paymentRepositoryProvider);

  final userUID = await userUIDFuture;

  if (userUID == null) {
    yield null;
    return;
  }

  yield* paymentRepo.streamConnectedAccount(userUID);
}
