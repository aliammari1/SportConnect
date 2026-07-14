// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeDriverRide)
final activeDriverRideProvider = ActiveDriverRideProvider._();

final class ActiveDriverRideProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideModel?>,
          RideModel?,
          Stream<RideModel?>
        >
    with $FutureModifier<RideModel?>, $StreamProvider<RideModel?> {
  ActiveDriverRideProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDriverRideProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDriverRideHash();

  @$internal
  @override
  $StreamProviderElement<RideModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<RideModel?> create(Ref ref) {
    return activeDriverRide(ref);
  }
}

String _$activeDriverRideHash() => r'27e74b0e2d3d541b3e15b44119f211a0226cace2';

@ProviderFor(pastDriverRides)
final pastDriverRidesProvider = PastDriverRidesProvider._();

final class PastDriverRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  PastDriverRidesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastDriverRidesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastDriverRidesHash();

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    return pastDriverRides(ref);
  }
}

String _$pastDriverRidesHash() => r'e5842eba14106f7e0fc07050657b3d678e64e8e6';

/// ViewModel for all driver dashboard screens.

@ProviderFor(DriverViewModel)
final driverViewModelProvider = DriverViewModelProvider._();

/// ViewModel for all driver dashboard screens.
final class DriverViewModelProvider
    extends $NotifierProvider<DriverViewModel, DriverState> {
  /// ViewModel for all driver dashboard screens.
  DriverViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverViewModelHash();

  @$internal
  @override
  DriverViewModel create() => DriverViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverState>(value),
    );
  }
}

String _$driverViewModelHash() => r'a1a4438118bbe45ddc2ad4a4a072d79743865483';

/// ViewModel for all driver dashboard screens.

abstract class _$DriverViewModel extends $Notifier<DriverState> {
  DriverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DriverState, DriverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverState, DriverState>,
              DriverState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
