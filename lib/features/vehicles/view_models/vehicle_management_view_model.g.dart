// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_management_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddVehicleSheetUiViewModel)
final addVehicleSheetUiViewModelProvider = AddVehicleSheetUiViewModelFamily._();

final class AddVehicleSheetUiViewModelProvider
    extends
        $NotifierProvider<AddVehicleSheetUiViewModel, AddVehicleSheetUiState> {
  AddVehicleSheetUiViewModelProvider._({
    required AddVehicleSheetUiViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addVehicleSheetUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addVehicleSheetUiViewModelHash();

  @override
  String toString() {
    return r'addVehicleSheetUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddVehicleSheetUiViewModel create() => AddVehicleSheetUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddVehicleSheetUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddVehicleSheetUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddVehicleSheetUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addVehicleSheetUiViewModelHash() =>
    r'ee172022ffe86d0ff36128a007cc3114cbcdc193';

final class AddVehicleSheetUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          AddVehicleSheetUiViewModel,
          AddVehicleSheetUiState,
          AddVehicleSheetUiState,
          AddVehicleSheetUiState,
          String
        > {
  AddVehicleSheetUiViewModelFamily._()
    : super(
        retry: null,
        name: r'addVehicleSheetUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddVehicleSheetUiViewModelProvider call(String arg) =>
      AddVehicleSheetUiViewModelProvider._(argument: arg, from: this);

  @override
  String toString() => r'addVehicleSheetUiViewModelProvider';
}

abstract class _$AddVehicleSheetUiViewModel
    extends $Notifier<AddVehicleSheetUiState> {
  late final _$args = ref.$arg as String;
  String get arg => _$args;

  AddVehicleSheetUiState build(String arg);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AddVehicleSheetUiState, AddVehicleSheetUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddVehicleSheetUiState, AddVehicleSheetUiState>,
              AddVehicleSheetUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
