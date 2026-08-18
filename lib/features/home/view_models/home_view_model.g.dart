// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for the home screen.
///
/// Exposes the current authenticated user for the home surfaces. Map,
/// location and routing concerns are owned by `RiderHomeViewModel`.

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

/// ViewModel for the home screen.
///
/// Exposes the current authenticated user for the home surfaces. Map,
/// location and routing concerns are owned by `RiderHomeViewModel`.
final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeState> {
  /// ViewModel for the home screen.
  ///
  /// Exposes the current authenticated user for the home surfaces. Map,
  /// location and routing concerns are owned by `RiderHomeViewModel`.
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeViewModelHash() => r'008072fef03e59d1d1ef4e815743923ee4b3aa4d';

/// ViewModel for the home screen.
///
/// Exposes the current authenticated user for the home surfaces. Map,
/// location and routing concerns are owned by `RiderHomeViewModel`.

abstract class _$HomeViewModel extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// VM-layer stream provider for nearby rides (wraps home repository).

@ProviderFor(nearbyRidesStream)
final nearbyRidesStreamProvider = NearbyRidesStreamFamily._();

/// VM-layer stream provider for nearby rides (wraps home repository).

final class NearbyRidesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// VM-layer stream provider for nearby rides (wraps home repository).
  NearbyRidesStreamProvider._({
    required NearbyRidesStreamFamily super.from,
    required (LatLng, double) super.argument,
  }) : super(
         retry: null,
         name: r'nearbyRidesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyRidesStreamHash();

  @override
  String toString() {
    return r'nearbyRidesStreamProvider'
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
    final argument = this.argument as (LatLng, double);
    return nearbyRidesStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyRidesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyRidesStreamHash() => r'fb1810db342e59fa54c98cffc6ebf28e4fdd6644';

/// VM-layer stream provider for nearby rides (wraps home repository).

final class NearbyRidesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, (LatLng, double)> {
  NearbyRidesStreamFamily._()
    : super(
        retry: null,
        name: r'nearbyRidesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// VM-layer stream provider for nearby rides (wraps home repository).

  NearbyRidesStreamProvider call(LatLng location, double radiusKm) =>
      NearbyRidesStreamProvider._(argument: (location, radiusKm), from: this);

  @override
  String toString() => r'nearbyRidesStreamProvider';
}
