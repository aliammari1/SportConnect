// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_selection_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoleSelectionViewModel)
final roleSelectionViewModelProvider = RoleSelectionViewModelProvider._();

final class RoleSelectionViewModelProvider
    extends $NotifierProvider<RoleSelectionViewModel, RoleSelectionState> {
  RoleSelectionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roleSelectionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roleSelectionViewModelHash();

  @$internal
  @override
  RoleSelectionViewModel create() => RoleSelectionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoleSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoleSelectionState>(value),
    );
  }
}

String _$roleSelectionViewModelHash() =>
    r'f15ac5e08b360cc46076bd8533bb6c8863697a93';

abstract class _$RoleSelectionViewModel extends $Notifier<RoleSelectionState> {
  RoleSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RoleSelectionState, RoleSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoleSelectionState, RoleSelectionState>,
              RoleSelectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
