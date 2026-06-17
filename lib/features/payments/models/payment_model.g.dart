// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StripeCapabilities _$StripeCapabilitiesFromJson(Map json) =>
    _StripeCapabilities(
      transfers:
          $enumDecodeNullable(
            _$StripeCapabilityStatusEnumMap,
            json['transfers'],
          ) ??
          StripeCapabilityStatus.inactive,
      cardPayments:
          $enumDecodeNullable(
            _$StripeCapabilityStatusEnumMap,
            json['cardPayments'],
          ) ??
          StripeCapabilityStatus.inactive,
    );

Map<String, dynamic> _$StripeCapabilitiesToJson(_StripeCapabilities instance) =>
    <String, dynamic>{
      'transfers': _$StripeCapabilityStatusEnumMap[instance.transfers]!,
      'cardPayments': _$StripeCapabilityStatusEnumMap[instance.cardPayments]!,
    };

const _$StripeCapabilityStatusEnumMap = {
  StripeCapabilityStatus.active: 'active',
  StripeCapabilityStatus.inactive: 'inactive',
  StripeCapabilityStatus.pending: 'pending',
};

_StripeRequirements _$StripeRequirementsFromJson(
  Map json,
) => _StripeRequirements(
  currentlyDue:
      (json['currentlyDue'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  eventuallyDue:
      (json['eventuallyDue'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  pastDue:
      (json['pastDue'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  pendingVerification:
      (json['pendingVerification'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  currentDeadline: const TimestampConverter().fromJson(json['currentDeadline']),
  disabledReason: $enumDecodeNullable(
    _$StripeDisabledReasonEnumMap,
    json['disabledReason'],
  ),
);

Map<String, dynamic> _$StripeRequirementsToJson(_StripeRequirements instance) =>
    <String, dynamic>{
      'currentlyDue': instance.currentlyDue,
      'eventuallyDue': instance.eventuallyDue,
      'pastDue': instance.pastDue,
      'pendingVerification': instance.pendingVerification,
      'currentDeadline': const TimestampConverter().toJson(
        instance.currentDeadline,
      ),
      'disabledReason': _$StripeDisabledReasonEnumMap[instance.disabledReason],
    };

const _$StripeDisabledReasonEnumMap = {
  StripeDisabledReason.actionRequiredRequestedCapabilities:
      'actionRequiredRequestedCapabilities',
  StripeDisabledReason.listed: 'listed',
  StripeDisabledReason.other: 'other',
  StripeDisabledReason.platformPaused: 'platformPaused',
  StripeDisabledReason.rejectedFraud: 'rejectedFraud',
  StripeDisabledReason.rejectedIncompleteVerification:
      'rejectedIncompleteVerification',
  StripeDisabledReason.rejectedListed: 'rejectedListed',
  StripeDisabledReason.rejectedOther: 'rejectedOther',
  StripeDisabledReason.rejectedPlatformFraud: 'rejectedPlatformFraud',
  StripeDisabledReason.rejectedPlatformOther: 'rejectedPlatformOther',
  StripeDisabledReason.rejectedPlatformTermsOfService:
      'rejectedPlatformTermsOfService',
  StripeDisabledReason.rejectedTermsOfService: 'rejectedTermsOfService',
  StripeDisabledReason.requirementsPastDue: 'requirementsPastDue',
  StripeDisabledReason.requirementsPendingVerification:
      'requirementsPendingVerification',
  StripeDisabledReason.underReview: 'underReview',
};

_PaymentTransaction _$PaymentTransactionFromJson(Map json) =>
    _PaymentTransaction(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      riderId: json['riderId'] as String,
      riderName: json['riderName'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      amountInCents: (json['amountInCents'] as num).toInt(),
      currency: json['currency'] as String,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      platformFeeInCents: (json['platformFeeInCents'] as num).toInt(),
      driverEarningsInCents: (json['driverEarningsInCents'] as num).toInt(),
      stripeFeeInCents: (json['stripeFeeInCents'] as num?)?.toInt() ?? 0,
      paymentMethodType: $enumDecodeNullable(
        _$PaymentMethodTypeEnumMap,
        json['paymentMethodType'],
      ),
      paymentMethodLast4: json['paymentMethodLast4'] as String?,
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeChargeId: json['stripeChargeId'] as String?,
      stripeTransferId: json['stripeTransferId'] as String?,
      stripeBalanceTransactionId: json['stripeBalanceTransactionId'] as String?,
      stripeRefundId: json['stripeRefundId'] as String?,
      seatsBooked: (json['seatsBooked'] as num?)?.toInt(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      completedAt: const TimestampConverter().fromJson(json['completedAt']),
      refundedAt: const TimestampConverter().fromJson(json['refundedAt']),
      failureReason: json['failureReason'] as String?,
      refundReason: json['refundReason'] as String?,
      refundedAmountInCents: (json['refundedAmountInCents'] as num?)?.toInt(),
      metadata:
          (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
          const {},
    );

Map<String, dynamic> _$PaymentTransactionToJson(
  _PaymentTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'riderId': instance.riderId,
  'riderName': instance.riderName,
  'driverId': instance.driverId,
  'driverName': instance.driverName,
  'amountInCents': instance.amountInCents,
  'currency': instance.currency,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'platformFeeInCents': instance.platformFeeInCents,
  'driverEarningsInCents': instance.driverEarningsInCents,
  'stripeFeeInCents': instance.stripeFeeInCents,
  'paymentMethodType': _$PaymentMethodTypeEnumMap[instance.paymentMethodType],
  'paymentMethodLast4': instance.paymentMethodLast4,
  'stripePaymentIntentId': instance.stripePaymentIntentId,
  'stripeCustomerId': instance.stripeCustomerId,
  'stripeChargeId': instance.stripeChargeId,
  'stripeTransferId': instance.stripeTransferId,
  'stripeBalanceTransactionId': instance.stripeBalanceTransactionId,
  'stripeRefundId': instance.stripeRefundId,
  'seatsBooked': instance.seatsBooked,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'completedAt': const TimestampConverter().toJson(instance.completedAt),
  'refundedAt': const TimestampConverter().toJson(instance.refundedAt),
  'failureReason': instance.failureReason,
  'refundReason': instance.refundReason,
  'refundedAmountInCents': instance.refundedAmountInCents,
  'metadata': instance.metadata,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.processing: 'processing',
  PaymentStatus.succeeded: 'succeeded',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.refunding: 'refunding',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.refundFailed: 'refundFailed',
  PaymentStatus.partiallyRefunded: 'partiallyRefunded',
};

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.card: 'card',
  PaymentMethodType.applePay: 'applePay',
  PaymentMethodType.googlePay: 'googlePay',
  PaymentMethodType.link: 'link',
};

_DriverPayout _$DriverPayoutFromJson(Map json) => _DriverPayout(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  driverName: json['driverName'] as String,
  connectedAccountId: json['connectedAccountId'] as String,
  amountInCents: (json['amountInCents'] as num).toInt(),
  currency: json['currency'] as String,
  status: $enumDecode(_$PayoutStatusEnumMap, json['status']),
  method:
      $enumDecodeNullable(_$PayoutMethodEnumMap, json['method']) ??
      PayoutMethod.standard,
  type:
      $enumDecodeNullable(_$PayoutTypeEnumMap, json['type']) ??
      PayoutType.bankAccount,
  destination: json['destination'] as String?,
  stripePayoutId: json['stripePayoutId'] as String?,
  stripeTransferId: json['stripeTransferId'] as String?,
  stripeBalanceTransactionId: json['stripeBalanceTransactionId'] as String?,
  transactionIds:
      (json['transactionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  expectedArrivalDate: const TimestampConverter().fromJson(
    json['expectedArrivalDate'],
  ),
  arrivedAt: const TimestampConverter().fromJson(json['arrivedAt']),
  failureReason: json['failureReason'] as String?,
  failureCode: json['failureCode'] as String?,
  metadata:
      (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
);

Map<String, dynamic> _$DriverPayoutToJson(_DriverPayout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'connectedAccountId': instance.connectedAccountId,
      'amountInCents': instance.amountInCents,
      'currency': instance.currency,
      'status': _$PayoutStatusEnumMap[instance.status]!,
      'method': _$PayoutMethodEnumMap[instance.method]!,
      'type': _$PayoutTypeEnumMap[instance.type]!,
      'destination': instance.destination,
      'stripePayoutId': instance.stripePayoutId,
      'stripeTransferId': instance.stripeTransferId,
      'stripeBalanceTransactionId': instance.stripeBalanceTransactionId,
      'transactionIds': instance.transactionIds,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'expectedArrivalDate': const TimestampConverter().toJson(
        instance.expectedArrivalDate,
      ),
      'arrivedAt': const TimestampConverter().toJson(instance.arrivedAt),
      'failureReason': instance.failureReason,
      'failureCode': instance.failureCode,
      'metadata': instance.metadata,
    };

const _$PayoutStatusEnumMap = {
  PayoutStatus.pending: 'pending',
  PayoutStatus.inTransit: 'inTransit',
  PayoutStatus.paid: 'paid',
  PayoutStatus.failed: 'failed',
  PayoutStatus.cancelled: 'cancelled',
};

const _$PayoutMethodEnumMap = {
  PayoutMethod.standard: 'standard',
  PayoutMethod.instant: 'instant',
};

const _$PayoutTypeEnumMap = {
  PayoutType.bankAccount: 'bankAccount',
  PayoutType.card: 'card',
};

_DriverConnectedAccount _$DriverConnectedAccountFromJson(
  Map json,
) => _DriverConnectedAccount(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  stripeAccountId: json['stripeAccountId'] as String,
  email: json['email'] as String,
  country: json['country'] as String,
  defaultCurrency: json['defaultCurrency'] as String,
  chargesEnabled: json['chargesEnabled'] as bool,
  payoutsEnabled: json['payoutsEnabled'] as bool,
  detailsSubmitted: json['detailsSubmitted'] as bool,
  capabilities: json['capabilities'] == null
      ? const StripeCapabilities()
      : StripeCapabilities.fromJson(
          Map<String, dynamic>.from(json['capabilities'] as Map),
        ),
  requirements: json['requirements'] == null
      ? const StripeRequirements()
      : StripeRequirements.fromJson(
          Map<String, dynamic>.from(json['requirements'] as Map),
        ),
  futureRequirements: json['futureRequirements'] == null
      ? const StripeRequirements()
      : StripeRequirements.fromJson(
          Map<String, dynamic>.from(json['futureRequirements'] as Map),
        ),
  onboardingCompleted: json['onboardingCompleted'] as bool?,
  onboardingCompletedAt: const TimestampConverter().fromJson(
    json['onboardingCompletedAt'],
  ),
  accountHolderName: json['accountHolderName'] as String?,
  totalEarningsInCents: (json['totalEarningsInCents'] as num?)?.toInt() ?? 0,
  availableBalanceInCents:
      (json['availableBalanceInCents'] as num?)?.toInt() ?? 0,
  pendingBalanceInCents: (json['pendingBalanceInCents'] as num?)?.toInt() ?? 0,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  lastPayoutAt: const TimestampConverter().fromJson(json['lastPayoutAt']),
  metadata:
      (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
);

Map<String, dynamic> _$DriverConnectedAccountToJson(
  _DriverConnectedAccount instance,
) => <String, dynamic>{
  'id': instance.id,
  'driverId': instance.driverId,
  'stripeAccountId': instance.stripeAccountId,
  'email': instance.email,
  'country': instance.country,
  'defaultCurrency': instance.defaultCurrency,
  'chargesEnabled': instance.chargesEnabled,
  'payoutsEnabled': instance.payoutsEnabled,
  'detailsSubmitted': instance.detailsSubmitted,
  'capabilities': instance.capabilities.toJson(),
  'requirements': instance.requirements.toJson(),
  'futureRequirements': instance.futureRequirements.toJson(),
  'onboardingCompleted': instance.onboardingCompleted,
  'onboardingCompletedAt': const TimestampConverter().toJson(
    instance.onboardingCompletedAt,
  ),
  'accountHolderName': instance.accountHolderName,
  'totalEarningsInCents': instance.totalEarningsInCents,
  'availableBalanceInCents': instance.availableBalanceInCents,
  'pendingBalanceInCents': instance.pendingBalanceInCents,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'lastPayoutAt': const TimestampConverter().toJson(instance.lastPayoutAt),
  'metadata': instance.metadata,
};

_RiderPaymentMethod _$RiderPaymentMethodFromJson(Map json) =>
    _RiderPaymentMethod(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String,
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      exMonth: (json['exMonth'] as num).toInt(),
      exYear: (json['exYear'] as num).toInt(),
      fingerprint: json['fingerprint'] as String?,
      funding: json['funding'] as String?,
      cardCountry: json['cardCountry'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$RiderPaymentMethodToJson(_RiderPaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderId': instance.riderId,
      'stripeCustomerId': instance.stripeCustomerId,
      'stripePaymentMethodId': instance.stripePaymentMethodId,
      'brand': instance.brand,
      'last4': instance.last4,
      'exMonth': instance.exMonth,
      'exYear': instance.exYear,
      'fingerprint': instance.fingerprint,
      'funding': instance.funding,
      'cardCountry': instance.cardCountry,
      'isDefault': instance.isDefault,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_EarningsSummary _$EarningsSummaryFromJson(Map json) => _EarningsSummary(
  driverId: json['driverId'] as String,
  totalEarningsInCents: (json['totalEarningsInCents'] as num?)?.toInt() ?? 0,
  totalPlatformFeesInCents:
      (json['totalPlatformFeesInCents'] as num?)?.toInt() ?? 0,
  totalStripeFeesInCents:
      (json['totalStripeFeesInCents'] as num?)?.toInt() ?? 0,
  earningsTodayInCents: (json['earningsTodayInCents'] as num?)?.toInt() ?? 0,
  earningsThisWeekInCents:
      (json['earningsThisWeekInCents'] as num?)?.toInt() ?? 0,
  earningsThisMonthInCents:
      (json['earningsThisMonthInCents'] as num?)?.toInt() ?? 0,
  earningsThisYearInCents:
      (json['earningsThisYearInCents'] as num?)?.toInt() ?? 0,
  totalRidesCompleted: (json['totalRidesCompleted'] as num?)?.toInt() ?? 0,
  ridesCompletedToday: (json['ridesCompletedToday'] as num?)?.toInt() ?? 0,
  ridesCompletedThisWeek:
      (json['ridesCompletedThisWeek'] as num?)?.toInt() ?? 0,
  ridesCompletedThisMonth:
      (json['ridesCompletedThisMonth'] as num?)?.toInt() ?? 0,
  availableBalanceInCents:
      (json['availableBalanceInCents'] as num?)?.toInt() ?? 0,
  pendingBalanceInCents: (json['pendingBalanceInCents'] as num?)?.toInt() ?? 0,
  lastUpdated: const TimestampConverter().fromJson(json['lastUpdated']),
  lastPayoutDate: const TimestampConverter().fromJson(json['lastPayoutDate']),
);

Map<String, dynamic> _$EarningsSummaryToJson(
  _EarningsSummary instance,
) => <String, dynamic>{
  'driverId': instance.driverId,
  'totalEarningsInCents': instance.totalEarningsInCents,
  'totalPlatformFeesInCents': instance.totalPlatformFeesInCents,
  'totalStripeFeesInCents': instance.totalStripeFeesInCents,
  'earningsTodayInCents': instance.earningsTodayInCents,
  'earningsThisWeekInCents': instance.earningsThisWeekInCents,
  'earningsThisMonthInCents': instance.earningsThisMonthInCents,
  'earningsThisYearInCents': instance.earningsThisYearInCents,
  'totalRidesCompleted': instance.totalRidesCompleted,
  'ridesCompletedToday': instance.ridesCompletedToday,
  'ridesCompletedThisWeek': instance.ridesCompletedThisWeek,
  'ridesCompletedThisMonth': instance.ridesCompletedThisMonth,
  'availableBalanceInCents': instance.availableBalanceInCents,
  'pendingBalanceInCents': instance.pendingBalanceInCents,
  'lastUpdated': const TimestampConverter().toJson(instance.lastUpdated),
  'lastPayoutDate': const TimestampConverter().toJson(instance.lastPayoutDate),
};
