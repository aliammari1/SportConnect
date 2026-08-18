// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_iap_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PremiumIapService)
final premiumIapServiceProvider = PremiumIapServiceProvider._();

final class PremiumIapServiceProvider
    extends $NotifierProvider<PremiumIapService, void> {
  PremiumIapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumIapServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumIapServiceHash();

  @$internal
  @override
  PremiumIapService create() => PremiumIapService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$premiumIapServiceHash() => r'ed3f8d69adba42ced93220f515c88f02aa7e8438';

abstract class _$PremiumIapService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
