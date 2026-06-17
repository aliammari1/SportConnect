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

String _$rideServiceHash() => r'06e3440f59c8189a36328b5c50c7ca594cde5f69';

/// Ride service - handles ride business logic

abstract class _$RideService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
