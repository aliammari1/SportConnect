// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LegalScreenUiViewModel)
final legalScreenUiViewModelProvider = LegalScreenUiViewModelFamily._();

final class LegalScreenUiViewModelProvider
    extends $NotifierProvider<LegalScreenUiViewModel, LegalScreenUiState> {
  LegalScreenUiViewModelProvider._({
    required LegalScreenUiViewModelFamily super.from,
    required LegalDocumentType super.argument,
  }) : super(
         retry: null,
         name: r'legalScreenUiViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$legalScreenUiViewModelHash();

  @override
  String toString() {
    return r'legalScreenUiViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LegalScreenUiViewModel create() => LegalScreenUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LegalScreenUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LegalScreenUiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LegalScreenUiViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$legalScreenUiViewModelHash() =>
    r'1768a3fc481ad2a955e7cf54fd8ea4744c5c0a3b';

final class LegalScreenUiViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          LegalScreenUiViewModel,
          LegalScreenUiState,
          LegalScreenUiState,
          LegalScreenUiState,
          LegalDocumentType
        > {
  LegalScreenUiViewModelFamily._()
    : super(
        retry: null,
        name: r'legalScreenUiViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LegalScreenUiViewModelProvider call(LegalDocumentType arg) =>
      LegalScreenUiViewModelProvider._(argument: arg, from: this);

  @override
  String toString() => r'legalScreenUiViewModelProvider';
}

abstract class _$LegalScreenUiViewModel extends $Notifier<LegalScreenUiState> {
  late final _$args = ref.$arg as LegalDocumentType;
  LegalDocumentType get arg => _$args;

  LegalScreenUiState build(LegalDocumentType arg);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LegalScreenUiState, LegalScreenUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LegalScreenUiState, LegalScreenUiState>,
              LegalScreenUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
