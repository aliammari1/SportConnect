// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_entitlement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(premiumEntitlementRepository)
final premiumEntitlementRepositoryProvider =
    PremiumEntitlementRepositoryProvider._();

final class PremiumEntitlementRepositoryProvider
    extends
        $FunctionalProvider<
          PremiumEntitlementRepository,
          PremiumEntitlementRepository,
          PremiumEntitlementRepository
        >
    with $Provider<PremiumEntitlementRepository> {
  PremiumEntitlementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumEntitlementRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumEntitlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<PremiumEntitlementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PremiumEntitlementRepository create(Ref ref) {
    return premiumEntitlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PremiumEntitlementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PremiumEntitlementRepository>(value),
    );
  }
}

String _$premiumEntitlementRepositoryHash() =>
    r'a2fb910e260bca68582a38741242950350407df2';
