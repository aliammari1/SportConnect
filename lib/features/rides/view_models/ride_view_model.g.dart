// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RideDetailUiViewModel)
final rideDetailUiViewModelProvider = RideDetailUiViewModelFamily._();

final class RideDetailUiViewModelProvider
    extends $NotifierProvider<RideDetailUiViewModel, RideDetailUiState> {
  RideDetailUiViewModelProvider._({
    required RideDetailUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideDetailUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideDetailUiViewModelHash();

  @override
  String toString() {
    return r'rideDetailUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RideDetailUiViewModel create() => RideDetailUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideDetailUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideDetailUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RideDetailUiViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideDetailUiViewModelHash() =>
    r'ca6b53b3943a803cc6b5b0d845f1552a8524e892';

final class RideDetailUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RideDetailUiViewModel,
          RideDetailUiState,
          RideDetailUiState,
          RideDetailUiState,
          String
        > {
  RideDetailUiViewModelFamily._()
    : super(
        retry: null,
        name: r'rideDetailUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RideDetailUiViewModelProvider call(String rideId) =>
      RideDetailUiViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideDetailUiViewModelProvider';
}

abstract class _$RideDetailUiViewModel extends $Notifier<RideDetailUiState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  RideDetailUiState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideDetailUiState, RideDetailUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideDetailUiState, RideDetailUiState>,
              RideDetailUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Delegates ride operations through the [RideService] for validated
/// business logic. Falls back to the repository only for operations
/// that don't require additional validation (start, complete, stream).
// keepAlive: action-only VM - accessed from notification/background contexts.

@ProviderFor(RideActionsViewModel)
final rideActionsViewModelProvider = RideActionsViewModelProvider._();

/// Delegates ride operations through the [RideService] for validated
/// business logic. Falls back to the repository only for operations
/// that don't require additional validation (start, complete, stream).
// keepAlive: action-only VM - accessed from notification/background contexts.
final class RideActionsViewModelProvider
    extends $NotifierProvider<RideActionsViewModel, void> {
  /// Delegates ride operations through the [RideService] for validated
  /// business logic. Falls back to the repository only for operations
  /// that don't require additional validation (start, complete, stream).
  // keepAlive: action-only VM - accessed from notification/background contexts.
  RideActionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideActionsViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideActionsViewModelHash();

  @$internal
  @override
  RideActionsViewModel create() => RideActionsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rideActionsViewModelHash() =>
    r'928de38b15380cf43fab6eb80ac42d7fdee7d3ac';

/// Delegates ride operations through the [RideService] for validated
/// business logic. Falls back to the repository only for operations
/// that don't require additional validation (start, complete, stream).
// keepAlive: action-only VM - accessed from notification/background contexts.

abstract class _$RideActionsViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CancellationReasonViewModel)
final cancellationReasonViewModelProvider =
    CancellationReasonViewModelFamily._();

final class CancellationReasonViewModelProvider
    extends
        $NotifierProvider<
          CancellationReasonViewModel,
          CancellationReasonState
        > {
  CancellationReasonViewModelProvider._({
    required CancellationReasonViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cancellationReasonViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cancellationReasonViewModelHash();

  @override
  String toString() {
    return r'cancellationReasonViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CancellationReasonViewModel create() => CancellationReasonViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CancellationReasonState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CancellationReasonState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CancellationReasonViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cancellationReasonViewModelHash() =>
    r'dd435b2258ce45c75391ebdb3a5205d91b8a79cf';

final class CancellationReasonViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CancellationReasonViewModel,
          CancellationReasonState,
          CancellationReasonState,
          CancellationReasonState,
          String
        > {
  CancellationReasonViewModelFamily._()
    : super(
        retry: null,
        name: r'cancellationReasonViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CancellationReasonViewModelProvider call(String rideId) =>
      CancellationReasonViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'cancellationReasonViewModelProvider';
}

abstract class _$CancellationReasonViewModel
    extends $Notifier<CancellationReasonState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  CancellationReasonState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<CancellationReasonState, CancellationReasonState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CancellationReasonState, CancellationReasonState>,
              CancellationReasonState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(DisputeFormViewModel)
final disputeFormViewModelProvider = DisputeFormViewModelFamily._();

final class DisputeFormViewModelProvider
    extends $NotifierProvider<DisputeFormViewModel, DisputeFormState> {
  DisputeFormViewModelProvider._({
    required DisputeFormViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'disputeFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$disputeFormViewModelHash();

  @override
  String toString() {
    return r'disputeFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DisputeFormViewModel create() => DisputeFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisputeFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisputeFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DisputeFormViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$disputeFormViewModelHash() =>
    r'8fdf7a9f414be93080f45c004bc5650dc28a5629';

final class DisputeFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DisputeFormViewModel,
          DisputeFormState,
          DisputeFormState,
          DisputeFormState,
          String
        > {
  DisputeFormViewModelFamily._()
    : super(
        retry: null,
        name: r'disputeFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DisputeFormViewModelProvider call(String rideId) =>
      DisputeFormViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'disputeFormViewModelProvider';
}

abstract class _$DisputeFormViewModel extends $Notifier<DisputeFormState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  DisputeFormState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DisputeFormState, DisputeFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DisputeFormState, DisputeFormState>,
              DisputeFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Streams the driver's live GPS location for a ride.

@ProviderFor(driverLiveLocation)
final driverLiveLocationProvider = DriverLiveLocationFamily._();

/// Streams the driver's live GPS location for a ride.

final class DriverLiveLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<({double latitude, double longitude})?>,
          ({double latitude, double longitude})?,
          Stream<({double latitude, double longitude})?>
        >
    with
        $FutureModifier<({double latitude, double longitude})?>,
        $StreamProvider<({double latitude, double longitude})?> {
  /// Streams the driver's live GPS location for a ride.
  DriverLiveLocationProvider._({
    required DriverLiveLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverLiveLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverLiveLocationHash();

  @override
  String toString() {
    return r'driverLiveLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<({double latitude, double longitude})?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<({double latitude, double longitude})?> create(Ref ref) {
    final argument = this.argument as String;
    return driverLiveLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverLiveLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverLiveLocationHash() =>
    r'52e9c60a6af6559413c59aacb58bee755b1aca7c';

/// Streams the driver's live GPS location for a ride.

final class DriverLiveLocationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<({double latitude, double longitude})?>,
          String
        > {
  DriverLiveLocationFamily._()
    : super(
        retry: null,
        name: r'driverLiveLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams the driver's live GPS location for a ride.

  DriverLiveLocationProvider call(String rideId) =>
      DriverLiveLocationProvider._(argument: rideId, from: this);

  @override
  String toString() => r'driverLiveLocationProvider';
}

@ProviderFor(ridePhaseStream)
final ridePhaseStreamProvider = RidePhaseStreamFamily._();

final class RidePhaseStreamProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  RidePhaseStreamProvider._({
    required RidePhaseStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ridePhaseStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ridePhaseStreamHash();

  @override
  String toString() {
    return r'ridePhaseStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return ridePhaseStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RidePhaseStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ridePhaseStreamHash() => r'520f49bf1df6ec93e9eb3a5bf61307fb9f9d9a10';

final class RidePhaseStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  RidePhaseStreamFamily._()
    : super(
        retry: null,
        name: r'ridePhaseStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RidePhaseStreamProvider call(String rideId) =>
      RidePhaseStreamProvider._(argument: rideId, from: this);

  @override
  String toString() => r'ridePhaseStreamProvider';
}

/// Ride Form View Model

@ProviderFor(RideFormViewModel)
final rideFormViewModelProvider = RideFormViewModelProvider._();

/// Ride Form View Model
final class RideFormViewModelProvider
    extends $NotifierProvider<RideFormViewModel, RideFormState> {
  /// Ride Form View Model
  RideFormViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideFormViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideFormViewModelHash();

  @$internal
  @override
  RideFormViewModel create() => RideFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideFormState>(value),
    );
  }
}

String _$rideFormViewModelHash() => r'cba749db2931dc1f761910c12587e7fb51eab731';

/// Ride Form View Model

abstract class _$RideFormViewModel extends $Notifier<RideFormState> {
  RideFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideFormState, RideFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideFormState, RideFormState>,
              RideFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(rideSearchResults)
final rideSearchResultsProvider = RideSearchResultsProvider._();

final class RideSearchResultsProvider
    extends
        $FunctionalProvider<
          RideSearchResultsData,
          RideSearchResultsData,
          RideSearchResultsData
        >
    with $Provider<RideSearchResultsData> {
  RideSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSearchResultsHash();

  @$internal
  @override
  $ProviderElement<RideSearchResultsData> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RideSearchResultsData create(Ref ref) {
    return rideSearchResults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideSearchResultsData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideSearchResultsData>(value),
    );
  }
}

String _$rideSearchResultsHash() => r'02423f4db1db36494f445968d0193f650c11bef1';

/// Ride Search View Model
///
/// Uses client-side batching: the Firestore geo query returns all matches
/// (up to 100) since cursor pagination isn't possible with latitude
/// inequality filters. Results are stored in [_allResults] and surfaced
/// in pages of [_pageSize] via [loadMore].

@ProviderFor(RideSearchViewModel)
final rideSearchViewModelProvider = RideSearchViewModelProvider._();

/// Ride Search View Model
///
/// Uses client-side batching: the Firestore geo query returns all matches
/// (up to 100) since cursor pagination isn't possible with latitude
/// inequality filters. Results are stored in [_allResults] and surfaced
/// in pages of [_pageSize] via [loadMore].
final class RideSearchViewModelProvider
    extends $NotifierProvider<RideSearchViewModel, RideSearchState> {
  /// Ride Search View Model
  ///
  /// Uses client-side batching: the Firestore geo query returns all matches
  /// (up to 100) since cursor pagination isn't possible with latitude
  /// inequality filters. Results are stored in [_allResults] and surfaced
  /// in pages of [_pageSize] via [loadMore].
  RideSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSearchViewModelHash();

  @$internal
  @override
  RideSearchViewModel create() => RideSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideSearchState>(value),
    );
  }
}

String _$rideSearchViewModelHash() =>
    r'8155e69a06aea98ad386cbefad9c59dc7b862e7e';

/// Ride Search View Model
///
/// Uses client-side batching: the Firestore geo query returns all matches
/// (up to 100) since cursor pagination isn't possible with latitude
/// inequality filters. Results are stored in [_allResults] and surfaced
/// in pages of [_pageSize] via [loadMore].

abstract class _$RideSearchViewModel extends $Notifier<RideSearchState> {
  RideSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideSearchState, RideSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideSearchState, RideSearchState>,
              RideSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.

@ProviderFor(RideDetailViewModel)
final rideDetailViewModelProvider = RideDetailViewModelFamily._();

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.
final class RideDetailViewModelProvider
    extends $NotifierProvider<RideDetailViewModel, RideDetailState> {
  /// Single Ride Detail View Model — views watch only this, never separate
  /// stream/booking providers directly.
  RideDetailViewModelProvider._({
    required RideDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideDetailViewModelHash();

  @override
  String toString() {
    return r'rideDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RideDetailViewModel create() => RideDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RideDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideDetailViewModelHash() =>
    r'cf948c23599ca1f3cba85f5881ab74cd8f3316e7';

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.

final class RideDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RideDetailViewModel,
          RideDetailState,
          RideDetailState,
          RideDetailState,
          String
        > {
  RideDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'rideDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single Ride Detail View Model — views watch only this, never separate
  /// stream/booking providers directly.

  RideDetailViewModelProvider call(String rideId) =>
      RideDetailViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideDetailViewModelProvider';
}

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.

abstract class _$RideDetailViewModel extends $Notifier<RideDetailState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  RideDetailState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideDetailState, RideDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideDetailState, RideDetailState>,
              RideDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// ViewModel for active-ride screens — views watch only this provider.

@ProviderFor(ActiveRideViewModel)
final activeRideViewModelProvider = ActiveRideViewModelFamily._();

/// ViewModel for active-ride screens — views watch only this provider.
final class ActiveRideViewModelProvider
    extends $NotifierProvider<ActiveRideViewModel, ActiveRideState> {
  /// ViewModel for active-ride screens — views watch only this provider.
  ActiveRideViewModelProvider._({
    required ActiveRideViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeRideViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeRideViewModelHash();

  @override
  String toString() {
    return r'activeRideViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveRideViewModel create() => ActiveRideViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveRideState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveRideState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveRideViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeRideViewModelHash() =>
    r'83514944963a34d79e018f9f7d6c0d4be8a2086e';

/// ViewModel for active-ride screens — views watch only this provider.

final class ActiveRideViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveRideViewModel,
          ActiveRideState,
          ActiveRideState,
          ActiveRideState,
          String
        > {
  ActiveRideViewModelFamily._()
    : super(
        retry: null,
        name: r'activeRideViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ViewModel for active-ride screens — views watch only this provider.

  ActiveRideViewModelProvider call(String rideId) =>
      ActiveRideViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'activeRideViewModelProvider';
}

/// ViewModel for active-ride screens — views watch only this provider.

abstract class _$ActiveRideViewModel extends $Notifier<ActiveRideState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  ActiveRideState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ActiveRideState, ActiveRideState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveRideState, ActiveRideState>,
              ActiveRideState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// User's Rides Provider (as driver)

@ProviderFor(myRidesAsDriver)
final myRidesAsDriverProvider = MyRidesAsDriverFamily._();

/// User's Rides Provider (as driver)

final class MyRidesAsDriverProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          FutureOr<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $FutureProvider<List<RideModel>> {
  /// User's Rides Provider (as driver)
  MyRidesAsDriverProvider._({
    required MyRidesAsDriverFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsDriverProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsDriverHash();

  @override
  String toString() {
    return r'myRidesAsDriverProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsDriver(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsDriverProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsDriverHash() => r'3c8f52a8143b6b23c2c59db7d2d7ad47f8795875';

/// User's Rides Provider (as driver)

final class MyRidesAsDriverFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RideModel>>, String> {
  MyRidesAsDriverFamily._()
    : super(
        retry: null,
        name: r'myRidesAsDriverProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides Provider (as driver)

  MyRidesAsDriverProvider call(String userId) =>
      MyRidesAsDriverProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsDriverProvider';
}

/// User's Rides Stream Provider (as driver) - Real-time

@ProviderFor(myRidesAsDriverStream)
final myRidesAsDriverStreamProvider = MyRidesAsDriverStreamFamily._();

/// User's Rides Stream Provider (as driver) - Real-time

final class MyRidesAsDriverStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// User's Rides Stream Provider (as driver) - Real-time
  MyRidesAsDriverStreamProvider._({
    required MyRidesAsDriverStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsDriverStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsDriverStreamHash();

  @override
  String toString() {
    return r'myRidesAsDriverStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsDriverStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsDriverStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsDriverStreamHash() =>
    r'f60e94e4f91167f9f36c5a88de72d58ab497012a';

/// User's Rides Stream Provider (as driver) - Real-time

final class MyRidesAsDriverStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, String> {
  MyRidesAsDriverStreamFamily._()
    : super(
        retry: null,
        name: r'myRidesAsDriverStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides Stream Provider (as driver) - Real-time

  MyRidesAsDriverStreamProvider call(String userId) =>
      MyRidesAsDriverStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsDriverStreamProvider';
}

/// User's Rides as Passenger Stream Provider

@ProviderFor(myRidesAsPassengerStream)
final myRidesAsPassengerStreamProvider = MyRidesAsPassengerStreamFamily._();

/// User's Rides as Passenger Stream Provider

final class MyRidesAsPassengerStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// User's Rides as Passenger Stream Provider
  MyRidesAsPassengerStreamProvider._({
    required MyRidesAsPassengerStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsPassengerStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsPassengerStreamHash();

  @override
  String toString() {
    return r'myRidesAsPassengerStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsPassengerStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsPassengerStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsPassengerStreamHash() =>
    r'0839ae884645c1920dca8617f4776e51f6a762b5';

/// User's Rides as Passenger Stream Provider

final class MyRidesAsPassengerStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, String> {
  MyRidesAsPassengerStreamFamily._()
    : super(
        retry: null,
        name: r'myRidesAsPassengerStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides as Passenger Stream Provider

  MyRidesAsPassengerStreamProvider call(String userId) =>
      MyRidesAsPassengerStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsPassengerStreamProvider';
}

/// Nearby Rides Stream Provider

@ProviderFor(nearbyRides)
final nearbyRidesProvider = NearbyRidesFamily._();

/// Nearby Rides Stream Provider

final class NearbyRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// Nearby Rides Stream Provider
  NearbyRidesProvider._({
    required NearbyRidesFamily super.from,
    required ({double latitude, double longitude}) super.argument,
  }) : super(
         retry: null,
         name: r'nearbyRidesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyRidesHash();

  @override
  String toString() {
    return r'nearbyRidesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as ({double latitude, double longitude});
    return nearbyRides(
      ref,
      latitude: argument.latitude,
      longitude: argument.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyRidesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyRidesHash() => r'29c2605890770901bd81120b0ad349c05180f01c';

/// Nearby Rides Stream Provider

final class NearbyRidesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<RideModel>>,
          ({double latitude, double longitude})
        > {
  NearbyRidesFamily._()
    : super(
        retry: null,
        name: r'nearbyRidesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nearby Rides Stream Provider

  NearbyRidesProvider call({
    required double latitude,
    required double longitude,
  }) => NearbyRidesProvider._(
    argument: (latitude: latitude, longitude: longitude),
    from: this,
  );

  @override
  String toString() => r'nearbyRidesProvider';
}

/// Real-time stream of bookings for a given ride, scoped to the current user's role.
///
/// • Driver  → all bookings for the ride (filtered by driverId so Firestore
///             security rules can allow the collection query).
/// • Passenger → only their own booking (filtered by passengerId).
///
/// The role is determined lazily from [rideStreamProvider] so there is no
/// extra Firestore read — the ride document is already being watched.

@ProviderFor(bookingsByRide)
final bookingsByRideProvider = BookingsByRideFamily._();

/// Real-time stream of bookings for a given ride, scoped to the current user's role.
///
/// • Driver  → all bookings for the ride (filtered by driverId so Firestore
///             security rules can allow the collection query).
/// • Passenger → only their own booking (filtered by passengerId).
///
/// The role is determined lazily from [rideStreamProvider] so there is no
/// extra Firestore read — the ride document is already being watched.

final class BookingsByRideProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideBooking>>,
          List<RideBooking>,
          Stream<List<RideBooking>>
        >
    with
        $FutureModifier<List<RideBooking>>,
        $StreamProvider<List<RideBooking>> {
  /// Real-time stream of bookings for a given ride, scoped to the current user's role.
  ///
  /// • Driver  → all bookings for the ride (filtered by driverId so Firestore
  ///             security rules can allow the collection query).
  /// • Passenger → only their own booking (filtered by passengerId).
  ///
  /// The role is determined lazily from [rideStreamProvider] so there is no
  /// extra Firestore read — the ride document is already being watched.
  BookingsByRideProvider._({
    required BookingsByRideFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingsByRideProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingsByRideHash();

  @override
  String toString() {
    return r'bookingsByRideProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideBooking>> create(Ref ref) {
    final argument = this.argument as String;
    return bookingsByRide(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingsByRideProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingsByRideHash() => r'e517bd21e25da61cfb0260450031bed94889492f';

/// Real-time stream of bookings for a given ride, scoped to the current user's role.
///
/// • Driver  → all bookings for the ride (filtered by driverId so Firestore
///             security rules can allow the collection query).
/// • Passenger → only their own booking (filtered by passengerId).
///
/// The role is determined lazily from [rideStreamProvider] so there is no
/// extra Firestore read — the ride document is already being watched.

final class BookingsByRideFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideBooking>>, String> {
  BookingsByRideFamily._()
    : super(
        retry: null,
        name: r'bookingsByRideProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Real-time stream of bookings for a given ride, scoped to the current user's role.
  ///
  /// • Driver  → all bookings for the ride (filtered by driverId so Firestore
  ///             security rules can allow the collection query).
  /// • Passenger → only their own booking (filtered by passengerId).
  ///
  /// The role is determined lazily from [rideStreamProvider] so there is no
  /// extra Firestore read — the ride document is already being watched.

  BookingsByRideProvider call(String rideId) =>
      BookingsByRideProvider._(argument: rideId, from: this);

  @override
  String toString() => r'bookingsByRideProvider';
}

@ProviderFor(pickedUpPassengersStream)
final pickedUpPassengersStreamProvider = PickedUpPassengersStreamFamily._();

final class PickedUpPassengersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  PickedUpPassengersStreamProvider._({
    required PickedUpPassengersStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pickedUpPassengersStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pickedUpPassengersStreamHash();

  @override
  String toString() {
    return r'pickedUpPassengersStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return pickedUpPassengersStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PickedUpPassengersStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pickedUpPassengersStreamHash() =>
    r'17db255e96d736fb07421f70772cb18625b52b92';

final class PickedUpPassengersStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  PickedUpPassengersStreamFamily._()
    : super(
        retry: null,
        name: r'pickedUpPassengersStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PickedUpPassengersStreamProvider call(String rideId) =>
      PickedUpPassengersStreamProvider._(argument: rideId, from: this);

  @override
  String toString() => r'pickedUpPassengersStreamProvider';
}

/// Real-time stream of a single booking by ID.
///
/// Wraps [BookingRepository.streamBookingById] so views never import the
/// repository layer directly.

@ProviderFor(bookingStream)
final bookingStreamProvider = BookingStreamFamily._();

/// Real-time stream of a single booking by ID.
///
/// Wraps [BookingRepository.streamBookingById] so views never import the
/// repository layer directly.

final class BookingStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideBooking?>,
          RideBooking?,
          Stream<RideBooking?>
        >
    with $FutureModifier<RideBooking?>, $StreamProvider<RideBooking?> {
  /// Real-time stream of a single booking by ID.
  ///
  /// Wraps [BookingRepository.streamBookingById] so views never import the
  /// repository layer directly.
  BookingStreamProvider._({
    required BookingStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingStreamHash();

  @override
  String toString() {
    return r'bookingStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RideBooking?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RideBooking?> create(Ref ref) {
    final argument = this.argument as String;
    return bookingStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingStreamHash() => r'351f839d789404896c93b1583525689f5d093c59';

/// Real-time stream of a single booking by ID.
///
/// Wraps [BookingRepository.streamBookingById] so views never import the
/// repository layer directly.

final class BookingStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RideBooking?>, String> {
  BookingStreamFamily._()
    : super(
        retry: null,
        name: r'bookingStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Real-time stream of a single booking by ID.
  ///
  /// Wraps [BookingRepository.streamBookingById] so views never import the
  /// repository layer directly.

  BookingStreamProvider call(String bookingId) =>
      BookingStreamProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingStreamProvider';
}

/// Real-time stream of all bookings for a given passenger.
///
/// Used on the pending-booking screen where the passenger polls for
/// status changes before being auto-navigated.
///
/// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
/// previous user's Firestore subscription, and watches [currentAuthUidProvider]
/// so it bails out and re-runs whenever the authenticated user changes —
/// preventing one account from observing another account's bookings.

@ProviderFor(bookingsByPassenger)
final bookingsByPassengerProvider = BookingsByPassengerFamily._();

/// Real-time stream of all bookings for a given passenger.
///
/// Used on the pending-booking screen where the passenger polls for
/// status changes before being auto-navigated.
///
/// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
/// previous user's Firestore subscription, and watches [currentAuthUidProvider]
/// so it bails out and re-runs whenever the authenticated user changes —
/// preventing one account from observing another account's bookings.

final class BookingsByPassengerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideBooking>>,
          List<RideBooking>,
          Stream<List<RideBooking>>
        >
    with
        $FutureModifier<List<RideBooking>>,
        $StreamProvider<List<RideBooking>> {
  /// Real-time stream of all bookings for a given passenger.
  ///
  /// Used on the pending-booking screen where the passenger polls for
  /// status changes before being auto-navigated.
  ///
  /// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
  /// previous user's Firestore subscription, and watches [currentAuthUidProvider]
  /// so it bails out and re-runs whenever the authenticated user changes —
  /// preventing one account from observing another account's bookings.
  BookingsByPassengerProvider._({
    required BookingsByPassengerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingsByPassengerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingsByPassengerHash();

  @override
  String toString() {
    return r'bookingsByPassengerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideBooking>> create(Ref ref) {
    final argument = this.argument as String;
    return bookingsByPassenger(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingsByPassengerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingsByPassengerHash() =>
    r'262f56a95ae45320a507271fc417f1eaca5f1a73';

/// Real-time stream of all bookings for a given passenger.
///
/// Used on the pending-booking screen where the passenger polls for
/// status changes before being auto-navigated.
///
/// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
/// previous user's Firestore subscription, and watches [currentAuthUidProvider]
/// so it bails out and re-runs whenever the authenticated user changes —
/// preventing one account from observing another account's bookings.

final class BookingsByPassengerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideBooking>>, String> {
  BookingsByPassengerFamily._()
    : super(
        retry: null,
        name: r'bookingsByPassengerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Real-time stream of all bookings for a given passenger.
  ///
  /// Used on the pending-booking screen where the passenger polls for
  /// status changes before being auto-navigated.
  ///
  /// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
  /// previous user's Firestore subscription, and watches [currentAuthUidProvider]
  /// so it bails out and re-runs whenever the authenticated user changes —
  /// preventing one account from observing another account's bookings.

  BookingsByPassengerProvider call(String passengerId) =>
      BookingsByPassengerProvider._(argument: passengerId, from: this);

  @override
  String toString() => r'bookingsByPassengerProvider';
}

/// All Active Rides Stream Provider (for search screen)

@ProviderFor(activeRides)
final activeRidesProvider = ActiveRidesProvider._();

/// All Active Rides Stream Provider (for search screen)

final class ActiveRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// All Active Rides Stream Provider (for search screen)
  ActiveRidesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeRidesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeRidesHash();

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    return activeRides(ref);
  }
}

String _$activeRidesHash() => r'169a372aaad111eff5d3feed98ce7c4009398b96';

/// Single Ride Stream Provider (for active ride screens)

@ProviderFor(rideStream)
final rideStreamProvider = RideStreamFamily._();

/// Single Ride Stream Provider (for active ride screens)

final class RideStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideModel?>,
          RideModel?,
          Stream<RideModel?>
        >
    with $FutureModifier<RideModel?>, $StreamProvider<RideModel?> {
  /// Single Ride Stream Provider (for active ride screens)
  RideStreamProvider._({
    required RideStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideStreamHash();

  @override
  String toString() {
    return r'rideStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RideModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<RideModel?> create(Ref ref) {
    final argument = this.argument as String;
    return rideStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RideStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideStreamHash() => r'3ba2abd8f2013a5f99cd1950185c4d2490889277';

/// Single Ride Stream Provider (for active ride screens)

final class RideStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RideModel?>, String> {
  RideStreamFamily._()
    : super(
        retry: null,
        name: r'rideStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single Ride Stream Provider (for active ride screens)

  RideStreamProvider call(String rideId) =>
      RideStreamProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideStreamProvider';
}

/// Ride reliability stats for a user (cancel & no-show counts).
///
/// Streams the user's ride history (completed + cancelled) and counts
/// how many were cancelled by the driver.

@ProviderFor(userRideReliability)
final userRideReliabilityProvider = UserRideReliabilityFamily._();

/// Ride reliability stats for a user (cancel & no-show counts).
///
/// Streams the user's ride history (completed + cancelled) and counts
/// how many were cancelled by the driver.

final class UserRideReliabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int cancelCount, int noShowCount})>,
          ({int cancelCount, int noShowCount}),
          Stream<({int cancelCount, int noShowCount})>
        >
    with
        $FutureModifier<({int cancelCount, int noShowCount})>,
        $StreamProvider<({int cancelCount, int noShowCount})> {
  /// Ride reliability stats for a user (cancel & no-show counts).
  ///
  /// Streams the user's ride history (completed + cancelled) and counts
  /// how many were cancelled by the driver.
  UserRideReliabilityProvider._({
    required UserRideReliabilityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRideReliabilityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRideReliabilityHash();

  @override
  String toString() {
    return r'userRideReliabilityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<({int cancelCount, int noShowCount})> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<({int cancelCount, int noShowCount})> create(Ref ref) {
    final argument = this.argument as String;
    return userRideReliability(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRideReliabilityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRideReliabilityHash() =>
    r'4d698fe2607d545d7b3af30cf0f5226ea20de942';

/// Ride reliability stats for a user (cancel & no-show counts).
///
/// Streams the user's ride history (completed + cancelled) and counts
/// how many were cancelled by the driver.

final class UserRideReliabilityFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<({int cancelCount, int noShowCount})>,
          String
        > {
  UserRideReliabilityFamily._()
    : super(
        retry: null,
        name: r'userRideReliabilityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ride reliability stats for a user (cancel & no-show counts).
  ///
  /// Streams the user's ride history (completed + cancelled) and counts
  /// how many were cancelled by the driver.

  UserRideReliabilityProvider call(String userId) =>
      UserRideReliabilityProvider._(argument: userId, from: this);

  @override
  String toString() => r'userRideReliabilityProvider';
}

/// Delegates dispute submission through [DisputeRepository].

@ProviderFor(DisputeViewModel)
final disputeViewModelProvider = DisputeViewModelProvider._();

/// Delegates dispute submission through [DisputeRepository].
final class DisputeViewModelProvider
    extends $NotifierProvider<DisputeViewModel, void> {
  /// Delegates dispute submission through [DisputeRepository].
  DisputeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disputeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disputeViewModelHash();

  @$internal
  @override
  DisputeViewModel create() => DisputeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$disputeViewModelHash() => r'44f5a40963eb7cf1814a489cb187a02983f80e5f';

/// Delegates dispute submission through [DisputeRepository].

abstract class _$DisputeViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
