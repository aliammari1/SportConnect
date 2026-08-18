// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_center_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HelpCenterUiViewModel)
final helpCenterUiViewModelProvider = HelpCenterUiViewModelProvider._();

final class HelpCenterUiViewModelProvider
    extends $NotifierProvider<HelpCenterUiViewModel, HelpCenterUiState> {
  HelpCenterUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'helpCenterUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$helpCenterUiViewModelHash();

  @$internal
  @override
  HelpCenterUiViewModel create() => HelpCenterUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HelpCenterUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HelpCenterUiState>(value),
    );
  }
}

String _$helpCenterUiViewModelHash() =>
    r'c03be697384bb2c160b6414f347ab8d1e762a5a1';

abstract class _$HelpCenterUiViewModel extends $Notifier<HelpCenterUiState> {
  HelpCenterUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HelpCenterUiState, HelpCenterUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HelpCenterUiState, HelpCenterUiState>,
              HelpCenterUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
