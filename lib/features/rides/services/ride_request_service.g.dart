// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Booking action service — handles driver accept/reject of pending bookings.
///
/// Replaces the old RideRequestService which maintained a separate
/// `rideRequests` Firestore collection in parallel with `bookings`.
/// Now there is only one source of truth: the `bookings` collection.

@ProviderFor(RideRequestService)
final rideRequestServiceProvider = RideRequestServiceProvider._();

/// Booking action service — handles driver accept/reject of pending bookings.
///
/// Replaces the old RideRequestService which maintained a separate
/// `rideRequests` Firestore collection in parallel with `bookings`.
/// Now there is only one source of truth: the `bookings` collection.
final class RideRequestServiceProvider
    extends $AsyncNotifierProvider<RideRequestService, void> {
  /// Booking action service — handles driver accept/reject of pending bookings.
  ///
  /// Replaces the old RideRequestService which maintained a separate
  /// `rideRequests` Firestore collection in parallel with `bookings`.
  /// Now there is only one source of truth: the `bookings` collection.
  RideRequestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRequestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRequestServiceHash();

  @$internal
  @override
  RideRequestService create() => RideRequestService();
}

String _$rideRequestServiceHash() =>
    r'e19cb0913ee64bb55ed0256b04d310dc593a43e6';

/// Booking action service — handles driver accept/reject of pending bookings.
///
/// Replaces the old RideRequestService which maintained a separate
/// `rideRequests` Firestore collection in parallel with `bookings`.
/// Now there is only one source of truth: the `bookings` collection.

abstract class _$RideRequestService extends $AsyncNotifier<void> {
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
