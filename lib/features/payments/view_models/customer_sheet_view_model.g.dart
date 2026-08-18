// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_sheet_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerSheetViewModel)
final customerSheetViewModelProvider = CustomerSheetViewModelProvider._();

final class CustomerSheetViewModelProvider
    extends $NotifierProvider<CustomerSheetViewModel, CustomerSheetState> {
  CustomerSheetViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerSheetViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerSheetViewModelHash();

  @$internal
  @override
  CustomerSheetViewModel create() => CustomerSheetViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerSheetState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerSheetState>(value),
    );
  }
}

String _$customerSheetViewModelHash() =>
    r'a26631286a32305b63931dc5e3f8220dc504ee0f';

abstract class _$CustomerSheetViewModel extends $Notifier<CustomerSheetState> {
  CustomerSheetState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CustomerSheetState, CustomerSheetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CustomerSheetState, CustomerSheetState>,
              CustomerSheetState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
