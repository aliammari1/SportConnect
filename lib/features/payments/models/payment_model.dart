import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// Canonical currency for all payment records, earnings, and payouts.
///
/// This is the single source of truth for the currency casing the app stores
/// and compares against (`PaymentTransaction.currency`, `EarningsSummary`, and
/// `DriverConnectedAccount.defaultCurrency` are all normalized to this value).
///
/// Stripe's API accepts lowercase ISO codes; use [kPaymentCurrencyApi] when
/// calling the Stripe service so the stored record and the API call never drift
/// in casing.
const String kPaymentCurrency = 'EUR';

/// Lowercase ISO form of [kPaymentCurrency] for Stripe API calls (Stripe
/// expects lowercase currency codes such as `eur`).
const String kPaymentCurrencyApi = 'eur';

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
  refunding,
  refunded,
  refundFailed,
  partiallyRefunded,
}

/// Payment method type
enum PaymentMethodType { card, applePay, googlePay, link }

/// Payout status
enum PayoutStatus { pending, inTransit, paid, failed, cancelled }

/// Transaction type
enum TransactionType {
  payment,
  refund,
  payout,
  platformFee,
  stripeFee,
  ride,
  bonus,
}

enum StripeCapabilityStatus { active, inactive, pending }

enum StripeDisabledReason {
  actionRequiredRequestedCapabilities,
  listed,
  other,
  platformPaused,
  rejectedFraud,
  rejectedIncompleteVerification,
  rejectedListed,
  rejectedOther,
  rejectedPlatformFraud,
  rejectedPlatformOther,
  rejectedPlatformTermsOfService,
  rejectedTermsOfService,
  requirementsPastDue,
  requirementsPendingVerification,
  underReview,
}

@freezed
abstract class StripeCapabilities with _$StripeCapabilities {
  const factory StripeCapabilities({
    @Default(StripeCapabilityStatus.inactive) StripeCapabilityStatus transfers,
    @Default(StripeCapabilityStatus.inactive)
    StripeCapabilityStatus cardPayments,
  }) = _StripeCapabilities;

  factory StripeCapabilities.fromJson(Map<String, dynamic> json) =>
      _$StripeCapabilitiesFromJson(json);
}

@freezed
abstract class StripeRequirements with _$StripeRequirements {
  const factory StripeRequirements({
    @Default([]) List<String> currentlyDue,
    @Default([]) List<String> eventuallyDue,
    @Default([]) List<String> pastDue,
    @Default([]) List<String> pendingVerification,
    @TimestampConverter() DateTime? currentDeadline,
    StripeDisabledReason? disabledReason,
  }) = _StripeRequirements;

  factory StripeRequirements.fromJson(Map<String, dynamic> json) =>
      _$StripeRequirementsFromJson(json);
}

/// Payment Transaction Model
@freezed
abstract class PaymentTransaction with _$PaymentTransaction {
  const factory PaymentTransaction({
    required String id,
    required String rideId,
    required String riderId,
    required String riderName,
    required String driverId,
    required String driverName,
    required int amountInCents, // ✅ cents
    required String currency,
    required PaymentStatus status,
    required int platformFeeInCents, // ✅ cents
    required int driverEarningsInCents, // ✅ cents
    @Default(0) int stripeFeeInCents, // ✅ cents
    PaymentMethodType? paymentMethodType,
    String? paymentMethodLast4,
    // Stripe IDs
    String? stripePaymentIntentId,
    String? stripeCustomerId,
    String? stripeChargeId,
    String? stripeTransferId,
    String? stripeBalanceTransactionId,
    String? stripeRefundId,
    int? seatsBooked,
    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? completedAt,
    @TimestampConverter() DateTime? refundedAt,
    String? failureReason,
    String? refundReason,
    int? refundedAmountInCents,
    @Default({}) Map<String, dynamic> metadata,
  }) = _PaymentTransaction;

  const PaymentTransaction._();

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);

  // Display helpers convert from cents
  String get formattedAmount => CurrencyFormatter.fromCents(amountInCents);
  String get formattedPlatformFee =>
      CurrencyFormatter.fromCents(platformFeeInCents);
  String get formattedDriverEarnings =>
      CurrencyFormatter.fromCents(driverEarningsInCents);
  String get formattedStripeFee =>
      CurrencyFormatter.fromCents(stripeFeeInCents);

  /// Net amount actually settled: gross charge minus platform and Stripe fees.
  int get netAmountInCents =>
      amountInCents - platformFeeInCents - stripeFeeInCents;

  bool get isSuccessful => status == PaymentStatus.succeeded;
  bool get isRefunded => status == PaymentStatus.refunded;
  bool get isPartiallyRefunded => status == PaymentStatus.partiallyRefunded;
  bool get isFullyRefunded =>
      refundedAmountInCents != null &&
      refundedAmountInCents! >= amountInCents;

  /// Whether the payment has reached a final state and no longer needs polling.
  bool get isTerminal => const {
    PaymentStatus.succeeded,
    PaymentStatus.failed,
    PaymentStatus.cancelled,
    PaymentStatus.refunded,
  }.contains(status);

  bool get canRequestRefund =>
      (status == PaymentStatus.succeeded ||
          status == PaymentStatus.partiallyRefunded ||
          status == PaymentStatus.refundFailed) &&
      stripePaymentIntentId != null &&
      createdAt != null &&
      DateTime.now().difference(createdAt!).inDays <= 30;

  bool get canBeRefunded =>
      canRequestRefund &&
      status == PaymentStatus.succeeded &&
      stripeRefundId == null;
}

/// Driver Payout Model
enum PayoutMethod { standard, instant }

enum PayoutType { bankAccount, card }

@freezed
abstract class DriverPayout with _$DriverPayout {
  const factory DriverPayout({
    required String id,
    required String driverId,
    required String driverName,
    required String connectedAccountId,
    required int amountInCents, // ✅ cents
    required String currency,
    required PayoutStatus status,
    @Default(PayoutMethod.standard) PayoutMethod method, // ADD
    @Default(PayoutType.bankAccount) PayoutType type, // ADD
    String? destination, // ADD: bank account / card ID on Connect acct
    String? stripePayoutId,
    String? stripeTransferId,
    String? stripeBalanceTransactionId, // ADD: reconciliation
    @Default([]) List<String> transactionIds,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? expectedArrivalDate,
    @TimestampConverter() DateTime? arrivedAt,
    String? failureReason,
    String? failureCode, // ADD: Stripe failure code enum string
    @Default({}) Map<String, dynamic> metadata,
  }) = _DriverPayout;
  const DriverPayout._();

  factory DriverPayout.fromJson(Map<String, dynamic> json) =>
      _$DriverPayoutFromJson(json);

  bool get isCompleted => status == PayoutStatus.paid;
  bool get isPending => status == PayoutStatus.pending;
  bool get hasFailed => status == PayoutStatus.failed;
  bool get isInTransit => status == PayoutStatus.inTransit;
  bool get isCancelled => status == PayoutStatus.cancelled;
  bool get isInstantPayout => method == PayoutMethod.instant;

  /// Whether the payout has reached a final state and no longer needs polling.
  bool get isTerminal => const {
    PayoutStatus.paid,
    PayoutStatus.failed,
    PayoutStatus.cancelled,
  }.contains(status);

  String get formattedAmount => CurrencyFormatter.fromCents(amountInCents);
}

class ConnectedAccountCreationResult {
  const ConnectedAccountCreationResult({
    required this.account,
    this.onboardingUrl,
  });
  final DriverConnectedAccount account;
  final String? onboardingUrl;
}

/// Driver Connected Account Model
@freezed
abstract class DriverConnectedAccount with _$DriverConnectedAccount {
  const factory DriverConnectedAccount({
    required String id,
    required String driverId,
    required String stripeAccountId,
    required String email,
    required String country,
    required String defaultCurrency, // ✅ from Stripe directly
    required bool chargesEnabled,
    required bool payoutsEnabled,
    required bool detailsSubmitted,
    // Capabilities
    @Default(StripeCapabilities()) StripeCapabilities capabilities, // ADD
    // Requirements
    @Default(StripeRequirements()) StripeRequirements requirements, // ✅ typed
    @Default(StripeRequirements()) StripeRequirements futureRequirements, // ADD
    // Onboarding — no onboardingUrl, generate on-demand via CF
    bool? onboardingCompleted,
    @TimestampConverter() DateTime? onboardingCompletedAt,
    String? accountHolderName,
    // Balances in cents
    @Default(0) int totalEarningsInCents, // ✅ cents
    @Default(0) int availableBalanceInCents, // ✅ cents
    @Default(0) int pendingBalanceInCents, // ✅ cents
    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? lastPayoutAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DriverConnectedAccount;
  const DriverConnectedAccount._();

  factory DriverConnectedAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverConnectedAccountFromJson(json);

  bool get isFullySetup =>
      chargesEnabled &&
      payoutsEnabled &&
      detailsSubmitted &&
      capabilities.transfers == StripeCapabilityStatus.active;

  bool get needsOnboarding =>
      !chargesEnabled || !payoutsEnabled || !detailsSubmitted;

  bool get hasBlockedRequirements => requirements.pastDue.isNotEmpty;

  bool get hasPendingRequirements => requirements.currentlyDue.isNotEmpty;

  bool get hasFutureRequirements =>
      futureRequirements.currentlyDue.isNotEmpty ||
      futureRequirements.pastDue.isNotEmpty;

  bool get canReceivePayouts => payoutsEnabled && availableBalanceInCents > 0;

  int get totalBalanceInCents =>
      availableBalanceInCents + pendingBalanceInCents;

  String get formattedAvailableBalance =>
      CurrencyFormatter.fromCents(availableBalanceInCents);
  String get formattedPendingBalance =>
      CurrencyFormatter.fromCents(pendingBalanceInCents);
  String get formattedTotalBalance =>
      CurrencyFormatter.fromCents(totalBalanceInCents);
  String get formattedTotalEarnings =>
      CurrencyFormatter.fromCents(totalEarningsInCents);
}

/// Rider Payment Method Model
@freezed
abstract class RiderPaymentMethod with _$RiderPaymentMethod {
  const factory RiderPaymentMethod({
    required String id,
    required String riderId,
    required String stripeCustomerId,
    required String stripePaymentMethodId,
    required String brand,
    required String last4,
    required int exMonth,
    required int exYear,
    String? fingerprint, // ADD: dedup same card across customers
    String? funding,
    String? cardCountry,
    @Default(false) bool isDefault,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _RiderPaymentMethod;

  const RiderPaymentMethod._();

  factory RiderPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$RiderPaymentMethodFromJson(json);

  /// Get formatted card info
  String get cardDisplay => '$brand •••• $last4';

  /// Check if card is expired
  bool get isExpired {
    final now = DateTime.now();
    final expDate = DateTime(exYear, exMonth + 1, 0);
    return now.isAfter(expDate);
  }

  /// Whether the card expires within the next two months (and is not already
  /// expired), to power a proactive "card expiring soon" prompt.
  bool get expiresSoon {
    final now = DateTime.now();
    final twoMonthsOut = DateTime(now.year, now.month + 2, 1);
    final exp = DateTime(exYear, exMonth + 1, 0);
    return !isExpired && exp.isBefore(twoMonthsOut);
  }

  /// Get expiration display
  String get expirationDisplay =>
      '${exMonth.toString().padLeft(2, '0')}/$exYear';
}

/// Earnings Summary Model for drivers
@freezed
abstract class EarningsSummary with _$EarningsSummary {
  const factory EarningsSummary({
    required String driverId,

    // Total earnings
    @Default(0) int totalEarningsInCents,
    @Default(0) int totalPlatformFeesInCents,
    @Default(0) int totalStripeFeesInCents,

    // Period earnings
    @Default(0) int earningsTodayInCents,
    @Default(0) int earningsThisWeekInCents,
    @Default(0) int earningsThisMonthInCents,
    @Default(0) int earningsThisYearInCents,

    // Ride stats
    @Default(0) int totalRidesCompleted,
    @Default(0) int ridesCompletedToday,
    @Default(0) int ridesCompletedThisWeek,
    @Default(0) int ridesCompletedThisMonth,

    // Balance
    @Default(0) int availableBalanceInCents,
    @Default(0) int pendingBalanceInCents,

    // Timestamps
    @TimestampConverter() DateTime? lastUpdated,
    @TimestampConverter() DateTime? lastPayoutDate,
  }) = _EarningsSummary;
  const EarningsSummary._();

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);

  /// Get average earnings per ride
  double get averagePerRide => totalRidesCompleted > 0
      ? totalEarningsInCents / totalRidesCompleted / 100
      : 0.0;

  /// Net earnings after platform and Stripe fees.
  int get netEarningsInCents =>
      totalEarningsInCents - totalPlatformFeesInCents - totalStripeFeesInCents;

  int get totalBalanceInCents =>
      availableBalanceInCents + pendingBalanceInCents;

  String get formattedTotalEarnings =>
      CurrencyFormatter.fromCents(totalEarningsInCents);
  String get formattedAvailableBalance =>
      CurrencyFormatter.fromCents(availableBalanceInCents);
  String get formattedPendingBalance =>
      CurrencyFormatter.fromCents(pendingBalanceInCents);
}
