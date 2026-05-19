// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for RiderHomeScreen with all business logic

@ProviderFor(RiderHomeViewModel)
final riderHomeViewModelProvider = RiderHomeViewModelProvider._();

/// ViewModel for RiderHomeScreen with all business logic
final class RiderHomeViewModelProvider
    extends $NotifierProvider<RiderHomeViewModel, RiderHomeState> {
  /// ViewModel for RiderHomeScreen with all business logic
  RiderHomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riderHomeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riderHomeViewModelHash();

  @$internal
  @override
  RiderHomeViewModel create() => RiderHomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RiderHomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RiderHomeState>(value),
    );
  }
}

String _$riderHomeViewModelHash() =>
    r'5d701b62ee11205eebf89a40456e07790243f71b';

/// ViewModel for RiderHomeScreen with all business logic

abstract class _$RiderHomeViewModel extends $Notifier<RiderHomeState> {
  RiderHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RiderHomeState, RiderHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RiderHomeState, RiderHomeState>,
              RiderHomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
