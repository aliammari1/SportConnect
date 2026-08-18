// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_rate_passenger_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverPassengerRatingViewModel)
final driverPassengerRatingViewModelProvider =
    DriverPassengerRatingViewModelFamily._();

final class DriverPassengerRatingViewModelProvider
    extends
        $NotifierProvider<
          DriverPassengerRatingViewModel,
          DriverPassengerRatingState
        > {
  DriverPassengerRatingViewModelProvider._({
    required DriverPassengerRatingViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverPassengerRatingViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverPassengerRatingViewModelHash();

  @override
  String toString() {
    return r'driverPassengerRatingViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DriverPassengerRatingViewModel create() => DriverPassengerRatingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverPassengerRatingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverPassengerRatingState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DriverPassengerRatingViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverPassengerRatingViewModelHash() =>
    r'd9ddc944a79cba6256fed54d40676cb11619efd1';

final class DriverPassengerRatingViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DriverPassengerRatingViewModel,
          DriverPassengerRatingState,
          DriverPassengerRatingState,
          DriverPassengerRatingState,
          String
        > {
  DriverPassengerRatingViewModelFamily._()
    : super(
        retry: null,
        name: r'driverPassengerRatingViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DriverPassengerRatingViewModelProvider call(String rideId) =>
      DriverPassengerRatingViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'driverPassengerRatingViewModelProvider';
}

abstract class _$DriverPassengerRatingViewModel
    extends $Notifier<DriverPassengerRatingState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  DriverPassengerRatingState build(String rideId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<DriverPassengerRatingState, DriverPassengerRatingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                DriverPassengerRatingState,
                DriverPassengerRatingState
              >,
              DriverPassengerRatingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
