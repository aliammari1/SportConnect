// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_view_ride_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RiderViewRideUiViewModel)
final riderViewRideUiViewModelProvider = RiderViewRideUiViewModelFamily._();

final class RiderViewRideUiViewModelProvider
    extends $NotifierProvider<RiderViewRideUiViewModel, RiderViewRideUiState> {
  RiderViewRideUiViewModelProvider._({
    required RiderViewRideUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderViewRideUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderViewRideUiViewModelHash();

  @override
  String toString() {
    return r'riderViewRideUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RiderViewRideUiViewModel create() => RiderViewRideUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RiderViewRideUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RiderViewRideUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RiderViewRideUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderViewRideUiViewModelHash() =>
    r'911475fb24a2e79462413a2c74f003acf06911ab';

final class RiderViewRideUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RiderViewRideUiViewModel,
          RiderViewRideUiState,
          RiderViewRideUiState,
          RiderViewRideUiState,
          String
        > {
  RiderViewRideUiViewModelFamily._()
    : super(
        retry: null,
        name: r'riderViewRideUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RiderViewRideUiViewModelProvider call(String arg) =>
      RiderViewRideUiViewModelProvider._(argument: arg, from: this);

  @override
  String toString() => r'riderViewRideUiViewModelProvider';
}

abstract class _$RiderViewRideUiViewModel
    extends $Notifier<RiderViewRideUiState> {
  late final _$args = ref.$arg as String;
  String get arg => _$args;

  RiderViewRideUiState build(String arg);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RiderViewRideUiState, RiderViewRideUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RiderViewRideUiState, RiderViewRideUiState>,
              RiderViewRideUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
