// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverStripeStatus _$DriverStripeStatusFromJson(Map json) =>
    _DriverStripeStatus(
      isConnected: json['isConnected'] as bool? ?? false,
      payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
      chargesEnabled: json['chargesEnabled'] as bool? ?? false,
      detailsSubmitted: json['detailsSubmitted'] as bool? ?? false,
      availableBalanceInCents:
          (json['availableBalanceInCents'] as num?)?.toInt() ?? 0,
      pendingBalanceInCents:
          (json['pendingBalanceInCents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      stripeAccountId: json['stripeAccountId'] as String?,
    );

Map<String, dynamic> _$DriverStripeStatusToJson(_DriverStripeStatus instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'payoutsEnabled': instance.payoutsEnabled,
      'chargesEnabled': instance.chargesEnabled,
      'detailsSubmitted': instance.detailsSubmitted,
      'availableBalanceInCents': instance.availableBalanceInCents,
      'pendingBalanceInCents': instance.pendingBalanceInCents,
      'currency': instance.currency,
      'stripeAccountId': instance.stripeAccountId,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentHistoryFilterViewModel)
final paymentHistoryFilterViewModelProvider =
    PaymentHistoryFilterViewModelProvider._();

final class PaymentHistoryFilterViewModelProvider
    extends
        $NotifierProvider<
          PaymentHistoryFilterViewModel,
          PaymentHistoryFilterState
        > {
  PaymentHistoryFilterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentHistoryFilterViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentHistoryFilterViewModelHash();

  @$internal
  @override
  PaymentHistoryFilterViewModel create() => PaymentHistoryFilterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentHistoryFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentHistoryFilterState>(value),
    );
  }
}

String _$paymentHistoryFilterViewModelHash() =>
    r'dd8128a9e081630b517570e70334f4b877d6f857';

abstract class _$PaymentHistoryFilterViewModel
    extends $Notifier<PaymentHistoryFilterState> {
  PaymentHistoryFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PaymentHistoryFilterState, PaymentHistoryFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentHistoryFilterState, PaymentHistoryFilterState>,
              PaymentHistoryFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredRiderPayments)
final filteredRiderPaymentsProvider = FilteredRiderPaymentsFamily._();

final class FilteredRiderPaymentsProvider
    extends
        $FunctionalProvider<
          List<PaymentTransaction>,
          List<PaymentTransaction>,
          List<PaymentTransaction>
        >
    with $Provider<List<PaymentTransaction>> {
  FilteredRiderPaymentsProvider._({
    required FilteredRiderPaymentsFamily super.from,
    required List<PaymentTransaction> super.argument,
  }) : super(
         retry: null,
         name: r'filteredRiderPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredRiderPaymentsHash();

  @override
  String toString() {
    return r'filteredRiderPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PaymentTransaction> create(Ref ref) {
    final argument = this.argument as List<PaymentTransaction>;
    return filteredRiderPayments(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PaymentTransaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PaymentTransaction>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredRiderPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredRiderPaymentsHash() =>
    r'536db725e94761b205d050690c1470385603cd5e';

final class FilteredRiderPaymentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<PaymentTransaction>,
          List<PaymentTransaction>
        > {
  FilteredRiderPaymentsFamily._()
    : super(
        retry: null,
        name: r'filteredRiderPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredRiderPaymentsProvider call(List<PaymentTransaction> payments) =>
      FilteredRiderPaymentsProvider._(argument: payments, from: this);

  @override
  String toString() => r'filteredRiderPaymentsProvider';
}

@ProviderFor(DriverEarningsPeriodViewModel)
final driverEarningsPeriodViewModelProvider =
    DriverEarningsPeriodViewModelProvider._();

final class DriverEarningsPeriodViewModelProvider
    extends
        $NotifierProvider<
          DriverEarningsPeriodViewModel,
          DriverEarningsPeriodState
        > {
  DriverEarningsPeriodViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverEarningsPeriodViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverEarningsPeriodViewModelHash();

  @$internal
  @override
  DriverEarningsPeriodViewModel create() => DriverEarningsPeriodViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverEarningsPeriodState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverEarningsPeriodState>(value),
    );
  }
}

String _$driverEarningsPeriodViewModelHash() =>
    r'b6146d3c1252c7665faed188891319da4aa43817';

abstract class _$DriverEarningsPeriodViewModel
    extends $Notifier<DriverEarningsPeriodState> {
  DriverEarningsPeriodState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<DriverEarningsPeriodState, DriverEarningsPeriodState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverEarningsPeriodState, DriverEarningsPeriodState>,
              DriverEarningsPeriodState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Payment Processing View Model

@ProviderFor(PaymentViewModel)
final paymentViewModelProvider = PaymentViewModelProvider._();

/// Payment Processing View Model
final class PaymentViewModelProvider
    extends $AsyncNotifierProvider<PaymentViewModel, void> {
  /// Payment Processing View Model
  PaymentViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentViewModelHash();

  @$internal
  @override
  PaymentViewModel create() => PaymentViewModel();
}

String _$paymentViewModelHash() => r'c1e5cce291bdb664a99de1222cc01f797706f2e7';

/// Payment Processing View Model

abstract class _$PaymentViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<fr.AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<fr.AsyncValue<void>, void>,
              fr.AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Driver Onboarding View Model
///
/// Handles Stripe Connect account creation and onboarding for drivers.

@ProviderFor(DriverOnboardingViewModel)
final driverOnboardingViewModelProvider = DriverOnboardingViewModelProvider._();

/// Driver Onboarding View Model
///
/// Handles Stripe Connect account creation and onboarding for drivers.
final class DriverOnboardingViewModelProvider
    extends $AsyncNotifierProvider<DriverOnboardingViewModel, void> {
  /// Driver Onboarding View Model
  ///
  /// Handles Stripe Connect account creation and onboarding for drivers.
  DriverOnboardingViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverOnboardingViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverOnboardingViewModelHash();

  @$internal
  @override
  DriverOnboardingViewModel create() => DriverOnboardingViewModel();
}

String _$driverOnboardingViewModelHash() =>
    r'246d665232226885a9f823968aa33a9829c1e739';

/// Driver Onboarding View Model
///
/// Handles Stripe Connect account creation and onboarding for drivers.

abstract class _$DriverOnboardingViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<fr.AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<fr.AsyncValue<void>, void>,
              fr.AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DriverStripeOnboardingFlowViewModel)
final driverStripeOnboardingFlowViewModelProvider =
    DriverStripeOnboardingFlowViewModelProvider._();

final class DriverStripeOnboardingFlowViewModelProvider
    extends
        $NotifierProvider<
          DriverStripeOnboardingFlowViewModel,
          DriverStripeOnboardingFlowState
        > {
  DriverStripeOnboardingFlowViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStripeOnboardingFlowViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$driverStripeOnboardingFlowViewModelHash();

  @$internal
  @override
  DriverStripeOnboardingFlowViewModel create() =>
      DriverStripeOnboardingFlowViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverStripeOnboardingFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverStripeOnboardingFlowState>(
        value,
      ),
    );
  }
}

String _$driverStripeOnboardingFlowViewModelHash() =>
    r'88627ba63e583377e99108935cea11756c2a9000';

abstract class _$DriverStripeOnboardingFlowViewModel
    extends $Notifier<DriverStripeOnboardingFlowState> {
  DriverStripeOnboardingFlowState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              DriverStripeOnboardingFlowState,
              DriverStripeOnboardingFlowState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                DriverStripeOnboardingFlowState,
                DriverStripeOnboardingFlowState
              >,
              DriverStripeOnboardingFlowState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Rider Payment History Provider

@ProviderFor(riderPaymentHistory)
final riderPaymentHistoryProvider = RiderPaymentHistoryFamily._();

/// Rider Payment History Provider

final class RiderPaymentHistoryProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  /// Rider Payment History Provider
  RiderPaymentHistoryProvider._({
    required RiderPaymentHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderPaymentHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderPaymentHistoryHash();

  @override
  String toString() {
    return r'riderPaymentHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return riderPaymentHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiderPaymentHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderPaymentHistoryHash() =>
    r'c0e588f34bfc17cbaabf55f4271a9e4087720a48';

/// Rider Payment History Provider

final class RiderPaymentHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentTransaction>>, String> {
  RiderPaymentHistoryFamily._()
    : super(
        retry: null,
        name: r'riderPaymentHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rider Payment History Provider

  RiderPaymentHistoryProvider call(String riderId) =>
      RiderPaymentHistoryProvider._(argument: riderId, from: this);

  @override
  String toString() => r'riderPaymentHistoryProvider';
}

/// Rider Payment History Stream Provider

@ProviderFor(riderPaymentHistoryStream)
final riderPaymentHistoryStreamProvider = RiderPaymentHistoryStreamFamily._();

/// Rider Payment History Stream Provider

final class RiderPaymentHistoryStreamProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          Stream<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $StreamProvider<List<PaymentTransaction>> {
  /// Rider Payment History Stream Provider
  RiderPaymentHistoryStreamProvider._({
    required RiderPaymentHistoryStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderPaymentHistoryStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderPaymentHistoryStreamHash();

  @override
  String toString() {
    return r'riderPaymentHistoryStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return riderPaymentHistoryStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiderPaymentHistoryStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderPaymentHistoryStreamHash() =>
    r'd355c5ec9451e50bbd860c86449040c59d623549';

/// Rider Payment History Stream Provider

final class RiderPaymentHistoryStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PaymentTransaction>>, String> {
  RiderPaymentHistoryStreamFamily._()
    : super(
        retry: null,
        name: r'riderPaymentHistoryStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rider Payment History Stream Provider

  RiderPaymentHistoryStreamProvider call(String riderId) =>
      RiderPaymentHistoryStreamProvider._(argument: riderId, from: this);

  @override
  String toString() => r'riderPaymentHistoryStreamProvider';
}

/// Driver Connected Account View Model

@ProviderFor(DriverConnectedAccountViewModel)
final driverConnectedAccountViewModelProvider =
    DriverConnectedAccountViewModelFamily._();

/// Driver Connected Account View Model
final class DriverConnectedAccountViewModelProvider
    extends
        $AsyncNotifierProvider<
          DriverConnectedAccountViewModel,
          DriverConnectedAccount?
        > {
  /// Driver Connected Account View Model
  DriverConnectedAccountViewModelProvider._({
    required DriverConnectedAccountViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverConnectedAccountViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverConnectedAccountViewModelHash();

  @override
  String toString() {
    return r'driverConnectedAccountViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DriverConnectedAccountViewModel create() => DriverConnectedAccountViewModel();

  @override
  bool operator ==(Object other) {
    return other is DriverConnectedAccountViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverConnectedAccountViewModelHash() =>
    r'4fd66425a9eba429503c76ad3076c38725dead5e';

/// Driver Connected Account View Model

final class DriverConnectedAccountViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DriverConnectedAccountViewModel,
          fr.AsyncValue<DriverConnectedAccount?>,
          DriverConnectedAccount?,
          FutureOr<DriverConnectedAccount?>,
          String
        > {
  DriverConnectedAccountViewModelFamily._()
    : super(
        retry: null,
        name: r'driverConnectedAccountViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Connected Account View Model

  DriverConnectedAccountViewModelProvider call(String driverId) =>
      DriverConnectedAccountViewModelProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverConnectedAccountViewModelProvider';
}

/// Driver Connected Account View Model

abstract class _$DriverConnectedAccountViewModel
    extends $AsyncNotifier<DriverConnectedAccount?> {
  late final _$args = ref.$arg as String;
  String get driverId => _$args;

  FutureOr<DriverConnectedAccount?> build(String driverId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              fr.AsyncValue<DriverConnectedAccount?>,
              DriverConnectedAccount?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                fr.AsyncValue<DriverConnectedAccount?>,
                DriverConnectedAccount?
              >,
              fr.AsyncValue<DriverConnectedAccount?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Driver Earnings Summary Provider

@ProviderFor(driverEarningsSummary)
final driverEarningsSummaryProvider = DriverEarningsSummaryFamily._();

/// Driver Earnings Summary Provider

final class DriverEarningsSummaryProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<EarningsSummary>,
          EarningsSummary,
          FutureOr<EarningsSummary>
        >
    with $FutureModifier<EarningsSummary>, $FutureProvider<EarningsSummary> {
  /// Driver Earnings Summary Provider
  DriverEarningsSummaryProvider._({
    required DriverEarningsSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverEarningsSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverEarningsSummaryHash();

  @override
  String toString() {
    return r'driverEarningsSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EarningsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EarningsSummary> create(Ref ref) {
    final argument = this.argument as String;
    return driverEarningsSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverEarningsSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverEarningsSummaryHash() =>
    r'3b93788a1a85d89368016f36d3564f007a506163';

/// Driver Earnings Summary Provider

final class DriverEarningsSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EarningsSummary>, String> {
  DriverEarningsSummaryFamily._()
    : super(
        retry: null,
        name: r'driverEarningsSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Earnings Summary Provider

  DriverEarningsSummaryProvider call(String driverId) =>
      DriverEarningsSummaryProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverEarningsSummaryProvider';
}

/// Driver Earnings Transactions Provider

@ProviderFor(driverEarningsTransactions)
final driverEarningsTransactionsProvider = DriverEarningsTransactionsFamily._();

/// Driver Earnings Transactions Provider

final class DriverEarningsTransactionsProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  /// Driver Earnings Transactions Provider
  DriverEarningsTransactionsProvider._({
    required DriverEarningsTransactionsFamily super.from,
    required (String, {DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'driverEarningsTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverEarningsTransactionsHash();

  @override
  String toString() {
    return r'driverEarningsTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    final argument =
        this.argument as (String, {DateTime? startDate, DateTime? endDate});
    return driverEarningsTransactions(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DriverEarningsTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverEarningsTransactionsHash() =>
    r'dfa0e8c81f20c61ecf7a893c9bd9939e1688e77d';

/// Driver Earnings Transactions Provider

final class DriverEarningsTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PaymentTransaction>>,
          (String, {DateTime? startDate, DateTime? endDate})
        > {
  DriverEarningsTransactionsFamily._()
    : super(
        retry: null,
        name: r'driverEarningsTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Earnings Transactions Provider

  DriverEarningsTransactionsProvider call(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => DriverEarningsTransactionsProvider._(
    argument: (driverId, startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'driverEarningsTransactionsProvider';
}

/// Driver Payouts Provider

@ProviderFor(driverPayouts)
final driverPayoutsProvider = DriverPayoutsFamily._();

/// Driver Payouts Provider

final class DriverPayoutsProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<List<DriverPayout>>,
          List<DriverPayout>,
          FutureOr<List<DriverPayout>>
        >
    with
        $FutureModifier<List<DriverPayout>>,
        $FutureProvider<List<DriverPayout>> {
  /// Driver Payouts Provider
  DriverPayoutsProvider._({
    required DriverPayoutsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverPayoutsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverPayoutsHash();

  @override
  String toString() {
    return r'driverPayoutsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DriverPayout>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverPayout>> create(Ref ref) {
    final argument = this.argument as String;
    return driverPayouts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverPayoutsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverPayoutsHash() => r'582751cc4fae7553aacfe18a70d7fe546ef7cf5c';

/// Driver Payouts Provider

final class DriverPayoutsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DriverPayout>>, String> {
  DriverPayoutsFamily._()
    : super(
        retry: null,
        name: r'driverPayoutsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Payouts Provider

  DriverPayoutsProvider call(String driverId) =>
      DriverPayoutsProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverPayoutsProvider';
}

/// Single Payout Detail Provider

@ProviderFor(payoutDetail)
final payoutDetailProvider = PayoutDetailFamily._();

/// Single Payout Detail Provider

final class PayoutDetailProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<DriverPayout?>,
          DriverPayout?,
          FutureOr<DriverPayout?>
        >
    with $FutureModifier<DriverPayout?>, $FutureProvider<DriverPayout?> {
  /// Single Payout Detail Provider
  PayoutDetailProvider._({
    required PayoutDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'payoutDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$payoutDetailHash();

  @override
  String toString() {
    return r'payoutDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DriverPayout?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverPayout?> create(Ref ref) {
    final argument = this.argument as String;
    return payoutDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PayoutDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$payoutDetailHash() => r'c08b3e396e5d2c1e337c078ee77cdc6eefcbc854';

/// Single Payout Detail Provider

final class PayoutDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DriverPayout?>, String> {
  PayoutDetailFamily._()
    : super(
        retry: null,
        name: r'payoutDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single Payout Detail Provider

  PayoutDetailProvider call(String payoutId) =>
      PayoutDetailProvider._(argument: payoutId, from: this);

  @override
  String toString() => r'payoutDetailProvider';
}

/// Driver Payout View Model

@ProviderFor(DriverPayoutViewModel)
final driverPayoutViewModelProvider = DriverPayoutViewModelProvider._();

/// Driver Payout View Model
final class DriverPayoutViewModelProvider
    extends $AsyncNotifierProvider<DriverPayoutViewModel, void> {
  /// Driver Payout View Model
  DriverPayoutViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverPayoutViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverPayoutViewModelHash();

  @$internal
  @override
  DriverPayoutViewModel create() => DriverPayoutViewModel();
}

String _$driverPayoutViewModelHash() =>
    r'c98bd9f080d00e919c5eb8eb1ceefbd6ab9abad2';

/// Driver Payout View Model

abstract class _$DriverPayoutViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<fr.AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<fr.AsyncValue<void>, void>,
              fr.AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider to get current driver's Stripe status

@ProviderFor(driverStripeStatus)
final driverStripeStatusProvider = DriverStripeStatusProvider._();

/// Provider to get current driver's Stripe status

final class DriverStripeStatusProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<DriverStripeStatus>,
          DriverStripeStatus,
          FutureOr<DriverStripeStatus>
        >
    with
        $FutureModifier<DriverStripeStatus>,
        $FutureProvider<DriverStripeStatus> {
  /// Provider to get current driver's Stripe status
  DriverStripeStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStripeStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStripeStatusHash();

  @$internal
  @override
  $FutureProviderElement<DriverStripeStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverStripeStatus> create(Ref ref) {
    return driverStripeStatus(ref);
  }
}

String _$driverStripeStatusHash() =>
    r'fe9bb6950a9c477e6940cc9bbda1d348d624b6bf';

@ProviderFor(currentDriverConnectedAccount)
final currentDriverConnectedAccountProvider =
    CurrentDriverConnectedAccountProvider._();

final class CurrentDriverConnectedAccountProvider
    extends
        $FunctionalProvider<
          fr.AsyncValue<DriverConnectedAccount?>,
          DriverConnectedAccount?,
          Stream<DriverConnectedAccount?>
        >
    with
        $FutureModifier<DriverConnectedAccount?>,
        $StreamProvider<DriverConnectedAccount?> {
  CurrentDriverConnectedAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDriverConnectedAccountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDriverConnectedAccountHash();

  @$internal
  @override
  $StreamProviderElement<DriverConnectedAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DriverConnectedAccount?> create(Ref ref) {
    return currentDriverConnectedAccount(ref);
  }
}

String _$currentDriverConnectedAccountHash() =>
    r'655fd339f4441940b5a8dc9ef8e573fdc05cf5fc';
