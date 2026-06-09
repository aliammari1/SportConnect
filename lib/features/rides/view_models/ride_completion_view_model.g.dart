// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_completion_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RideCompletionUiViewModel)
final rideCompletionUiViewModelProvider = RideCompletionUiViewModelFamily._();

final class RideCompletionUiViewModelProvider
    extends
        $NotifierProvider<RideCompletionUiViewModel, RideCompletionUiState> {
  RideCompletionUiViewModelProvider._({
    required RideCompletionUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideCompletionUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideCompletionUiViewModelHash();

  @override
  String toString() {
    return r'rideCompletionUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RideCompletionUiViewModel create() => RideCompletionUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideCompletionUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideCompletionUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RideCompletionUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideCompletionUiViewModelHash() =>
    r'83aecac1c80070de04874200b166a435752c09f4';

final class RideCompletionUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RideCompletionUiViewModel,
          RideCompletionUiState,
          RideCompletionUiState,
          RideCompletionUiState,
          String
        > {
  RideCompletionUiViewModelFamily._()
    : super(
        retry: null,
        name: r'rideCompletionUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RideCompletionUiViewModelProvider call(String rideId) =>
      RideCompletionUiViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideCompletionUiViewModelProvider';
}

abstract class _$RideCompletionUiViewModel
    extends $Notifier<RideCompletionUiState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  RideCompletionUiState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideCompletionUiState, RideCompletionUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideCompletionUiState, RideCompletionUiState>,
              RideCompletionUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
