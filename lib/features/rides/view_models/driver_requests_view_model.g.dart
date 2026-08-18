// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_requests_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeclineReasonSheetViewModel)
final declineReasonSheetViewModelProvider =
    DeclineReasonSheetViewModelFamily._();

final class DeclineReasonSheetViewModelProvider
    extends
        $NotifierProvider<
          DeclineReasonSheetViewModel,
          DeclineReasonSheetState
        > {
  DeclineReasonSheetViewModelProvider._({
    required DeclineReasonSheetViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'declineReasonSheetViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$declineReasonSheetViewModelHash();

  @override
  String toString() {
    return r'declineReasonSheetViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeclineReasonSheetViewModel create() => DeclineReasonSheetViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeclineReasonSheetState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeclineReasonSheetState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeclineReasonSheetViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$declineReasonSheetViewModelHash() =>
    r'd827a61ae0be699c81c15828e55a8a64ca0a32bc';

final class DeclineReasonSheetViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DeclineReasonSheetViewModel,
          DeclineReasonSheetState,
          DeclineReasonSheetState,
          DeclineReasonSheetState,
          String
        > {
  DeclineReasonSheetViewModelFamily._()
    : super(
        retry: null,
        name: r'declineReasonSheetViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeclineReasonSheetViewModelProvider call(String arg) =>
      DeclineReasonSheetViewModelProvider._(argument: arg, from: this);

  @override
  String toString() => r'declineReasonSheetViewModelProvider';
}

abstract class _$DeclineReasonSheetViewModel
    extends $Notifier<DeclineReasonSheetState> {
  late final _$args = ref.$arg as String;
  String get arg => _$args;

  DeclineReasonSheetState build(String arg);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<DeclineReasonSheetState, DeclineReasonSheetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DeclineReasonSheetState, DeclineReasonSheetState>,
              DeclineReasonSheetState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
