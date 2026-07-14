// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_countdown_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RideCountdownUiViewModel)
final rideCountdownUiViewModelProvider = RideCountdownUiViewModelFamily._();

final class RideCountdownUiViewModelProvider
    extends $NotifierProvider<RideCountdownUiViewModel, RideCountdownUiState> {
  RideCountdownUiViewModelProvider._({
    required RideCountdownUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideCountdownUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideCountdownUiViewModelHash();

  @override
  String toString() {
    return r'rideCountdownUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RideCountdownUiViewModel create() => RideCountdownUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideCountdownUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideCountdownUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RideCountdownUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideCountdownUiViewModelHash() =>
    r'46d50efbb36318286bc4258f8ab00199e9279e5a';

final class RideCountdownUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RideCountdownUiViewModel,
          RideCountdownUiState,
          RideCountdownUiState,
          RideCountdownUiState,
          String
        > {
  RideCountdownUiViewModelFamily._()
    : super(
        retry: null,
        name: r'rideCountdownUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RideCountdownUiViewModelProvider call(String bookingId) =>
      RideCountdownUiViewModelProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'rideCountdownUiViewModelProvider';
}

abstract class _$RideCountdownUiViewModel
    extends $Notifier<RideCountdownUiState> {
  late final _$args = ref.$arg as String;
  String get bookingId => _$args;

  RideCountdownUiState build(String bookingId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideCountdownUiState, RideCountdownUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideCountdownUiState, RideCountdownUiState>,
              RideCountdownUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
