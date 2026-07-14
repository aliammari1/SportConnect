// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_booking_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingBookingViewModel)
final pendingBookingViewModelProvider = PendingBookingViewModelFamily._();

final class PendingBookingViewModelProvider
    extends $NotifierProvider<PendingBookingViewModel, PendingBookingState> {
  PendingBookingViewModelProvider._({
    required PendingBookingViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pendingBookingViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingBookingViewModelHash();

  @override
  String toString() {
    return r'pendingBookingViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PendingBookingViewModel create() => PendingBookingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingBookingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingBookingState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PendingBookingViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingBookingViewModelHash() =>
    r'aeb30fff8b355ff6fab8d0ebc40df0f6f9b2f0ed';

final class PendingBookingViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          PendingBookingViewModel,
          PendingBookingState,
          PendingBookingState,
          PendingBookingState,
          String
        > {
  PendingBookingViewModelFamily._()
    : super(
        retry: null,
        name: r'pendingBookingViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PendingBookingViewModelProvider call(String rideId) =>
      PendingBookingViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'pendingBookingViewModelProvider';
}

abstract class _$PendingBookingViewModel
    extends $Notifier<PendingBookingState> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  PendingBookingState build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PendingBookingState, PendingBookingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PendingBookingState, PendingBookingState>,
              PendingBookingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
