// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_view_ride_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverRideScreenUiViewModel)
final driverRideScreenUiViewModelProvider =
    DriverRideScreenUiViewModelFamily._();

final class DriverRideScreenUiViewModelProvider
    extends
        $NotifierProvider<
          DriverRideScreenUiViewModel,
          DriverRideScreenUiState
        > {
  DriverRideScreenUiViewModelProvider._({
    required DriverRideScreenUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverRideScreenUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverRideScreenUiViewModelHash();

  @override
  String toString() {
    return r'driverRideScreenUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DriverRideScreenUiViewModel create() => DriverRideScreenUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverRideScreenUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverRideScreenUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DriverRideScreenUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverRideScreenUiViewModelHash() =>
    r'fadf71629048bd456df0ac477cac6e0f3d09e3a4';

final class DriverRideScreenUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DriverRideScreenUiViewModel,
          DriverRideScreenUiState,
          DriverRideScreenUiState,
          DriverRideScreenUiState,
          String
        > {
  DriverRideScreenUiViewModelFamily._()
    : super(
        retry: null,
        name: r'driverRideScreenUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DriverRideScreenUiViewModelProvider call(String rideId) =>
      DriverRideScreenUiViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'driverRideScreenUiViewModelProvider';
}

abstract class _$DriverRideScreenUiViewModel
    extends $Notifier<DriverRideScreenUiState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  DriverRideScreenUiState build(String rideId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<DriverRideScreenUiState, DriverRideScreenUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverRideScreenUiState, DriverRideScreenUiState>,
              DriverRideScreenUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
