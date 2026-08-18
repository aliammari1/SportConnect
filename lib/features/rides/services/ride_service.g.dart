// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ride service - handles ride business logic

@ProviderFor(RideService)
final rideServiceProvider = RideServiceProvider._();

/// Ride service - handles ride business logic
final class RideServiceProvider
    extends $AsyncNotifierProvider<RideService, void> {
  /// Ride service - handles ride business logic
  RideServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideServiceHash();

  @$internal
  @override
  RideService create() => RideService();
}

String _$rideServiceHash() => r'8f4fe93376e13e41c7c1e6945af5109b16bd4018';

/// Ride service - handles ride business logic

abstract class _$RideService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
