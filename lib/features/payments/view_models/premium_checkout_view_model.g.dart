// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_checkout_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PremiumCheckoutViewModel)
final premiumCheckoutViewModelProvider = PremiumCheckoutViewModelProvider._();

final class PremiumCheckoutViewModelProvider
    extends $NotifierProvider<PremiumCheckoutViewModel, PremiumCheckoutState> {
  PremiumCheckoutViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumCheckoutViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumCheckoutViewModelHash();

  @$internal
  @override
  PremiumCheckoutViewModel create() => PremiumCheckoutViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PremiumCheckoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PremiumCheckoutState>(value),
    );
  }
}

String _$premiumCheckoutViewModelHash() =>
    r'aae04eb43f663b846ccb9ba5d54d8fc9a4890673';

abstract class _$PremiumCheckoutViewModel
    extends $Notifier<PremiumCheckoutState> {
  PremiumCheckoutState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PremiumCheckoutState, PremiumCheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PremiumCheckoutState, PremiumCheckoutState>,
              PremiumCheckoutState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
